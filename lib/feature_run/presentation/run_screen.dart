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
import 'package:palabra/feature_run/application/tts/run_tts_config.dart';
import 'package:palabra/feature_run/application/tts/run_tts_service.dart';
import 'package:palabra/feature_run/presentation/confetti_overlay.dart';

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
  late final RunTtsService _ttsService;
  DateTime? _lastTtsToastAt;

  @override
  void initState() {
    super.initState();
    _ttsService = ref.read(runTtsServiceProvider);
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
    unawaited(_ttsService.cancel());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final runState = ref.watch(runControllerProvider);
    final controller = ref.read(runControllerProvider.notifier);
    final settings = ref.watch(runSettingsProvider);
    final devPanelEnabled = ref.watch(runTtsDevPanelEnabledProvider);
    final ttsConfig = ref.watch(runTtsConfigProvider);
    final voiceLabel = ref.watch(runTtsVoiceLabelProvider);
    final configNotifier = ref.read(runTtsConfigProvider.notifier);

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
                    onTileTap: (row, column) {
                      if (!runState.inputLocked &&
                          column == TileColumn.right &&
                          runState.board.isNotEmpty) {
                        final tile = runState.tileAt(row, column);
                        unawaited(_handleSpanishTileTap(tile));
                      }
                      controller.onTileTapped(row, column);
                    },
                    onResume: controller.resumeFromPause,
                    onAcceptTimeExtend: controller.acceptTimeExtend,
                    onDeclineTimeExtend: controller.declineTimeExtend,
                    ttsDevPanelEnabled: devPanelEnabled,
                    ttsConfig: ttsConfig,
                    onRateChanged: configNotifier.setRate,
                    onPitchChanged: configNotifier.setPitch,
                    voiceLabel: voiceLabel,
                  ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleSpanishTileTap(BoardTile tile) async {
    await _ttsService.onUserGesture();
    final outcome = await _ttsService.speak(
      text: tile.text,
      itemId: tile.pairId.isEmpty ? null : tile.pairId,
    );
    if (outcome == RunTtsPlaybackOutcome.unavailable) {
      _showTtsUnavailableToast();
    }
  }

  void _showTtsUnavailableToast() {
    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger == null) {
      return;
    }
    final now = DateTime.now();
    if (_lastTtsToastAt != null &&
        now.difference(_lastTtsToastAt!) < const Duration(seconds: 3)) {
      return;
    }
    _lastTtsToastAt = now;
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: Text('TTS unavailable in this browser.'),
          duration: Duration(seconds: 2),
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
    required this.ttsDevPanelEnabled,
    required this.ttsConfig,
    required this.onRateChanged,
    required this.onPitchChanged,
    required this.voiceLabel,
  });

  final RunState state;
  final RunSettings settings;
  final void Function(int row, TileColumn column) onTileTap;
  final Future<void> Function() onResume;
  final Future<void> Function() onAcceptTimeExtend;
  final Future<void> Function() onDeclineTimeExtend;
  final bool ttsDevPanelEnabled;
  final RunTtsConfig ttsConfig;
  final ValueChanged<double> onRateChanged;
  final ValueChanged<double> onPitchChanged;
  final String? voiceLabel;

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
        if (state.celebrationEffect != null)
          _CelebrationOverlay(token: state.celebrationEffect!.token),
        if (state.confettiEffect != null)
          ConfettiOverlay(effect: state.confettiEffect!),
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
        if (ttsDevPanelEnabled)
          Positioned(
            top: AppSpacing.md,
            right: AppSpacing.md,
            child: _TtsDevPanel(
              config: ttsConfig,
              onRateChanged: onRateChanged,
              onPitchChanged: onPitchChanged,
              voiceLabel: voiceLabel,
            ),
          ),
      ],
    );
  }
}

class _CelebrationOverlay extends StatelessWidget {
  const _CelebrationOverlay({required this.token});

