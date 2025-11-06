import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';

import 'package:palabra/feature_numbers/models/number_drill_models.dart';
import 'package:palabra/feature_run/application/tts/run_tts_service.dart'
    as run_tts
    show RunTtsPlaybackOutcome, RunTtsService, runTtsServiceProvider;

/// Provides a reusable [AudioPlayer] scoped to the number drill lifecycle.
final _numberAudioPlayerProvider = Provider<AudioPlayer>((ref) {
  final player = AudioPlayer();
  ref.onDispose(player.dispose);
  return player;
});

/// Exposes the shared [NumberAudioService] for the drill mini-game.
final numberAudioServiceProvider = Provider<NumberAudioService>((ref) {
  final player = ref.watch(_numberAudioPlayerProvider);
  final tts = ref.watch(run_tts.runTtsServiceProvider);
  final service = NumberAudioService(
    audioPlayer: player,
    ttsService: tts,
    config: const NumberDrillConfig(),
  );
  ref.onDispose(service.dispose);
  return service;
});

/// Plays number pronunciations from cached assets with TTS fallback.
class NumberAudioService {
  NumberAudioService({
    required AudioPlayer audioPlayer,
    required run_tts.RunTtsService ttsService,
    NumberDrillConfig config = const NumberDrillConfig(),
  }) : _audioPlayer = audioPlayer,
       _ttsService = ttsService,
       _config = config;

  final AudioPlayer _audioPlayer;
  final run_tts.RunTtsService _ttsService;
  final NumberDrillConfig _config;
  final Map<String, bool> _assetAvailability = <String, bool>{};

  /// Plays the clip for [value], preferring the bundled MP3 asset.
  Future<bool> play(int value) async {
    final assetPath = _config.assetFor(value);
    final assetAllowed = _assetAvailability[assetPath] ?? true;
    if (assetAllowed) {
      final success = await _playAsset(assetPath);
      if (success) {
        return true;
      }
      _assetAvailability[assetPath] = false;
    }
    return _playTtsFallback(value);
  }

  /// Stops any active playback.
  Future<void> stop() async {
    await _audioPlayer.stop();
  }

  void dispose() {
    // Intentionally left blank; player disposed by provider.
  }

  Future<bool> _playAsset(String assetPath) async {
    try {
      await _audioPlayer.stop();
      await _audioPlayer.setAsset(assetPath);
      await _audioPlayer.play();
      _assetAvailability[assetPath] = true;
      return true;
    } on Object {
      return false;
    }
  }

  Future<bool> _playTtsFallback(int value) async {
    if (!_ttsService.isSupported) {
      return false;
    }
    final outcome = await _ttsService.speak(
      text: value.toString(),
      itemId: 'num_$value',
    );
    switch (outcome) {
      case run_tts.RunTtsPlaybackOutcome.success:
      case run_tts.RunTtsPlaybackOutcome.fallbackVoice:
      case run_tts.RunTtsPlaybackOutcome.audioAsset:
      case run_tts.RunTtsPlaybackOutcome.queued:
        return true;
      default:
        return false;
    }
  }
}
