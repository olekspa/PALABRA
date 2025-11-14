import 'dart:math';

import 'package:characters/characters.dart';
import 'package:palabra/data_core/models/user_meta.dart';
import 'package:palabra/data_core/models/vocab_item.dart';
import 'package:palabra/feature_palabra_lines/domain/palabra_lines_config.dart';
import 'package:palabra/feature_palabra_lines/domain/palabra_lines_question.dart';

/// Provides vocabulary-driven quiz questions for Palabra Lines.
class PalabraLinesVocabService {
  PalabraLinesVocabService._({
    required Map<String, List<PalabraLinesVocabEntry>> entriesByLevel,
    required List<PalabraLinesVocabEntry> allEntries,
    required String baseLevel,
    required Random random,
  })  : _entriesByLevel = entriesByLevel,
        _allEntries = allEntries,
        _baseLevel = baseLevel,
        _rng = random;

  factory PalabraLinesVocabService({
    required Map<String, List<PalabraLinesVocabEntry>> entriesByLevel,
    required String baseLevel,
    Random? random,
  }) {
    final normalized = entriesByLevel.map(
      (key, value) => MapEntry(
        key.toLowerCase(),
        List<PalabraLinesVocabEntry>.unmodifiable(value),
      ),
    );
    final flattened = List<PalabraLinesVocabEntry>.unmodifiable(
      normalized.values.expand((value) => value),
    );
    return PalabraLinesVocabService._(
      entriesByLevel: normalized,
      allEntries: flattened,
      baseLevel: baseLevel.toLowerCase(),
      random: random ?? Random(),
    );
  }

  /// Convenience constructor for wiring the shared vocab assets.
  factory PalabraLinesVocabService.fromItems({
    required Iterable<VocabItem> items,
    required String baseLevel,
    Random? random,
  }) {
    final grouped = <String, List<PalabraLinesVocabEntry>>{};
    for (final item in items) {
      final entry = _entryFromItem(item);
      if (entry == null) {
        continue;
      }
      grouped.putIfAbsent(entry.level, () => <PalabraLinesVocabEntry>[]).add(entry);
    }
    return PalabraLinesVocabService(
      entriesByLevel: grouped,
      baseLevel: baseLevel,
      random: random,
    );
  }

  final Map<String, List<PalabraLinesVocabEntry>> _entriesByLevel;
  final List<PalabraLinesVocabEntry> _allEntries;
  final Random _rng;
  String _baseLevel;

  /// Adjusts the baseline CEFR level at runtime if the profile changes.
  void updateBaseLevel(String level) {
    _baseLevel = level.toLowerCase();
  }

  /// Draws a question scaled by the number of cleared balls.
  PalabraLinesQuestionState? createQuestion(
    int clearedCount, {
    int? maxLetterCount,
  }) {
    if (_allEntries.length < PalabraLinesConfig.quizOptions) {
      return null;
    }
    final preferredTier = _tierForClearedCount(clearedCount);
    final fallbacks = <PalabraLinesDifficultyTier>[
      preferredTier,
      PalabraLinesDifficultyTier.base,
      PalabraLinesDifficultyTier.intermediate,
      PalabraLinesDifficultyTier.advanced,
    ];
    final seen = <PalabraLinesDifficultyTier>{};
    for (final tier in fallbacks) {
      if (!seen.add(tier)) {
        continue;
      }
      final pool = _poolForTier(tier)
          .where(
            (entry) =>
                maxLetterCount == null ||
                _spanishLength(entry.spanish) <= maxLetterCount,
          )
          .toList();
      if (pool.isEmpty) {
        continue;
      }
      final entry = pool[_rng.nextInt(pool.length)];
      final question = _buildQuestion(entry);
      if (question != null) {
        return question;
      }
    }
    return null;
  }

  PalabraLinesQuestionState? _buildQuestion(PalabraLinesVocabEntry entry) {
    final optionResult = _buildOptions(entry);
    if (optionResult == null) {
      return null;
    }
    return PalabraLinesQuestionState(
      entry: entry,
      options: optionResult.options,
      correctIndex: optionResult.correctIndex,
    );
  }

  _QuestionOptions? _buildOptions(PalabraLinesVocabEntry entry) {
    final requiredDistractors = PalabraLinesConfig.quizOptions - 1;
    final candidates = _allEntries
        .where((item) => item.id != entry.id)
        .map((item) => item.english.trim())
        .where((english) => english.isNotEmpty && english != entry.english)
        .toList();
    if (candidates.isEmpty) {
      return null;
    }
    candidates.shuffle(_rng);
    final distractors = <String>[];
    for (final candidate in candidates) {
      if (distractors.contains(candidate)) {
        continue;
      }
      distractors.add(candidate);
      if (distractors.length == requiredDistractors) {
        break;
      }
    }
    if (distractors.length < requiredDistractors) {
      return null;
    }
    final options = <String>[entry.english, ...distractors];
    options.shuffle(_rng);
    final correctIndex = options.indexOf(entry.english);
    if (correctIndex == -1) {
      return null;
    }
    return _QuestionOptions(options, correctIndex);
  }

  List<PalabraLinesVocabEntry> _poolForTier(PalabraLinesDifficultyTier tier) {
    final levels = _levelsForTier(tier);
    final buffer = <PalabraLinesVocabEntry>[];
    for (final level in levels) {
      final entries = _entriesByLevel[level];
      if (entries != null) {
        buffer.addAll(entries);
      }
    }
    return buffer;
  }

  List<String> _levelsForTier(PalabraLinesDifficultyTier tier) {
    final levelOrder = UserMeta.levelOrder;
    final baseIndex = _resolveBaseIndex(levelOrder);
    switch (tier) {
      case PalabraLinesDifficultyTier.base:
        return <String>[levelOrder[baseIndex]];
      case PalabraLinesDifficultyTier.intermediate:
        return <String>[levelOrder[min(baseIndex + 1, levelOrder.length - 1)]];
      case PalabraLinesDifficultyTier.advanced:
        return <String>[levelOrder.last];
    }
  }

  int _resolveBaseIndex(List<String> levelOrder) {
    final normalized = _baseLevel.toLowerCase();
    final index = levelOrder.indexOf(normalized);
    if (index >= 0) {
      return index;
    }
    return 0;
  }

  PalabraLinesDifficultyTier _tierForClearedCount(int clearedCount) {
    if (clearedCount >= PalabraLinesConfig.lineLength + 2) {
      return PalabraLinesDifficultyTier.advanced;
    }
    if (clearedCount >= PalabraLinesConfig.lineLength + 1) {
      return PalabraLinesDifficultyTier.intermediate;
    }
    return PalabraLinesDifficultyTier.base;
  }

  static PalabraLinesVocabEntry? _entryFromItem(VocabItem item) {
    final english = item.english.trim();
    final spanish = item.spanish.trim();
    if (english.isEmpty || spanish.isEmpty) {
      return null;
    }
    final id = item.itemId.trim();
    final level = item.level.trim().toLowerCase();
    if (id.isEmpty || level.isEmpty) {
      return null;
    }
    return PalabraLinesVocabEntry(
      id: id,
      spanish: spanish,
      english: english,
      level: level,
    );
  }

  int _spanishLength(String input) {
    return input.characters.length;
  }
}

class _QuestionOptions {
  _QuestionOptions(this.options, this.correctIndex);

  final List<String> options;
  final int correctIndex;
}
