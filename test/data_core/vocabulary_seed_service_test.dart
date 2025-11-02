import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:palabra/data_core/data_core.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  var isarAvailable = true;

  setUpAll(() async {
    try {
      await Isar.initializeIsarCore();
    } catch (_) {
      isarAvailable = false;
    }
  });

  Directory? tempDir;
  AppDatabase? database;

  setUp(() async {
    if (!isarAvailable) {
      return;
    }
    tempDir = await Directory.systemTemp.createTemp('palabra_isar_test');
    database = await AppDatabase.open(tempDir!);
  });

  tearDown(() async {
    if (!isarAvailable) {
      return;
    }
    await database?.close();
    final dir = tempDir;
    if (dir != null && dir.existsSync()) {
      await dir.delete(recursive: true);
    }
  });

  test('seeds bundled vocabulary only once', () async {
    if (!isarAvailable) {
      return;
    }

    final db = database!;
    final userMetaRepository = UserMetaRepository(db.isar);
    final seedService = VocabularySeedService(
      isar: db.isar,
      assetBundle: rootBundle,
      userMetaRepository: userMetaRepository,
    );

    await seedService.seedIfNeeded();
    final firstCount = await db.isar.vocabItems.count();
    expect(firstCount, greaterThan(0));

    final meta = await userMetaRepository.getOrCreate();
    expect(meta.hasSeededVocabulary, isTrue);

    await seedService.seedIfNeeded();
    final secondCount = await db.isar.vocabItems.count();
    expect(secondCount, firstCount);
  });
}
