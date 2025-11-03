import 'package:palabra/data_core/in_memory_store.dart';
import 'package:palabra/data_core/models/user_item_state.dart';

/// Access layer for user item state persistence.
class UserProgressRepository {
  /// Creates the repository using the provided or default store instance.
  UserProgressRepository({InMemoryStore? store})
    : _store = store ?? InMemoryStore.instance;

  final InMemoryStore _store;

  /// Returns stored progress states for the provided item IDs.
  Future<List<UserItemState>> getStates(Iterable<String> itemIds) async {
    final store = _store.userStates;
    return itemIds
        .map((id) => store[id])
        .whereType<UserItemState>()
        .toList(growable: false);
  }

  /// Writes the provided states and persists the store snapshot.
  Future<void> upsertStates(List<UserItemState> states) async {
    for (final state in states) {
      _store.userStates[state.itemId] = state;
    }
    await _store.persist();
  }

  /// Returns the stored state for a single item, if any.
  Future<UserItemState?> getState(String itemId) async {
    return _store.userStates[itemId];
  }
}
