class UserItemState {
  UserItemState({this.itemId = ''});

  String itemId;
  int seenCount = 0;
  int correctStreak = 0;
  int wrongCount = 0;
  DateTime? lastSeenAt;
  DateTime? learnedAt;
  DateTime? troubleAt;
}
