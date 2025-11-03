import 'dart:convert';

import 'package:flutter/services.dart';

import 'package:palabra/data_core/models/attempt_log.dart';
import 'package:palabra/data_core/models/run_log.dart';
import 'package:palabra/data_core/models/user_item_state.dart';
import 'package:palabra/data_core/models/user_meta.dart';
import 'package:palabra/data_core/models/vocab_item.dart';
import 'package:palabra/data_core/persistence/store_persistence.dart';

/// Internal backing store for prototype flows; see docs for behaviour.
class InMemoryStore {
  /// Private constructor for the singleton store.
  InMemoryStore._();

  /// Singleton access to the shared in-memory store.
  static final InMemoryStore instance = InMemoryStore._();

  final Map<String, VocabItem> _vocabulary = <String, VocabItem>{};
  /// Runtime user item state keyed by vocabulary ID.
  final Map<String, UserItemState> userStates = <String, UserItemState>{};
  /// Persisted user metadata snapshot.
  UserMeta userMeta = UserMeta();
  /// Chronological run logs with the most recent first.
  final List<RunLog> runLogs = <RunLog>[];
  /// Attempt-level logs accumulated during runs.
  final List<AttemptLog> attemptLogs = <AttemptLog>[];

  bool _vocabularyLoaded = false;

  /// Restores the store state from persisted JSON if available.
  Future<void> restore() async {
    final payload = await StorePersistence.instance.load();
    if (payload == null) {
      return;
    }
    _loadFromJson(payload);
  }

  /// Persists the current store snapshot to shared preferences.
  Future<void> persist() {
    return StorePersistence.instance.save(_toJson());
  }

  /// Loads vocabulary assets once per runtime session.
  Future<void> ensureVocabularyLoaded(AssetBundle bundle) async {
    if (_vocabularyLoaded) {
      return;
    }
    const levels = ['a1', 'a2', 'b1', 'b2'];
    for (final level in levels) {
      await _loadLevel(bundle: bundle, level: level);
    }
    _vocabularyLoaded = true;
  }

  /// Returns vocabulary entries filtered by CEFR level.
  List<VocabItem> vocabularyByLevel(String level) {
    return _vocabulary.values
        .where((item) => item.level == level)
        .toList(growable: false);
  }

  /// Returns vocabulary entries for the provided IDs.
  List<VocabItem> vocabularyByIds(Iterable<String> ids) {
    return ids.map((id) => _vocabulary[id]).whereType<VocabItem>().toList();
  }

  /// Inserts or updates vocabulary entries in the store.
  void upsertVocabulary(List<VocabItem> items) {
    for (final item in items) {
      _vocabulary[item.itemId] = item;
    }
  }

  Map<String, dynamic> _toJson() {
    final states = <String, dynamic>{
      for (final entry in userStates.entries) entry.key: entry.value.toJson(),
    };
    return <String, dynamic>{
      'userMeta': userMeta.toJson(),
      'userStates': states,
      'runLogs': runLogs.map((log) => log.toJson()).toList(),
      'attemptLogs': attemptLogs.map((log) => log.toJson()).toList(),
    };
  }

  void _loadFromJson(Map<String, dynamic> json) {
    final metaJson = json['userMeta'];
    if (metaJson is Map<String, dynamic>) {
      userMeta = UserMeta.fromJson(metaJson);
    }

    final statesJson = json['userStates'];
    if (statesJson is Map) {
      userStates.clear();
      statesJson.forEach((key, value) {
        if (value is Map) {
          final map = Map<String, dynamic>.from(value);
          map['itemId'] ??= key.toString();
          final state = UserItemState.fromJson(map);
          if (state.itemId.isNotEmpty) {
            userStates[state.itemId] = state;
          }
        }
      });
    }

    final runLogsJson = json['runLogs'];
    if (runLogsJson is List) {
      runLogs
        ..clear()
        ..addAll(
          runLogsJson
              .whereType<Map<String, dynamic>>()
              .map(RunLog.fromJson),
        );
    }

    final attemptsJson = json['attemptLogs'];
    if (attemptsJson is List) {
      attemptLogs
        ..clear()
        ..addAll(
          attemptsJson
              .whereType<Map<String, dynamic>>()
              .map(AttemptLog.fromJson),
        );
    }
  }

  Future<void> _loadLevel({
    required AssetBundle bundle,
    required String level,
  }) async {
    final path = 'assets/vocabulary/spanish/$level.json';
    final raw = await bundle.loadString(path);
    final decoded = json.decode(raw);
    if (decoded is! List) {
      return;
    }
    for (final item in decoded) {
      if (item is! Map<String, dynamic>) {
        continue;
      }
      final id = (item['id'] ?? '').toString();
      final english = (item['en'] ?? item['english'] ?? '').toString();
      final spanish = (item['es'] ?? item['spanish'] ?? '').toString();
      if (id.isEmpty || english.isEmpty || spanish.isEmpty) {
        continue;
      }
      final familyValue = (item['family'] ?? '').toString();
      final topicValue = (item['topic'] ?? '').toString();
      _vocabulary[id] = VocabItem(
        itemId: id,
        english: english,
        spanish: spanish,
        level: level,
        family: familyValue.isEmpty ? null : familyValue,
        topic: topicValue.isEmpty ? null : topicValue,
      );
    }
  }
}
