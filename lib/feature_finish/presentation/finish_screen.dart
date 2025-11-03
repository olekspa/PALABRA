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
    final tier = run?.tierReached ?? 0;
    if (tier >= 3) {
      return 40;
    }
    if (tier == 2) {
      return 15;
    }
    if (tier == 1) {
      return 5;
    }
    return 0;
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
                  'You earned $_xpEarned XP.',
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
                  label: 'Learned promotions',
                  value: '$learnedCount',
                ),
                _FinishStatRow(
                  label: 'Trouble items flagged',
                  value: '$troubleCount',
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
    );
  }
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: theme.textTheme.bodyMedium),
          Text(
            value,
            style: theme.textTheme.bodyMedium
                ?.copyWith(color: AppColors.secondary),
          ),
        ],
      ),
    );
  }
}
