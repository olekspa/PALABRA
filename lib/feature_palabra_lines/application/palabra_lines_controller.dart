import 'dart:collection';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:palabra/feature_palabra_lines/application/palabra_lines_vocab_service.dart';
import 'package:palabra/feature_palabra_lines/domain/palabra_lines_board.dart';
import 'package:palabra/feature_palabra_lines/domain/palabra_lines_cell.dart';
import 'package:palabra/feature_palabra_lines/domain/palabra_lines_config.dart';
import 'package:palabra/feature_palabra_lines/domain/palabra_lines_game_state.dart';
import 'package:palabra/feature_palabra_lines/domain/palabra_lines_preview.dart';
import 'package:palabra/feature_palabra_lines/domain/palabra_lines_question.dart';
import 'package:riverpod/riverpod.dart';

/// Controller driving the Palabra Lines state machine.
class PalabraLinesController extends StateNotifier<PalabraLinesGameState> {
  PalabraLinesController({
    PalabraLinesVocabService? vocabService,
    Random? random,
    int initialHighScore = 0,
  })  : _rng = random ?? Random(),
        _vocabService = vocabService,
        super(
          PalabraLinesGameState.initial(
            board: PalabraLinesBoard.empty(),
            highScore: initialHighScore,
          ),
        ) {
    startNewGame();
  }

  final Random _rng;
  final PalabraLinesVocabService? _vocabService;

  /// Resets the board, score, and preview to a clean game.
  void startNewGame() {
    var board = PalabraLinesBoard.empty();
    board = _seedInitialBalls(board);
    final previewResult = _generatePreview(board);
    board = previewResult.board;
    state = PalabraLinesGameState(
      board: board,
      preview: previewResult.preview,
      score: 0,
      highScore: state.highScore,
      phase: PalabraLinesPhase.idle,
      isGameOver: false,
      selectedRow: null,
      selectedCol: null,
      activeQuestion: null,
    );
  }

  /// Handles taps on the board grid.
  void onCellTap(int row, int col) {
    final current = state;
    if (current.isGameOver ||
        current.phase == PalabraLinesPhase.gameOver ||
        current.phase == PalabraLinesPhase.quiz) {
      return;
    }
    final cell = current.board.cellAt(row, col);
    final hasBall = cell.ballColor != null;
    final hasSelection =
        current.selectedRow != null && current.selectedCol != null;
    if (!hasSelection && hasBall) {
      state = current.copyWith(
        phase: PalabraLinesPhase.ballSelected,
        selectedRow: row,
        selectedCol: col,
      );
      return;
    }
    if (hasBall && hasSelection) {
      state = current.copyWith(
        phase: PalabraLinesPhase.ballSelected,
        selectedRow: row,
        selectedCol: col,
      );
      return;
    }
    if (!hasSelection || cell.ballColor != null) {
      return;
    }
    final fromRow = current.selectedRow!;
    final fromCol = current.selectedCol!;
    final canMove = _hasPath(current.board, fromRow, fromCol, row, col);
    if (!canMove) {
      return;
    }
    _applyMove(fromRow, fromCol, row, col);
  }

  /// Resolves taps on the quiz overlay options.
  void onQuizOptionTap(int index) {
    final question = state.activeQuestion;
    if (question == null || state.phase != PalabraLinesPhase.quiz) {
      return;
    }
    if (index != question.correctIndex) {
      state = state.copyWith(
        activeQuestion: question.markWrongAttempt(),
      );
      return;
    }
    _resumeAfterQuiz();
  }

  bool _hasPath(
    PalabraLinesBoard board,
    int fromRow,
    int fromCol,
    int toRow,
    int toCol,
  ) {
    if (fromRow == toRow && fromCol == toCol) {
      return false;
    }
    final visited = Set<Point<int>>();
    final queue = Queue<Point<int>>();
    final start = Point<int>(fromRow, fromCol);
    final target = Point<int>(toRow, toCol);
    visited.add(start);
    queue.add(start);
    while (queue.isNotEmpty) {
      final current = queue.removeFirst();
      if (current == target) {
        return true;
      }
      for (final delta in _neighborDeltas) {
        final next = Point<int>(
          current.x + delta.x,
          current.y + delta.y,
        );
        if (!board.isInside(next.x, next.y) || visited.contains(next)) {
          continue;
        }
        final nextCell = board.cellAt(next.x, next.y);
        final isDestination = next == target;
        final isFree =
            nextCell.ballColor == null && (!nextCell.hasPreview || isDestination);
        if (!isFree) {
          continue;
        }
        visited.add(next);
        queue.add(next);
      }
    }
    return false;
  }

