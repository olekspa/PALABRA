import 'dart:io';

import 'package:isar/isar.dart';
import 'package:palabra/data_core/models/attempt_log.dart';
import 'package:palabra/data_core/models/run_log.dart';
import 'package:palabra/data_core/models/user_item_state.dart';
import 'package:palabra/data_core/models/user_meta.dart';
import 'package:palabra/data_core/models/vocab_item.dart';
import 'package:path/path.dart' as path;

/// Encapsulates the Isar database lifecycle for the app.
class AppDatabase {
  /// Creates an [AppDatabase] that wraps the provided [isar] instance.
  AppDatabase(this.isar);

  /// Active Isar instance.
  final Isar isar;

  /// Opens the database within the provided [directory].
  static Future<AppDatabase> open(Directory directory) async {
    if (!directory.existsSync()) {
      await directory.create(recursive: true);
    }

    final isar = await Isar.open(
      [
        VocabItemSchema,
        UserItemStateSchema,
        UserMetaSchema,
        RunLogSchema,
        AttemptLogSchema,
      ],
      directory: path.normalize(directory.path),
      inspector: false,
    );

    return AppDatabase(isar);
  }

  /// Closes the database connection.
  Future<void> close() async {
    await isar.close();
  }
}
