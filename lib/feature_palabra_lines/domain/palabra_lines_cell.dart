import 'package:palabra/feature_palabra_lines/domain/palabra_lines_config.dart';

/// Immutable representation of a single grid position.
class PalabraLinesCell {
  const PalabraLinesCell({
    required this.row,
    required this.col,
    this.ballColor,
    this.hasPreview = false,
    this.previewColor,
  });

  const PalabraLinesCell.empty({
    required this.row,
    required this.col,
  })  : ballColor = null,
        hasPreview = false,
        previewColor = null;

  final int row;
  final int col;
  final PalabraLinesColor? ballColor;
  final bool hasPreview;
  final PalabraLinesColor? previewColor;

  bool get isEmpty => ballColor == null && !hasPreview;

  PalabraLinesCell clearBall() {
    return PalabraLinesCell(
      row: row,
      col: col,
      ballColor: null,
      hasPreview: hasPreview,
      previewColor: previewColor,
    );
  }

  PalabraLinesCell withBall(PalabraLinesColor color) {
    return PalabraLinesCell(
      row: row,
      col: col,
      ballColor: color,
      hasPreview: false,
      previewColor: null,
    );
  }

  PalabraLinesCell withPreview(PalabraLinesColor color) {
    return PalabraLinesCell(
      row: row,
      col: col,
      ballColor: ballColor,
      hasPreview: true,
      previewColor: color,
    );
  }

  PalabraLinesCell clearPreview() {
    return PalabraLinesCell(
      row: row,
      col: col,
      ballColor: ballColor,
      hasPreview: false,
      previewColor: null,
    );
  }

  PalabraLinesCell clearAll() => PalabraLinesCell.empty(row: row, col: col);
}
