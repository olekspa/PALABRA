import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:palabra/app/router/app_router.dart';
import 'package:palabra/design_system/tokens/color_tokens.dart';
import 'package:palabra/design_system/tokens/spacing_tokens.dart';
import 'package:palabra/design_system/widgets/gradient_background.dart';
import 'package:palabra/feature_run/application/run_controller.dart';
import 'package:palabra/feature_run/application/run_settings.dart';
import 'package:palabra/feature_run/application/run_state.dart';

/// Core timed run experience view backed by [RunController].
class RunScreen extends ConsumerStatefulWidget {
  /// Creates a [RunScreen].
  const RunScreen({super.key});

  @override
  ConsumerState<RunScreen> createState() => _RunScreenState();
}

class _RunScreenState extends ConsumerState<RunScreen> {
  bool _navigatedToFinish = false;
  late final ProviderSubscription<RunState> _runSubscription;

  @override
  void initState() {
    super.initState();
    // React to completion so we can transition to the finish summary.
    _runSubscription = ref.listenManual<RunState>(
      runControllerProvider,
      (previous, next) {
        if (next.phase == RunPhase.completed && !_navigatedToFinish) {
          _navigatedToFinish = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) {
              return;
            }
            context.go(AppRoute.finish.path);
          });
        }
      },
    );
  }

  @override
  void dispose() {
    _runSubscription.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final runState = ref.watch(runControllerProvider);
    final controller = ref.read(runControllerProvider.notifier);
    final settings = ref.watch(runSettingsProvider);

    return GradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: runState.phase == RunPhase.loading
                ? const _LoadingState()
                : _RunView(
                    state: runState,
                    settings: settings,
                    onTileTap: controller.onTileTapped,
                    onResume: controller.resumeFromPause,
                    onAcceptTimeExtend: controller.acceptTimeExtend,
                    onDeclineTimeExtend: controller.declineTimeExtend,
                  ),
          ),
        ),
      ),
    );
  }
}

class _RunView extends StatelessWidget {
  const _RunView({
    required this.state,
    required this.settings,
    required this.onTileTap,
    required this.onResume,
    required this.onAcceptTimeExtend,
    required this.onDeclineTimeExtend,
  });

  final RunState state;
  final RunSettings settings;
  final void Function(int row, TileColumn column) onTileTap;
  final Future<void> Function() onResume;
  final Future<void> Function() onAcceptTimeExtend;
  final Future<void> Function() onDeclineTimeExtend;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _RunHeader(
              progress: state.progress,
              target: settings.targetMatches,
              millisecondsRemaining: state.millisecondsRemaining,
              deckRemaining: state.deckRemaining,
            ),
            const SizedBox(height: AppSpacing.lg),
            Expanded(
              child: _RunBoard(
                state: state,
                onTileTap: (row, column) {
                  if (state.inputLocked) {
                    return;
                  }
                  onTileTap(row, column);
                },
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            _RunFooter(
              deckRemaining: state.deckRemaining,
              rows: state.rows,
            ),
          ],
        ),
        if (state.inputLocked &&
            state.phase == RunPhase.ready &&
            !state.showingTimeExtendOffer)
          _TierPauseOverlay(
            state: state,
            onResume: onResume,
          ),
        if (state.showingTimeExtendOffer)
          _TimeExtendOverlay(
            tokensRemaining: state.timeExtendTokens,
            timeExtendsUsed: state.timeExtendsUsed,
            maxTimeExtends: settings.maxTimeExtendsPerRun,
            extendSeconds: (settings.timeExtendDurationMs / 1000).round(),
            onAccept: onAcceptTimeExtend,
            onDecline: onDeclineTimeExtend,
          ),
      ],
    );
  }
}

class _RunHeader extends StatelessWidget {
  const _RunHeader({
    required this.progress,
    required this.target,
    required this.millisecondsRemaining,
    required this.deckRemaining,
  });

  final int progress;
  final int target;
  final int millisecondsRemaining;
  final int deckRemaining;

