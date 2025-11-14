import 'dart:math';

import 'package:palabra/feature_palabra_lines/domain/palabra_lines_board.dart';
import 'package:palabra/feature_palabra_lines/domain/palabra_lines_config.dart';
import 'package:palabra/feature_palabra_lines/domain/palabra_lines_preview.dart';
import 'package:palabra/feature_palabra_lines/domain/palabra_lines_question.dart';

/// Aggregate state published by the Palabra Lines controller.
class PalabraLinesGameState {
  PalabraLinesGameState({
    required this.board,
    required this.preview,
    required this.score,
    required this.highScore,
    required this.phase,
    required this.isGameOver,
    required this.selectedRow,
    required this.selectedCol,
    required this.activeQuestion,
    required this.moveAnimation,
  });

  factory PalabraLinesGameState.initial({
    PalabraLinesBoard? board,
    int highScore = 0,
  }) {
    return PalabraLinesGameState(
      board: board ?? PalabraLinesBoard.empty(),
      preview: const <PalabraLinesPreviewSlot>[],
      score: 0,
      highScore: highScore,
      phase: PalabraLinesPhase.idle,
      isGameOver: false,
      selectedRow: null,
      selectedCol: null,
      activeQuestion: null,
      moveAnimation: null,
    );
  }

  final PalabraLinesBoard board;
  final List<PalabraLinesPreviewSlot> preview;
  final int score;
  final int highScore;
  final PalabraLinesPhase phase;
  final bool isGameOver;
  final int? selectedRow;
  final int? selectedCol;
  final PalabraLinesQuestionState? activeQuestion;
  final PalabraLinesMoveAnimation? moveAnimation;

  static const _sentinel = Object();

  PalabraLinesGameState copyWith({
    PalabraLinesBoard? board,
    List<PalabraLinesPreviewSlot>? preview,
    int? score,
    int? highScore,
    PalabraLinesPhase? phase,
    bool? isGameOver,
    Object? selectedRow = _sentinel,
    Object? selectedCol = _sentinel,
    Object? activeQuestion = _sentinel,
    Object? moveAnimation = _sentinel,
  }) {
    return PalabraLinesGameState(
      board: board ?? this.board,
      preview: preview ?? this.preview,
      score: score ?? this.score,
      highScore: highScore ?? this.highScore,
      phase: phase ?? this.phase,
      isGameOver: isGameOver ?? this.isGameOver,
      selectedRow:
          selectedRow == _sentinel ? this.selectedRow : selectedRow as int?,
      selectedCol:
          selectedCol == _sentinel ? this.selectedCol : selectedCol as int?,
      activeQuestion: activeQuestion == _sentinel
          ? this.activeQuestion
          : activeQuestion as PalabraLinesQuestionState?,
      moveAnimation: moveAnimation == _sentinel
          ? this.moveAnimation
          : moveAnimation as PalabraLinesMoveAnimation?,
    );
  }

  PalabraLinesGameState clearSelection() {
    return copyWith(selectedRow: null, selectedCol: null);
  }
}

/// Metadata describing an in-flight ball movement animation.
class PalabraLinesMoveAnimation {
  const PalabraLinesMoveAnimation({
    required this.id,
    required this.from,
    required this.to,
    required this.color,
    required this.path,
  });

  final int id;
  final Point<int> from;
  final Point<int> to;
  final PalabraLinesColor color;
  final List<Point<int>> path;

  static const Duration duration = Duration(milliseconds: 320);
}
