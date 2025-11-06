import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:palabra/feature_gate/application/gate_access.dart';
import 'package:palabra/feature_gate/application/gate_detection_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
  });

  tearDown(() {
    debugDefaultTargetPlatformOverride = null;
  });

  test('denies unsupported devices when overrides are disabled', () async {
    final container = ProviderContainer(
      overrides: [
        gateFeatureFlagsProvider.overrideWithValue(
          const GateFeatureFlags(
            allowWebBeta: false,
            allowDebugDeviceOverride: false,
            forceCourseId: null,
          ),
        ),
        gateDetectionServiceProvider.overrideWithValue(
          _FakeGateDetectionService(
            result: GateDetectionResult(
              deviceLabel: 'Android Emulator',
              isSupportedDevice: false,
              courseId: 'spanish',
            ),
          ),
        ),
        gateRequiredCourseProvider.overrideWithValue('spanish'),
      ],
    );
    addTearDown(container.dispose);

    final status = await container.read(gateAccessProvider.future);
    expect(status.device.allowed, isFalse);
    expect(status.course.allowed, isTrue);
    expect(status.device.value, 'Android Emulator');
    expect(status.canProceed, isFalse);
  });

  test('applies forced course override when provided by feature flags', () async {
    final container = ProviderContainer(
      overrides: [
        gateFeatureFlagsProvider.overrideWithValue(
          const GateFeatureFlags(
            allowWebBeta: false,
            allowDebugDeviceOverride: true,
            forceCourseId: 'spanish',
          ),
        ),
        gateDetectionServiceProvider.overrideWithValue(
          _FakeGateDetectionService(
            result: GateDetectionResult(
              deviceLabel: 'iPhone 15',
              isSupportedDevice: true,
              courseId: 'french',
            ),
          ),
        ),
        gateRequiredCourseProvider.overrideWithValue('spanish'),
      ],
    );
    addTearDown(container.dispose);

    final status = await container.read(gateAccessProvider.future);
    expect(status.device.allowed, isTrue);
    expect(status.course.allowed, isTrue);
    expect(status.course.overrideApplied, isTrue);
    expect(status.course.value, 'Spanish course (override)');
    expect(status.canProceed, isTrue);
  });

  test('grants debug course access when detection is unavailable', () async {
    final container = ProviderContainer(
      overrides: [
        gateFeatureFlagsProvider.overrideWithValue(
          const GateFeatureFlags(
            allowWebBeta: false,
            allowDebugDeviceOverride: true,
            forceCourseId: null,
          ),
        ),
        gateDetectionServiceProvider.overrideWithValue(
          _FakeGateDetectionService(
            result: GateDetectionResult(
              deviceLabel: 'Android Dev',
              isSupportedDevice: false,
              courseId: null,
            ),
          ),
        ),
        gateRequiredCourseProvider.overrideWithValue('spanish'),
      ],
    );
    addTearDown(container.dispose);

    final status = await container.read(gateAccessProvider.future);
    expect(status.device.allowed, isTrue);
    expect(status.course.allowed, isTrue);
    expect(status.course.overrideApplied, isTrue);
    expect(status.course.value, 'Debug override active');
    expect(status.device.value.contains('override'), isTrue);
    expect(status.canProceed, isTrue);
  });
}

class _FakeGateDetectionService extends GateDetectionService {
  const _FakeGateDetectionService({required this.result});

  final GateDetectionResult result;

  @override
  Future<GateDetectionResult> detect() async => result;
}
