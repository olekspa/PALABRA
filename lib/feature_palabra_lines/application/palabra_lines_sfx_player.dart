import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';

/// Plays Palabra Lines-specific sound effects.
class PalabraLinesSfxPlayer {
  PalabraLinesSfxPlayer({Random? random})
    : _movePlayer = AudioPlayer(),
      _trailPlayer = AudioPlayer(),
      _linePlayer = AudioPlayer(),
      _largeLinePlayer = AudioPlayer(),
      _invalidPlayer = AudioPlayer(),
      _random = random ?? Random();

  static const String _moveAssetA = 'assets/audio/sfx/bubble_move1.wav';
  static const String _moveAssetB = 'assets/audio/sfx/bubble_move2.wav';
  static const String _lineAsset =
      'assets/audio/sfx/lines98_line_completion.wav';
  static const String _largeLineAsset =
      'assets/audio/sfx/lines98_score_large_line.wav';
  static const String _invalidAsset =
      'assets/audio/sfx/lines98_incorrect_move.wav';

  final AudioPlayer _movePlayer;
  final AudioPlayer _trailPlayer;
  final AudioPlayer _linePlayer;
  final AudioPlayer _largeLinePlayer;
  final AudioPlayer _invalidPlayer;
  final Random _random;

  String? _activeMoveAsset;
  bool _lineLoaded = false;
  bool _largeLineLoaded = false;
  bool _invalidLoaded = false;
  bool _trailLoaded = false;

  Future<void> playBubbleMove() {
    final asset = _random.nextBool() ? _moveAssetA : _moveAssetB;
    return _playAsset(
      player: _movePlayer,
      assetPath: asset,
      activeAsset: () => _activeMoveAsset,
      markActive: (value) => _activeMoveAsset = value,
      volume: 0.8,
    );
  }

  Future<void> playLineClear() {
    return _playAsset(
      player: _linePlayer,
      assetPath: _lineAsset,
      loadedFlag: () => _lineLoaded,
      markLoaded: () => _lineLoaded = true,
      markStale: () => _lineLoaded = false,
      volume: 0.9,
    );
  }

  Future<void> playLargeLineClear() {
    return _playAsset(
      player: _largeLinePlayer,
      assetPath: _largeLineAsset,
      loadedFlag: () => _largeLineLoaded,
      markLoaded: () => _largeLineLoaded = true,
      markStale: () => _largeLineLoaded = false,
    );
  }

  Future<void> playInvalidMove() {
    return _playAsset(
      player: _invalidPlayer,
      assetPath: _invalidAsset,
      loadedFlag: () => _invalidLoaded,
      markLoaded: () => _invalidLoaded = true,
      markStale: () => _invalidLoaded = false,
    );
  }

  Future<void> playTrailStep() {
    final asset = _random.nextBool() ? _moveAssetA : _moveAssetB;
    return _playAsset(
      player: _trailPlayer,
      assetPath: asset,
      loadedFlag: () => _trailLoaded,
      markLoaded: () => _trailLoaded = true,
      markStale: () => _trailLoaded = false,
      volume: 0.35,
      speed: 1.15,
    );
  }

  Future<void> dispose() async {
    await Future.wait<void>([
      _movePlayer.dispose(),
      _trailPlayer.dispose(),
      _linePlayer.dispose(),
      _largeLinePlayer.dispose(),
      _invalidPlayer.dispose(),
    ]);
  }

  Future<void> _playAsset({
    required AudioPlayer player,
    required String assetPath,
    bool Function()? loadedFlag,
    VoidCallback? markLoaded,
    VoidCallback? markStale,
    String? Function()? activeAsset,
    void Function(String?)? markActive,
    double volume = 1.0,
    double speed = 1.0,
  }) async {
    try {
      if (activeAsset != null && markActive != null) {
        if (activeAsset() != assetPath) {
          await player.setAsset(assetPath);
          markActive(assetPath);
        } else {
          await player.seek(Duration.zero);
        }
      } else {
        if (!(loadedFlag?.call() ?? false)) {
          await player.setAsset(assetPath);
          markLoaded?.call();
        } else {
          await player.seek(Duration.zero);
        }
      }
      await player.setVolume(volume.clamp(0, 1));
      await player.setSpeed(speed.clamp(0.5, 2.0));
      await player.play();
    } on Object {
      markStale?.call();
      markActive?.call(null);
    }
  }
}
