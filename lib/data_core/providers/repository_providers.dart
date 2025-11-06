import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:palabra/app/app_config.dart';
import 'package:palabra/data_core/in_memory_store.dart';
import 'package:palabra/data_core/repositories/attempt_log_repository.dart';
import 'package:palabra/data_core/repositories/run_log_repository.dart';
import 'package:palabra/data_core/repositories/user_meta_repository.dart';
import 'package:palabra/data_core/repositories/user_progress_repository.dart';
import 'package:palabra/data_core/repositories/vocab_repository.dart';
import 'package:palabra/data_core/remote/profile_api_client.dart';

/// Exposes the shared in-memory store instance.
final inMemoryStoreProvider = Provider<InMemoryStore>((ref) {
  return InMemoryStore.instance;
});

/// Repository wiring for vocabulary access baked into the store.
final vocabRepositoryProvider = Provider<VocabRepository>((ref) {
  final store = ref.watch(inMemoryStoreProvider);
  return VocabRepository(store: store);
});

/// Repository wiring for user progress state transitions.
final userProgressRepositoryProvider = Provider<UserProgressRepository>((ref) {
  final store = ref.watch(inMemoryStoreProvider);
  return UserProgressRepository(store: store);
});

/// Repository wiring for persisted user metadata.
final userMetaRepositoryProvider = Provider<UserMetaRepository>((ref) {
  final store = ref.watch(inMemoryStoreProvider);
  return UserMetaRepository(store: store);
});

/// Repository wiring for recent run summaries.
final runLogRepositoryProvider = Provider<RunLogRepository>((ref) {
  final store = ref.watch(inMemoryStoreProvider);
  return RunLogRepository(store: store);
});

/// Repository wiring for attempt logs generated during runs.
final attemptLogRepositoryProvider = Provider<AttemptLogRepository>((ref) {
  final store = ref.watch(inMemoryStoreProvider);
  return AttemptLogRepository(store: store);
});

final remoteProfileApiProvider = Provider<RemoteProfileApi?>((ref) {
  if (!AppConfig.profileSyncEnabled) {
    return null;
  }
  final api = RemoteProfileApi(
    baseUrl: AppConfig.profileApiBaseUrl,
    apiKey: AppConfig.profileApiKey,
  );
  ref.onDispose(api.dispose);
  return api;
});
