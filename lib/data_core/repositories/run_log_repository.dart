// ignore_for_file: public_member_api_docs

import 'package:isar/isar.dart';

import 'package:palabra/data_core/models/run_log.dart';

class RunLogRepository {
  RunLogRepository(this._isar);

  final Isar _isar;

  Future<int> add(RunLog runLog) async {
    return _isar.writeTxn(() async {
      return _isar.runLogs.put(runLog);
    });
  }
}
