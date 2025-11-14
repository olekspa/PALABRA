import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:palabra/feature_palabra_lines/domain/palabra_lines_board.dart';
import 'package:palabra/feature_palabra_lines/domain/palabra_lines_config.dart';
import 'package:palabra/feature_palabra_lines/domain/palabra_lines_question.dart';
import 'package:palabra/feature_palabra_lines/presentation/widgets/palabra_lines_board_widget.dart';
import 'package:palabra/feature_palabra_lines/presentation/widgets/palabra_lines_quiz_overlay.dart';

void main() {
  testWidgets('board widget renders every Color Lines cell', (tester) async {
    final board = PalabraLinesBoard.empty();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: PalabraLinesBoardWidget(
              board: board,
              selectedRow: null,
              selectedCol: null,
              isLocked: false,
              isGameOver: false,
              onCellTap: (_, __) {},
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

  testWidgets('quiz overlay displays Spanish word and options', (tester) async {
    const question = PalabraLinesQuestionState(
      entry: PalabraLinesVocabEntry(
        id: 'test',
        spanish: 'camino',
        english: 'road',
        level: 'a1',
      ),
      options: <String>['road', 'path', 'stone', 'flower', 'mind', 'rope'],
      correctIndex: 0,
    );
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Stack(
            children: <Widget>[
              const SizedBox.shrink(),
              PalabraLinesQuizOverlay(
                question: question,
                onOptionTap: (_) {},
              ),
            ],
          ),
        ),
      ),
    );
    expect(find.text('camino'), findsOneWidget);
    expect(find.byType(ElevatedButton), findsNWidgets(question.options.length));
  });
}
