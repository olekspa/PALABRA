import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Compile-time feature switches used to evaluate gate access.
class GateFeatureFlags {
  const GateFeatureFlags({
    required this.allowWebBeta,
    required this.allowDebugDeviceOverride,
    this.forceCourseId,
  });

  final bool allowWebBeta;
  final bool allowDebugDeviceOverride;
  final String? forceCourseId;
}

/// Result of evaluating a single gate check (device or course).
class GateCheckStatus {
  const GateCheckStatus({
    required this.value,
    required this.allowed,
    this.overrideApplied = false,
  });

  final String value;
  final bool allowed;
  final bool overrideApplied;
}

/// Aggregated gate status for both device and course checks.
class GateAccessStatus {
  const GateAccessStatus({
    required this.device,
    required this.course,
  });

  final GateCheckStatus device;
  final GateCheckStatus course;

  bool get canProceed => device.allowed && course.allowed;
}

const bool _allowWebBetaFlag =
    bool.fromEnvironment('PALABRA_ALLOW_WEB_BETA', defaultValue: true);
const bool _allowDebugDeviceOverrideFlag =
    bool.fromEnvironment('PALABRA_ALLOW_DEBUG_DEVICE', defaultValue: true);
const String _forcedCourseFlag =
    String.fromEnvironment('PALABRA_FORCE_COURSE', defaultValue: '');
const String _detectedCourseFlag =
    String.fromEnvironment('PALABRA_CURRENT_COURSE', defaultValue: '');
const String _requiredCourseFlag =
    String.fromEnvironment('PALABRA_REQUIRED_COURSE', defaultValue: 'spanish');

/// Provides the active feature flags for the gate.
final gateFeatureFlagsProvider = Provider<GateFeatureFlags>((ref) {
  return GateFeatureFlags(
    allowWebBeta: _allowWebBetaFlag,
    allowDebugDeviceOverride: _allowDebugDeviceOverrideFlag,
    forceCourseId: _normalizeId(_forcedCourseFlag),
  );
});

/// Provides the detected course identifier from the host platform, if any.
final gateDetectedCourseProvider = Provider<String?>((ref) {
  return _normalizeId(_detectedCourseFlag);
});

/// Provides the course identifier required for access.
final gateRequiredCourseProvider = Provider<String>((ref) {
  return _normalizeId(_requiredCourseFlag) ?? 'spanish';
});

/// Evaluates the device and course gate checks using feature flags.
final gateAccessProvider = Provider<GateAccessStatus>((ref) {
  final flags = ref.watch(gateFeatureFlagsProvider);
  final detectedCourseId = ref.watch(gateDetectedCourseProvider);
  final requiredCourseId = ref.watch(gateRequiredCourseProvider);

  final isIos = defaultTargetPlatform == TargetPlatform.iOS;
  final isWeb = kIsWeb;
  final allowsWeb = flags.allowWebBeta && isWeb;
  final allowsDebug = flags.allowDebugDeviceOverride && kDebugMode;

  final deviceAllowed = isIos || allowsWeb || allowsDebug;
  final deviceOverrideApplied = !isIos && (allowsWeb || allowsDebug);
  final deviceValue = _describeDevice(
    isIos: isIos,
    isWeb: isWeb,
    allowsWeb: allowsWeb,
    allowsDebug: allowsDebug,
  );

  final forcedCourseId = flags.forceCourseId;
  final effectiveCourseId = forcedCourseId ?? detectedCourseId;
  final normalizedCourseId = effectiveCourseId?.toLowerCase();
  final hasCourse =
      normalizedCourseId != null && normalizedCourseId.isNotEmpty;
  final debugCourseOverride = !hasCourse && allowsDebug;
  final courseOverrideApplied = forcedCourseId != null || debugCourseOverride;
  final courseAllowed = debugCourseOverride ||
      (hasCourse && normalizedCourseId == requiredCourseId);
  final courseValue = debugCourseOverride
      ? 'Debug override active'
      : _describeCourse(
          courseId: effectiveCourseId,
          requiredCourseId: requiredCourseId,
          overrideApplied: forcedCourseId != null,
        );

  return GateAccessStatus(
    device: GateCheckStatus(
      value: deviceValue,
      allowed: deviceAllowed,
      overrideApplied: deviceOverrideApplied,
    ),
    course: GateCheckStatus(
      value: courseValue,
      allowed: courseAllowed,
      overrideApplied: courseOverrideApplied && courseAllowed,
    ),
  );
});

String _describeDevice({
  required bool isIos,
  required bool isWeb,
  required bool allowsWeb,
  required bool allowsDebug,
}) {
  if (isIos) {
    return 'iPhone detected';
  }
  if (isWeb) {
    return allowsWeb ? 'Web beta enabled' : 'Web not supported';
  }
  if (allowsDebug) {
    return 'Debug override active';
  }
  final platformLabel = describeEnum(defaultTargetPlatform).toUpperCase();
  return '$platformLabel not supported';
}

String _describeCourse({
  required String? courseId,
  required String requiredCourseId,
  required bool overrideApplied,
}) {
  if (courseId == null || courseId.isEmpty) {
    return 'Course unavailable';
  }
  final formatted = _formatCourse(courseId);
  if (courseId == requiredCourseId) {
    return overrideApplied
        ? '$formatted course (override)'
        : '$formatted course confirmed';
  }
  return 'Detected $formatted (unsupported)';
}

String _formatCourse(String value) {
  if (value.isEmpty) {
    return 'Unknown';
  }
  final segments = value.split(RegExp('[_\\-]')).where((s) => s.isNotEmpty);
  return segments
      .map(
        (segment) =>
            segment.substring(0, 1).toUpperCase() + segment.substring(1),
      )
      .join(' ');
}

String? _normalizeId(String value) {
  final trimmed = value.trim().toLowerCase();
  return trimmed.isEmpty ? null : trimmed;
}
