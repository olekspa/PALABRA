import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:palabra/data_core/db/database_providers.dart';
import 'package:palabra/data_core/models/user_meta.dart';

/// Loads the singleton [UserMeta] record, creating it on demand.
final userMetaFutureProvider = FutureProvider<UserMeta>((ref) async {
  final repository = ref.watch(userMetaRepositoryProvider);
  return repository.getOrCreate();
});
