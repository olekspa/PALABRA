import 'package:flutter/services.dart';

import 'package:palabra/data_core/in_memory_store.dart';
import 'package:palabra/data_core/models/vocab_item.dart';

/// In-memory vocabulary accessor for prototype builds.
class VocabRepository {
  /// Creates the repository using the provided or default store instance.
  VocabRepository({InMemoryStore? store})
    : _store = store ?? InMemoryStore.instance;

  final InMemoryStore _store;

  /// Loads vocabulary assets from the bundled JSON files.
  Future<void> ensureLoaded(AssetBundle bundle) {
    return _store.ensureVocabularyLoaded(bundle);
  }

  /// Returns vocabulary entries filtered by CEFR level.
  Future<List<VocabItem>> getByLevel(String level) async {
    return _store.vocabularyByLevel(level);
  }

  /// Returns vocabulary entries for the provided item IDs.
  Future<List<VocabItem>> getByItemIds(Iterable<String> itemIds) async {
    return _store.vocabularyByIds(itemIds);
  }

  /// Updates or inserts vocabulary entries within the store.
  Future<void> upsertItems(List<VocabItem> items) async {
    _store.upsertVocabulary(items);
  }
}
