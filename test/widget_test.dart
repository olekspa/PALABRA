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
import 'package:palabra/feature_run/application/run_settings.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('App boots to the gate screen', (WidgetTester tester) async {
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
    expect(find.text('Choose your profile'), findsOneWidget);
    if (find.text('Create new profile').evaluate().isNotEmpty) {
      await tester.tap(find.text('Create new profile'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'QA Tester');
      await tester.tap(find.text('Create'));
      await tester.pumpAndSettle();
    } else {
      await tester.tap(find.byType(ListTile).first);
      await tester.pumpAndSettle();
    }

    const runSettings = RunSettings();
    final runDuration = Duration(milliseconds: runSettings.runDurationMs);
    final minutes = runDuration.inMinutes;
    final seconds = (runDuration.inSeconds % 60).toString().padLeft(2, '0');
    final expectedObjective =
        "Make ${runSettings.minTargetMatches} correct matches in $minutes:$seconds.";

    expect(find.text('Palabra'), findsOneWidget);
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
