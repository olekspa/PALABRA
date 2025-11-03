import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Handles persisting and hydrating the in-memory store across app sessions.
class StorePersistence {
  StorePersistence._();

  /// Singleton accessor for shared persistence helpers.
  static final StorePersistence instance = StorePersistence._();

  /// Key used to store the serialized in-memory store payload.
  static const String _storageKey = 'palabra_store_v1';

  /// Loads the persisted JSON payload, returning `null` when no data exists.
  Future<Map<String, dynamic>?> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_storageKey);
      if (raw == null || raw.isEmpty) {
        return null;
      }
      final decoded = json.decode(raw);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
      if (decoded is Map) {
        return decoded.map(
          (key, value) => MapEntry(key.toString(), value),
        );
      }
    } on Object catch (_) {
      // Ignore persistence errors; the store will fallback to defaults.
    }
    return null;
  }

  /// Persists the provided JSON payload to shared preferences.
  Future<void> save(Map<String, dynamic> payload) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_storageKey, json.encode(payload));
    } on Object catch (_) {
      // Ignore persistence errors in the beta prototype.
    }
  }

  /// Removes any stored payload for the current build.
  Future<void> clear() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_storageKey);
    } on Object catch (_) {
      // Ignore in beta builds.
    }
  }
}
