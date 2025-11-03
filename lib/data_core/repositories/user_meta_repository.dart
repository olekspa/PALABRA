import 'package:palabra/data_core/in_memory_store.dart';
import 'package:palabra/data_core/models/user_meta.dart';

/// CRUD helper for prototype user metadata.
class UserMetaRepository {
  /// Creates the repository using the provided or default store instance.
  UserMetaRepository({InMemoryStore? store})
    : _store = store ?? InMemoryStore.instance;

  final InMemoryStore _store;

  /// Returns the existing metadata or initializes defaults.
  Future<UserMeta> getOrCreate() async {
    return _store.userMeta;
  }

  /// Persists the provided metadata snapshot.
  Future<void> save(UserMeta meta) async {
    _store.userMeta = meta;
    await _store.persist();
  }
}
