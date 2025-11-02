import 'package:isar/isar.dart';

part 'run_log.g.dart';

/// Summary of a single timed run session.
@collection
class RunLog {
  /// Primary key for the run record.
  Id id = Isar.autoIncrement;

  /// Wall-clock start timestamp.
  late DateTime startedAt;

  /// Timestamp when the run finished or aborted.
  DateTime? completedAt;

  /// Active tier when the run ended (1, 2, or 3).
  int tierReached = 1;

  /// Rows used during the run (4 or 5).
  int rowsUsed = 5;

  /// Number of time extend powerups consumed.
  int timeExtendsUsed = 0;

  /// Mix of CEFR levels that seeded the deck.
  List<DeckLevelCount> deckComposition = <DeckLevelCount>[];

  /// Item identifiers promoted to learned after the run.
  List<String> learnedPromoted = <String>[];

  /// Item identifiers flagged as trouble.
  List<String> troubleDetected = <String>[];
}

/// Represents how many cards from a given CEFR level were used in a run.
@embedded
class DeckLevelCount {
  /// CEFR level label (a1, a2, b1, b2).
  late String level;

  /// Count of cards served from the level.
  int count = 0;
}
