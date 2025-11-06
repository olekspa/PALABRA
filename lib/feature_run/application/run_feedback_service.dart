import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provides audio and haptic feedback for run milestones.
class RunFeedbackService {
  const RunFeedbackService();

  /// Triggered when the player resolves a correct match.
  Future<void> onMatch({required int tier}) async {
    await Future.wait<void>([
      _safe(() => HapticFeedback.lightImpact()),
      _safe(
        () => SystemSound.play(
          tier >= 3 ? SystemSoundType.alert : SystemSoundType.click,
        ),
      ),
    ]);
  }

  /// Triggered on wrong matches.
  Future<void> onMismatch() async {
    await Future.wait<void>([
      _safe(() => HapticFeedback.mediumImpact()),
      _safe(() => SystemSound.play(SystemSoundType.alert)),
    ]);
  }

  /// Triggered at tier pauses (first or second milestone).
  Future<void> onTierPause({required int tier}) async {
    await Future.wait<void>([
      _safe(
        () => tier >= 2
            ? HapticFeedback.heavyImpact()
            : HapticFeedback.mediumImpact(),
      ),
      _safe(() => SystemSound.play(SystemSoundType.click)),
    ]);
  }

  /// Triggered when the run completes.
  Future<void> onRunComplete({
    required int tierReached,
    required bool success,
  }) {
    if (!success) {
      return _safe(() => HapticFeedback.heavyImpact());
    }
    return Future.wait<void>([
      _safe(() => HapticFeedback.vibrate()),
      _safe(
        () => SystemSound.play(
          tierReached >= 3 ? SystemSoundType.alert : SystemSoundType.click,
        ),
      ),
    ]);
  }

  static Future<void> _safe(Future<void> Function() action) async {
    if (kIsWeb) {
      return;
    }
    try {
      await action();
    } on Object {
      // Ignore unsupported platform or missing bindings.
    }
  }
}

/// Provides a shared instance of [RunFeedbackService] for dependency injection.
final runFeedbackServiceProvider = Provider<RunFeedbackService>((ref) {
  return const RunFeedbackService();
});
