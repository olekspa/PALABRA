import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:palabra/design_system/widgets/gradient_background.dart';
import 'package:palabra/feature_palabra_lines/application/palabra_lines_providers.dart';
import 'package:palabra/feature_palabra_lines/domain/palabra_lines_config.dart';
import 'package:palabra/feature_palabra_lines/domain/palabra_lines_game_state.dart';
import 'package:palabra/feature_palabra_lines/presentation/widgets/palabra_lines_board_widget.dart';
import 'package:palabra/feature_palabra_lines/presentation/widgets/palabra_lines_preview_widget.dart';
import 'package:palabra/feature_palabra_lines/presentation/widgets/palabra_lines_quiz_overlay.dart';
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
          child: Stack(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(16),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final isWide = constraints.maxWidth > 900;
                    if (isWide) {
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          SizedBox(
                            width: 280,
                            child: _HeaderSection(
                              state: state,
                              onNewGame: controller.startNewGame,
                            ),
                          ),
                          const SizedBox(width: 24),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                PalabraLinesPreviewWidget(
                                  preview: state.preview,
                                ),
                                const SizedBox(height: 24),
                                Expanded(
                                  child: Center(
                                    child: PalabraLinesBoardWidget(
                                      board: state.board,
                                      selectedRow: state.selectedRow,
                                      selectedCol: state.selectedCol,
                                      isLocked: isLocked,
                                      isGameOver: state.isGameOver,
                                      onCellTap: controller.onCellTap,
                                    ),
                                  ),
                                ),
                                if (!state.isGameOver)
                                  const SizedBox(height: 24),
                                if (!state.isGameOver)
                                  Text(
                                    'Selecciona una bola y muévela\npor el camino libre como en Lines 98.',
                                    textAlign: TextAlign.center,
                                    style: Theme.of(context).textTheme.bodyLarge
                                        ?.copyWith(color: Colors.white70),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      );
                    }
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        _HeaderSection(
                          state: state,
                          onNewGame: controller.startNewGame,
                        ),
                        const SizedBox(height: 16),
                        PalabraLinesPreviewWidget(preview: state.preview),
                        const SizedBox(height: 16),
                        Expanded(
                          child: Center(
                            child: PalabraLinesBoardWidget(
                              board: state.board,
                              selectedRow: state.selectedRow,
                              selectedCol: state.selectedCol,
                              isLocked: isLocked,
                              isGameOver: state.isGameOver,
                              onCellTap: controller.onCellTap,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Forma líneas de ${PalabraLinesConfig.lineLength} bolas\npara contestar vocabulario español.',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(color: Colors.white70),
                        ),
                        const SizedBox(height: 12),
                      ],
                    );
                  },
                ),
              ),
              if (state.activeQuestion != null)
                PalabraLinesQuizOverlay(
                  question: state.activeQuestion!,
                  onOptionTap: controller.onQuizOptionTap,
                ),
            ],
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
