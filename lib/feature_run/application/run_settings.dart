// These settings objects intentionally skip doc comments while gameplay is in flux.
// ignore_for_file: public_member_api_docs

import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:palabra/data_core/models/level_progress.dart';

class RunSettings {
  const RunSettings({
    this.rows = 5,
    this.targetMatches = 50,
    this.minTargetMatches = 5,
    this.runDurationMs = 60000,
    this.timeExtendDurationMs = 60000,
    this.maxTimeExtendsPerRun = 2,
    this.refillBatchSize = 3,
    this.refillStepDelayMs = 320,
    this.mismatchPenaltyMs = 1000,
    this.tierOneRatio = 0.3,
    this.tierTwoRatio = 0.65,
    this.baseMatchXp = 10,
    this.streakBonusTable = const {3: 5, 6: 10, 9: 15},
    this.powerupXpThresholds = const {'timeExtend': 120, 'rowBlaster': 600},
    this.cleanRunRewardPowerup = 'timeExtend',
    this.matchesToLearn = 5,
    this.successesPerTargetIncrement = 4,
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
  final double tierOneRatio;
  final double tierTwoRatio;
  final int baseMatchXp;
  final Map<int, int> streakBonusTable;
  final Map<String, int> powerupXpThresholds;
  final String cleanRunRewardPowerup;
  final int matchesToLearn;
  final int successesPerTargetIncrement;

  int targetForProgress(LevelProgress? progress) {
    final minTarget = minTargetMatches;
    final maxTarget = targetMatches;
    final candidate = progress?.targetMatches ?? minTarget;
    final clamped = candidate.clamp(minTarget, maxTarget);
    return clamped is int ? clamped : clamped.round();
  }

  int tierOneThresholdFor(int target) => _scaledThreshold(tierOneRatio, target);

  int tierTwoThresholdFor(int target) => _scaledThreshold(tierTwoRatio, target);

  int _scaledThreshold(double ratio, int target) {
    final clampedRatio = ratio.clamp(0.0, 1.0);
    final scaled = max(1, (target * clampedRatio).round());
    return min(scaled, max(target - 1, 1));
  }
}

/// Tracks the active board row count (Row Blaster toggles this to four).
final runRowsProvider = StateProvider<int>((ref) => const RunSettings().rows);

final runSettingsProvider = Provider<RunSettings>((ref) {
  final rows = ref.watch(runRowsProvider);
  return RunSettings(rows: rows);
});
