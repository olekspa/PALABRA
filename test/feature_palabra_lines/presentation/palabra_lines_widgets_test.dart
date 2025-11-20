import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:palabra/feature_palabra_lines/domain/palabra_lines_board.dart';
import 'package:palabra/feature_palabra_lines/domain/palabra_lines_config.dart';
import 'package:palabra/feature_palabra_lines/domain/palabra_lines_question.dart';
import 'package:palabra/feature_palabra_lines/presentation/widgets/palabra_lines_board_widget.dart';

void main() {
  testWidgets('board widget renders every Color Lines cell', (tester) async {
    final board = PalabraLinesBoard.empty();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 360,
              height: 440,
              child: PalabraLinesBoardWidget(
                board: board,
                selectedRow: null,
                selectedCol: null,
                isLocked: false,
                isGameOver: false,
                onCellTap: (_, __) {},
                activeQuestion: null,
                moveAnimation: null,
              ),
            ),
          ),
        ),
      ),
    );
    final cellFinder = find.byWidgetPredicate((widget) {
      final key = widget.key;
      if (key is! ValueKey<String>) {
        return false;
      }
      return key.value.startsWith('palabraLinesCell_');
    });
    expect(
      cellFinder.evaluate().length,
      PalabraLinesConfig.boardSize * PalabraLinesConfig.boardSize,
    );
  });

  testWidgets('quiz prompt renders inside the board', (tester) async {
    const question = PalabraLinesQuestionState(
      entry: PalabraLinesVocabEntry(
        id: 'test',
        spanish: 'camino',
        english: 'road',
        level: 'a1',
      ),
      options: <String>['road', 'path', 'stone', 'flower', 'mind', 'rope'],
      correctIndex: 0,
      highlightCells: <Point<int>>[
        Point<int>(4, 0),
        Point<int>(4, 1),
        Point<int>(4, 2),
        Point<int>(4, 3),
        Point<int>(4, 4),
      ],
    );
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 420,
              height: 480,
              child: PalabraLinesBoardWidget(
                board: PalabraLinesBoard.empty(),
                selectedRow: null,
                selectedCol: null,
              isLocked: true,
              isGameOver: false,
              onCellTap: (_, __) {},
              activeQuestion: question,
              moveAnimation: null,
            ),
          ),
        ),
      ),
      ),
    );
    for (final letter in <String>['C', 'A', 'M', 'I', 'N']) {
      expect(find.text(letter), findsWidgets);
    }
    expect(find.byType(FilledButton), findsNothing);
  });
}
