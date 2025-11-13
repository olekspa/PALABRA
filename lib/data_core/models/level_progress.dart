/// Tracks per-level progression, streaks, and clean-run stats.
class LevelProgress {
  LevelProgress({
    this.totalMatches = 0,
    this.cleanRuns = 0,
    this.bestStreak = 0,
    this.completedAt,
    this.lastCleanRunAt,
    this.targetMatches = 5,
    this.successRampProgress = 0,
    List<String>? masteredItemIds,
  }) : masteredItemIds = masteredItemIds ?? <String>[];

  /// Total unique matches available for the level (deck size baseline).
  int totalMatches;

  /// Number of clean runs (zero mistakes) completed for the level.
  int cleanRuns;

  /// Highest streak achieved within this level.
  int bestStreak;

  /// Timestamp when the level was first completed (if ever).
  DateTime? completedAt;

  /// Timestamp of the most recent clean run.
  DateTime? lastCleanRunAt;

  /// Unique vocabulary item ids mastered for this level.
  List<String> masteredItemIds;

  /// Current run target for this level (persists between sessions).
  int targetMatches;

  /// Counts successful runs since the last difficulty increase.
  int successRampProgress;

  /// Number of clean runs (zero mistakes) completed for the level.
  int get matchesCleared => masteredItemIds.length;

  /// Whether the level is considered complete.
  bool get isCompleted => completedAt != null;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'totalMatches': totalMatches,
      'cleanRuns': cleanRuns,
      'bestStreak': bestStreak,
      'completedAt': completedAt?.toIso8601String(),
      'lastCleanRunAt': lastCleanRunAt?.toIso8601String(),
      'masteredItemIds': masteredItemIds,
      'targetMatches': targetMatches,
      'successRampProgress': successRampProgress,
    };
  }

  factory LevelProgress.fromJson(Map<String, dynamic> json) {
    return LevelProgress(
      totalMatches: json['totalMatches'] as int? ?? 0,
      cleanRuns: json['cleanRuns'] as int? ?? 0,
      bestStreak: json['bestStreak'] as int? ?? 0,
      completedAt: _parseTimestamp(json['completedAt']),
      lastCleanRunAt: _parseTimestamp(json['lastCleanRunAt']),
      masteredItemIds: _decodeIds(json['masteredItemIds']),
      targetMatches: json['targetMatches'] as int? ?? 5,
      successRampProgress: json['successRampProgress'] as int? ?? 0,
    );
  }

  static DateTime? _parseTimestamp(Object? raw) {
    if (raw is String && raw.isNotEmpty) {
      return DateTime.tryParse(raw);
    }
    return null;
  }

  static List<String> _decodeIds(Object? raw) {
    if (raw is List) {
      return raw.map((id) => id.toString()).toSet().toList();
    }
    return <String>[];
  }

  void recordMasteredItems(Iterable<String> itemIds) {
    final merged = <String>{...masteredItemIds, ...itemIds};
    masteredItemIds = merged.toList();
  }
}
