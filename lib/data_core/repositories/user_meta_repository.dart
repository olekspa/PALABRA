import 'package:palabra/data_core/in_memory_store.dart';
import 'package:palabra/data_core/models/user_meta.dart';

/// CRUD helper for prototype user metadata.
class UserMetaRepository {
  /// Creates the repository using the provided or default store instance.
  UserMetaRepository({InMemoryStore? store})
    : _store = store ?? InMemoryStore.instance;

  final InMemoryStore _store;

  /// Returns the existing metadata or initializes defaults.
  Future<UserMeta> getOrCreate({String? profileId}) async {
    final id = _store.ensureActiveProfile(profileId: profileId);
    return _store.profileMeta(id);
  }

  /// Persists the provided metadata snapshot.
  Future<void> save(UserMeta meta) async {
    final id = _store.ensureActiveProfile();
    _store.upsertProfile(id, meta);
    await _store.persist();
  }

  Future<List<String>> listProfileIds() async => _store.profileIds;

  Future<void> switchProfile(String profileId) async {
    _store.ensureActiveProfile(profileId: profileId);
    await _store.persist();
  }

  Future<void> deleteProfile(String profileId) async {
    _store.deleteProfile(profileId);
    await _store.persist();
  }
}