  void _applyMove(int fromRow, int fromCol, int toRow, int toCol) {
    var board = state.board;
    final fromCell = board.cellAt(fromRow, fromCol);
    final movingColor = fromCell.ballColor;
    if (movingColor == null) {
      return;
    }
    board = board.setCell(
      fromRow,
      fromCol,
      PalabraLinesCell.empty(row: fromRow, col: fromCol),
    );
    final nextCell = PalabraLinesCell(
      row: toRow,
      col: toCol,
      ballColor: movingColor,
    );
    board = board.setCell(toRow, toCol, nextCell);
    final filteredPreview = state.preview
        .where((slot) => slot.row != toRow || slot.col != toCol)
        .toList(growable: false);
    state = state.copyWith(
      board: board,
      preview: filteredPreview,
      phase: PalabraLinesPhase.idle,
      selectedRow: null,
      selectedCol: null,
    );
    _handlePostMove(board);
  }

  void _handlePostMove(PalabraLinesBoard board) {
    final removal = _findAndRemoveLines(board);
    if (removal.removedCount > 0) {
      _handleLinesCleared(removal);
    } else {
      _spawnNewBalls(removal.board);
    }
  }

  void _handleLinesCleared(PalabraLinesLineRemovalResult result) {
    var workingBoard = result.board;
    final previewResult = _generatePreview(workingBoard);
    workingBoard = previewResult.board;
    final updatedScore = state.score + result.scoreDelta;
    final newHighScore = max(state.highScore, updatedScore);
    final question = _maybeCreateQuestion(result.removedCount);
    state = state.copyWith(
      board: workingBoard,
      preview: previewResult.preview,
      score: updatedScore,
      highScore: newHighScore,
      phase: question != null ? PalabraLinesPhase.quiz : PalabraLinesPhase.idle,
      activeQuestion: question,
    );
  }

  void _spawnNewBalls(PalabraLinesBoard board) {
    var workingBoard = board;
    for (final slot in state.preview) {
      final cell = workingBoard.cellAt(slot.row, slot.col);
      if (cell.ballColor != null) {
        continue;
      }
      workingBoard = workingBoard.setCell(
        slot.row,
        slot.col,
        PalabraLinesCell(
          row: slot.row,
          col: slot.col,
          ballColor: slot.color,
        ),
      );
    }
    final removal = _findAndRemoveLines(workingBoard);
    final updatedScore = state.score + removal.scoreDelta;
    final newHighScore = max(state.highScore, updatedScore);
    workingBoard = removal.board;
    final isBoardFull = !workingBoard.hasOpenCells;
    if (isBoardFull) {
      state = state.copyWith(
        board: workingBoard,
        preview: const <PalabraLinesPreviewSlot>[],
        score: updatedScore,
        highScore: newHighScore,
        phase: PalabraLinesPhase.gameOver,
        isGameOver: true,
        activeQuestion: null,
        selectedRow: null,
        selectedCol: null,
      );
      return;
    }
    final previewResult = _generatePreview(workingBoard);
    state = state.copyWith(
      board: previewResult.board,
      preview: previewResult.preview,
      score: updatedScore,
      highScore: newHighScore,
      phase: PalabraLinesPhase.idle,
      activeQuestion: null,
      selectedRow: null,
      selectedCol: null,
    );
  }

  PalabraLinesLineRemovalResult _findAndRemoveLines(PalabraLinesBoard board) {
    final cellsToClear = <Point<int>>{};
    for (final cell in board.cells) {
      final color = cell.ballColor;
      if (color == null) {
        continue;
      }
      _scanDirection(board, cell, const Point<int>(0, 1), cellsToClear);
      _scanDirection(board, cell, const Point<int>(1, 0), cellsToClear);
      _scanDirection(board, cell, const Point<int>(1, 1), cellsToClear);
      _scanDirection(board, cell, const Point<int>(1, -1), cellsToClear);
    }
    if (cellsToClear.isEmpty) {
      return PalabraLinesLineRemovalResult(board, 0, 0);
    }
    var updatedBoard = board;
    for (final point in cellsToClear) {
      updatedBoard = updatedBoard.setCell(
        point.x,
        point.y,
        PalabraLinesCell.empty(row: point.x, col: point.y),
      );
    }
    final removedCount = cellsToClear.length;
    return PalabraLinesLineRemovalResult(updatedBoard, removedCount, removedCount);
  }

