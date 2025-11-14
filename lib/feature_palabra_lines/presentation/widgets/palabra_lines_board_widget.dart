import 'package:flutter/material.dart';
import 'package:palabra/feature_palabra_lines/domain/palabra_lines_board.dart';
import 'package:palabra/feature_palabra_lines/domain/palabra_lines_cell.dart';
import 'package:palabra/feature_palabra_lines/domain/palabra_lines_config.dart';

/// Renders the 9x9 Palabra Lines grid with selectable cells.
class PalabraLinesBoardWidget extends StatelessWidget {
  const PalabraLinesBoardWidget({
    required this.board,
    required this.selectedRow,
    required this.selectedCol,
    required this.isLocked,
    required this.isGameOver,
    required this.onCellTap,
    super.key,
  });

  final PalabraLinesBoard board;
  final int? selectedRow;
  final int? selectedCol;
  final bool isLocked;
  final bool isGameOver;
  final void Function(int row, int col) onCellTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final background = theme.colorScheme.surfaceVariant.withOpacity(0.4);
    final border = theme.colorScheme.onSurface.withOpacity(0.1);
    final boardSize = PalabraLinesConfig.boardSize;
    return AspectRatio(
      aspectRatio: 1,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Container(
          decoration: BoxDecoration(
            color: background,
            border: Border.all(color: border, width: 2),
          ),
          child: Stack(
            children: <Widget>[
              IgnorePointer(
                ignoring: isLocked,
                child: GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: boardSize,
                    mainAxisSpacing: 2,
                    crossAxisSpacing: 2,
                  ),
                  padding: const EdgeInsets.all(8),
                  itemCount: boardSize * boardSize,
                  itemBuilder: (context, index) {
                    final row = index ~/ boardSize;
                    final col = index % boardSize;
                    final cell = board.cellAt(row, col);
                    final isSelected = selectedRow == row && selectedCol == col;
                    return _PalabraLinesCellTile(
                      cell: cell,
                      isSelected: isSelected,
                      isLocked: isLocked,
                      onTap: () => onCellTap(row, col),
                    );
                  },
                ),
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
                        'Sin espacios\nJuego terminado',
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
          ),
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
    required this.onTap,
  });

  final PalabraLinesCell cell;
  final bool isSelected;
  final bool isLocked;
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
              Align(
                alignment: Alignment.center,
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: cell.previewColor!.color.withOpacity(0.7),
                  ),
                ),
              ),
            if (cell.ballColor != null)
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
  });

  final Color color;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutBack,
      width: 36,
      height: 36,
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
