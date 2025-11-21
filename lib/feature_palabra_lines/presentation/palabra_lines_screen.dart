import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:palabra/design_system/widgets/gradient_background.dart';
import 'package:palabra/feature_palabra_lines/application/palabra_lines_controller.dart';
import 'package:palabra/feature_palabra_lines/application/palabra_lines_providers.dart';
import 'package:palabra/feature_palabra_lines/domain/palabra_lines_config.dart';
import 'package:palabra/feature_palabra_lines/domain/palabra_lines_game_state.dart';
import 'package:palabra/feature_palabra_lines/domain/palabra_lines_question.dart';
import 'package:palabra/feature_palabra_lines/presentation/widgets/palabra_lines_board_widget.dart';
import 'package:palabra/feature_palabra_lines/presentation/widgets/palabra_lines_score_column.dart';

class PalabraLinesScreen extends ConsumerStatefulWidget {
  const PalabraLinesScreen({super.key});

  @override
  ConsumerState<PalabraLinesScreen> createState() => _PalabraLinesScreenState();
}

class _PalabraLinesScreenState extends ConsumerState<PalabraLinesScreen> {
  ProviderSubscription<PalabraLinesGameState>? _gameSubscription;

  @override
  void initState() {
    super.initState();
    _gameSubscription = ref.listenManual<PalabraLinesGameState>(
      palabraLinesControllerProvider,
      _handleGameStateChanged,
    );
  }

  @override
  void dispose() {
    _gameSubscription?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(palabraLinesControllerProvider);
    final controller = ref.read(palabraLinesControllerProvider.notifier);
    final isLocked = state.phase == PalabraLinesPhase.quiz;
    return GradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 900;
              if (isWide) {
                return _WidePalabraLinesLayout(
                  state: state,
                  controller: controller,
                  isLocked: isLocked,
                  constraints: constraints,
                );
              }
              return _StackedPalabraLinesLayout(
                state: state,
                controller: controller,
                isLocked: isLocked,
              );
            },
          ),
        ),
      ),
    );
  }

  void _handleGameStateChanged(
    PalabraLinesGameState? previous,
    PalabraLinesGameState next,
  ) {
    final feedback = next.feedback;
    final newFeedback =
        feedback != null &&
        feedback.id != previous?.feedback?.id &&
        feedback.message.isNotEmpty;
    if (!newFeedback) {
      return;
    }
    final theme = Theme.of(context);
    final messenger = ScaffoldMessenger.of(context);
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(feedback.message),
          backgroundColor: feedback.isError
              ? theme.colorScheme.error.withOpacity(0.9)
              : theme.colorScheme.surfaceVariant.withOpacity(0.95),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
  }
}

class _HeaderSection extends StatelessWidget {
  const _HeaderSection({
    required this.state,
    required this.onNewGame,
  });

  final PalabraLinesGameState state;
  final VoidCallback onNewGame;

  @override
  Widget build(BuildContext context) {
    return PalabraLinesScoreColumn(
      score: state.score,
      highScore: state.highScore,
      onNewGame: onNewGame,
    );
  }
}

class _WidePalabraLinesLayout extends StatelessWidget {
  const _WidePalabraLinesLayout({
    required this.state,
    required this.controller,
    required this.isLocked,
    required this.constraints,
  });

  final PalabraLinesGameState state;
  final PalabraLinesController controller;
  final bool isLocked;
  final BoxConstraints constraints;

  @override
  Widget build(BuildContext context) {
    const double sidebarWidth = 220;
    const double gap = 24;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Expanded(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
              child: LayoutBuilder(
                builder: (context, boardConstraints) {
                  final boardSide = boardConstraints.maxWidth.clamp(
                    0.0,
                    constraints.maxHeight,
                  );
                  return SizedBox(
                    width: boardSide,
                    height: boardSide,
                    child: PalabraLinesBoardWidget(
                      board: state.board,
                      selectedRow: state.selectedRow,
                      selectedCol: state.selectedCol,
                      isLocked: isLocked,
                      isGameOver: state.isGameOver,
                      onCellTap: controller.onCellTap,
                      activeQuestion: state.activeQuestion,
                      moveAnimation: state.moveAnimation,
                    ),
                  );
                },
              ),
            ),
          ),
        ),
        const SizedBox(width: gap),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: sidebarWidth),
          child: _SidebarInfo(
            state: state,
            onNewGame: controller.startNewGame,
            onOptionTap: controller.onQuizOptionTap,
          ),
        ),
      ],
    );
  }
}

class _StackedPalabraLinesLayout extends StatelessWidget {
  const _StackedPalabraLinesLayout({
    required this.state,
    required this.controller,
    required this.isLocked,
  });

