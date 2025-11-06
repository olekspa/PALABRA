import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:palabra/feature_gate/application/gate_access.dart';
import 'package:palabra/feature_gate/application/gate_detection_service.dart';
import 'package:palabra/feature_gate/application/gate_detection_service.dart';
import 'package:palabra/feature_gate/presentation/gate_screen.dart';

void main() {
  Widget _buildHarness({
    required GateDetectionResult detection,
    GateFeatureFlags? flags,
    String requiredCourse = 'spanish',
  }) {
    return ProviderScope(
      overrides: [
        gateFeatureFlagsProvider.overrideWithValue(
          flags ??
              const GateFeatureFlags(
                allowWebBeta: true,
                allowDebugDeviceOverride: true,
              ),
        ),
        gateRequiredCourseProvider.overrideWithValue(requiredCourse),
        gateDetectionServiceProvider.overrideWithValue(
          _FakeGateDetectionService(result: detection),
        ),
      ],
      child: const MaterialApp(
        home: GateScreen(),
      ),
    );
  }

  group('GateScreen', () {
    testWidgets('enables Continue button when access is granted',
        (WidgetTester tester) async {
      final detection = GateDetectionResult(
        deviceLabel: 'iPhone 15',
        isSupportedDevice: true,
        courseId: 'spanish',
      );

      await tester.pumpWidget(_buildHarness(detection: detection));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      final continueFinder = find.widgetWithText(ElevatedButton, 'Continue');
      expect(continueFinder, findsOneWidget);

      final button = tester.widget<ElevatedButton>(continueFinder);
      expect(button.onPressed, isNotNull);
    });

    testWidgets('shows locked message when access is denied',
        (WidgetTester tester) async {
      final detection = GateDetectionResult(
        deviceLabel: 'Android Emulator',
        isSupportedDevice: false,
        courseId: null,
      );

      await tester.pumpWidget(
        _buildHarness(
          detection: detection,
          requiredCourse: 'spanish',
          flags: const GateFeatureFlags(
            allowWebBeta: false,
            allowDebugDeviceOverride: false,
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      final continueFinder = find.widgetWithText(ElevatedButton, 'Continue');
      expect(continueFinder, findsOneWidget);

      final button = tester.widget<ElevatedButton>(continueFinder);
      expect(button.onPressed, isNull);

      expect(
        find.textContaining('Palabra is currently limited to'),
        findsOneWidget,
      );
    });
  });
}

class _FakeGateDetectionService extends GateDetectionService {
  _FakeGateDetectionService({required this.result});

  final GateDetectionResult result;

  @override
  Future<GateDetectionResult> detect() async => result;
}
