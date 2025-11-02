import 'package:isar/isar.dart';

part 'user_meta.g.dart';

/// Aggregated progress and settings persisted per user.
@collection
class UserMeta {
  /// Single-row table identifier.
  Id id = Isar.autoIncrement;

  /// Whether the vocabulary assets have been seeded into Isar.
  bool hasSeededVocabulary = false;

  /// Preferred board row count (4 or 5).
  int preferredRows = 5;

  /// Last selected CEFR level bucket (a1, a2, b1, b2).
  String level = 'a1';

  /// Count of vocabulary items marked learned.
  int learnedCount = 0;

  /// Count of items currently marked as trouble.
  int troubleCount = 0;

  /// Last time the user completed a run.
  DateTime? lastRunAt;

  /// Available row blaster charges.
  int rowBlasterCharges = 0;

  /// Available time extend tokens.
  int timeExtendTokens = 0;
}
