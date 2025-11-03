import '../in_memory_store.dart';
import '../models/user_meta.dart';

class UserMetaRepository {
  UserMetaRepository({InMemoryStore? store})
    : _store = store ?? InMemoryStore.instance;

  final InMemoryStore _store;

  Future<UserMeta> getOrCreate() async {
    return _store.userMeta;
  }

  Future<void> save(UserMeta meta) async {
    _store.userMeta = meta;
  }
}
