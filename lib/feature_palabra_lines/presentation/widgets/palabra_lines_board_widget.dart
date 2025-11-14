import 'dart:math';

import 'package:characters/characters.dart';
import 'package:flutter/material.dart';
import 'package:palabra/feature_palabra_lines/domain/palabra_lines_board.dart';
import 'package:palabra/feature_palabra_lines/domain/palabra_lines_cell.dart';
import 'package:palabra/feature_palabra_lines/domain/palabra_lines_config.dart';
import 'package:palabra/feature_palabra_lines/domain/palabra_lines_game_state.dart';
import 'package:palabra/feature_palabra_lines/domain/palabra_lines_question.dart';

const double _gridPadding = 8;
const double _gridSpacing = 2;

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
    this.onQuizOptionTap,
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
  final void Function(int index)? onQuizOptionTap;

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
                if (moveAnimation != null) ...[
                  _PathOverlay(
                    animation: moveAnimation!,
                    boardWidth: boardWidth,
                    boardHeight: boardHeight,
                  ),
                  _MovingBallOverlay(
                    animation: moveAnimation!,
                    boardWidth: boardWidth,
                    boardHeight: boardHeight,
                  ),
                ],
                if (activeQuestion != null && onQuizOptionTap != null)
                  _BoardQuizOverlay(
                    question: activeQuestion!,
                    onOptionTap: onQuizOptionTap!,
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
    return GestureDetector(
      onTap: isLocked ? null : onTap,
      child: AnimatedContainer(
        key: ValueKey<String>('palabraLinesCell_${cell.row}_${cell.col}'),
        margin: const EdgeInsets.all(1),
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
              Positioned(
                top: 6,
                left: 6,
                child: _PreviewMarble(color: cell.previewColor!.color),
              ),
            if (cell.ballColor != null && !shouldHideBall)
              _PalabraLinesBall(color: cell.ballColor!.color),
          ],
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
  const _PreviewMarble({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 18,
      height: 18,
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
    required this.onOptionTap,
    required this.boardWidth,
    required this.boardHeight,
  });

  final PalabraLinesQuestionState question;
  final void Function(int index) onOptionTap;
  final double boardWidth;
  final double boardHeight;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final highlightCells = question.highlightCells;
    final cellWidth = _cellExtent(boardWidth);
    final cellHeight = _cellExtent(boardHeight);
    final scrim = Container(color: Colors.black.withOpacity(0.55));
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
        Positioned(
          top: 16,
          left: 16,
          right: 16,
          child: Column(
            children: <Widget>[
              Text(
                'Translate this word',
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              if (question.wrongAttempts > 0) ...<Widget>[
                const SizedBox(height: 6),
                Text(
                  'Try again!',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.error,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ],
          ),
        ),
        ...letterWidgets,
        Positioned(
          left: 16,
          right: 16,
          bottom: 16,
          child: _QuizOptions(
            options: question.options,
            onTap: onOptionTap,
          ),
        ),
      ],
    );
  }
}

class _QuizOptions extends StatelessWidget {
  const _QuizOptions({
    required this.options,
    required this.onTap,
  });

  final List<String> options;
  final void Function(int index) onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 12,
      runSpacing: 12,
      children: List<Widget>.generate(
        options.length,
        (index) => SizedBox(
          width: 140,
          child: FilledButton(
            onPressed: () => onTap(index),
            style: FilledButton.styleFrom(
              backgroundColor: theme.colorScheme.secondary.withOpacity(0.9),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: Text(
              options[index],
              textAlign: TextAlign.center,
              style: theme.textTheme.titleSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
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
    final start = _cellOffset(animation.from, cellWidth, cellHeight);
    final end = _cellOffset(animation.to, cellWidth, cellHeight);
    final tween = Tween<Offset>(
      begin: Offset(start.dx, start.dy),
      end: Offset(end.dx, end.dy),
    );
    final baseSize = min(cellWidth, cellHeight);
    final ballSize = (baseSize * 0.7).clamp(28.0, baseSize);
    return TweenAnimationBuilder<Offset>(
      key: ValueKey<int>(animation.id),
      tween: tween,
      duration: PalabraLinesMoveAnimation.duration,
      builder: (context, value, child) {
        return Positioned(
          left: value.dx,
          top: value.dy,
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

class _PathOverlay extends StatelessWidget {
  const _PathOverlay({
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
    final trailSize = (baseSize * 0.25).clamp(10, baseSize).toDouble();
    final dots = animation.path.map((point) {
      final offset = _cellOffset(point, cellWidth, cellHeight);
      return Positioned(
        left: offset.dx + (cellWidth - trailSize) / 2,
        top: offset.dy + (cellHeight - trailSize) / 2,
        child: Container(
          width: trailSize,
          height: trailSize,
          decoration: BoxDecoration(
            color: animation.color.color.withOpacity(0.4),
            borderRadius: BorderRadius.circular(trailSize / 2),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: animation.color.color.withOpacity(0.35),
                blurRadius: 6,
              ),
            ],
          ),
        ),
      );
    }).toList();
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 1, end: 0),
      duration: PalabraLinesMoveAnimation.duration,
      builder: (context, opacity, child) {
        return Opacity(
          opacity: opacity.clamp(0, 1),
          child: child,
        );
      },
      child: Stack(children: dots),
    );
  }
}
