import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:palabra/data_core/data_core.dart';
import 'package:palabra/data_core/models/run_log.dart';
import 'package:palabra/feature_finish/presentation/finish_screen.dart';

void main() {
  setUp(() {
    final store = InMemoryStore.instance;
    store.runLogs.clear();
    store.attemptLogs.clear();
    store.userMeta = UserMeta();
  });

  Widget _app() {
    return const ProviderScope(
      child: MaterialApp(home: FinishScreen()),
    );
  }

  group('FinishScreen', () {
    testWidgets('renders latest run summary when run log exists', (
      WidgetTester tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(1280, 2000));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final store = InMemoryStore.instance;
      final log = RunLog()
        ..tierReached = 3
        ..xpEarned = 40
        ..xpBonus = 10
        ..streakMax = 12
        ..cleanRun = true
        ..powerupsEarned = ['timeExtend']
        ..rowsUsed = 4
        ..timeExtendsUsed = 1
        ..matchesCompleted = 90
        ..attemptCount = 95
        ..durationMs = 60000
        ..deckComposition = [
          DeckLevelCount(level: 'a1', count: 10),
          DeckLevelCount(level: 'a2', count: 5),
        ]
        ..learnedPromoted = ['a1_0001']
        ..troubleDetected = ['a1_0002'];
      store.runLogs.insert(0, log);
      store.userMeta
        ..totalRuns = 12
        ..totalMatches = 600
        ..totalAttempts = 720
        ..totalTimeMs = 360000
        ..currentStreak = 3
        ..bestStreak = 5
        ..learnedCount = 20
        ..troubleCount = 7
        ..lastLearnedDelta = 1
        ..lastTroubleDelta = 1;

      await tester.pumpWidget(_app());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.text('Goal achieved!'), findsOneWidget);
      expect(find.text('You earned 40 XP (+10 bonus).'), findsOneWidget);
      expect(find.text('Tier reached'), findsOneWidget);
      expect(find.text('3'), findsWidgets);
      expect(find.text('Rows used'), findsOneWidget);
      expect(find.text('4'), findsWidgets);
      expect(find.text('A1'), findsOneWidget);
      expect(find.text('10'), findsWidgets);
      expect(find.text('Learned/Trouble delta'), findsOneWidget);
      expect(find.text('Learned +1 / Trouble +1'), findsOneWidget);
      expect(find.text('Powerups earned'), findsOneWidget);
      expect(find.text('Time Extend ×1'), findsOneWidget);
      expect(find.text('Lifetime stats'), findsOneWidget);
      expect(find.text('Runs played'), findsOneWidget);
      expect(find.text('12'), findsWidgets);
      expect(find.text('Current streak'), findsOneWidget);
      expect(find.text('3'), findsWidgets);
      expect(find.text('Best streak'), findsOneWidget);
      expect(find.text('5'), findsWidgets);
      expect(find.text('Avg matches/run'), findsOneWidget);
      expect(find.text('50.0'), findsOneWidget);
      expect(find.text('Avg accuracy'), findsOneWidget);
      expect(find.text('83.3%'), findsOneWidget);
      expect(find.text('Avg time/run'), findsOneWidget);
      expect(find.text('30s'), findsOneWidget);
    });

    testWidgets('shows fallback view when no runs exist', (
      WidgetTester tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(1280, 2000));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(_app());
      await tester.pump();

      expect(find.text('Run complete'), findsOneWidget);
      expect(find.text('You earned 0 XP.'), findsOneWidget);
      expect(find.text('Learned/Trouble delta'), findsOneWidget);
      expect(find.text('Learned +0 / Trouble +0'), findsOneWidget);
      expect(find.text('Lifetime stats'), findsNothing);
    });
  });
}