  final int token;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        child: TweenAnimationBuilder<double>(
          key: ValueKey(token),
          duration: const Duration(milliseconds: 320),
          tween: Tween<double>(begin: 0, end: 1),
          builder: (context, value, __) {
            final opacity = (1 - value).clamp(0.0, 1.0);
            final scale = 0.85 + (value * 0.3);
            return Opacity(
              opacity: opacity,
              child: Transform.scale(
                scale: scale,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: <Color>[
                          AppColors.success.withValues(alpha: 0.3),
                          Colors.transparent,
                        ],
                      ),
                    ),
                    child: Icon(
                      Icons.check_circle,
                      size: 72,
                      color: AppColors.success,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _TtsDevPanel extends StatelessWidget {
  const _TtsDevPanel({
    required this.config,
    required this.onRateChanged,
    required this.onPitchChanged,
    required this.voiceLabel,
  });

  final RunTtsConfig config;
  final ValueChanged<double> onRateChanged;
  final ValueChanged<double> onPitchChanged;
  final String? voiceLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveVoice = voiceLabel ?? 'Voice unavailable';
    return Card(
      color: AppColors.surfaceVariant.withValues(alpha: 0.9),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: AppColors.outline.withValues(alpha: 0.4)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minWidth: 240, maxWidth: 280),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'TTS Dev Settings',
                style: theme.textTheme.titleSmall,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                effectiveVoice,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.textMuted,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Rate ${config.rate.toStringAsFixed(2)}',
                style: theme.textTheme.bodyMedium,
              ),
              Slider(
                value: config.rate,
                min: 0.5,
                max: 1.2,
                divisions: 14,
                onChanged: onRateChanged,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Pitch ${config.pitch.toStringAsFixed(2)}',
                style: theme.textTheme.bodyMedium,
              ),
              Slider(
                value: config.pitch,
                min: 0.8,
                max: 1.2,
                divisions: 8,
                onChanged: onPitchChanged,
              ),
            ],
          ),
        ),
      ),
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
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(color: AppColors.secondary),
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
              mismatchEffect: state.mismatchEffect,
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
    required this.mismatchEffect,
    required this.onTileTap,
    required this.inputLocked,
  });

  final int index;
  final BoardRow row;
  final TileSelection? selection;
  final MismatchEffect? mismatchEffect;
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
            isMismatch:
                mismatchEffect?.involves(index, TileColumn.left) ?? false,
            mismatchToken: mismatchEffect?.token ?? 0,
            onTap: () => onTileTap(index, TileColumn.left),
            enabled: !inputLocked && row.left.pairId.isNotEmpty,
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: _RunTile(
            text: row.right.text,
            isSelected: _isSelected(TileColumn.right),
            isMismatch:
                mismatchEffect?.involves(index, TileColumn.right) ?? false,
            mismatchToken: mismatchEffect?.token ?? 0,
            onTap: () => onTileTap(index, TileColumn.right),
            enabled: !inputLocked && row.right.pairId.isNotEmpty,
          ),
        ),
      ],
    );
  }
}

class _RunTile extends StatefulWidget {
  const _RunTile({
    required this.text,
    required this.isSelected,
    required this.isMismatch,
    required this.mismatchToken,
    required this.onTap,
    required this.enabled,
  });

  final String text;
  final bool isSelected;
  final bool isMismatch;
  final int mismatchToken;
  final VoidCallback onTap;
  final bool enabled;

  @override
  State<_RunTile> createState() => _RunTileState();
}

class _RunTileState extends State<_RunTile>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _offsetAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );
    _offsetAnimation = _buildShakeAnimation();
    if (widget.isMismatch) {
      _controller.forward(from: 0);
    }
  }

  Animation<double> _buildShakeAnimation() {
    return TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: -6.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -6.0, end: 6.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 6.0, end: -4.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -4.0, end: 4.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 4.0, end: 0.0), weight: 1),
    ]).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void didUpdateWidget(covariant _RunTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    final mismatchTokenChanged =
        widget.mismatchToken != oldWidget.mismatchToken;
    if (widget.isMismatch && (!oldWidget.isMismatch || mismatchTokenChanged)) {
      _controller.forward(from: 0);
    } else if (!widget.isMismatch && oldWidget.isMismatch) {
      _controller.stop();
      _controller.reset();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool mismatch = widget.isMismatch;
    final background = mismatch
        ? AppColors.danger.withValues(alpha: 0.18)
        : widget.isSelected
        ? AppColors.secondary.withValues(alpha: 0.2)
        : AppColors.surfaceVariant;
    final border = mismatch
        ? AppColors.danger
        : widget.isSelected
        ? AppColors.secondary
        : AppColors.outline;

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 150),
      opacity: widget.enabled ? 1 : 0.5,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final double dx = mismatch ? _offsetAnimation.value : 0.0;
          return Transform.translate(
            offset: Offset(dx, 0),
            child: child,
          );
        },
        child: InkWell(
          onTap: widget.enabled ? widget.onTap : null,
          borderRadius: BorderRadius.circular(18),
          splashColor: mismatch
              ? AppColors.danger.withValues(alpha: 0.1)
              : AppColors.secondary.withValues(alpha: 0.1),
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
              widget.text,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium?.copyWith(
                color: mismatch ? AppColors.danger : null,
              ),
            ),
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
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textMuted,
                    ),
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
