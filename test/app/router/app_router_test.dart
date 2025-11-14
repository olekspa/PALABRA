import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:palabra/app/router/app_router.dart';
import 'package:palabra/data_core/models/vocab_item.dart';
import 'package:palabra/feature_palabra_lines/application/palabra_lines_controller.dart';
import 'package:palabra/feature_palabra_lines/application/palabra_lines_providers.dart';
import 'package:palabra/feature_palabra_lines/application/palabra_lines_vocab_service.dart';
import 'package:palabra/feature_palabra_lines/domain/palabra_lines_config.dart';

void main() {
  testWidgets('GoRouter navigates to Palabra Lines screen', (tester) async {
    final binding = TestWidgetsFlutterBinding.ensureInitialized();
    binding.window.physicalSizeTestValue = const Size(1024, 1920);
    binding.window.devicePixelRatioTestValue = 1.0;
    addTearDown(binding.window.clearPhysicalSizeTestValue);
    addTearDown(binding.window.clearDevicePixelRatioTestValue);

    GoRouter? router;
    final controller = PalabraLinesController(
      vocabService: PalabraLinesVocabService.fromItems(
        items: _buildSampleItems(),
        baseLevel: 'a1',
        random: Random(1),
      ),
      random: Random(1),
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[
          palabraLinesControllerProvider.overrideWith((ref) => controller),
        ],
        child: Consumer(
          builder: (context, ref, _) {
            router = ref.watch(goRouterProvider);
            return MaterialApp.router(routerConfig: router);
          },
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 16));
    expect(router, isNotNull);
    router!.go(AppRoute.palabraLines.path);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 16));
    expect(find.text('Palabra Lines'), findsWidgets);
  });
}

List<VocabItem> _buildSampleItems() {
  return List<VocabItem>.generate(
    PalabraLinesConfig.quizOptions,
    (index) => VocabItem(
      itemId: 'a1_$index',
      english: 'english_$index',
      spanish: 'spanish_$index',
      level: 'a1',
    ),
  );
}
