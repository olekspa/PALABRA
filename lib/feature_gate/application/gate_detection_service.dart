import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Result returned by the gate detection service.
class GateDetectionResult {
  GateDetectionResult({
    required this.deviceLabel,
    required this.isSupportedDevice,
    required this.courseId,
  });

  /// Human-readable label describing the detected device.
  final String deviceLabel;

  /// Whether the detected device is considered supported.
  final bool isSupportedDevice;

  /// Course identifier returned by the host platform (lowercased).
  final String? courseId;
}

/// Platform abstraction that retrieves device + course information for gating.
class GateDetectionService {
  const GateDetectionService();

  static const MethodChannel _channel = MethodChannel('palabra/gate_detection');

  /// Detects the current device + course context.
  Future<GateDetectionResult> detect() async {
    if (kIsWeb) {
      return _detectForWeb();
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.iOS:
      case TargetPlatform.android:
        return _detectFromPlatformChannel();
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
      case TargetPlatform.linux:
      case TargetPlatform.fuchsia:
        return _fallbackResult(
          label: describeEnum(defaultTargetPlatform),
          supported: false,
        );
    }
  }

  GateDetectionResult _detectForWeb() {
    // Web beta: allow web clients but rely on env overrides for course gating.
    final envCourse = const String.fromEnvironment('PALABRA_CURRENT_COURSE');
    final course = _normalize(envCourse);
    return GateDetectionResult(
      deviceLabel: 'Web Browser',
      isSupportedDevice: true,
      courseId: course,
    );
  }

  Future<GateDetectionResult> _detectFromPlatformChannel() async {
    try {
      final payload = await _channel.invokeMapMethod<String, dynamic>('detect');
      if (payload != null) {
        final device = payload['device']?.toString() ?? 'Unknown';
        final supported = (payload['supported'] as bool?) ?? false;
        final course = _normalize(payload['course']);
        return GateDetectionResult(
          deviceLabel: device,
          isSupportedDevice: supported,
          courseId: course,
        );
      }
    } on MissingPluginException {
      // Native handler not installed yet – fall back to defaults.
    } on PlatformException {
      // Detection failed – fall back below.
    }

    final label = describeEnum(defaultTargetPlatform);
    return _fallbackResult(label: label, supported: defaultTargetPlatform == TargetPlatform.iOS);
  }

  GateDetectionResult _fallbackResult({
    required String label,
    required bool supported,
  }) {
    final envCourse = const String.fromEnvironment('PALABRA_CURRENT_COURSE');
    return GateDetectionResult(
      deviceLabel: '$label (fallback)',
      isSupportedDevice: supported,
      courseId: _normalize(envCourse),
    );
  }

  String? _normalize(Object? raw) {
    if (raw == null) {
      return null;
    }
    final trimmed = raw.toString().trim().toLowerCase();
    return trimmed.isEmpty ? null : trimmed;
  }
}

/// Exposes the shared detection service (overridable in tests/platforms).
final gateDetectionServiceProvider = Provider<GateDetectionService>((ref) {
  return const GateDetectionService();
});
