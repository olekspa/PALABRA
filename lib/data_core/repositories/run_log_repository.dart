import '../in_memory_store.dart';
import '../models/run_log.dart';

class RunLogRepository {
  RunLogRepository({InMemoryStore? store})
    : _store = store ?? InMemoryStore.instance;

  final InMemoryStore _store;

  Future<int> add(RunLog runLog) async {
    _store.runLogs.insert(0, runLog);
    return _store.runLogs.length;
  }

  Future<RunLog?> latest() async {
    if (_store.runLogs.isEmpty) {
      return null;
    }
    return _store.runLogs.first;
  }
}
