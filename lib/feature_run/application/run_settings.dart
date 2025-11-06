// These settings objects intentionally skip doc comments while gameplay is in flux.
// ignore_for_file: public_member_api_docs

import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:palabra/data_core/models/level_progress.dart';

class RunSettings {
  const RunSettings({
    this.rows = 5,
    this.targetMatches = 50,
    this.minTargetMatches = 15,
    this.runDurationMs = 60000,
    this.timeExtendDurationMs = 60000,
    this.maxTimeExtendsPerRun = 2,
    this.refillBatchSize = 3,
    this.refillStepDelayMs = 320,
    this.mismatchPenaltyMs = 1000,
    this.tierOneThreshold = 12,
    this.tierTwoThreshold = 30,
    this.baseMatchXp = 10,
    this.streakBonusTable = const {3: 5, 6: 10, 9: 15},
    this.powerupXpThresholds = const {'timeExtend': 120, 'rowBlaster': 600},
    this.cleanRunRewardPowerup = 'timeExtend',
    this.matchesToLearn = 3,
  });

  final int rows;
  final int targetMatches;
  final int minTargetMatches;
  final int runDurationMs;
  final int timeExtendDurationMs;
  final int maxTimeExtendsPerRun;
  final int refillBatchSize;
  final int refillStepDelayMs;
  final int mismatchPenaltyMs;
  final int tierOneThreshold;
  final int tierTwoThreshold;
  final int baseMatchXp;
  final Map<int, int> streakBonusTable;
  final Map<String, int> powerupXpThresholds;
  final String cleanRunRewardPowerup;
  final int matchesToLearn;

  int targetForProgress(LevelProgress? progress) {
    final minTarget = minTargetMatches;
    final maxTarget = targetMatches;
    if (progress == null || progress.totalMatches <= 0) {
      return minTarget;
    }
    final mastered = progress.matchesCleared.clamp(0, progress.totalMatches);
    final ratio = progress.totalMatches == 0
        ? 0.0
        : mastered / progress.totalMatches;
    final span = max(0, maxTarget - minTarget);
    final interpolated = (minTarget + span * ratio).round();
    return interpolated.clamp(minTarget, maxTarget);
  }
}

/// Tracks the active board row count (Row Blaster toggles this to four).
final runRowsProvider = StateProvider<int>((ref) => const RunSettings().rows);

final runSettingsProvider = Provider<RunSettings>((ref) {
  final rows = ref.watch(runRowsProvider);
  return RunSettings(rows: rows);
});
