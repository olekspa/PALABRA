import '../in_memory_store.dart';
import '../models/user_item_state.dart';

class UserProgressRepository {
  UserProgressRepository({InMemoryStore? store})
    : _store = store ?? InMemoryStore.instance;

  final InMemoryStore _store;

  Future<List<UserItemState>> getStates(Iterable<String> itemIds) async {
    final store = _store.userStates;
    return itemIds
        .map((id) => store[id])
        .whereType<UserItemState>()
        .toList(growable: false);
  }

  Future<void> upsertStates(List<UserItemState> states) async {
    for (final state in states) {
      _store.userStates[state.itemId] = state;
    }
  }

  Future<UserItemState?> getState(String itemId) async {
    return _store.userStates[itemId];
  }
}
