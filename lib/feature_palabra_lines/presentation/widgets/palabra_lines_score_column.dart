import 'dart:math';

import 'package:flutter/material.dart';

/// Displays score, best score, and the retro climbing column.
class PalabraLinesScoreColumn extends StatelessWidget {
  const PalabraLinesScoreColumn({
    required this.score,
    required this.highScore,
    required this.onNewGame,
    super.key,
  });

  final int score;
  final int highScore;
  final VoidCallback onNewGame;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final baseline = max(600, highScore);
    final progress = baseline == 0
        ? 0.0
        : (score / baseline).clamp(0, 1).toDouble();
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Text(
          'Palabra Lines',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Score: $score',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          'Best: $highScore',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: Colors.white70,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: 140,
          child: FilledButton(
            onPressed: onNewGame,
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 10),
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('New game'),
          ),
        ),
        const SizedBox(height: 8),
        _CompetitionColumn(progress: progress),
      ],
    );
  }
}

class _CompetitionColumn extends StatelessWidget {
  const _CompetitionColumn({required this.progress});

  final double progress;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const double columnHeight = 180;
    const double iconSize = 28;
    final clamped = progress.clamp(0, 1);
    final topOffset = (1 - clamped) * (columnHeight - iconSize);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Goal',
          style: theme.textTheme.labelLarge?.copyWith(
            color: Colors.white70,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: columnHeight,
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: <Widget>[
              Container(
                width: 56,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(
                    color: Colors.white38,
                    width: 2,
                  ),
                  gradient: const LinearGradient(
                    colors: <Color>[
                      Color(0xFF0E1A2D),
                      Color(0xFF1D3557),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
              Positioned(
                top: topOffset,
                child: Column(
                  children: <Widget>[
                    Icon(
                      Icons.emoji_people,
                      size: iconSize,
                      color: theme.colorScheme.secondary,
                    ),
                    Container(
                      width: 6,
                      height: 12,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.secondary,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
