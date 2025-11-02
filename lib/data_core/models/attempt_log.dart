import 'package:isar/isar.dart';

part 'attempt_log.g.dart';

/// Individual tile pair attempt captured during a run.
@collection
class AttemptLog {
  /// Primary key.
  Id id = Isar.autoIncrement;

  /// Identifier of the run this attempt belongs to.
  @Index()
  late int runLogId;

  /// Tier marker (1, 2, or 3).
  int tier = 1;

  /// Zero-based row index tapped.
  int row = 0;

  /// Column index (0 = English, 1 = Spanish).
  int column = 0;

  /// Remaining milliseconds on the timer when the tap occurred.
  int timeRemainingMs = 0;

  /// Captured timestamp of the attempt.
  late DateTime timestamp;

  /// Identifier for the English tile presented.
  late String englishItemId;

  /// Identifier for the Spanish tile the player tapped.
  late String spanishItemId;

  /// Whether the attempt resolved correctly.
  bool correct = false;
}
