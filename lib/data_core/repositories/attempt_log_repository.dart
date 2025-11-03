import 'package:palabra/data_core/in_memory_store.dart';
import 'package:palabra/data_core/models/attempt_log.dart';

/// Persists attempt log entries into the shared in-memory store.
class AttemptLogRepository {
  /// Creates the repository using the provided or default store instance.
  AttemptLogRepository({InMemoryStore? store})
    : _store = store ?? InMemoryStore.instance;

  final InMemoryStore _store;

  /// Appends attempt logs and persists the snapshot.
  Future<void> addAll(List<AttemptLog> attempts) async {
    _store.attemptLogs.addAll(attempts);
    await _store.persist();
  }
}
