class ProfileSummary {
  const ProfileSummary({
    required this.id,
    required this.displayName,
    required this.createdAt,
    this.lastSeenAt,
    this.level,
    this.totalRuns = 0,
    this.isActive = false,
  });

  final String id;
  final String displayName;
  final DateTime createdAt;
  final DateTime? lastSeenAt;
  final String? level;
  final int totalRuns;
  final bool isActive;

  ProfileSummary copyWith({
    String? displayName,
    DateTime? createdAt,
    DateTime? lastSeenAt,
    String? level,
    int? totalRuns,
    bool? isActive,
  }) {
    return ProfileSummary(
      id: id,
      displayName: displayName ?? this.displayName,
      createdAt: createdAt ?? this.createdAt,
      lastSeenAt: lastSeenAt ?? this.lastSeenAt,
      level: level ?? this.level,
      totalRuns: totalRuns ?? this.totalRuns,
      isActive: isActive ?? this.isActive,
    );
  }
}
