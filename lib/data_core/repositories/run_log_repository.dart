import 'package:palabra/data_core/in_memory_store.dart';
import 'package:palabra/data_core/models/run_log.dart';

/// Handles persistence for run log summaries.
class RunLogRepository {
  /// Creates the repository using the provided or default store instance.
  RunLogRepository({InMemoryStore? store})
    : _store = store ?? InMemoryStore.instance;

  final InMemoryStore _store;

  /// Inserts a new run log at the head of the history and persists it.
  Future<int> add(RunLog runLog) async {
    _store.runLogs.insert(0, runLog);
    await _store.persist();
    return _store.runLogs.length;
  }

  /// Returns the most recent run log if one exists.
  Future<RunLog?> latest() async {
    if (_store.runLogs.isEmpty) {
      return null;
    }
    return _store.runLogs.first;
  }
}
