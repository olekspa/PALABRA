import 'package:flutter/material.dart';

/// Static gameplay constants for Palabra Lines.
class PalabraLinesConfig {
  const PalabraLinesConfig._();

  static const int boardSize = 9;
  static const int initialBalls = 5;
  static const int spawnPerTurn = 3;
  static const int lineLength = 5;
  static const int quizOptions = 6;

  static const List<PalabraLinesColor> availableColors = <PalabraLinesColor>[
    PalabraLinesColor.red,
    PalabraLinesColor.green,
    PalabraLinesColor.blue,
    PalabraLinesColor.yellow,
    PalabraLinesColor.purple,
    PalabraLinesColor.cyan,
    PalabraLinesColor.orange,
  ];
}

/// Palette entries for rendered balls/preview markers.
enum PalabraLinesColor {
  red(Color(0xFFE53935)),
  green(Color(0xFF43A047)),
  blue(Color(0xFF1E88E5)),
  yellow(Color(0xFFFDD835)),
  purple(Color(0xFF8E24AA)),
  cyan(Color(0xFF26C6DA)),
  orange(Color(0xFFFB8C00));

  const PalabraLinesColor(this.color);

  final Color color;
}

/// Lifecycle phases for the controller state machine.
enum PalabraLinesPhase {
  idle,
  ballSelected,
  spawning,
  quiz,
  gameOver,
}

