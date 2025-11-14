import 'package:flutter/material.dart';
import 'package:palabra/feature_palabra_lines/domain/palabra_lines_config.dart';
import 'package:palabra/feature_palabra_lines/domain/palabra_lines_preview.dart';

/// Displays the next set of balls that will spawn on the board.
class PalabraLinesPreviewWidget extends StatelessWidget {
  const PalabraLinesPreviewWidget({
    required this.preview,
    super.key,
  });

  final List<PalabraLinesPreviewSlot> preview;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final total = PalabraLinesConfig.spawnPerTurn;
    final previewMap = <int, PalabraLinesPreviewSlot>{
      for (var i = 0; i < preview.length; i++) i: preview[i],
    };
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withOpacity(0.4),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.colorScheme.onSurface.withOpacity(0.12),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            'Próximas bolas',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List<Widget>.generate(
              total,
              (index) => _PreviewBall(slot: previewMap[index]),
            ),
          ),
        ],
      ),
    );
  }
}

class _PreviewBall extends StatelessWidget {
  const _PreviewBall({this.slot});

  final PalabraLinesPreviewSlot? slot;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color =
        slot?.color.color ?? theme.colorScheme.onSurface.withOpacity(0.25);
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: <Color>[
            Colors.white.withOpacity(slot == null ? 0.15 : 0.9),
            color,
          ],
        ),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
        ),
        boxShadow: slot == null
            ? null
            : <BoxShadow>[
                BoxShadow(
                  color: color.withOpacity(0.4),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ],
      ),
    );
  }
}
