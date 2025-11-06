import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:palabra/app/router/app_router.dart';
import 'package:palabra/data_core/data_core.dart';
import 'package:palabra/data_core/providers/repository_providers.dart';
import 'package:palabra/data_core/providers/user_meta_providers.dart';
import 'package:palabra/design_system/tokens/color_tokens.dart';
import 'package:palabra/design_system/tokens/spacing_tokens.dart';
import 'package:palabra/design_system/widgets/gradient_background.dart';
import 'package:palabra/feature_numbers/application/number_drill_controller.dart';
import 'package:palabra/feature_numbers/application/number_drill_state.dart';

class NumberDrillScreen extends ConsumerStatefulWidget {
  const NumberDrillScreen({super.key});

  @override
  ConsumerState<NumberDrillScreen> createState() => _NumberDrillScreenState();
}

class _NumberDrillScreenState extends ConsumerState<NumberDrillScreen> {
  bool _started = false;
  bool _savedProgress = false;

  @override
  Widget build(BuildContext context) {
    final userMetaAsync = ref.watch(userMetaFutureProvider);
    final drillState = ref.watch(numberDrillControllerProvider);
    final theme = Theme.of(context);

    userMetaAsync.whenData((meta) {
      if (!_started) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted || _started) {
            return;
          }
          ref
              .read(numberDrillControllerProvider.notifier)
              .start(
                progress: meta.numberDrillProgress,
                levelId: meta.level,
              );
          _started = true;
        });
      }
    });

    return GradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: userMetaAsync.when(
              data: (meta) => _DrillContent(
                theme: theme,
                state: drillState,
                onTileTap: (value) => ref
                    .read(numberDrillControllerProvider.notifier)
                    .select(value),
                onRepeat: () =>
                    ref.read(numberDrillControllerProvider.notifier).repeat(),
                onContinue: () => _handleContinue(meta, drillState),
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, __) => Center(
                child: Text(
                  'Unable to load number drill.',
                  style: theme.textTheme.bodyLarge,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleContinue(UserMeta meta, NumberDrillState state) async {
    if (!_savedProgress) {
      await _persistProgress(meta, state);
      _savedProgress = true;
    }
    if (!mounted) {
      return;
    }
    if (!context.mounted) {
      return;
    }
    context.go(AppRoute.finish.path);
  }

  Future<void> _persistProgress(UserMeta meta, NumberDrillState state) async {
    final repo = ref.read(userMetaRepositoryProvider);
    final progress = meta.numberDrillProgress;
    progress.drillsCompleted += 1;
    progress.totalMistakes += state.mistakes;
    if (state.gridNumbers.isNotEmpty) {
      progress.highestNumberUnlocked = max(
        progress.highestNumberUnlocked,
        state.gridNumbers.reduce(max),
      );
    }
    final controller = ref.read(numberDrillControllerProvider.notifier);
    controller.mistakeSummary.forEach((number, count) {
      progress.mistakeCounts[number] =
          (progress.mistakeCounts[number] ?? 0) + count;
    });
    if (state.mistakes == 0) {
      progress.masteredNumbers.addAll(state.clearedNumbers);
    }
    meta.numberDrillProgress = progress;
    await repo.save(meta);
    ref.invalidate(userMetaFutureProvider);
  }
}

class _DrillContent extends StatelessWidget {
  const _DrillContent({
    required this.theme,
    required this.state,
    required this.onTileTap,
    required this.onRepeat,
    required this.onContinue,
  });

  final ThemeData theme;
  final NumberDrillState state;
  final void Function(int value) onTileTap;
  final VoidCallback onRepeat;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    if (state.phase == NumberDrillPhase.loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state.phase == NumberDrillPhase.completed) {
      return _CompletedView(
        theme: theme,
        state: state,
        onContinue: onContinue,
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _DrillHeader(
          theme: theme,
          state: state,
          onRepeat: onRepeat,
        ),
        const SizedBox(height: AppSpacing.lg),
        Expanded(
          child: _NumberGrid(
            numbers: state.gridNumbers,
            cleared: state.clearedNumbers,
            onTap: onTileTap,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          'Tap the number that matches the spoken audio. Use repeat any time.',
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium,
        ),
      ],
    );
  }
}

class _DrillHeader extends StatelessWidget {
  const _DrillHeader({
    required this.theme,
    required this.state,
    required this.onRepeat,
  });

  final ThemeData theme;
  final NumberDrillState state;
  final VoidCallback onRepeat;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Number drill',
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Matches ${state.completedCount} / ${state.goal}',
              style: theme.textTheme.bodyMedium,
            ),
            Text(
              'Mistakes ${state.mistakes}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.textMuted,
              ),
            ),
          ],
        ),
        FilledButton.icon(
          onPressed: onRepeat,
          icon: const Icon(Icons.volume_up_rounded),
          label: const Text('Repeat'),
        ),
      ],
    );
  }
}

class _NumberGrid extends StatelessWidget {
  const _NumberGrid({
    required this.numbers,
    required this.cleared,
    required this.onTap,
  });

  final List<int> numbers;
  final Set<int> cleared;
  final void Function(int value) onTap;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const columns = 4;
        final spacing = AppSpacing.sm.toDouble();
        final availableWidth = constraints.maxWidth;
        final availableHeight = constraints.maxHeight;
        final tileWidth = (availableWidth - (columns - 1) * spacing) / columns;
        final rows = (numbers.length / columns).ceil();
        final tileHeight = (availableHeight - (rows - 1) * spacing) / rows;
        final tileSize = tileWidth < tileHeight ? tileWidth : tileHeight;
        final gridWidth = tileSize * columns + spacing * (columns - 1);
        final gridHeight = tileSize * rows + spacing * (rows - 1);
        return Align(
          alignment: Alignment.topCenter,
          child: SizedBox(
            width: gridWidth,
            height: gridHeight,
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              padding: EdgeInsets.zero,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: columns,
                crossAxisSpacing: spacing,
                mainAxisSpacing: spacing,
                childAspectRatio: 1,
              ),
              itemCount: numbers.length,
              itemBuilder: (context, index) {
                final value = numbers[index];
                final isCleared = cleared.contains(value);
                return _NumberTile(
                  value: value,
                  cleared: isCleared,
                  size: tileSize,
                  onTap: () => onTap(value),
                );
              },
            ),
          ),
        );
      },
    );
  }
}

class _NumberTile extends StatelessWidget {
  const _NumberTile({
    required this.value,
    required this.cleared,
    required this.size,
    required this.onTap,
  });

  final int value;
  final bool cleared;
  final double size;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 200),
      opacity: cleared ? 0.25 : 1,
      child: SizedBox.square(
        dimension: size,
        child: Material(
          color: cleared
              ? AppColors.surfaceVariant
              : Colors.black.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(14),
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: cleared ? null : onTap,
            overlayColor: MaterialStateProperty.all(
              AppColors.secondary.withValues(alpha: 0.08),
            ),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.sm),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  '$value',
                  style: theme.textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CompletedView extends StatelessWidget {
  const _CompletedView({
    required this.theme,
    required this.state,
    required this.onContinue,
  });

  final ThemeData theme;
  final NumberDrillState state;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    final seconds = (state.millisecondsElapsed / 1000).toStringAsFixed(1);
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
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
                  'Bonus complete!',
                  style: theme.textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Time: ${seconds}s',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyLarge,
                ),
                Text(
                  'Mistakes: ${state.mistakes}',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyLarge,
                ),
                const SizedBox(height: AppSpacing.lg),
                ElevatedButton(
                  onPressed: onContinue,
                  child: const Text('Continue'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
