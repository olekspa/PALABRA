// ignore_for_file: public_member_api_docs

import 'package:flutter_riverpod/flutter_riverpod.dart';

class RunSettings {
  const RunSettings({
    this.rows = 5,
    this.targetMatches = 90,
    this.runDurationMs = 105000,
    this.timeExtendDurationMs = 60000,
    this.maxTimeExtendsPerRun = 2,
    this.refillBatchSize = 3,
  });

  final int rows;
  final int targetMatches;
  final int runDurationMs;
  final int timeExtendDurationMs;
  final int maxTimeExtendsPerRun;
  final int refillBatchSize;
}

/// Tracks the active board row count (Row Blaster toggles this to four).
final runRowsProvider = StateProvider<int>((ref) => const RunSettings().rows);

final runSettingsProvider = Provider<RunSettings>((ref) {
  final rows = ref.watch(runRowsProvider);
  return RunSettings(rows: rows);
});