  final PalabraLinesGameState state;
  final PalabraLinesController controller;
  final bool isLocked;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, outerConstraints) {
        final maxWidth = outerConstraints.maxWidth;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
          child: Column(
            children: <Widget>[
              _GridOverlayInfoBar(
                state: state,
                onNewGame: controller.startNewGame,
                maxWidth: max(0.0, maxWidth - 8),
              ),
              const SizedBox(height: 6),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, boxConstraints) {
                    final boardSide = min(
                      boxConstraints.maxWidth,
                      boxConstraints.maxHeight,
                    );
                    return Center(
                      child: SizedBox(
                        width: boardSide,
                        height: boardSide,
                        child: PalabraLinesBoardWidget(
                          board: state.board,
                          selectedRow: state.selectedRow,
                          selectedCol: state.selectedCol,
                          isLocked: isLocked,
                          isGameOver: state.isGameOver,
                          onCellTap: controller.onCellTap,
                          activeQuestion: state.activeQuestion,
                          moveAnimation: state.moveAnimation,
                        ),
                      ),
                    );
                  },
                ),
              ),
              if (state.activeQuestion != null) ...<Widget>[
                const SizedBox(height: 12),
                _QuizPanel(
                  question: state.activeQuestion!,
                  onOptionTap: controller.onQuizOptionTap,
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _GridOverlayInfoBar extends StatelessWidget {
  const _GridOverlayInfoBar({
    required this.state,
    required this.onNewGame,
    required this.maxWidth,
  });

  final PalabraLinesGameState state;
  final VoidCallback onNewGame;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final showHint = maxWidth > 320;
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.65),
            borderRadius: BorderRadius.circular(32),
            border: Border.all(color: Colors.white.withOpacity(0.14), width: 1),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    _MiniStat(label: 'Score', value: state.score.toString()),
                    const SizedBox(width: 12),
                    _MiniStat(label: 'Best', value: state.highScore.toString()),
                    const SizedBox(width: 12),
                    FilledButton.tonalIcon(
                      onPressed: onNewGame,
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        visualDensity: VisualDensity.compact,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      icon: const Icon(Icons.restart_alt_rounded, size: 18),
                      label: const Text('New'),
                    ),
                  ],
                ),
                if (showHint) ...<Widget>[
                  const SizedBox(height: 4),
                  Text(
                    'Line up ${PalabraLinesConfig.lineLength} glowing marbles to reveal the word.',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: Colors.white70,
                      letterSpacing: 0.2,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: Colors.white70,
            fontSize: 11,
            letterSpacing: 0.4,
          ),
        ),
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class _QuizPanel extends StatelessWidget {
  const _QuizPanel({
    required this.question,
    required this.onOptionTap,
  });

  final PalabraLinesQuestionState question;
  final void Function(int index) onOptionTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.55),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.12), width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  'Translate this word',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (question.wrongAttempts > 0)
                  Text(
                    'Try again',
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: theme.colorScheme.error,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.08),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white.withOpacity(0.14)),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                child: Center(
                  child: Text(
                    question.entry.spanish.toUpperCase(),
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 12,
              runSpacing: 12,
              children: List<Widget>.generate(
                question.options.length,
                (index) => SizedBox(
                  width: 140,
                  child: Semantics(
                    button: true,
                    label:
                        'Answer ${index + 1} of ${question.options.length}: ${question.options[index]}',
                    hint: 'Double tap to submit this answer',
                    child: FilledButton(
                      onPressed: () => onOptionTap(index),
                      style: FilledButton.styleFrom(
                        backgroundColor: theme.colorScheme.secondary
                            .withOpacity(
                              0.95,
                            ),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Text(
                        question.options[index],
                        textAlign: TextAlign.center,
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SidebarInfo extends StatelessWidget {
  const _SidebarInfo({
    required this.state,
    required this.onNewGame,
    required this.onOptionTap,
  });

  final PalabraLinesGameState state;
  final VoidCallback onNewGame;
  final void Function(int index) onOptionTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        _HeaderSection(
          state: state,
          onNewGame: onNewGame,
        ),
        Text(
          'Create lines of ${PalabraLinesConfig.lineLength} balls to reveal a Spanish word, then answer without leaving the grid.',
          textAlign: TextAlign.center,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: Colors.white70),
        ),
        if (state.activeQuestion != null) ...<Widget>[
          const SizedBox(height: 16),
          _QuizPanel(
            question: state.activeQuestion!,
            onOptionTap: onOptionTap,
          ),
        ],
      ],
    );
  }
}
