// ignore_for_file: public_member_api_docs

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:palabra/feature_run/application/run_state.dart';

/// Lightweight helper for playing run-specific sound effects.
class RunSfxPlayer {
  RunSfxPlayer()
      : _celebrationPlayer = AudioPlayer(),
        _mismatchPlayer = AudioPlayer(),
        _confettiPlayer = AudioPlayer();

  static const String _celebrationAsset = 'assets/audio/sfx/match_success.wav';
  static const String _mismatchAsset = 'assets/audio/sfx/match_error.wav';

  final AudioPlayer _celebrationPlayer;
  final AudioPlayer _mismatchPlayer;
  final AudioPlayer _confettiPlayer;

  bool _celebrationLoaded = false;
  bool _mismatchLoaded = false;
  bool _confettiLoaded = false;

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

  Future<void> playConfettiTone(ConfettiTone tone) async {
    final (speed, volume) = switch (tone) {
      ConfettiTone.streak => (1.2, 0.65),
      ConfettiTone.tier => (1.0, 0.9),
      ConfettiTone.finishWin => (0.92, 1.0),
      ConfettiTone.finishFail => (0.85, 0.5),
    };
    await _play(
      player: _confettiPlayer,
      assetPath: _celebrationAsset,
      loadedFlag: () => _confettiLoaded,
      markLoaded: () => _confettiLoaded = true,
      markStale: () => _confettiLoaded = false,
      speed: speed,
      volume: volume,
    );
  }

  Future<void> dispose() async {
    await Future.wait<void>([
      _celebrationPlayer.dispose(),
      _mismatchPlayer.dispose(),
      _confettiPlayer.dispose(),
    ]);
  }

  Future<void> _play({
    required AudioPlayer player,
    required String assetPath,
    required bool Function() loadedFlag,
    required VoidCallback markLoaded,
    required VoidCallback markStale,
    double speed = 1.0,
    double volume = 1.0,
  }) async {
    try {
      if (!loadedFlag()) {
        await player.setAsset(assetPath);
        markLoaded();
      } else {
        await player.seek(Duration.zero);
      }
      await player.setVolume(volume.clamp(0.0, 1.0));
      await player.setSpeed(speed.clamp(0.5, 2.0));
      await player.play();
    } on Object {
      markStale();
    }
  }
}
