import 'package:palabra/data_core/models/level_progress.dart';
import 'package:palabra/data_core/models/number_drill_progress.dart';

/// Persistent metadata for the prototype user profile across sessions.
class UserMeta {
  /// Creates prototype metadata with default values.
  UserMeta() {
    _ensureLevelProgress();
    _ensurePowerupInventory();
  }

  static const List<String> defaultPowerupIds = <String>[
    'timeExtend',
    'rowBlaster',
    'hintGlow',
    'freezeTimer',
    'autoMatch',
    'audioEcho',
  ];

  /// Ordered list of CEFR levels supported by the app.
  static const List<String> levelOrder = <String>['a1', 'a2', 'b1', 'b2'];

  /// Remote sync version for concurrency control.
  int syncVersion = 0;

  /// Whether the vocabulary cache has been seeded for the user.
  bool hasSeededVocabulary = false;

  /// Preferred row count on the board.
  int preferredRows = 5;

  /// Current CEFR level for the user.
  String level = 'a1';

  /// Friendly display name for the profile.
  String profileName = 'Player';

  /// When the profile was created.
  DateTime createdAt = DateTime.now();

  /// When the profile was last selected.
  DateTime? lastSeenAt;

  /// Total learned item count.
  int learnedCount = 0;

  /// Total trouble item count.
  int troubleCount = 0;

  /// Timestamp of the most recent run.
  DateTime? lastRunAt;

  /// Available Row Blaster powerups.
  int rowBlasterCharges = 0;

  /// Available time-extend tokens.
  int timeExtendTokens = 0;

  /// Aggregate XP earned across all runs.
  int xp = 0;

  /// XP earned since the last powerup reward or threshold.
  int xpSinceLastReward = 0;

  /// Total number of runs completed.
  int totalRuns = 0;

  /// Aggregate correct matches across all runs.
  int totalMatches = 0;

  /// Aggregate attempt count across all runs.
  int totalAttempts = 0;

  /// Aggregate time spent in milliseconds.
  int totalTimeMs = 0;

  /// Current streak of successful runs.
  int currentStreak = 0;

  /// Best streak of successful runs.
  int bestStreak = 0;

  /// Learned promotions captured from the last run.
  int lastLearnedDelta = 0;

  /// Trouble items flagged during the last run.
  int lastTroubleDelta = 0;

  /// Per-level progression details.
  Map<String, LevelProgress> levelProgress = <String, LevelProgress>{};

  /// Additional powerup inventory keyed by powerup id.
  Map<String, int> powerupInventory = <String, int>{};

  /// Set of powerups the player has unlocked at least once.
  Set<String> unlockedPowerups = <String>{};

  /// Progress tracking for the number drill bonus game.
  NumberDrillProgress numberDrillProgress = NumberDrillProgress();