  void _scanDirection(
    PalabraLinesBoard board,
    PalabraLinesCell origin,
    Point<int> delta,
    Set<Point<int>> sink,
  ) {
    final color = origin.ballColor;
    if (color == null) {
      return;
    }
    final forward =
        _collectInDirection(board, origin.row, origin.col, delta, color);
    final backward = _collectInDirection(
      board,
      origin.row,
      origin.col,
      Point<int>(-delta.x, -delta.y),
      color,
    );
    final total = <Point<int>>{...forward, ...backward};
    total.add(Point<int>(origin.row, origin.col));
    if (total.length >= PalabraLinesConfig.lineLength) {
      sink.addAll(total);
    }
  }

  Set<Point<int>> _collectInDirection(
    PalabraLinesBoard board,
    int startRow,
    int startCol,
    Point<int> delta,
    PalabraLinesColor color,
  ) {
    final results = <Point<int>>{};
    var row = startRow + delta.x;
    var col = startCol + delta.y;
    while (board.isInside(row, col)) {
      final cell = board.cellAt(row, col);
      if (cell.ballColor != color) {
        break;
      }
      results.add(Point<int>(row, col));
      row += delta.x;
      col += delta.y;
    }
    return results;
  }

  PalabraLinesBoard _seedInitialBalls(PalabraLinesBoard board) {
    var workingBoard = board;
    for (var i = 0; i < PalabraLinesConfig.initialBalls; i++) {
      final options = workingBoard.emptyPositions(includePreview: true).toList();
      if (options.isEmpty) {
        break;
      }
      final position = options[_rng.nextInt(options.length)];
      workingBoard = workingBoard.setCell(
        position.x,
        position.y,
        PalabraLinesCell(
          row: position.x,
          col: position.y,
          ballColor: _randomColor(),
        ),
      );
    }
    return workingBoard;
  }

  _PreviewResult _generatePreview(PalabraLinesBoard board) {
    var workingBoard = _clearPreviewMarkers(board);
    final options = workingBoard.emptyPositions().toList();
    if (options.isEmpty) {
      return _PreviewResult(workingBoard, const <PalabraLinesPreviewSlot>[]);
    }
    final count = min(PalabraLinesConfig.spawnPerTurn, options.length);
    final nextPreview = <PalabraLinesPreviewSlot>[];
    final remaining = List<Point<int>>.from(options);
    for (var i = 0; i < count; i++) {
      final index = _rng.nextInt(remaining.length);
      final position = remaining.removeAt(index);
      final color = _randomColor();
      workingBoard = workingBoard.updateCell(
        position.x,
        position.y,
        (cell) => cell.withPreview(color),
      );
      nextPreview.add(
        PalabraLinesPreviewSlot(
          row: position.x,
          col: position.y,
          color: color,
        ),
      );
    }
    return _PreviewResult(workingBoard, nextPreview);
  }

  PalabraLinesColor _randomColor() {
    final colors = PalabraLinesConfig.availableColors;
    return colors[_rng.nextInt(colors.length)];
  }

  void _resumeAfterQuiz() {
    state = state.copyWith(
      phase:
          state.isGameOver ? PalabraLinesPhase.gameOver : PalabraLinesPhase.idle,
      activeQuestion: null,
    );
  }

  PalabraLinesBoard _clearPreviewMarkers(PalabraLinesBoard board) {
    var working = board;
    for (final cell in board.cells) {
      if (cell.hasPreview) {
        working = working.setCell(
          cell.row,
          cell.col,
          PalabraLinesCell.empty(row: cell.row, col: cell.col),
        );
      }
    }
    return working;
  }

  @visibleForTesting
  bool debugHasPath(
    PalabraLinesBoard board,
    int fromRow,
    int fromCol,
    int toRow,
    int toCol,
  ) =>
      _hasPath(board, fromRow, fromCol, toRow, toCol);

  @visibleForTesting
  PalabraLinesLineRemovalResult debugFindAndRemoveLines(
    PalabraLinesBoard board,
  ) =>
      _findAndRemoveLines(board);

  PalabraLinesQuestionState? _maybeCreateQuestion(int clearedCount) {
    return _vocabService?.createQuestion(clearedCount);
  }
}

/// Result payload from the line detector.
class PalabraLinesLineRemovalResult {
  PalabraLinesLineRemovalResult(this.board, this.removedCount, this.scoreDelta);

  final PalabraLinesBoard board;
  final int removedCount;
  final int scoreDelta;
}

class _PreviewResult {
  _PreviewResult(this.board, this.preview);

  final PalabraLinesBoard board;
  final List<PalabraLinesPreviewSlot> preview;
}

const List<Point<int>> _neighborDeltas = <Point<int>>[
  Point<int>(0, 1),
  Point<int>(1, 0),
  Point<int>(0, -1),
  Point<int>(-1, 0),
];
