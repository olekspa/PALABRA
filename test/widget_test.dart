// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:palabra/app/app.dart';
import 'package:palabra/feature_gate/application/gate_detection_service.dart';
import 'package:palabra/feature_gate/presentation/gate_screen.dart';
import 'package:palabra/feature_run/application/run_settings.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('App boots to the gate screen', (WidgetTester tester) async {
    final binding = TestWidgetsFlutterBinding.ensureInitialized();
    binding.window.physicalSizeTestValue = const Size(1024, 1920);
    binding.window.devicePixelRatioTestValue = 1.0;
    addTearDown(binding.window.clearPhysicalSizeTestValue);
    addTearDown(binding.window.clearDevicePixelRatioTestValue);

    SharedPreferences.setMockInitialValues(const <String, Object>{});
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          gateDetectionServiceProvider.overrideWithValue(
            _TestGateDetectionService(
              GateDetectionResult(
                deviceLabel: 'Web Browser',
                isSupportedDevice: true,
                courseId: 'spanish',
              ),
            ),
          ),
        ],
        child: const PalabraApp(),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    // Profile selector appears first.
    expect(find.text("Who's playing?"), findsOneWidget);
    if (find.text('Create profile').evaluate().isNotEmpty) {
      await tester.tap(find.text('Create profile'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      await tester.enterText(find.byType(TextField), 'QA Tester');
      await tester.tap(find.text('Create'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
    } else {
      await tester.tap(find.byType(ListTile).first);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
    }

    expect(find.text('Palabra Arcade'), findsOneWidget);
    final wordMatchCard = find.ancestor(
      of: find.text('Palabra Word Match'),
      matching: find.byWidgetPredicate(
        (widget) => widget.runtimeType.toString() == '_GameCard',
      ),
    );
    final wordMatchPlayButton = find.descendant(
      of: wordMatchCard,
      matching: find.widgetWithText(FilledButton, 'Play'),
    );
    await tester.tap(wordMatchPlayButton);
    for (var i = 0; i < 5; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }

    const runSettings = RunSettings();
    final runDuration = Duration(milliseconds: runSettings.runDurationMs);
    final minutes = runDuration.inMinutes;
    final seconds = (runDuration.inSeconds % 60).toString().padLeft(2, '0');
    final expectedObjective =
        "Make ${runSettings.minTargetMatches} correct matches in $minutes:$seconds.";

    expect(find.text('Palabra Word Match'), findsOneWidget);
    expect(find.byType(GateScreen), findsOneWidget);
    expect(find.text(expectedObjective), findsOneWidget);
    expect(find.text('Continue'), findsOneWidget);
  });
}

class _TestGateDetectionService extends GateDetectionService {
  _TestGateDetectionService(this._result);

  final GateDetectionResult _result;

  @override
  Future<GateDetectionResult> detect() async => _result;
}
