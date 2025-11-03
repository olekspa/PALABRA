import 'package:flutter/services.dart';

import '../in_memory_store.dart';
import '../models/vocab_item.dart';

class VocabRepository {
  VocabRepository({InMemoryStore? store})
    : _store = store ?? InMemoryStore.instance;

  final InMemoryStore _store;

  Future<void> ensureLoaded(AssetBundle bundle) {
    return _store.ensureVocabularyLoaded(bundle);
  }

  Future<List<VocabItem>> getByLevel(String level) async {
    return _store.vocabularyByLevel(level);
  }

  Future<List<VocabItem>> getByItemIds(Iterable<String> itemIds) async {
    return _store.vocabularyByIds(itemIds);
  }

  Future<void> upsertItems(List<VocabItem> items) async {
    _store.upsertVocabulary(items);
  }
}
