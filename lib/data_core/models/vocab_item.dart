import 'package:isar/isar.dart';

part 'vocab_item.g.dart';

/// Vocabulary entry seeded from the leveled JSON assets.
@collection
class VocabItem {
  /// Unique identifier for the record in Isar.
  Id id = Isar.autoIncrement;

  /// Stable string identifier from the source content (e.g. `a1_000123`).
  @Index(unique: true, replace: true)
  late String itemId;

  /// English source text.
  late String english;

  /// Spanish translation text.
  late String spanish;

  /// CEFR level label (a1/a2/b1/b2).
  late String level;

  /// Confusable family identifier.
  String? family;

  /// Semantic topic bucket.
  String? topic;
}
