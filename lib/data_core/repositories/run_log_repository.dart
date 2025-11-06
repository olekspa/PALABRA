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
    final id = _store.ensureActiveProfile();
    final logs = _store.runLogsFor(id);
    logs.insert(0, runLog);
    await _store.persist();
    return logs.length;
  }

  /// Returns the most recent run log if one exists.
  Future<RunLog?> latest() async {
    final id = _store.ensureActiveProfile();
    final logs = _store.runLogsFor(id);
    if (logs.isEmpty) {
      return null;
    }
    return logs.first;
  }
}
