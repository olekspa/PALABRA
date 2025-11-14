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
                constraints: constraints,
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
            child: AspectRatio(
              aspectRatio: 1,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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

class _StackedPalabraLinesLayout extends StatelessWidget {
  const _StackedPalabraLinesLayout({
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      child: Column(
        children: <Widget>[
          Expanded(
            child: Center(
              child: AspectRatio(
                aspectRatio: 1,
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
            ),
          ),
          const SizedBox(height: 12),
          _SidebarInfo(
            state: state,
            onNewGame: controller.startNewGame,
          ),
        ],
      ),
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
          style: Theme.of(context).textTheme.bodyMedium
              ?.copyWith(color: Colors.white70),
        ),
      ],
    );
  }
}
