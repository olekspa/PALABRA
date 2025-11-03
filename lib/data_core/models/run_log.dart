class RunLog {
  DateTime startedAt = DateTime.now();
  DateTime? completedAt;
  int tierReached = 1;
  int rowsUsed = 5;
  int timeExtendsUsed = 0;
  List<DeckLevelCount> deckComposition = <DeckLevelCount>[];
  List<String> learnedPromoted = <String>[];
  List<String> troubleDetected = <String>[];

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'startedAt': startedAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'tierReached': tierReached,
      'rowsUsed': rowsUsed,
      'timeExtendsUsed': timeExtendsUsed,
      'deckComposition': deckComposition.map((entry) => entry.toJson()).toList(),
      'learnedPromoted': learnedPromoted,
      'troubleDetected': troubleDetected,
    };
  }

  factory RunLog.fromJson(Map<String, dynamic> json) {
    final log = RunLog();
    final started = json['startedAt'];
    if (started is String && started.isNotEmpty) {
      log.startedAt = DateTime.tryParse(started) ?? DateTime.now();
    }
    final completed = json['completedAt'];
    if (completed is String && completed.isNotEmpty) {
      log.completedAt = DateTime.tryParse(completed);
    }
    log.tierReached = json['tierReached'] as int? ?? 1;
    log.rowsUsed = json['rowsUsed'] as int? ?? 5;
    log.timeExtendsUsed = json['timeExtendsUsed'] as int? ?? 0;
    final composition = json['deckComposition'];
    if (composition is List) {
      log.deckComposition = composition
          .whereType<Map>()
          .map((entry) => DeckLevelCount.fromJson(
                Map<String, dynamic>.from(entry),
              ))
          .toList();
    }
    final learned = json['learnedPromoted'];
    if (learned is List) {
      log.learnedPromoted =
          learned.map((entry) => entry.toString()).toList(growable: false);
    }
    final trouble = json['troubleDetected'];
    if (trouble is List) {
      log.troubleDetected =
          trouble.map((entry) => entry.toString()).toList(growable: false);
    }
    return log;
  }
}

class DeckLevelCount {
  DeckLevelCount({this.level = '', this.count = 0});

  String level;
  int count;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'level': level,
      'count': count,
    };
  }

  factory DeckLevelCount.fromJson(Map<String, dynamic> json) {
    return DeckLevelCount(
      level: json['level'] as String? ?? '',
      count: json['count'] as int? ?? 0,
    );
  }
}
