// Early SRS experiments skip exhaustive docs/types to keep iteration fast.
// ignore_for_file: public_member_api_docs, omit_local_variable_types

import 'dart:math';

import 'package:collection/collection.dart';

import 'package:palabra/data_core/models/user_meta.dart';
import 'package:palabra/data_core/models/level_progress.dart';
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
    Random? random,
  }) : _vocabularyFetcher = vocabularyFetcher,
       _progressFetcher = progressFetcher,
       _userMetaRepository = userMetaRepository,
       _config = config,
       _random = random ?? Random();

  final DeckVocabularyFetcher _vocabularyFetcher;
  final DeckProgressFetcher _progressFetcher;
  final UserMetaRepository _userMetaRepository;
  final DeckBuilderConfig _config;
  final Random _random;

  /// Builds a deck using the given configuration and user state.
  Future<DeckBuildResult> buildDeck() async {
    final meta = await _userMetaRepository.getOrCreate();
    final activeLevel = meta.activeLevel;
    final requireSingleLevel =
        !(meta.levelProgress[activeLevel]?.isCompleted ?? false);

    if (requireSingleLevel) {
      final result = await _buildSingleLevelDeck(meta, activeLevel);
      await _userMetaRepository.save(meta);
      return result;
    }

    final mix = requireSingleLevel
        ? <String, double>{activeLevel: 1.0}
        : (_config.levelMix[activeLevel] ??
              _config.levelMix.entries
                  .firstWhereOrNull(
                    (entry) => entry.value.containsKey(activeLevel),
                  )
                  ?.value ??
              _config.levelMix['a1']!);
    final targetCounts = _allocateCounts(_config.deckSize, mix);

    final deck = <_DeckEntry>[];
    final usedFamilies = <String>{};
    var freshCount = 0;
    var troubleCount = 0;
    final freshLimit = (_config.deckSize * _config.freshCap).floor();
    var progressUpdated = false;

    for (final entry in targetCounts.entries) {
      final level = entry.key;
      final target = entry.value;
      if (target <= 0) {
        continue;
      }

      final vocab = await _vocabularyFetcher(level);
      final states = await _progressFetcher(vocab.map((item) => item.itemId));
      final progress = meta.levelProgress[level] ?? LevelProgress();
      if (progress.totalMatches != vocab.length) {
        progress.totalMatches = vocab.length;
        progressUpdated = true;
      }
      meta.levelProgress[level] = progress;

      final entries = vocab
          .map(
            (item) => _DeckEntry(
              item: item,
              state: states[item.itemId],
              prioritySeed: _random.nextDouble(),
            ),
          )
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

    deck.shuffle(_random);
    if (progressUpdated) {
      await _userMetaRepository.save(meta);
    }
    return DeckBuildResult(
      items: deck.map((entry) => entry.item).toList(),
      freshCount: freshCount,
      troubleCount: troubleCount,
    );
  }

  Future<DeckBuildResult> _buildSingleLevelDeck(
    UserMeta meta,
    String level,
  ) async {
    final vocab = await _vocabularyFetcher(level);
    final states = await _progressFetcher(vocab.map((item) => item.itemId));
    final progress = meta.levelProgress[level] ?? LevelProgress();
      if (progress.totalMatches != vocab.length) {
        progress.totalMatches = vocab.length;
      }
    meta.levelProgress[level] = progress;

    final entries = vocab
        .map(
          (item) => _DeckEntry(
            item: item,
            state: states[item.itemId],
            prioritySeed: _random.nextDouble(),
          ),
        )
        .toList();

    final deck = <_DeckEntry>[];
    final selection = _selectForLevel(
      entries: entries,
      target: entries.length,
      deck: deck,
      usedFamilies: <String>{},
      freshLimit: entries.length,
      freshCount: 0,
      troubleCount: 0,
    );
    deck.shuffle(_random);

    return DeckBuildResult(
      items: deck.map((entry) => entry.item).toList(),
      freshCount: selection.freshCount,
      troubleCount: selection.troubleCount,
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
    final selectedIds = deck.map((entry) => entry.item.itemId).toSet();
    final available = entries.where((entry) => !entry.isLearned).toList();
    final learned = entries.where((entry) => entry.isLearned).toList();
    final trouble = _prioritizePool(
      available.where((entry) => entry.isTrouble).toList(),
    );
    final fresh = _prioritizePool(
      available.where((entry) => entry.isFresh).toList(),
    );
    final review = _prioritizePool(
      available.where((entry) => !entry.isTrouble && !entry.isFresh).toList(),
    );
    final learnedPool = _prioritizePool(learned.toList());
    final fallbackAvailable = _prioritizePool(available.toList());

    int added = 0;
    bool tryAdd(
      _DeckEntry entry, {
      bool allowDuplicateFamily = false,
      bool ignoreFreshLimit = false,
    }) {
      if (selectedIds.contains(entry.item.itemId)) {
        return false;
      }
      final familyKey = entry.familyKey;
      if (!allowDuplicateFamily && usedFamilies.contains(familyKey)) {
        return false;
      }
      if (entry.isFresh && !ignoreFreshLimit && addedFresh >= freshLimit) {
        return false;
      }
      usedFamilies.add(familyKey);
      selectedIds.add(entry.item.itemId);
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
      for (final entry in learnedPool) {
        if (added >= target) {
          break;
        }
        tryAdd(entry);
      }
    }

    if (added < target) {
      for (final entry in fallbackAvailable) {
        if (added >= target) {
          break;
        }
        tryAdd(entry, allowDuplicateFamily: true);
      }
    }

    if (added < target) {
      for (final entry in learnedPool) {
        if (added >= target) {
          break;
        }
        tryAdd(entry, allowDuplicateFamily: true);
      }
    }

    if (added < target) {
      for (final entry in fresh) {
        if (added >= target) {
          break;
        }
        tryAdd(
          entry,
          allowDuplicateFamily: true,
          ignoreFreshLimit: true,
        );
      }
    }

    if (added < target) {
      for (final entry in fallbackAvailable) {
        if (added >= target) {
          break;
        }
        tryAdd(
          entry,
          allowDuplicateFamily: true,
          ignoreFreshLimit: true,
        );
      }
    }

    return _SelectionResult(freshCount: addedFresh, troubleCount: addedTrouble);
  }

  List<_DeckEntry> _prioritizePool(List<_DeckEntry> pool) {
    if (pool.isEmpty) {
      return pool;
    }
    pool.shuffle(_random);
    pool.sort(_experienceComparator);
    return pool;
  }

  int _experienceComparator(_DeckEntry a, _DeckEntry b) {
    final seenA = a.state?.seenCount ?? 0;
    final seenB = b.state?.seenCount ?? 0;
    if (seenA != seenB) {
      return seenA.compareTo(seenB);
    }
    final lastSeenA =
        a.state?.lastSeenAt ?? DateTime.fromMillisecondsSinceEpoch(0);
    final lastSeenB =
        b.state?.lastSeenAt ?? DateTime.fromMillisecondsSinceEpoch(0);
    final lastSeenComparison = lastSeenA.compareTo(lastSeenB);
    if (lastSeenComparison != 0) {
      return lastSeenComparison;
    }
    if (a.prioritySeed != b.prioritySeed) {
      return a.prioritySeed.compareTo(b.prioritySeed);
    }
    return a.item.itemId.compareTo(b.item.itemId);
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
  _DeckEntry({
    required this.item,
    required this.state,
    required this.prioritySeed,
  });

  final VocabItem item;
  final UserItemState? state;
  final double prioritySeed;

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
