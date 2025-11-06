import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:palabra/data_core/models/number_drill_progress.dart';
import 'package:palabra/feature_numbers/application/number_drill_state.dart';
import 'package:palabra/feature_numbers/models/number_drill_models.dart';
import 'package:palabra/feature_numbers/services/number_audio_service.dart';
import 'package:palabra/feature_numbers/services/number_pool_service.dart';

final numberDrillControllerProvider =
    StateNotifierProvider.autoDispose<NumberDrillController, NumberDrillState>(
      (ref) {
        final pool = ref.watch(numberPoolServiceProvider);
        final audio = ref.watch(numberAudioServiceProvider);
        return NumberDrillController(
          poolService: pool,
          audioService: audio,
        );
      },
    );

class NumberDrillController extends StateNotifier<NumberDrillState> {
  NumberDrillController({
    required NumberPoolService poolService,
    required NumberAudioService audioService,
    NumberDrillConfig config = const NumberDrillConfig(),
  }) : _poolService = poolService,
       _audioService = audioService,
       _config = config,
       super(NumberDrillState.loading(goal: config.roundGoal));

  final NumberPoolService _poolService;
  final NumberAudioService _audioService;
  final NumberDrillConfig _config;

  List<int> _promptQueue = const <int>[];
  int _promptIndex = 0;
  DateTime? _startedAt;
  Timer? _audioDebounce;
  final Map<int, int> _mistakeCounters = <int, int>{};

  Future<void> start({
    required NumberDrillProgress progress,
    required String levelId,
  }) async {
    state = NumberDrillState.loading(goal: _config.roundGoal);
    _promptIndex = 0;
    _mistakeCounters.clear();
    _startedAt = DateTime.now();
    _audioDebounce?.cancel();
    final seed = _poolService.buildSeed(progress: progress, levelId: levelId);
    _promptQueue = seed.promptQueue;
    final active = _promptQueue.first;
    state = NumberDrillState.running(
      gridNumbers: seed.gridNumbers,
      goal: _config.roundGoal,
      activeNumber: active,
    );
    await _playActiveNumber();
  }

  Future<void> repeat() async {
    if (!state.isRunning || state.activeNumber == null) {
      return;
    }
    await _playActiveNumber(force: true);
  }

  Future<void> select(int value) async {
    final current = state;
    if (!current.isRunning || current.activeNumber == null) {
      return;
    }
    if (value != current.activeNumber) {
      _mistakeCounters[value] = (_mistakeCounters[value] ?? 0) + 1;
      state = current.copyWith(mistakes: current.mistakes + 1);
      return;
    }
    final cleared = {...current.clearedNumbers, value};
    final completed = current.completedCount + 1;
    final isDone = completed >= current.goal;
    final nextIndex = _promptIndex + 1;
    _promptIndex = nextIndex;
    final nextActive = isDone || nextIndex >= _promptQueue.length
        ? null
        : _promptQueue[nextIndex];
    state = current.copyWith(
      clearedNumbers: cleared,
      mergeCleared: true,
      completedCount: completed,
      activeNumber: nextActive,
      clearActive: nextActive == null,
    );
    if (isDone) {
      await _complete();
    } else if (nextActive != null) {
      await _playActiveNumber();
    }
  }

  @override
  void dispose() {
    _audioDebounce?.cancel();
    super.dispose();
  }

  Future<void> _playActiveNumber({bool force = false}) async {
    final number = state.activeNumber;
    if (number == null) {
      return;
    }
    if (!force && state.audioBusy) {
      return;
    }
    state = state.copyWith(audioBusy: true);
    _audioDebounce?.cancel();
    _audioDebounce = Timer(const Duration(milliseconds: 120), () {});
    await _audioService.play(number);
    state = state.copyWith(audioBusy: false);
  }

  Future<void> _complete() async {
    await _audioService.stop();
    final elapsed = _startedAt == null
        ? 0
        : DateTime.now().difference(_startedAt!).inMilliseconds;
    state = state.copyWith(
      phase: NumberDrillPhase.completed,
      millisecondsElapsed: elapsed,
      audioBusy: false,
      clearActive: true,
    );
  }

  Map<int, int> get mistakeSummary => Map<int, int>.unmodifiable(
    _mistakeCounters,
  );
}
