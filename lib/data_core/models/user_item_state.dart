/// Ephemeral state container for prototype flows; see docs for behaviour.
class UserItemState {
  /// Creates a user item state tied to the provided vocabulary item ID.
  UserItemState({this.itemId = ''});

  /// Vocabulary item identifier tracked by this state entry.
  String itemId;

  /// Number of times the item has been surfaced.
  int seenCount = 0;

  /// Current correct streak for the item.
  int correctStreak = 0;

  /// Total correct matches across all runs.
  int totalCorrect = 0;

  /// Number of wrong attempts recorded for the item.
  int wrongCount = 0;

  /// Timestamp when the item was last seen.
  DateTime? lastSeenAt;

  /// Timestamp when the item was promoted to learned.
  DateTime? learnedAt;

  /// Timestamp when the item was flagged as trouble.
  DateTime? troubleAt;

  /// Hydrates user state from a persisted JSON map.
  factory UserItemState.fromJson(Map<String, dynamic> json) {
    return UserItemState(itemId: json['itemId'] as String? ?? '')
      ..seenCount = json['seenCount'] as int? ?? 0
      ..correctStreak = json['correctStreak'] as int? ?? 0
      ..totalCorrect = json['totalCorrect'] as int? ?? 0
      ..wrongCount = json['wrongCount'] as int? ?? 0
      ..lastSeenAt = _parseTimestamp(json['lastSeenAt'])
      ..learnedAt = _parseTimestamp(json['learnedAt'])
      ..troubleAt = _parseTimestamp(json['troubleAt']);
  }

  /// Serializes the state to a JSON-compatible map.
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'itemId': itemId,
      'seenCount': seenCount,
      'correctStreak': correctStreak,
      'totalCorrect': totalCorrect,
      'wrongCount': wrongCount,
      'lastSeenAt': lastSeenAt?.toIso8601String(),
      'learnedAt': learnedAt?.toIso8601String(),
      'troubleAt': troubleAt?.toIso8601String(),
    };
  }

  static DateTime? _parseTimestamp(Object? raw) {
    if (raw is String && raw.isNotEmpty) {
      return DateTime.tryParse(raw);
    }
    return null;
  }
}
