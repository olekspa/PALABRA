// ignore_for_file: public_member_api_docs

import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:palabra/data_core/db/app_database.dart';
import 'package:palabra/data_core/repositories/attempt_log_repository.dart';
import 'package:palabra/data_core/repositories/run_log_repository.dart';
import 'package:palabra/data_core/repositories/user_meta_repository.dart';
import 'package:palabra/data_core/repositories/user_progress_repository.dart';
import 'package:palabra/data_core/repositories/vocab_repository.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

/// Provides the on-device directory used for Isar persistence.
final databaseDirectoryProvider = FutureProvider<Directory>((ref) async {
  final supportDir = await getApplicationSupportDirectory();
  final dbDir = Directory(path.join(supportDir.path, 'isar'));
  if (!dbDir.existsSync()) {
    await dbDir.create(recursive: true);
  }
  return dbDir;
});

/// Lazily opens the Isar database and keeps it alive for the app lifetime.
final appDatabaseProvider = FutureProvider<AppDatabase>((ref) async {
  final directory = await ref.watch(databaseDirectoryProvider.future);
  final database = await AppDatabase.open(directory);
  ref.onDispose(database.close);
  return database;
});

/// Exposes the raw [Isar] instance once initialization completes.
final isarProvider = Provider<Isar>((ref) {
  final database = ref.watch(appDatabaseProvider).value;
  if (database == null) {
    throw StateError('Isar database is not ready yet.');
  }
  return database.isar;
});

/// Provides access to the vocabulary repository.
final vocabRepositoryProvider = Provider<VocabRepository>((ref) {
  final isar = ref.watch(isarProvider);
  return VocabRepository(isar);
});

/// Provides access to the user item progress repository.
final userProgressRepositoryProvider = Provider<UserProgressRepository>((ref) {
  final isar = ref.watch(isarProvider);
  return UserProgressRepository(isar);
});

/// Provides access to the user meta repository.
final userMetaRepositoryProvider = Provider<UserMetaRepository>((ref) {
  final isar = ref.watch(isarProvider);
  return UserMetaRepository(isar);
});

final runLogRepositoryProvider = Provider<RunLogRepository>((ref) {
  final isar = ref.watch(isarProvider);
  return RunLogRepository(isar);
});

final attemptLogRepositoryProvider = Provider<AttemptLogRepository>((ref) {
  final isar = ref.watch(isarProvider);
  return AttemptLogRepository(isar);
});
