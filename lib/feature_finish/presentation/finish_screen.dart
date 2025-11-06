import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:palabra/app/router/app_router.dart';
import 'package:palabra/data_core/data_core.dart';
import 'package:palabra/design_system/tokens/color_tokens.dart';
import 'package:palabra/design_system/tokens/spacing_tokens.dart';
import 'package:palabra/design_system/widgets/gradient_background.dart';
import 'package:palabra/feature_run/application/run_settings.dart';

final _latestRunProvider = FutureProvider<RunLog?>((ref) async {
  final repository = ref.watch(runLogRepositoryProvider);
  return repository.latest();
});

/// Finish screen shown after the run completes.
class FinishScreen extends ConsumerWidget {
  /// Creates a [FinishScreen].
  const FinishScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final latestRun = ref.watch(_latestRunProvider);
    return GradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: latestRun.when(
              data: (run) => _FinishSummary(run: run),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, __) => Center(
                child: Text(
                  'Run summary unavailable.',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FinishSummary extends ConsumerWidget {
  const _FinishSummary({required this.run});

  final RunLog? run;

  int get _xpEarned {
    return run?.xpEarned ?? 0;
  }

  String get _headline {
    if (run == null) {
      return 'Run complete';
    }
    if (run!.tierReached >= 3) {
      return 'Goal achieved!';
    }
    return 'Nice work!';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final deckMix = run?.deckComposition ?? const <DeckLevelCount>[];
    final learnedCount = run?.learnedPromoted.length ?? 0;
    final troubleCount = run?.troubleDetected.length ?? 0;
    final rows = run?.rowsUsed ?? ref.watch(runRowsProvider);
    final timeExtends = run?.timeExtendsUsed ?? 0;
    final xpBonus = run?.xpBonus ?? 0;
    final streakMax = run?.streakMax ?? 0;
    final cleanRun = run?.cleanRun ?? false;
    final powerupsEarned = run?.powerupsEarned ?? const <String>[];
    final meta = ref
        .watch(userMetaFutureProvider)
        .maybeWhen(
          data: (value) => value,
          orElse: () => null,
        );
    final inventoryChange = _formatInventoryChange(
      meta: meta,
      run: run,
    );
    final avgMatches = _formatAverageMatches(meta);
    final avgAccuracy = _formatAverageAccuracy(meta);
    final avgDuration = _formatAverageDuration(meta);

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Card(
          color: Colors.black.withValues(alpha: 0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    _headline,
                    style: theme.textTheme.headlineMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'You earned $_xpEarned XP${xpBonus > 0 ? " (+$xpBonus bonus)" : ""}.',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: AppColors.secondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  _FinishStatRow(
                    label: 'Tier reached',
                    value: run?.tierReached.toString() ?? '—',
                  ),
                  _FinishStatRow(
                    label: 'Rows used',
                    value: '$rows',
                  ),
                  _FinishStatRow(
                    label: 'Time extends used',
                    value: '$timeExtends',
                  ),
                  _FinishStatRow(
                    label: 'Max streak',
                    value: '$streakMax',
                  ),
                  _FinishStatRow(
                    label: 'Clean run',
                    value: cleanRun ? 'Yes' : 'No',
                  ),
                  _FinishStatRow(
                    label: 'Learned promotions',
                    value: '$learnedCount',
                  ),
                  _FinishStatRow(
                    label: 'Trouble items flagged',
                    value: '$troubleCount',
                  ),
                  _FinishStatRow(
                    label: 'Learned/Trouble delta',
                    value: inventoryChange,
                  ),
                  _FinishStatRow(
                    label: 'Powerups earned',
                    value: _formatPowerups(powerupsEarned),
                  ),
                  if (deckMix.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      'Deck mix',
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    for (final entry in deckMix)
                      _FinishStatRow(
                        label: entry.level.toUpperCase(),
                        value: '${entry.count}',
                      ),
                  ],
                  if (meta != null && meta.totalRuns > 0) ...[
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      'Lifetime stats',
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    _FinishStatRow(
                      label: 'Runs played',
                      value: '${meta.totalRuns}',
                    ),
                    _FinishStatRow(
                      label: 'Current streak',
                      value: '${meta.currentStreak}',
                    ),
                    _FinishStatRow(
                      label: 'Best streak',
                      value: '${meta.bestStreak}',
                    ),
                    _FinishStatRow(
                      label: 'Avg matches/run',
                      value: avgMatches,
                    ),
                    _FinishStatRow(
                      label: 'Avg accuracy',
                      value: avgAccuracy,
                    ),
                    _FinishStatRow(
                      label: 'Avg time/run',
                      value: avgDuration,
                    ),
                  ],
                  const SizedBox(height: AppSpacing.xl),
                  ElevatedButton(
                    onPressed: () => context.go(AppRoute.preRun.path),
                    child: const Text('Play again'),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  TextButton(
                    onPressed: () => context.go(AppRoute.gate.path),
                    child: const Text('Exit to gate'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

String _formatInventoryChange({UserMeta? meta, RunLog? run}) {
  final learned = meta?.lastLearnedDelta ?? run?.learnedPromoted.length ?? 0;
  final trouble = meta?.lastTroubleDelta ?? run?.troubleDetected.length ?? 0;
  final learnedLabel = _formatSignedDelta(learned);
  final troubleLabel = _formatSignedDelta(trouble);
  return 'Learned $learnedLabel / Trouble $troubleLabel';
}

String _formatPowerups(List<String> powerups) {
  if (powerups.isEmpty) {
    return 'None';
  }
  final counts = <String, int>{};
  for (final id in powerups) {
    final label = _powerupLabel(id);
    counts[label] = (counts[label] ?? 0) + 1;
  }
  return counts.entries
      .map((entry) => '${entry.key} ×${entry.value}')
      .join(', ');
}

String _powerupLabel(String id) {
  switch (id.toLowerCase()) {
    case 'timeextend':
    case 'time_extend':
    case 'timeextendtoken':
    case 'timeextendpowerup':
      return 'Time Extend';
    case 'rowblaster':
    case 'row_blaster':
      return 'Row Blaster';
    default:
      return id;
  }
}

String _formatAverageMatches(UserMeta? meta) {
  if (meta == null || meta.totalRuns == 0) {
    return '—';
  }
  final average = meta.totalMatches / meta.totalRuns;
  return average.toStringAsFixed(1);
}

String _formatAverageAccuracy(UserMeta? meta) {
  if (meta == null || meta.totalAttempts == 0) {
    return '—';
  }
  final accuracy = (meta.totalMatches / meta.totalAttempts) * 100;
  return '${accuracy.toStringAsFixed(1)}%';
}

String _formatAverageDuration(UserMeta? meta) {
  if (meta == null || meta.totalRuns == 0) {
    return '—';
  }
  final averageMs = meta.totalTimeMs ~/ meta.totalRuns;
  return _formatDuration(averageMs);
}

String _formatSignedDelta(int value) {
  final prefix = value >= 0 ? '+' : '';
  return '$prefix$value';
}

String _formatDuration(int milliseconds) {
  if (milliseconds <= 0) {
    return '—';
  }
  final duration = Duration(milliseconds: milliseconds);
  final minutes = duration.inMinutes;
  final seconds = duration.inSeconds.remainder(60);
  if (minutes == 0) {
    return '${seconds}s';
  }
  return '${minutes}m ${seconds.toString().padLeft(2, '0')}s';
}

class _FinishStatRow extends StatelessWidget {
  const _FinishStatRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: theme.textTheme.bodyMedium),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.secondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
