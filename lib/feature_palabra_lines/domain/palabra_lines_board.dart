import 'dart:math';

import 'package:palabra/feature_palabra_lines/domain/palabra_lines_cell.dart';
import 'package:palabra/feature_palabra_lines/domain/palabra_lines_config.dart';

/// Immutable board state for Palabra Lines.
class PalabraLinesBoard {
  PalabraLinesBoard._(this.size, List<PalabraLinesCell> cells)
    : _cells = List<PalabraLinesCell>.unmodifiable(cells);

  factory PalabraLinesBoard.empty({int size = PalabraLinesConfig.boardSize}) {
    final cells = <PalabraLinesCell>[];
    for (var row = 0; row < size; row++) {
      for (var col = 0; col < size; col++) {
        cells.add(PalabraLinesCell.empty(row: row, col: col));
      }
    }
    return PalabraLinesBoard._(size, cells);
  }

  final int size;
  final List<PalabraLinesCell> _cells;

  List<PalabraLinesCell> get cells => _cells;

  bool isInside(int row, int col) =>
      row >= 0 && row < size && col >= 0 && col < size;

  int _index(int row, int col) => row * size + col;

  PalabraLinesCell cellAt(int row, int col) => _cells[_index(row, col)];

  PalabraLinesBoard updateCell(
    int row,
    int col,
    PalabraLinesCell Function(PalabraLinesCell cell) updater,
  ) {
    final index = _index(row, col);
    final updated = List<PalabraLinesCell>.from(_cells);
    updated[index] = updater(_cells[index]);
    return PalabraLinesBoard._(size, updated);
  }

  PalabraLinesBoard setCell(int row, int col, PalabraLinesCell cell) {
    final index = _index(row, col);
    final updated = List<PalabraLinesCell>.from(_cells);
    updated[index] = cell;
    return PalabraLinesBoard._(size, updated);
  }

  Iterable<Point<int>> emptyPositions({bool includePreview = false}) sync* {
    for (final cell in _cells) {
      final isAvailable =
          cell.ballColor == null && (includePreview || !cell.hasPreview);
      if (isAvailable) {
        yield Point<int>(cell.row, cell.col);
      }
    }
  }

  bool get hasOpenCells => emptyPositions(includePreview: true).isNotEmpty;

  int countBalls() {
    return _cells.where((cell) => cell.ballColor != null).length;
  }
}

