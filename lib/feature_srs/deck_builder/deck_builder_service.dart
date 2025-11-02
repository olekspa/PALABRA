// ignore_for_file: public_member_api_docs, omit_local_variable_types

import 'dart:math';

import 'package:collection/collection.dart';

import 'package:palabra/data_core/models/user_item_state.dart';
import 'package:palabra/data_core/models/vocab_item.dart';
import 'package:palabra/data_core/repositories/user_meta_repository.dart';

/// Retrieves vocabulary entries for a requested level.
typedef DeckVocabularyFetcher = Future<List<VocabItem>> Function(String level);

/// Retrieves user progress state for the provided vocabulary identifiers.
typedef DeckProgressFetcher =
    Future<Map<String, UserItemState>> Function(Iterable<String> itemIds);

/// Result produced after building a deck.
class DeckBuildResult {
  DeckBuildResult({
    required this.items,
    required this.freshCount,
    required this.troubleCount,
  });

  final List<VocabItem> items;
  final int freshCount;
  final int troubleCount;
}

/// Configuration options applied during deck building.
class DeckBuilderConfig {
  const DeckBuilderConfig({
    this.deckSize = 120,
    this.freshCap = 0.2,
    this.levelMix = const {
      'a1': {'a1': 0.7, 'a2': 0.3},
      'a2': {'a1': 0.4, 'a2': 0.4, 'b1': 0.2},
      'b1': {'a1': 0.2, 'a2': 0.4, 'b1': 0.3, 'b2': 0.1},
      'b2': {'a1': 0.1, 'a2': 0.2, 'b1': 0.4, 'b2': 0.3},
    },
  });

  /// Total number of entries to return.
  final int deckSize;

  /// Maximum ratio of fresh items allowed.
  final double freshCap;

  /// Target level mix per user CEFR preference.
  final Map<String, Map<String, double>> levelMix;
}

/// Builds a deck of vocabulary items according to SRS rules.
class DeckBuilderService {
  DeckBuilderService({
    required DeckVocabularyFetcher vocabularyFetcher,
    required DeckProgressFetcher progressFetcher,
    required UserMetaRepository userMetaRepository,
    DeckBuilderConfig config = const DeckBuilderConfig(),
  }) : _vocabularyFetcher = vocabularyFetcher,
       _progressFetcher = progressFetcher,
       _userMetaRepository = userMetaRepository,
       _config = config;

  final DeckVocabularyFetcher _vocabularyFetcher;
  final DeckProgressFetcher _progressFetcher;
  final UserMetaRepository _userMetaRepository;
  final DeckBuilderConfig _config;

  /// Builds a deck using the given configuration and user state.
  Future<DeckBuildResult> buildDeck() async {
    final meta = await _userMetaRepository.getOrCreate();
    final userLevel = meta.level;
    final mix =
        _config.levelMix[userLevel] ??
        _config.levelMix.entries
            .firstWhereOrNull((entry) => entry.value.containsKey(userLevel))
            ?.value ??
        _config.levelMix['a1']!;
    final targetCounts = _allocateCounts(_config.deckSize, mix);

    final deck = <_DeckEntry>[];
    final usedFamilies = <String>{};
    var freshCount = 0;
    var troubleCount = 0;
    final freshLimit = (_config.deckSize * _config.freshCap).floor();

    for (final entry in targetCounts.entries) {
      final level = entry.key;
      final target = entry.value;
      if (target <= 0) {
        continue;
      }

      final vocab = await _vocabularyFetcher(level);
      final states = await _progressFetcher(vocab.map((item) => item.itemId));
      final entries = vocab
          .map((item) => _DeckEntry(item: item, state: states[item.itemId]))
          .toList();

      final added = _selectForLevel(
        entries: entries,
        target: target,
        deck: deck,
        usedFamilies: usedFamilies,
        freshLimit: freshLimit,
        freshCount: freshCount,
        troubleCount: troubleCount,
      );
      freshCount = added.freshCount;
      troubleCount = added.troubleCount;
    }

    return DeckBuildResult(
      items: deck.map((entry) => entry.item).toList(),
      freshCount: freshCount,
      troubleCount: troubleCount,
    );
  }

