// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:palabra/app/app.dart';
import 'package:palabra/feature_gate/application/gate_detection_service.dart';
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

    expect(find.text('Palabra'), findsOneWidget);
    expect(find.text('Make 90 correct matches in 1:45.'), findsOneWidget);
    expect(find.text('Continue'), findsOneWidget);
  });
}

class _TestGateDetectionService extends GateDetectionService {
  _TestGateDetectionService(this._result);

  final GateDetectionResult _result;

  @override
  Future<GateDetectionResult> detect() async => _result;
}
