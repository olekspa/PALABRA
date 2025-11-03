class AttemptLog {
  int tier = 1;
  int row = 0;
  int column = 0;
  int timeRemainingMs = 0;
  DateTime timestamp = DateTime.now();
  String englishItemId = '';
  String spanishItemId = '';
  bool correct = false;
  int runLogId = 0;

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

  factory AttemptLog.fromJson(Map<String, dynamic> json) {
    final log = AttemptLog();
    log.tier = json['tier'] as int? ?? 1;
    log.row = json['row'] as int? ?? 0;
    log.column = json['column'] as int? ?? 0;
    log.timeRemainingMs = json['timeRemainingMs'] as int? ?? 0;
    final timestampValue = json['timestamp'];
    if (timestampValue is String && timestampValue.isNotEmpty) {
      log.timestamp = DateTime.tryParse(timestampValue) ?? DateTime.now();
    }
    log.englishItemId = json['englishItemId'] as String? ?? '';
    log.spanishItemId = json['spanishItemId'] as String? ?? '';
    log.correct = json['correct'] as bool? ?? false;
    log.runLogId = json['runLogId'] as int? ?? 0;
    return log;
  }
}
