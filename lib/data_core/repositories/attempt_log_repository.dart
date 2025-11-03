import '../in_memory_store.dart';
import '../models/attempt_log.dart';

class AttemptLogRepository {
  AttemptLogRepository({InMemoryStore? store})
    : _store = store ?? InMemoryStore.instance;

  final InMemoryStore _store;

  Future<void> addAll(List<AttemptLog> attempts) async {
    _store.attemptLogs.addAll(attempts);
  }
}
