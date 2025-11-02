// ignore_for_file: public_member_api_docs

import 'package:isar/isar.dart';

import 'package:palabra/data_core/models/attempt_log.dart';

class AttemptLogRepository {
  AttemptLogRepository(this._isar);

  final Isar _isar;

  Future<void> addAll(List<AttemptLog> attempts) async {
    if (attempts.isEmpty) {
      return;
    }
    await _isar.writeTxn(() async {
      await _isar.attemptLogs.putAll(attempts);
    });
  }
}
