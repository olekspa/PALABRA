import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:palabra/feature_palabra_lines/application/palabra_lines_controller.dart';
import 'package:palabra/data_core/models/vocab_item.dart';
import 'package:palabra/feature_palabra_lines/application/palabra_lines_vocab_service.dart';
import 'package:palabra/feature_palabra_lines/domain/palabra_lines_board.dart';
import 'package:palabra/feature_palabra_lines/domain/palabra_lines_cell.dart';
import 'package:palabra/feature_palabra_lines/domain/palabra_lines_config.dart';
import 'package:palabra/feature_palabra_lines/domain/palabra_lines_game_state.dart';
import 'package:palabra/feature_palabra_lines/domain/palabra_lines_question.dart';

void main() {
  PalabraLinesController createController() {
    final controller = PalabraLinesController(random: Random(1));
    controller.state = PalabraLinesGameState.initial(
      board: PalabraLinesBoard.empty(),
    );
    return controller;
  }

  PalabraLinesVocabService createVocabService() {
    final items = <VocabItem>[
      ..._buildItems('a1'),
      ..._buildItems('a2'),
      ..._buildItems('b2'),
    ];
    return PalabraLinesVocabService.fromItems(
      items: items,
      baseLevel: 'a1',
      random: Random(1),
    );
  }

  group('PalabraLinesController pathfinding', () {
    test('returns true when a clear path exists', () {
      final controller = createController();
      final board = PalabraLinesBoard.empty(size: 5);
      expect(
        controller.debugHasPath(board, 0, 0, 4, 4),
        isTrue,
      );
    });

    test('blocks movement when start is enclosed', () {
      final controller = createController();
      var board = PalabraLinesBoard.empty(size: 3);
      const blockers = <Point<int>>[
        Point<int>(0, 1),
        Point<int>(1, 0),
        Point<int>(1, 1),
      ];
      for (final blocker in blockers) {
        board = board.setCell(
          blocker.x,
          blocker.y,
          PalabraLinesCell(
            row: blocker.x,
            col: blocker.y,
            ballColor: PalabraLinesColor.blue,
          ),
        );
      }
      expect(
        controller.debugHasPath(board, 0, 0, 2, 2),
        isFalse,
      );
    });
  });

  group('PalabraLinesController line detection', () {
    test('clears horizontal lines of five or more', () {
      final controller = createController();
      var board = PalabraLinesBoard.empty(size: 5);
      for (var col = 0; col < PalabraLinesConfig.lineLength; col++) {
        board = board.setCell(
          0,
          col,
          PalabraLinesCell(
            row: 0,
            col: col,
            ballColor: PalabraLinesColor.green,
          ),
        );
      }
      final result = controller.debugFindAndRemoveLines(board);
      expect(result.removedCount, PalabraLinesConfig.lineLength);
      for (var col = 0; col < PalabraLinesConfig.lineLength; col++) {
        final cell = result.board.cellAt(0, col);
        expect(cell.ballColor, isNull);
      }
    });
  });

  group('PalabraLines vocab + quiz', () {
    test('vocab service scales tiers according to cleared count', () {
      final service = createVocabService();
      final baseQuestion = service.createQuestion(5);
      final intermediateQuestion = service.createQuestion(6);
      final advancedQuestion = service.createQuestion(7);
      expect(baseQuestion, isNotNull);
      expect(baseQuestion!.entry.level, 'a1');
      expect(intermediateQuestion, isNotNull);
      expect(intermediateQuestion!.entry.level, 'a2');
      expect(advancedQuestion, isNotNull);
      expect(advancedQuestion!.entry.level, 'b2');
    });

    test('controller ignores taps while quiz overlay is active', () {
      final controller = createController();
      const question = PalabraLinesQuestionState(
        entry: PalabraLinesVocabEntry(
          id: 'q1',
          spanish: 'uno',
          english: 'one',
          level: 'a1',
        ),
        options: <String>['one', 'two', 'three', 'four', 'five', 'six'],
        correctIndex: 0,
      );
      final initial = controller.state;
      controller.state = initial.copyWith(
        phase: PalabraLinesPhase.quiz,
        activeQuestion: question,
      );
      controller.onCellTap(0, 0);
      expect(controller.state.activeQuestion, isNotNull);
      expect(controller.state.phase, PalabraLinesPhase.quiz);
    });

    test('quiz answers update state appropriately', () {
      final controller = createController();
      const question = PalabraLinesQuestionState(
        entry: PalabraLinesVocabEntry(
          id: 'q1',
          spanish: 'uno',
          english: 'one',
          level: 'a1',
        ),
        options: <String>['one', 'two', 'three', 'four', 'five', 'six'],
        correctIndex: 0,
      );
      controller.state = controller.state.copyWith(
        phase: PalabraLinesPhase.quiz,
        activeQuestion: question,
      );
      controller.onQuizOptionTap(3);
      expect(controller.state.activeQuestion?.wrongAttempts, 1);
      expect(controller.state.phase, PalabraLinesPhase.quiz);
      controller.onQuizOptionTap(0);
      expect(controller.state.activeQuestion, isNull);
      expect(controller.state.phase, PalabraLinesPhase.idle);
    });
  });
}

List<VocabItem> _buildItems(String level) {
  return List<VocabItem>.generate(
    PalabraLinesConfig.quizOptions,
    (index) => VocabItem(
      itemId: '${level}_$index',
      english: '$level-en-$index',
      spanish: '$level-es-$index',
      level: level,
    ),
  );
}
