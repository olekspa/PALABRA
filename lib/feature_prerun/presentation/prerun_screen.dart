import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:palabra/app/router/app_router.dart';
import 'package:palabra/data_core/data_core.dart';
import 'package:palabra/design_system/tokens/color_tokens.dart';
import 'package:palabra/design_system/tokens/spacing_tokens.dart';
import 'package:palabra/design_system/widgets/gradient_background.dart';
import 'package:palabra/feature_run/application/run_settings.dart';

final _rowBlasterEnabledProvider =
    StateProvider.autoDispose<bool>((ref) => false);
final _isStartingProvider = StateProvider.autoDispose<bool>((ref) => false);

/// Pre-run staging screen where the player configures the run.
class PreRunScreen extends ConsumerStatefulWidget {
  /// Creates a [PreRunScreen].
  const PreRunScreen({super.key});

  @override
  ConsumerState<PreRunScreen> createState() => _PreRunScreenState();
}

class _PreRunScreenState extends ConsumerState<PreRunScreen> {
  ProviderSubscription<AsyncValue<UserMeta>>? _metaSubscription;

  @override
  void initState() {
    super.initState();
    // Keep run rows aligned with the persisted preference unless the Row
    // Blaster override is active.
    _metaSubscription = ref.listenManual<AsyncValue<UserMeta>>(
      userMetaFutureProvider,
      (previous, next) {
        next.whenData((meta) {
          final preferredRows = meta.preferredRows.clamp(4, 5);
          ref.read(runRowsProvider.notifier).state = preferredRows;
          ref.read(_rowBlasterEnabledProvider.notifier).state = false;
        });
      },
      fireImmediately: true,
    );
  }

  @override
  void dispose() {
    _metaSubscription?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final metaAsync = ref.watch(userMetaFutureProvider);
    return GradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: metaAsync.when(
              data: (meta) => _PreRunContent(meta: meta),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, __) => Center(
                child: Text(
                  'Unable to load run settings.',
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

class _PreRunContent extends ConsumerWidget {
  const _PreRunContent({required this.meta});

  final UserMeta meta;

  Future<void> _startRun(BuildContext context, WidgetRef ref) async {
    final isStartingNotifier = ref.read(_isStartingProvider.notifier);
    if (isStartingNotifier.state) {
      return;
    }
    isStartingNotifier.state = true;

    final rowBlasterEnabled = ref.read(_rowBlasterEnabledProvider);
    final rows = ref.read(runRowsProvider);
    final repository = ref.read(userMetaRepositoryProvider);

    // Persist latest preferences and consume Row Blaster if toggled.
    meta.preferredRows = rows;
    if (rowBlasterEnabled && meta.rowBlasterCharges > 0) {
      meta.rowBlasterCharges -= 1;
    }

    await repository.save(meta);
    ref.invalidate(userMetaFutureProvider);
    ref.read(_rowBlasterEnabledProvider.notifier).state = false;

    if (context.mounted) {
      context.go(AppRoute.run.path);
    }
    isStartingNotifier.state = false;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final rowBlasterEnabled = ref.watch(_rowBlasterEnabledProvider);
    final isStarting = ref.watch(_isStartingProvider);
    final rowBlasterCharges = meta.rowBlasterCharges;
    final baseRows = meta.preferredRows.clamp(4, 5);

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 520),
      child: Card(
        color: Colors.black.withValues(alpha: 0.25),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Ready to run?',
                style: theme.textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Make 90 correct matches in 1:45.',
                style: theme.textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.lg),
              _TierRewards(theme: theme),
              const SizedBox(height: AppSpacing.lg),
              _RowBlasterToggle(
                enabled: rowBlasterEnabled,
                charges: rowBlasterCharges,
                baseRows: baseRows,
              ),
              const SizedBox(height: AppSpacing.md),
              _TimeExtendInfo(tokens: meta.timeExtendTokens),
              const SizedBox(height: AppSpacing.xl),
              ElevatedButton(
                onPressed: isStarting ? null : () => _startRun(context, ref),
                child: isStarting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Start'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TierRewards extends StatelessWidget {
  const _TierRewards({required this.theme});

  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    final items = <(String, String)>[
      ('20 matches', '+5 XP secured'),
      ('50 matches', '+10 XP secured'),
      ('90 matches', '+25 XP secured'),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Tier rewards',
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: AppSpacing.sm),
        for (final (label, reward) in items)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxs),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(label, style: theme.textTheme.bodyMedium),
                Text(
                  reward,
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(color: AppColors.secondary),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _RowBlasterToggle extends ConsumerWidget {
  const _RowBlasterToggle({
    required this.enabled,
    required this.charges,
    required this.baseRows,
  });

  final bool enabled;
  final int charges;
  final int baseRows;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasCharges = charges > 0;
    final activeRows = ref.watch(runRowsProvider);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outline),
        color: Colors.black.withValues(alpha: 0.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Row Blaster',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Switch(
                value: enabled && hasCharges,
                onChanged: hasCharges
                    ? (value) {
                        ref
                            .read(_rowBlasterEnabledProvider.notifier)
                            .state = value;
                        ref.read(runRowsProvider.notifier).state =
                            value ? 4 : baseRows;
                      }
                    : null,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            hasCharges
                ? 'Reduce the board to four rows for this run. Charges left: '
                    '$charges'
                : 'You need a Row Blaster charge to activate this powerup.',
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: AppColors.textMuted),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Active rows: $activeRows',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

class _TimeExtendInfo extends StatelessWidget {
  const _TimeExtendInfo({required this.tokens});

  final int tokens;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outline),
        color: Colors.black.withValues(alpha: 0.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Time Extend', style: theme.textTheme.titleMedium),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Adds 60 seconds when the timer hits zero. Tokens in inventory: '
            '$tokens',
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}
