import 'package:isar/isar.dart';

import 'package:palabra/data_core/models/user_item_state.dart';

/// Handles persistence of user-level spaced repetition state.
class UserProgressRepository {
  /// Creates a [UserProgressRepository] linked to the provided [_isar]
  /// instance.
  UserProgressRepository(this._isar);

  final Isar _isar;

  /// Fetches state rows for the provided [itemIds].
  Future<List<UserItemState>> getStates(Iterable<String> itemIds) async {
    final ids = itemIds.toSet().toList();
    final records = await _isar.userItemStates.getAllByItemId(ids);
    return records.whereType<UserItemState>().toList();
  }

  /// Saves the supplied [states] set within a single transaction.
  Future<void> upsertStates(List<UserItemState> states) async {
    if (states.isEmpty) {
      return;
    }
    await _isar.writeTxn(() async {
      await _isar.userItemStates.putAll(states);
    });
  }

  /// Retrieves a single row for [itemId], if present.
  Future<UserItemState?> getState(String itemId) {
    return _isar.userItemStates.filter().itemIdEqualTo(itemId).findFirst();
  }
}
