import 'package:isar/isar.dart';
import 'package:palabra/data_core/models/vocab_item.dart';

part 'user_item_state.g.dart';

/// Player-specific spaced repetition metadata for a vocabulary item.
@collection
class UserItemState {
  /// Internal identifier for Isar persistence.
  Id id = Isar.autoIncrement;

  /// Foreign key to [VocabItem.itemId].
  @Index(unique: true, replace: true)
  late String itemId;

  /// Number of times the tile surfaced during runs.
  int seenCount = 0;

  /// Consecutive correct matches achieved.
  int correctStreak = 0;

  /// Number of incorrect attempts recorded.
  int wrongCount = 0;

  /// When the user last saw the item during a run.
  DateTime? lastSeenAt;

  /// When the item was last marked as learned.
  DateTime? learnedAt;

  /// When the item was last flagged as trouble.
  DateTime? troubleAt;
}
