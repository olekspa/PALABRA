import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:palabra/design_system/widgets/gradient_background.dart';
import 'package:palabra/feature_palabra_lines/application/palabra_lines_controller.dart';
import 'package:palabra/feature_palabra_lines/application/palabra_lines_providers.dart';
import 'package:palabra/feature_palabra_lines/domain/palabra_lines_config.dart';
import 'package:palabra/feature_palabra_lines/domain/palabra_lines_game_state.dart';
import 'package:palabra/feature_palabra_lines/presentation/widgets/palabra_lines_board_widget.dart';
import 'package:palabra/feature_palabra_lines/presentation/widgets/palabra_lines_score_column.dart';

class PalabraLinesScreen extends ConsumerWidget {
  const PalabraLinesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                      onQuizOptionTap: controller.onQuizOptionTap,
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
          ),
        ),
      ],
    );
  }
}

const double _mobileBoardHeightFactor = 1.18;

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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
      child: Column(
        children: <Widget>[
          Expanded(
            child: LayoutBuilder(
              builder: (context, boxConstraints) {
                final boardWidth = min(
                  boxConstraints.maxWidth,
                  boxConstraints.maxHeight,
                );
                final availableHeight = boxConstraints.maxHeight;
                final desiredHeight = boardWidth * _mobileBoardHeightFactor;
                final boardHeight = min(
                  availableHeight,
                  desiredHeight,
                ).clamp(boardWidth, availableHeight).toDouble();
                return Center(
                  child: SizedBox(
                    width: boardWidth,
                    height: boardHeight,
                    child: Stack(
                      children: <Widget>[
                        Positioned.fill(
                          child: PalabraLinesBoardWidget(
                            board: state.board,
                            selectedRow: state.selectedRow,
                            selectedCol: state.selectedCol,
                            isLocked: isLocked,
                            isGameOver: state.isGameOver,
                            onCellTap: controller.onCellTap,
                            activeQuestion: state.activeQuestion,
                            onQuizOptionTap: controller.onQuizOptionTap,
                            moveAnimation: state.moveAnimation,
                          ),
                        ),
                        Positioned(
                          top: 12,
                          left: 12,
                          right: 12,
                          child: _GridOverlayInfoBar(
                            state: state,
                            onNewGame: controller.startNewGame,
                            maxWidth: max(0.0, boardWidth - 24),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
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
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
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

class _SidebarInfo extends StatelessWidget {
  const _SidebarInfo({
    required this.state,
    required this.onNewGame,
  });

  final PalabraLinesGameState state;
  final VoidCallback onNewGame;

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
      ],
    );
  }
}
