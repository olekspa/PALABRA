/// Vocabulary item snapshot used by the in-memory store.
class VocabItem {
  /// Creates a vocabulary entry with optional seed values.
  VocabItem({
    this.itemId = '',
    this.english = '',
    this.spanish = '',
    this.level = '',
    this.family,
    this.topic,
  });

  /// Stable identifier for the item (level-prefixed).
  String itemId;
  /// English text shown on the tile.
  String english;
  /// Spanish text shown on the tile.
  String spanish;
  /// CEFR level where the word belongs.
  String level;
  /// Optional family grouping slug.
  String? family;
  /// Optional semantic topic grouping.
  String? topic;
}
