// Developer-tuning utilities intentionally omit docs while the API stabilizes.
// ignore_for_file: public_member_api_docs

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Runtime-configurable voice parameters for the run TTS service.
class RunTtsConfig {
  const RunTtsConfig({
    required this.rate,
    required this.pitch,
  });

  final double rate;
  final double pitch;

  RunTtsConfig copyWith({
    double? rate,
    double? pitch,
  }) {
    return RunTtsConfig(
      rate: rate ?? this.rate,
      pitch: pitch ?? this.pitch,
    );
  }
}

const double kDefaultTtsRate = 0.9;
const double kDefaultTtsPitch = 1.0;

class RunTtsConfigNotifier extends StateNotifier<RunTtsConfig> {
  RunTtsConfigNotifier()
    : super(
        const RunTtsConfig(
          rate: kDefaultTtsRate,
          pitch: kDefaultTtsPitch,
        ),
      );

  void setRate(double value) {
    final clamped = value.clamp(0.5, 1.2).toDouble();
    if ((clamped - state.rate).abs() < 0.0001) {
      return;
    }
    state = state.copyWith(rate: clamped);
  }

  void setPitch(double value) {
    final clamped = value.clamp(0.8, 1.2).toDouble();
    if ((clamped - state.pitch).abs() < 0.0001) {
      return;
    }
    state = state.copyWith(pitch: clamped);
  }
}

/// Session-scoped configuration for tuning TTS rate and pitch.
final runTtsConfigProvider =
    StateNotifierProvider<RunTtsConfigNotifier, RunTtsConfig>(
      (ref) => RunTtsConfigNotifier(),
    );

const bool _enableDevPanelFlag = bool.fromEnvironment(
  'PALABRA_TTS_DEV_PANEL',
  defaultValue: false,
);

/// Whether the developer tuning panel for TTS should be displayed.
final runTtsDevPanelEnabledProvider = Provider<bool>(
  (ref) => _enableDevPanelFlag && kIsWeb,
);

/// Developer-facing label for the currently selected speech voice.
final runTtsVoiceLabelProvider = StateProvider<String?>(
  (ref) => null,
);
