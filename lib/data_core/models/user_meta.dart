/// Persistent metadata for the prototype user profile across sessions.
class UserMeta {
  /// Creates prototype metadata with default values.
  UserMeta();

  /// Whether the vocabulary cache has been seeded for the user.
  bool hasSeededVocabulary = false;
  /// Preferred row count on the board.
  int preferredRows = 5;
  /// Current CEFR level for the user.
  String level = 'a1';
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

  /// Hydrates metadata from persisted JSON.
  factory UserMeta.fromJson(Map<String, dynamic> json) {
    return UserMeta()
      ..hasSeededVocabulary = json['hasSeededVocabulary'] as bool? ?? false
      ..preferredRows = json['preferredRows'] as int? ?? 5
      ..level = (json['level'] as String? ?? 'a1').toLowerCase()
      ..learnedCount = json['learnedCount'] as int? ?? 0
      ..troubleCount = json['troubleCount'] as int? ?? 0
      ..lastRunAt = _parseTimestamp(json['lastRunAt'])
      ..rowBlasterCharges = json['rowBlasterCharges'] as int? ?? 0
      ..timeExtendTokens = json['timeExtendTokens'] as int? ?? 0;
  }

  /// Serializes metadata to a JSON-compatible map.
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'hasSeededVocabulary': hasSeededVocabulary,
      'preferredRows': preferredRows,
      'level': level,
      'learnedCount': learnedCount,
      'troubleCount': troubleCount,
      'lastRunAt': lastRunAt?.toIso8601String(),
      'rowBlasterCharges': rowBlasterCharges,
      'timeExtendTokens': timeExtendTokens,
    };
  }

  static DateTime? _parseTimestamp(Object? raw) {
    if (raw is String && raw.isNotEmpty) {
      return DateTime.tryParse(raw);
    }
    return null;
  }
}
