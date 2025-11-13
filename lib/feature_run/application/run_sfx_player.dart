import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';

/// Lightweight helper for playing run-specific sound effects.
class RunSfxPlayer {
  RunSfxPlayer()
      : _celebrationPlayer = AudioPlayer(),
        _mismatchPlayer = AudioPlayer();

  static const String _celebrationAsset = 'assets/audio/sfx/match_success.wav';
  static const String _mismatchAsset = 'assets/audio/sfx/match_error.wav';

  final AudioPlayer _celebrationPlayer;
  final AudioPlayer _mismatchPlayer;

  bool _celebrationLoaded = false;
  bool _mismatchLoaded = false;

  Future<void> playCelebration() async {
    await _play(
      player: _celebrationPlayer,
      assetPath: _celebrationAsset,
      loadedFlag: () => _celebrationLoaded,
      markLoaded: () => _celebrationLoaded = true,
      markStale: () => _celebrationLoaded = false,
    );
  }

  Future<void> playMismatch() async {
    await _play(
      player: _mismatchPlayer,
      assetPath: _mismatchAsset,
      loadedFlag: () => _mismatchLoaded,
      markLoaded: () => _mismatchLoaded = true,
      markStale: () => _mismatchLoaded = false,
    );
  }

  Future<void> dispose() async {
    await Future.wait<void>([
      _celebrationPlayer.dispose(),
      _mismatchPlayer.dispose(),
    ]);
  }

  Future<void> _play({
    required AudioPlayer player,
    required String assetPath,
    required bool Function() loadedFlag,
    required VoidCallback markLoaded,
    required VoidCallback markStale,
  }) async {
    try {
      if (!loadedFlag()) {
        await player.setAsset(assetPath);
        markLoaded();
      } else {
        await player.seek(Duration.zero);
      }
      await player.play();
    } on Object {
      markStale();
    }
  }
}