  /// Hydrates metadata from persisted JSON.
  factory UserMeta.fromJson(Map<String, dynamic> json) {
    final meta = UserMeta()
      ..hasSeededVocabulary = json['hasSeededVocabulary'] as bool? ?? false
      ..preferredRows = json['preferredRows'] as int? ?? 5
      ..level = (json['level'] as String? ?? 'a1').toLowerCase()
      ..profileName = (json['profileName'] as String? ?? 'Player').trim()
      ..createdAt = _parseTimestamp(json['createdAt']) ?? DateTime.now()
      ..lastSeenAt = _parseTimestamp(json['lastSeenAt'])
      ..learnedCount = json['learnedCount'] as int? ?? 0
      ..troubleCount = json['troubleCount'] as int? ?? 0
      ..lastRunAt = _parseTimestamp(json['lastRunAt'])
      ..rowBlasterCharges = json['rowBlasterCharges'] as int? ?? 0
      ..timeExtendTokens = json['timeExtendTokens'] as int? ?? 0
      ..xp = json['xp'] as int? ?? 0
      ..xpSinceLastReward = json['xpSinceLastReward'] as int? ?? 0
      ..totalRuns = json['totalRuns'] as int? ?? 0
      ..totalMatches = json['totalMatches'] as int? ?? 0
      ..totalAttempts = json['totalAttempts'] as int? ?? 0
      ..totalTimeMs = json['totalTimeMs'] as int? ?? 0
      ..currentStreak = json['currentStreak'] as int? ?? 0
      ..bestStreak = json['bestStreak'] as int? ?? 0
      ..lastLearnedDelta = json['lastLearnedDelta'] as int? ?? 0
      ..lastTroubleDelta = json['lastTroubleDelta'] as int? ?? 0;
    meta.syncVersion = json['syncVersion'] as int? ?? 0;

    final progressJson = json['levelProgress'];
    if (progressJson is Map<String, dynamic>) {
      meta.levelProgress = progressJson.map(
        (key, value) => MapEntry(
          key.toLowerCase(),
          LevelProgress.fromJson(
            (value as Map).cast<String, dynamic>(),
          ),
        ),
      );
    }

    final inventoryJson = json['powerupInventory'];
    if (inventoryJson is Map<String, dynamic>) {
      meta.powerupInventory = inventoryJson.map(
        (key, value) => MapEntry(key, (value as num).toInt()),
      );
    }

    final unlockedJson = json['unlockedPowerups'];
    if (unlockedJson is List) {
      meta.unlockedPowerups = unlockedJson.map((e) => e.toString()).toSet();
    }

    final numberDrillJson = json['numberDrillProgress'];
    if (numberDrillJson is Map<String, dynamic>) {
      meta.numberDrillProgress = NumberDrillProgress.fromJson(numberDrillJson);
    }

    meta._ensureLevelProgress();
    meta._ensurePowerupInventory();
    return meta;
  }

  /// Serializes metadata to a JSON-compatible map.
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'hasSeededVocabulary': hasSeededVocabulary,
      'syncVersion': syncVersion,
      'preferredRows': preferredRows,
      'level': level,
      'profileName': profileName,
      'createdAt': createdAt.toIso8601String(),
      'lastSeenAt': lastSeenAt?.toIso8601String(),
      'learnedCount': learnedCount,
      'troubleCount': troubleCount,
      'lastRunAt': lastRunAt?.toIso8601String(),
      'rowBlasterCharges': rowBlasterCharges,
      'timeExtendTokens': timeExtendTokens,
      'totalRuns': totalRuns,
      'totalMatches': totalMatches,
      'totalAttempts': totalAttempts,
      'totalTimeMs': totalTimeMs,
      'currentStreak': currentStreak,
      'bestStreak': bestStreak,
      'lastLearnedDelta': lastLearnedDelta,
      'lastTroubleDelta': lastTroubleDelta,
      'xp': xp,
      'xpSinceLastReward': xpSinceLastReward,
      'levelProgress': levelProgress.map(
        (key, value) => MapEntry(key, value.toJson()),
      ),
      'powerupInventory': powerupInventory,
      'unlockedPowerups': unlockedPowerups.toList(),
      'numberDrillProgress': numberDrillProgress.toJson(),
    };
  }

  /// Returns the first level that has not yet been completed.
  String get activeLevel {
    for (final levelId in levelOrder) {
      final progress = levelProgress[levelId];
      if (progress == null || !progress.isCompleted) {
        return levelId;
      }
    }
    return levelOrder.last;
  }

  void _ensureLevelProgress() {
    final existing = levelProgress;
    levelProgress = {
      for (final levelId in levelOrder)
        levelId: existing[levelId]?.mapCopy() ?? LevelProgress(),
    };
    level = activeLevel;
    if (profileName.trim().isEmpty) {
      profileName = 'Player';
    }
  }

  void _ensurePowerupInventory() {
    for (final id in defaultPowerupIds) {
      powerupInventory.putIfAbsent(id, () => 0);
    }
  }

  static DateTime? _parseTimestamp(Object? raw) {
    if (raw is String && raw.isNotEmpty) {
      return DateTime.tryParse(raw);
    }
    return null;
  }
}

extension on LevelProgress {
  LevelProgress mapCopy() {
    return LevelProgress(
      totalMatches: totalMatches,
      cleanRuns: cleanRuns,
      bestStreak: bestStreak,
      completedAt: completedAt,
      lastCleanRunAt: lastCleanRunAt,
      masteredItemIds: List<String>.from(masteredItemIds),
    );
  }
}