  String get _timeLabel {
    final duration = Duration(milliseconds: millisecondsRemaining);
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final value = (progress / target).clamp(0.0, 1.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Matches $progress / $target',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Text(
              _timeLabel,
              style: Theme.of(context)
                  .textTheme
                  .headlineMedium
                  ?.copyWith(color: AppColors.secondary),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: LinearProgressIndicator(
            value: value.isNaN ? 0 : value,
            minHeight: 10,
            color: AppColors.secondary,
            backgroundColor: AppColors.surfaceVariant,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Deck remaining: $deckRemaining',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}

class _RunBoard extends StatelessWidget {
  const _RunBoard({
    required this.state,
    required this.onTileTap,
  });

  final RunState state;
  final void Function(int row, TileColumn column) onTileTap;

  @override
  Widget build(BuildContext context) {
    if (!state.isReady || state.board.isEmpty) {
      return const Center(child: _LoadingState());
    }

    return Column(
      children: [
        for (var i = 0; i < state.board.length; i++)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
            child: _BoardRowView(
              index: i,
              row: state.board[i],
              selection: state.selection,
              onTileTap: onTileTap,
              inputLocked: state.inputLocked,
            ),
          ),
      ],
    );
  }
}

class _BoardRowView extends StatelessWidget {
  const _BoardRowView({
    required this.index,
    required this.row,
    required this.selection,
    required this.onTileTap,
    required this.inputLocked,
  });

  final int index;
  final BoardRow row;
  final TileSelection? selection;
  final void Function(int row, TileColumn column) onTileTap;
  final bool inputLocked;

  bool _isSelected(TileColumn column) {
    return selection != null &&
        selection!.row == index &&
        selection!.column == column;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _RunTile(
            text: row.left.text,
            isSelected: _isSelected(TileColumn.left),
            onTap: () => onTileTap(index, TileColumn.left),
            enabled: !inputLocked && row.left.pairId.isNotEmpty,
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: _RunTile(
            text: row.right.text,
            isSelected: _isSelected(TileColumn.right),
            onTap: () => onTileTap(index, TileColumn.right),
            enabled: !inputLocked && row.right.pairId.isNotEmpty,
          ),
        ),
      ],
    );
  }
}

class _RunTile extends StatelessWidget {
  const _RunTile({
    required this.text,
    required this.isSelected,
    required this.onTap,
    required this.enabled,
  });

  final String text;
  final bool isSelected;
  final VoidCallback onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final background = isSelected
        ? AppColors.secondary.withValues(alpha: 0.2)
        : AppColors.surfaceVariant;
    final border = isSelected ? AppColors.secondary : AppColors.outline;

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 150),
      opacity: enabled ? 1 : 0.5,
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(18),
        splashColor: AppColors.secondary.withValues(alpha: 0.1),
        child: Ink(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: border),
          ),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: theme.textTheme.titleMedium,
          ),
        ),
      ),
    );
  }
}

class _RunFooter extends StatelessWidget {
  const _RunFooter({
    required this.deckRemaining,
    required this.rows,
  });

  final int deckRemaining;
  final int rows;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.bodySmall;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('Rows in play: $rows', style: style),
        Text('Deck queue: $deckRemaining', style: style),
      ],
    );
  }
}

class _TierPauseOverlay extends StatelessWidget {
  const _TierPauseOverlay({
    required this.state,
    required this.onResume,
  });

  final RunState state;
  final Future<void> Function() onResume;

  String get _title {
    if (state.pausedAtTier50 && state.progress >= 50) {
      return 'Tier 2 complete';
    }
    if (state.pausedAtTier20 && state.progress >= 20) {
      return 'Tier 1 complete';
    }
    return 'Paused';
  }

  String get _subtitle {
    if (state.pausedAtTier50 && state.progress >= 50) {
      return '+10 XP secured • Total +15 XP';
    }
    if (state.pausedAtTier20 && state.progress >= 20) {
      return '+5 XP secured';
    }
    return 'Catch your breath and resume when ready.';
  }

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: ColoredBox(
        color: Colors.black.withValues(alpha: 0.6),
        child: Center(
          child: Card(
            color: AppColors.surfaceVariant,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _title,
                    style: Theme.of(context).textTheme.headlineSmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    _subtitle,
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(color: AppColors.textMuted),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  ElevatedButton(
                    onPressed: () => unawaited(onResume()),
                    child: const Text('Continue'),
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

class _TimeExtendOverlay extends StatelessWidget {
  const _TimeExtendOverlay({
    required this.tokensRemaining,
    required this.timeExtendsUsed,
    required this.maxTimeExtends,
    required this.extendSeconds,
    required this.onAccept,
    required this.onDecline,
  });

  final int tokensRemaining;
  final int timeExtendsUsed;
  final int maxTimeExtends;
  final int extendSeconds;
  final Future<void> Function() onAccept;
  final Future<void> Function() onDecline;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Positioned.fill(
      child: ColoredBox(
        color: Colors.black.withValues(alpha: 0.6),
        child: Center(
          child: Card(
            color: AppColors.surfaceVariant,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Out of time!',
                    style: theme.textTheme.headlineSmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Add $extendSeconds seconds and keep your run alive?',
                    style: theme.textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'Tokens remaining: $tokensRemaining',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.textMuted,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    'Extends used this run: $timeExtendsUsed / $maxTimeExtends',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.textMuted,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  ElevatedButton(
                    onPressed: () => unawaited(onAccept()),
                    child: Text('Add $extendSeconds seconds'),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  TextButton(
                    onPressed: () => unawaited(onDecline()),
                    child: const Text('Finish run'),
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

class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }
}
