import 'package:isar/isar.dart';

import 'package:palabra/data_core/models/vocab_item.dart';

/// Persistence gateway for vocabulary content.
class VocabRepository {
  /// Creates a [VocabRepository] backed by the provided [_isar] instance.
  VocabRepository(this._isar);

  final Isar _isar;

  /// Writes or updates the provided items in bulk.
  Future<void> upsertItems(List<VocabItem> items) async {
    if (items.isEmpty) {
      return;
    }

    await _isar.writeTxn(() async {
      await _isar.vocabItems.putAll(items);
    });
  }

  /// Returns all vocabulary items for a particular CEFR [level].
  Future<List<VocabItem>> getByLevel(String level) {
    return _isar.vocabItems.filter().levelEqualTo(level).findAll();
  }

  /// Loads specific vocabulary entries by their stable identifiers.
  Future<List<VocabItem>> getByItemIds(Iterable<String> itemIds) async {
    final deduped = itemIds.toSet().toList();
    final records = await _isar.vocabItems.getAllByItemId(deduped);
    return records.whereType<VocabItem>().toList();
  }
}
