import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:isar/isar.dart';
import 'package:palabra/data_core/models/vocab_item.dart';
import 'package:palabra/data_core/repositories/user_meta_repository.dart';

const _vocabularyLevels = <String>['a1', 'a2', 'b1', 'b2'];

/// Handles importing bundled vocabulary assets into the local database.
class VocabularySeedService {
  /// Creates a [VocabularySeedService].
  VocabularySeedService({
    required Isar isar,
    required AssetBundle assetBundle,
    required UserMetaRepository userMetaRepository,
    this.assetRoot = 'assets/vocabulary/spanish',
  }) : _isar = isar,
       _assetBundle = assetBundle,
       _userMetaRepository = userMetaRepository;

  final Isar _isar;
  final AssetBundle _assetBundle;
  final UserMetaRepository _userMetaRepository;

  /// Root folder containing leveled JSON files.
  final String assetRoot;

  /// Seeds the vocabulary tables if they have not been imported yet.
  Future<void> seedIfNeeded() async {
    final meta = await _userMetaRepository.getOrCreate();
    if (meta.hasSeededVocabulary) {
      return;
    }

    final items = await _loadVocabulary();
    if (items.isEmpty) {
      return;
    }

    await _isar.writeTxn(() async {
      await _isar.vocabItems.clear();
      await _isar.vocabItems.putAllByItemId(items);
    });

    meta.hasSeededVocabulary = true;
    await _userMetaRepository.save(meta);
  }

  Future<List<VocabItem>> _loadVocabulary() async {
    final items = <VocabItem>[];
    for (final level in _vocabularyLevels) {
      final path = '$assetRoot/$level.json';
      final contents = await _assetBundle.loadString(path);
      final decoded = json.decode(contents);
      if (decoded is! List) {
        continue;
      }
      for (final entry in decoded) {
        if (entry is! Map<String, dynamic>) {
          continue;
        }
        final id = (entry['id'] ?? '').toString();
        final en = (entry['en'] ?? entry['english'] ?? '').toString();
        final es = (entry['es'] ?? entry['spanish'] ?? '').toString();
        final family = (entry['family'] ?? '').toString();
        final topic = (entry['topic'] ?? '').toString();
        if (id.isEmpty || en.isEmpty || es.isEmpty) {
          continue;
        }
        items.add(
          VocabItem()
            ..itemId = id
            ..english = en
            ..spanish = es
            ..level = level
            ..family = family
            ..topic = topic,
        );
      }
    }
    return items;
  }
}
