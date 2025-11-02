import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:palabra/data_core/data_core.dart';
import 'package:path_provider/path_provider.dart';

/// Handles one-time bootstrapping before the app widget tree is mounted.
Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();
  final supportDir = await getApplicationSupportDirectory();
  final database = await AppDatabase.open(supportDir);

  try {
    final userMetaRepository = UserMetaRepository(database.isar);
    final seedService = VocabularySeedService(
      isar: database.isar,
      assetBundle: rootBundle,
      userMetaRepository: userMetaRepository,
    );
    await seedService.seedIfNeeded();
  } finally {
    await database.close();
  }
}
