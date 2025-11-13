import 'package:palabra/feature_palabra_lines/domain/palabra_lines_config.dart';

/// Metadata describing a reserved spawn slot from the preview.
class PalabraLinesPreviewSlot {
  const PalabraLinesPreviewSlot({
    required this.row,
    required this.col,
    required this.color,
  });

  final int row;
  final int col;
  final PalabraLinesColor color;
}

