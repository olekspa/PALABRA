class UserMeta {
  bool hasSeededVocabulary = false;
  int preferredRows = 5;
  String level = 'a1';
  int learnedCount = 0;
  int troubleCount = 0;
  DateTime? lastRunAt;
  int rowBlasterCharges = 0;
  int timeExtendTokens = 0;

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

  factory UserMeta.fromJson(Map<String, dynamic> json) {
    final meta = UserMeta();
    meta.hasSeededVocabulary = json['hasSeededVocabulary'] as bool? ?? false;
    meta.preferredRows = json['preferredRows'] as int? ?? 5;
    meta.level = (json['level'] as String? ?? 'a1').toLowerCase();
    meta.learnedCount = json['learnedCount'] as int? ?? 0;
    meta.troubleCount = json['troubleCount'] as int? ?? 0;
    final lastRun = json['lastRunAt'];
    if (lastRun is String && lastRun.isNotEmpty) {
      meta.lastRunAt = DateTime.tryParse(lastRun);
    }
    meta.rowBlasterCharges = json['rowBlasterCharges'] as int? ?? 0;
    meta.timeExtendTokens = json['timeExtendTokens'] as int? ?? 0;
    return meta;
  }
}
