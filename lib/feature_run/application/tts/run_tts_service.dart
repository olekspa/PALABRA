import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:palabra/feature_run/application/tts/run_tts_service_stub.dart'
    if (dart.library.html) 'package:palabra/feature_run/application/tts/run_tts_service_web.dart'
    as impl;

/// Result of attempting to play speech for a requested utterance.
enum RunTtsPlaybackOutcome {
  /// Speech succeeded with the preferred voice.
  success,

  /// Speech succeeded after switching to a fallback voice.
  fallbackVoice,

  /// Speech succeeded by playing a pre-recorded audio asset.
  audioAsset,

  /// Request was ignored due to debounce handling.
  debounced,

  /// No playback could be produced; the caller should surface a toast.
  unavailable,

  /// The request was queued while initialization completes.
  queued,
}

/// Abstraction for the run experience text-to-speech service.
abstract class RunTtsService {
  /// Whether the underlying platform supports the implementation.
  bool get isSupported;

  /// Marks an explicit user gesture (tap/click) to satisfy autoplay policies.
  Future<void> onUserGesture();

  /// Speaks the provided [text] if possible.
  Future<RunTtsPlaybackOutcome> speak({
    required String text,
    String? itemId,
  });

  /// Cancels any in-flight utterance.
  Future<void> cancel();

  /// Releases any platform resources.
  void dispose();
}

/// Provider wiring for the run text-to-speech service.
final runTtsServiceProvider = Provider<RunTtsService>((ref) {
  final service = impl.createRunTtsService(ref);
  ref.onDispose(service.dispose);
  return service;
});

/// Exposes whether web speech APIs are available this session.
final runTtsSupportedProvider = Provider<bool>((ref) {
  final service = ref.watch(runTtsServiceProvider);
  return kIsWeb && service.isSupported;
});
