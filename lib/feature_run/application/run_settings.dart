// These settings objects intentionally skip doc comments while gameplay is in flux.
// ignore_for_file: public_member_api_docs

import 'package:flutter_riverpod/flutter_riverpod.dart';

class RunSettings {
  const RunSettings({
    this.rows = 5,
    this.targetMatches = 50,
    this.runDurationMs = 60000,
    this.timeExtendDurationMs = 60000,
    this.maxTimeExtendsPerRun = 2,
    this.refillBatchSize = 3,
    this.refillStepDelayMs = 150,
    this.mismatchPenaltyMs = 1000,
    this.tierOneThreshold = 12,
    this.tierTwoThreshold = 30,
  });

  final int rows;
  final int targetMatches;
  final int runDurationMs;
  final int timeExtendDurationMs;
  final int maxTimeExtendsPerRun;
  final int refillBatchSize;
  final int refillStepDelayMs;
  final int mismatchPenaltyMs;
  final int tierOneThreshold;
  final int tierTwoThreshold;
}

/// Tracks the active board row count (Row Blaster toggles this to four).
final runRowsProvider = StateProvider<int>((ref) => const RunSettings().rows);

final runSettingsProvider = Provider<RunSettings>((ref) {
  final rows = ref.watch(runRowsProvider);
  return RunSettings(rows: rows);
});
