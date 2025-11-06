/// Run summaries mirrored from stored JSON snapshots used in QA.
class RunLog {
  /// Creates an empty run log with default-initialized metrics.
  RunLog();

  /// Hydrates a run log from persisted JSON.
  factory RunLog.fromJson(Map<String, dynamic> json) {
    return RunLog()
      ..startedAt = _parseTimestamp(json['startedAt']) ?? DateTime.now()
      ..completedAt = _parseTimestamp(json['completedAt'])
      ..tierReached = json['tierReached'] as int? ?? 1
      ..levelId = (json['levelId'] as String? ?? 'a1').toLowerCase()
      ..rowsUsed = json['rowsUsed'] as int? ?? 5
      ..timeExtendsUsed = json['timeExtendsUsed'] as int? ?? 0
      ..matchesCompleted = json['matchesCompleted'] as int? ?? 0
      ..attemptCount = json['attemptCount'] as int? ?? 0
      ..durationMs = json['durationMs'] as int? ?? 0
      ..xpEarned = json['xpEarned'] as int? ?? 0
      ..xpBonus = json['xpBonus'] as int? ?? 0
      ..streakMax = json['streakMax'] as int? ?? 0
      ..cleanRun = json['cleanRun'] as bool? ?? false
      ..deckComposition = _decodeDeck(json['deckComposition'])
      ..learnedPromoted = _stringList(json['learnedPromoted'])
      ..troubleDetected = _stringList(json['troubleDetected'])
      ..powerupsEarned = _stringList(json['powerupsEarned']);
  }

  /// Timestamp when the run started.
  DateTime startedAt = DateTime.now();

  /// Timestamp when the run finished, if completion occurred.
  DateTime? completedAt;

  /// Highest tier reached during the run.
  int tierReached = 1;

  /// Level identifier the run was targeting.
  String levelId = 'a1';

  /// Number of rows active on the board.
  int rowsUsed = 5;

  /// Number of time-extend powerups consumed.
  int timeExtendsUsed = 0;

  /// Total matches completed during the run.
  int matchesCompleted = 0;

  /// Total attempts logged during the run.
  int attemptCount = 0;

  /// Duration of the run in milliseconds.
  int durationMs = 0;

  /// Total XP earned (base + bonus).
  int xpEarned = 0;

  /// XP awarded specifically from streak/clean bonuses.
  int xpBonus = 0;

  /// Highest streak achieved in this run.
  int streakMax = 0;

  /// Whether the run completed without mistakes.
  bool cleanRun = false;

  /// Deck composition snapshot (counts by level).
  List<DeckLevelCount> deckComposition = <DeckLevelCount>[];

  /// Identifiers promoted to the learned bucket.
  List<String> learnedPromoted = <String>[];

  /// Identifiers marked as trouble during the run.
  List<String> troubleDetected = <String>[];

  /// Powerups granted upon completion of the run.
  List<String> powerupsEarned = <String>[];

  /// Serializes the run log to a JSON-compatible map.
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'startedAt': startedAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'tierReached': tierReached,
      'levelId': levelId,
      'rowsUsed': rowsUsed,
      'timeExtendsUsed': timeExtendsUsed,
      'matchesCompleted': matchesCompleted,
      'attemptCount': attemptCount,
      'durationMs': durationMs,
      'xpEarned': xpEarned,
      'xpBonus': xpBonus,
      'streakMax': streakMax,
      'cleanRun': cleanRun,
      'deckComposition': deckComposition
          .map((entry) => entry.toJson())
          .toList(),
      'learnedPromoted': learnedPromoted,
      'troubleDetected': troubleDetected,
      'powerupsEarned': powerupsEarned,
    };
  }

  static DateTime? _parseTimestamp(Object? raw) {
    if (raw is String && raw.isNotEmpty) {
      return DateTime.tryParse(raw);
    }
    return null;
  }

  static List<DeckLevelCount> _decodeDeck(Object? raw) {
    if (raw is List) {
      return raw
          .whereType<Map<dynamic, dynamic>>()
          .map(
            (entry) => DeckLevelCount.fromJson(
              Map<String, dynamic>.from(entry),
            ),
          )
          .toList();
    }
    return <DeckLevelCount>[];
  }

  static List<String> _stringList(Object? raw) {
    if (raw is List) {
      return raw.map((entry) => entry.toString()).toList(growable: false);
    }
    return <String>[];
  }
}

class DeckLevelCount {
  /// Creates a deck-level count entry with optional seed values.
  DeckLevelCount({this.level = '', this.count = 0});

  /// Vocabulary level associated with the count.
  String level;

  /// Number of cards seen for the level.
  int count;

  /// Hydrates a deck-count entry from JSON.
  factory DeckLevelCount.fromJson(Map<String, dynamic> json) {
    return DeckLevelCount(
      level: json['level'] as String? ?? '',
      count: json['count'] as int? ?? 0,
    );
  }

  /// Serializes the deck-count entry to JSON.
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'level': level,
      'count': count,
    };
  }
}
