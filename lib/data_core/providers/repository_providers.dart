import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../in_memory_store.dart';
import '../repositories/attempt_log_repository.dart';
import '../repositories/run_log_repository.dart';
import '../repositories/user_meta_repository.dart';
import '../repositories/user_progress_repository.dart';
import '../repositories/vocab_repository.dart';

final inMemoryStoreProvider = Provider<InMemoryStore>((ref) {
  return InMemoryStore.instance;
});

final vocabRepositoryProvider = Provider<VocabRepository>((ref) {
  final store = ref.watch(inMemoryStoreProvider);
  return VocabRepository(store: store);
});

final userProgressRepositoryProvider = Provider<UserProgressRepository>((ref) {
  final store = ref.watch(inMemoryStoreProvider);
  return UserProgressRepository(store: store);
});

final userMetaRepositoryProvider = Provider<UserMetaRepository>((ref) {
  final store = ref.watch(inMemoryStoreProvider);
  return UserMetaRepository(store: store);
});

final runLogRepositoryProvider = Provider<RunLogRepository>((ref) {
  final store = ref.watch(inMemoryStoreProvider);
  return RunLogRepository(store: store);
});

final attemptLogRepositoryProvider = Provider<AttemptLogRepository>((ref) {
  final store = ref.watch(inMemoryStoreProvider);
  return AttemptLogRepository(store: store);
});
