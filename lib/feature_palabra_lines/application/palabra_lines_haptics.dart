import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Lightweight haptics used by the Palabra Lines interaction loop.
class PalabraLinesHaptics {
  const PalabraLinesHaptics();

  Future<void> onSelect() => _safe(() => HapticFeedback.selectionClick());

  Future<void> onMoveStart() => _safe(() => HapticFeedback.lightImpact());

  Future<void> onInvalid() => _safe(() => HapticFeedback.mediumImpact());

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
