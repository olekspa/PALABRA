class UserItemState {
  UserItemState({this.itemId = ''});

  String itemId;
  int seenCount = 0;
  int correctStreak = 0;
  int wrongCount = 0;
  DateTime? lastSeenAt;
  DateTime? learnedAt;
  DateTime? troubleAt;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'itemId': itemId,
      'seenCount': seenCount,
      'correctStreak': correctStreak,
      'wrongCount': wrongCount,
      'lastSeenAt': lastSeenAt?.toIso8601String(),
      'learnedAt': learnedAt?.toIso8601String(),
      'troubleAt': troubleAt?.toIso8601String(),
    };
  }

  factory UserItemState.fromJson(Map<String, dynamic> json) {
    final state = UserItemState(itemId: json['itemId'] as String? ?? '');
    state.seenCount = json['seenCount'] as int? ?? 0;
    state.correctStreak = json['correctStreak'] as int? ?? 0;
    state.wrongCount = json['wrongCount'] as int? ?? 0;
    final lastSeen = json['lastSeenAt'];
    if (lastSeen is String && lastSeen.isNotEmpty) {
      state.lastSeenAt = DateTime.tryParse(lastSeen);
    }
    final learned = json['learnedAt'];
    if (learned is String && learned.isNotEmpty) {
      state.learnedAt = DateTime.tryParse(learned);
    }
    final trouble = json['troubleAt'];
    if (trouble is String && trouble.isNotEmpty) {
      state.troubleAt = DateTime.tryParse(trouble);
    }
    return state;
  }
}
