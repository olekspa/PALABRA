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

  /// Runtime user item state keyed by active profile and vocabulary ID.
  final Map<String, Map<String, UserItemState>> _profileUserStates =
      <String, Map<String, UserItemState>>{};

  /// Persisted metadata per profile id.
  final Map<String, UserMeta> _profiles = <String, UserMeta>{};

  /// Chronological run logs grouped by profile id.
  final Map<String, List<RunLog>> _profileRunLogs = <String, List<RunLog>>{};

  /// Attempt-level logs grouped by profile id.
  final Map<String, List<AttemptLog>> _profileAttemptLogs =
      <String, List<AttemptLog>>{};

  /// Currently selected profile id.
  String? activeProfileId;

  /// Returns the active profile id, creating a default profile as needed.
  String ensureActiveProfile({String? profileId}) {
    final requested = profileId ?? activeProfileId;
    if (requested != null && _profiles.containsKey(requested)) {
      activeProfileId = requested;
      return requested;
    }
    if (activeProfileId != null && _profiles.containsKey(activeProfileId)) {
      return activeProfileId!;
    }
    final id = _generateDefaultProfileId();
    _profiles.putIfAbsent(id, UserMeta.new);
    _profileUserStates.putIfAbsent(id, () => <String, UserItemState>{});
    _profileRunLogs.putIfAbsent(id, () => <RunLog>[]);
    _profileAttemptLogs.putIfAbsent(id, () => <AttemptLog>[]);
    activeProfileId = id;
    return id;
  }

  /// Returns the metadata for the profile.
  UserMeta profileMeta(String profileId) {
    return _profiles.putIfAbsent(profileId, UserMeta.new);
  }

  /// Updates or inserts the provided profile metadata.
  void upsertProfile(String profileId, UserMeta meta) {
    _profiles[profileId] = meta;
  }

  /// Returns all known profile ids.
  List<String> get profileIds => _profiles.keys.toList(growable: false);

  /// Deletes the profile and associated state.
  void deleteProfile(String profileId) {
    _profiles.remove(profileId);
    _profileUserStates.remove(profileId);
    _profileRunLogs.remove(profileId);
    _profileAttemptLogs.remove(profileId);
    if (activeProfileId == profileId) {
      activeProfileId = _profiles.isEmpty ? null : _profiles.keys.first;
    }
  }

  Map<String, UserItemState> userStatesFor(String profileId) {
    return _profileUserStates.putIfAbsent(
      profileId,
      () => <String, UserItemState>{},
    );
  }

  List<RunLog> runLogsFor(String profileId) {
    return _profileRunLogs.putIfAbsent(profileId, () => <RunLog>[]);
  }

  List<AttemptLog> attemptLogsFor(String profileId) {
    return _profileAttemptLogs.putIfAbsent(profileId, () => <AttemptLog>[]);
  }

  /// Convenience getter for the active profile metadata.
  UserMeta get userMeta => profileMeta(ensureActiveProfile());

  /// Convenience setter for the active profile metadata.
  set userMeta(UserMeta value) => upsertProfile(ensureActiveProfile(), value);

  /// Convenience getter for active profile user states.
  Map<String, UserItemState> get userStates =>
      userStatesFor(ensureActiveProfile());

  /// Convenience getter for active profile run logs.
  List<RunLog> get runLogs => runLogsFor(ensureActiveProfile());

  /// Convenience getter for active profile attempt logs.
  List<AttemptLog> get attemptLogs => attemptLogsFor(ensureActiveProfile());

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
    final profilesJson = <String, dynamic>{
      for (final entry in _profiles.entries)
        entry.key: entry.value.toJson(),
    };
    final userStatesJson = _profileUserStates.map(
      (profileId, map) => MapEntry(
        profileId,
        <String, dynamic>{
          for (final entry in map.entries) entry.key: entry.value.toJson(),
        },
      ),
    );
    final runLogsJson = _profileRunLogs.map(
      (key, value) => MapEntry(key, value.map((log) => log.toJson()).toList()),
    );
    final attemptLogsJson = _profileAttemptLogs.map(
      (key, value) => MapEntry(key, value.map((log) => log.toJson()).toList()),
    );
    return <String, dynamic>{
      'activeProfileId': activeProfileId,
      'profiles': profilesJson,
      'userStates': userStatesJson,
      'runLogs': runLogsJson,
      'attemptLogs': attemptLogsJson,
    };
  }

  void _loadFromJson(Map<String, dynamic> json) {
    activeProfileId = json['activeProfileId'] as String?;

    final profilesJson = json['profiles'];
    if (profilesJson is Map) {
      _profiles.clear();
      profilesJson.forEach((key, value) {
        if (value is Map) {
          _profiles[key.toString()] = UserMeta.fromJson(
            Map<String, dynamic>.from(value.cast<String, dynamic>()),
          );
        }
      });
    }

    final statesJson = json['userStates'];
    if (statesJson is Map) {
      _profileUserStates.clear();
      statesJson.forEach((profileKey, mapValue) {
        if (mapValue is Map) {
          final states = <String, UserItemState>{};
          mapValue.forEach((key, value) {
            if (value is Map) {
              final map = Map<String, dynamic>.from(value);
              map['itemId'] ??= key.toString();
              final state = UserItemState.fromJson(map);
              if (state.itemId.isNotEmpty) {
                states[state.itemId] = state;
              }
            }
          });
          _profileUserStates[profileKey.toString()] = states;
        }
      });
    }

    final runLogsJson = json['runLogs'];
    if (runLogsJson is Map) {
      _profileRunLogs.clear();
      runLogsJson.forEach((profileKey, listValue) {
        if (listValue is List) {
          final logs = listValue
              .whereType<Map<String, dynamic>>()
              .map(RunLog.fromJson)
              .toList();
          _profileRunLogs[profileKey.toString()] = logs;
        }
      });
    }

    final attemptsJson = json['attemptLogs'];
    if (attemptsJson is Map) {
      _profileAttemptLogs.clear();
      attemptsJson.forEach((profileKey, listValue) {
        if (listValue is List) {
          final logs = listValue
              .whereType<Map<String, dynamic>>()
              .map(AttemptLog.fromJson)
              .toList();
          _profileAttemptLogs[profileKey.toString()] = logs;
        }
      });
    }

    ensureActiveProfile();
  }

  String _generateDefaultProfileId() {
    const base = 'profile';
    var suffix = 1;
    while (_profiles.containsKey('$base$suffix')) {
      suffix += 1;
    }
    return '$base$suffix';
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
