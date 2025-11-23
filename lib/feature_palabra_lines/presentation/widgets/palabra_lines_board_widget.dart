import 'dart:math';
import 'dart:ui';

import 'package:characters/characters.dart';
import 'package:flutter/material.dart';
import 'package:palabra/feature_palabra_lines/domain/palabra_lines_board.dart';
import 'package:palabra/feature_palabra_lines/domain/palabra_lines_cell.dart';
import 'package:palabra/feature_palabra_lines/domain/palabra_lines_config.dart';
import 'package:palabra/feature_palabra_lines/domain/palabra_lines_game_state.dart';
import 'package:palabra/feature_palabra_lines/domain/palabra_lines_question.dart';

const double _gridPadding = 6;
const double _gridSpacing = 1.2;

/// Renders the 9x9 Palabra Lines grid with selectable cells.
class PalabraLinesBoardWidget extends StatelessWidget {
  const PalabraLinesBoardWidget({
    required this.board,
    required this.selectedRow,
    required this.selectedCol,
    required this.isLocked,
    required this.isGameOver,
    required this.onCellTap,
    required this.activeQuestion,
    required this.moveAnimation,
    super.key,
  });

  final PalabraLinesBoard board;
  final int? selectedRow;
  final int? selectedCol;
  final bool isLocked;
  final bool isGameOver;
  final void Function(int row, int col) onCellTap;
  final PalabraLinesQuestionState? activeQuestion;
  final PalabraLinesMoveAnimation? moveAnimation;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final background = theme.colorScheme.surfaceVariant.withOpacity(0.4);
    final border = theme.colorScheme.onSurface.withOpacity(0.1);
    final boardSize = PalabraLinesConfig.boardSize;
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: Container(
        decoration: BoxDecoration(
          color: background,
          border: Border.all(color: border, width: 2),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final boardWidth = constraints.maxWidth;
            final boardHeight = constraints.maxHeight;
            final cellWidth = _cellExtent(boardWidth);
            final cellHeight = _cellExtent(boardHeight);
            final cellAspectRatio = _cellAspectRatio(cellWidth, cellHeight);
            return Stack(
              children: <Widget>[
                IgnorePointer(
                  ignoring: isLocked,
                  child: Padding(
                    padding: const EdgeInsets.all(_gridPadding),
                    child: GridView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: boardSize,
                        mainAxisSpacing: _gridSpacing,
                        crossAxisSpacing: _gridSpacing,
                        childAspectRatio: cellAspectRatio,
                      ),
                      itemCount: boardSize * boardSize,
                      itemBuilder: (context, index) {
                        final row = index ~/ boardSize;
                        final col = index % boardSize;
                        final cell = board.cellAt(row, col);
                        final isSelected =
                            selectedRow == row && selectedCol == col;
                        final shouldHideBall =
                            moveAnimation != null &&
                            moveAnimation!.to.x == row &&
                            moveAnimation!.to.y == col;
                        return _PalabraLinesCellTile(
                          cell: cell,
                          isSelected: isSelected,
                          isLocked: isLocked,
                          shouldHideBall: shouldHideBall,
                          onTap: () => onCellTap(row, col),
                        );
                      },
                    ),
                  ),
                ),
                if (moveAnimation != null)
                  _MovingBallOverlay(
                    animation: moveAnimation!,
                    boardWidth: boardWidth,
                    boardHeight: boardHeight,
                  ),
                if (activeQuestion != null)
                  _BoardQuizOverlay(
                    question: activeQuestion!,
                    boardWidth: boardWidth,
                    boardHeight: boardHeight,
                  ),
                if (isGameOver)
                  Container(
                    color: Colors.black54,
                    alignment: Alignment.center,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: const <Widget>[
                        Icon(
                          Icons.flag,
                          color: Colors.white,
                          size: 48,
                        ),
                        SizedBox(height: 8),
                        Text(
                          'No more moves\nGame over',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 22,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _PalabraLinesCellTile extends StatelessWidget {
  const _PalabraLinesCellTile({
    required this.cell,
    required this.isSelected,
    required this.isLocked,
    required this.shouldHideBall,
    required this.onTap,
  });

  final PalabraLinesCell cell;
  final bool isSelected;
  final bool isLocked;
  final bool shouldHideBall;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final borderColor = isSelected
        ? theme.colorScheme.primary
        : theme.colorScheme.onSurface.withOpacity(0.15);
    final tileColor = isSelected
        ? theme.colorScheme.primary.withOpacity(0.18)
        : Colors.black.withOpacity(0.15);
    final highlight = isSelected
        ? theme.colorScheme.primary.withOpacity(0.3)
        : Colors.white.withOpacity(0.08);
    final colorLabel = cell.ballColor?.name ?? 'empty';
    final previewLabel = cell.hasPreview && cell.previewColor != null
        ? 'preview'
        : '';
    final label = StringBuffer()
      ..write('Row ${cell.row + 1}, column ${cell.col + 1}. ')
      ..write(cell.ballColor != null ? 'Ball $colorLabel. ' : 'Empty cell. ')
      ..write(previewLabel);
    return Semantics(
      container: true,
      button: true,
      selected: isSelected,
      enabled: !isLocked,
      focusable: true,
      label: label.toString().trim(),
      hint: isLocked ? 'Action locked' : 'Double tap to select or move here',
      onTap: isLocked ? null : onTap,
      child: GestureDetector(
        onTap: isLocked ? null : onTap,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final tileSide = min(constraints.maxWidth, constraints.maxHeight);
            final ballMin = min(30.0, tileSide);
            final ballSize = min(
              tileSide,
              max(tileSide * 0.82, ballMin),
            ).toDouble();
            final previewMax = tileSide * 0.6;
            final previewMin = min(14.0, previewMax);
            final previewSize = min(
              tileSide,
              max(tileSide * 0.4, previewMin),
            ).toDouble();
            return AnimatedContainer(
              key: ValueKey<String>('palabraLinesCell_${cell.row}_${cell.col}'),
              margin: const EdgeInsets.all(0.5),
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                color: tileColor,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: borderColor, width: 1.5),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: <Widget>[
                  if (cell.ballColor == null)
                    Align(
                      alignment: Alignment.center,
                      child: Container(
                        width: double.infinity,
                        height: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          gradient: LinearGradient(
                            colors: <Color>[
                              Colors.white.withOpacity(0.015),
                              highlight,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                      ),
                    ),
                  if (cell.hasPreview && cell.previewColor != null)
                    Center(
                      child: SizedBox.square(
                        dimension: previewSize,
                        child: _PreviewMarble(
                          color: cell.previewColor!.color,
                          size: previewSize,
                        ),
                      ),
                    ),
                  if (cell.ballColor != null && !shouldHideBall)
                    _PalabraLinesBall(
                      color: cell.ballColor!.color,
                      diameter: ballSize,
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _PalabraLinesBall extends StatelessWidget {
  const _PalabraLinesBall({
    required this.color,
    this.diameter = 36,
  });

  final Color color;
  final double diameter;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutBack,
      width: diameter,
      height: diameter,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: <Color>[
            Colors.white.withOpacity(0.85),
            color,
          ],
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: color.withOpacity(0.55),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
    );
  }
}

class _PreviewMarble extends StatelessWidget {
  const _PreviewMarble({
    required this.color,
    this.size = 18,
  });

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: <Color>[
            color.withOpacity(0.45),
            color.withOpacity(0.9),
          ],
        ),
        border: Border.all(
          color: Colors.white.withOpacity(0.4),
          width: 1,
        ),
      ),
    );
  }
}

class _BoardQuizOverlay extends StatelessWidget {
  const _BoardQuizOverlay({
    required this.question,
    required this.boardWidth,
    required this.boardHeight,
  });

  final PalabraLinesQuestionState question;
  final double boardWidth;
  final double boardHeight;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final highlightCells = question.highlightCells;
    final cellWidth = _cellExtent(boardWidth);
    final cellHeight = _cellExtent(boardHeight);
    final scrim = Container(color: Colors.black.withOpacity(0.4));
    final letters = question.entry.spanish.characters.toList();
    final letterWidgets = <Widget>[];
    for (var i = 0; i < highlightCells.length; i++) {
      final point = highlightCells[i];
      final offset = _cellOffset(point, cellWidth, cellHeight);
      final letter = i < letters.length ? letters[i].toUpperCase() : '';
      letterWidgets.add(
        Positioned(
          left: offset.dx,
          top: offset.dy,
          child: Container(
            width: cellWidth,
            height: cellHeight,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: theme.colorScheme.primary.withOpacity(0.45),
            ),
            child: Center(
              child: Text(
                letter,
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ),
        ),
      );
    }
    return Stack(
      children: <Widget>[
        scrim,
        ...letterWidgets,
      ],
    );
  }
}

double _cellExtent(double boardSpan) {
  final spacingTotal =
      _gridSpacing * (PalabraLinesConfig.boardSize - 1) + _gridPadding * 2;
  final available = max(0.0, boardSpan - spacingTotal);
  return available / PalabraLinesConfig.boardSize;
}

double _cellAspectRatio(double cellWidth, double cellHeight) {
  if (cellHeight <= 0) {
    return 1;
  }
  final safeWidth = max(cellWidth, 1);
  final safeHeight = max(cellHeight, 1);
  return safeWidth / safeHeight;
}

Offset _cellOffset(Point<int> cell, double cellWidth, double cellHeight) {
  final row = cell.x;
  final col = cell.y;
  final dx = _gridPadding + col * (cellWidth + _gridSpacing);
  final dy = _gridPadding + row * (cellHeight + _gridSpacing);
  return Offset(dx, dy);
}

Offset _offsetAlongPath(
  List<Point<int>> path,
  double progress,
  double cellWidth,
  double cellHeight,
) {
  if (path.isEmpty) {
    return Offset.zero;
  }
  final clamped = progress.clamp(0.0, 1.0);
  final hopCount = max(path.length - 1, 1);
  final position = clamped * hopCount;
  final index = position.floor().clamp(0, hopCount - 1);
  final t = position - index;
  final start = path[index];
  final end = path[min(index + 1, path.length - 1)];
  final startOffset = _cellOffset(start, cellWidth, cellHeight);
  final endOffset = _cellOffset(end, cellWidth, cellHeight);
  return Offset(
    lerpDouble(startOffset.dx, endOffset.dx, t)!,
    lerpDouble(startOffset.dy, endOffset.dy, t)!,
  );
}

class _MovingBallOverlay extends StatelessWidget {
  const _MovingBallOverlay({
    required this.animation,
    required this.boardWidth,
    required this.boardHeight,
  });

  final PalabraLinesMoveAnimation animation;
  final double boardWidth;
  final double boardHeight;

  @override
  Widget build(BuildContext context) {
    final cellWidth = _cellExtent(boardWidth);
    final cellHeight = _cellExtent(boardHeight);
    final baseSize = min(cellWidth, cellHeight);
    final ballMin = min(30.0, baseSize);
    final ballSize = min(baseSize, max(baseSize * 0.82, ballMin));
    return TweenAnimationBuilder<double>(
      key: ValueKey<int>(animation.id),
      tween: Tween<double>(begin: 0, end: 1),
      duration: animation.movementDuration,
      builder: (context, value, child) {
        final offset = _offsetAlongPath(
          animation.path,
          value,
          cellWidth,
          cellHeight,
        );
        return Positioned(
          left: offset.dx,
          top: offset.dy,
          child: SizedBox(
            width: cellWidth,
            height: cellHeight,
            child: Center(
              child: _PalabraLinesBall(
                color: animation.color.color,
                diameter: ballSize,
              ),
            ),
          ),
        );
      },
    );
  }
}
