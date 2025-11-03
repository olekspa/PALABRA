/// Data-only container mirrored from persisted JSON during beta builds.
class AttemptLog {
  AttemptLog();

  /// Hydrates an attempt log from persisted JSON.
  factory AttemptLog.fromJson(Map<String, dynamic> json) {
    return AttemptLog()
      ..tier = json['tier'] as int? ?? 1
      ..row = json['row'] as int? ?? 0
      ..column = json['column'] as int? ?? 0
      ..timeRemainingMs = json['timeRemainingMs'] as int? ?? 0
      ..timestamp = _parseTimestamp(json['timestamp'])
      ..englishItemId = json['englishItemId'] as String? ?? ''
      ..spanishItemId = json['spanishItemId'] as String? ?? ''
      ..correct = json['correct'] as bool? ?? false
      ..runLogId = json['runLogId'] as int? ?? 0;
  }

  /// Tier reached when this attempt occurred (1-indexed).
  int tier = 1;
  /// Row index containing the tile selection.
  int row = 0;
  /// Column index containing the tile selection.
  int column = 0;
  /// Time remaining (milliseconds) when the attempt was made.
  int timeRemainingMs = 0;
  /// Timestamp when the attempt was recorded.
  DateTime timestamp = DateTime.now();
  /// Identifier for the English tile involved in the attempt.
  String englishItemId = '';
  /// Identifier for the Spanish tile involved in the attempt.
  String spanishItemId = '';
  /// Whether the attempt resulted in a correct match.
  bool correct = false;
  /// Identifier linking the attempt to its parent run log.
  int runLogId = 0;

  /// Serializes the attempt log to a JSON-compatible map.
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'tier': tier,
      'row': row,
      'column': column,
      'timeRemainingMs': timeRemainingMs,
      'timestamp': timestamp.toIso8601String(),
      'englishItemId': englishItemId,
      'spanishItemId': spanishItemId,
      'correct': correct,
      'runLogId': runLogId,
    };
  }

  static DateTime _parseTimestamp(Object? raw) {
    if (raw is String && raw.isNotEmpty) {
      return DateTime.tryParse(raw) ?? DateTime.now();
    }
    return DateTime.now();
  }
}
