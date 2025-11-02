import 'package:isar/isar.dart';

import 'package:palabra/data_core/models/user_meta.dart';

/// Repository for persisting and retrieving [UserMeta].
class UserMetaRepository {
  /// Creates a [UserMetaRepository] backed by the provided [Isar] instance.
  UserMetaRepository(this._isar);

  final Isar _isar;

  /// Fetches the singleton [UserMeta], creating a default row if missing.
  /// Returns the singleton [UserMeta] row, creating a default record if absent.
  Future<UserMeta> getOrCreate() async {
    final existing = await _isar.userMetas.where().findFirst();
    if (existing != null) {
      return existing;
    }

    final meta = UserMeta();
    await _isar.writeTxn(() async {
      await _isar.userMetas.put(meta);
    });
    return meta;
  }

  /// Persists changes to [meta].
  /// Persists the supplied [meta] instance.
  Future<void> save(UserMeta meta) async {
    await _isar.writeTxn(() async {
      await _isar.userMetas.put(meta);
    });
  }
}
