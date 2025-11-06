/// Tracks per-user progress for the number-listening bonus drill.
class NumberDrillProgress {
  NumberDrillProgress({
    this.highestNumberUnlocked = 20,
    this.drillsCompleted = 0,
    this.totalMistakes = 0,
    Map<int, int>? mistakeCounts,
    Set<int>? masteredNumbers,
  }) : mistakeCounts = mistakeCounts ?? <int, int>{},
       masteredNumbers = masteredNumbers ?? <int>{};

  /// Highest number (1-100) that may appear in the grid.
  int highestNumberUnlocked;

  /// Total number of drills completed.
  int drillsCompleted;

  /// Aggregate mistakes across all drills.
  int totalMistakes;

  /// Per-number mistake counts to bias future selections.
  Map<int, int> mistakeCounts;

  /// Set of number values the learner has proven mastery over.
  Set<int> masteredNumbers;

  factory NumberDrillProgress.fromJson(Map<String, dynamic> json) {
    return NumberDrillProgress(
      highestNumberUnlocked: json['highestNumberUnlocked'] as int? ?? 20,
      drillsCompleted: json['drillsCompleted'] as int? ?? 0,
      totalMistakes: json['totalMistakes'] as int? ?? 0,
      mistakeCounts: (json['mistakeCounts'] as Map<String, dynamic>?)?.map(
        (key, value) => MapEntry(int.parse(key), (value as num).toInt()),
      ),
      masteredNumbers: json['masteredNumbers'] is List
          ? (json['masteredNumbers'] as List)
                .map((value) => (value as num).toInt())
                .toSet()
          : <int>{},
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'highestNumberUnlocked': highestNumberUnlocked,
      'drillsCompleted': drillsCompleted,
      'totalMistakes': totalMistakes,
      'mistakeCounts': mistakeCounts.map(
        (key, value) => MapEntry(key.toString(), value),
      ),
      'masteredNumbers': masteredNumbers.toList(),
    };
  }
}