  _SelectionResult _selectForLevel({
    required List<_DeckEntry> entries,
    required int target,
    required List<_DeckEntry> deck,
    required Set<String> usedFamilies,
    required int freshLimit,
    required int freshCount,
    required int troubleCount,
  }) {
    var addedFresh = freshCount;
    var addedTrouble = troubleCount;
    final available = entries.where((entry) => !entry.isLearned).toList();
    final learned = entries.where((entry) => entry.isLearned).toList();
    final trouble = available.where((entry) => entry.isTrouble).toList();
    final fresh = available.where((entry) => entry.isFresh).toList();
    final review = available
        .where((entry) => !entry.isTrouble && !entry.isFresh)
        .toList();

    int added = 0;
    bool tryAdd(_DeckEntry entry, {bool allowDuplicateFamily = false}) {
      final familyKey = entry.familyKey;
      if (!allowDuplicateFamily && usedFamilies.contains(familyKey)) {
        return false;
      }
      if (entry.isFresh && addedFresh >= freshLimit) {
        return false;
      }
      usedFamilies.add(familyKey);
      deck.add(entry);
      added += 1;
      if (entry.isFresh) {
        addedFresh += 1;
      }
      if (entry.isTrouble) {
        addedTrouble += 1;
      }
      return true;
    }

    void consume(List<_DeckEntry> pool) {
      for (final entry in pool) {
        if (added >= target) {
          break;
        }
        tryAdd(entry);
      }
    }

    consume(trouble);
    consume(fresh);
    consume(review);

    if (added < target) {
      for (final entry in learned) {
        if (added >= target) {
          break;
        }
        tryAdd(entry);
      }
    }

    if (added < target) {
      for (final entry in available) {
        if (added >= target) {
          break;
        }
        tryAdd(entry, allowDuplicateFamily: true);
      }
    }

    if (added < target) {
      for (final entry in learned) {
        if (added >= target) {
          break;
        }
        tryAdd(entry, allowDuplicateFamily: true);
      }
    }

    return _SelectionResult(freshCount: addedFresh, troubleCount: addedTrouble);
  }

  Map<String, int> _allocateCounts(int total, Map<String, double> mix) {
    final ratios = mix.entries.toList();
    final raw = ratios
        .map((entry) => MapEntry(entry.key, total * entry.value))
        .toList();

    final counts = <String, int>{};
    var allocated = 0;
    final remainders = <String, double>{};
    for (final entry in raw) {
      final whole = entry.value.floor();
      counts[entry.key] = whole;
      allocated += whole;
      remainders[entry.key] = entry.value - whole;
    }

    var remaining = max(0, total - allocated);
    final sortedRemainders = remainders.entries.sorted(
      (a, b) => b.value.compareTo(a.value),
    );
    for (final entry in sortedRemainders) {
      if (remaining == 0) {
        break;
      }
      counts[entry.key] = (counts[entry.key] ?? 0) + 1;
      remaining -= 1;
    }

    return counts;
  }
}

class _DeckEntry {
  _DeckEntry({required this.item, required this.state});

  final VocabItem item;
  final UserItemState? state;

  String get familyKey {
    final family = item.family;
    if (family != null && family.isNotEmpty) {
      return family;
    }
    return item.itemId;
  }

  bool get isTrouble => (state?.wrongCount ?? 0) > 0;

  bool get isFresh => (state?.seenCount ?? 0) == 0;

  bool get isLearned => (state?.correctStreak ?? 0) >= 3 && !isTrouble;
}

class _SelectionResult {
  const _SelectionResult({
    required this.freshCount,
    required this.troubleCount,
  });

  final int freshCount;
  final int troubleCount;
}
