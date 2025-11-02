// ignore_for_file: cascade_invocations

import 'package:flutter_test/flutter_test.dart';
import 'package:palabra/data_core/models/attempt_log.dart';
import 'package:palabra/data_core/models/run_log.dart';
import 'package:palabra/data_core/models/user_item_state.dart';
import 'package:palabra/data_core/models/user_meta.dart';
import 'package:palabra/data_core/models/vocab_item.dart';
import 'package:palabra/data_core/repositories/user_meta_repository.dart';
import 'package:palabra/feature_run/application/run_controller.dart';
import 'package:palabra/feature_run/application/run_settings.dart';
import 'package:palabra/feature_run/application/run_state.dart';
import 'package:palabra/feature_run/application/timer_service.dart';
import 'package:palabra/feature_srs/deck_builder/deck_builder_service.dart';

class _InMemoryUserMetaRepository implements UserMetaRepository {
  _InMemoryUserMetaRepository(this._meta);

  UserMeta _meta;

  @override
  Future<UserMeta> getOrCreate() async => _meta;

  @override
  Future<void> save(UserMeta meta) async {
    _meta = meta;
  }
}

DeckBuilderService _buildDeckBuilder({int deckSize = 50}) {
  final vocab = <String, List<VocabItem>>{
    'a1': List.generate(
      deckSize,
      (index) => VocabItem()
        ..itemId = 'a1_${index.toString().padLeft(4, '0')}'
        ..english = 'english_$index'
        ..spanish = 'spanish_$index'
        ..level = 'a1'
        ..family = 'family_$index'
        ..topic = 'topic',
    ),
  };

  Future<List<VocabItem>> vocabularyFetcher(String level) async {
    return List<VocabItem>.from(vocab[level] ?? const <VocabItem>[]);
  }

  Future<Map<String, UserItemState>> progressFetcher(
    Iterable<String> itemIds,
  ) async {
    return {
      for (final id in itemIds)
        id: (UserItemState()
          ..itemId = id
          ..seenCount = 0),
    };
  }

  return DeckBuilderService(
    vocabularyFetcher: vocabularyFetcher,
    progressFetcher: progressFetcher,
    userMetaRepository: _InMemoryUserMetaRepository(UserMeta()),
    config: DeckBuilderConfig(deckSize: deckSize),
  );
}

void main() {
  group('RunController', () {
    test('initializes board with deck data', () async {
      final userStates = <String, UserItemState>{};
      Future<List<UserItemState>> fetchStates(Iterable<String> ids) async {
        return ids
            .map(
              (id) => userStates.putIfAbsent(
                id,
                () => UserItemState()..itemId = id,
              ),
            )
            .toList();
      }

      Future<void> saveStates(List<UserItemState> states) async {
        for (final state in states) {
          userStates[state.itemId] = state;
        }
      }

      final runLogs = <RunLog>[];
      Future<int> addRunLog(RunLog log) async {
        runLogs.add(log);
        return runLogs.length;
      }

      final attempts = <AttemptLog>[];
      Future<void> addAttempts(List<AttemptLog> entries) async {
        attempts.addAll(entries);
      }

      final controller = RunController(
        deckBuilderService: _buildDeckBuilder(deckSize: 30),
        settings: const RunSettings(),
        timerService: RunTimerService.fake(),
        fetchUserStates: fetchStates,
        saveUserStates: saveStates,
        addRunLog: addRunLog,
        addAttemptLogs: addAttempts,
      );

      await controller.initialize();

      final state = controller.state;
      expect(state.isReady, isTrue);
      expect(state.board.length, 5);
      expect(state.deckRemaining, greaterThan(0));
    });

    test('resolving matching tiles progresses the run', () async {
      final userStates = <String, UserItemState>{};
      Future<List<UserItemState>> fetchStates(Iterable<String> ids) async {
        return ids
            .map(
              (id) => userStates.putIfAbsent(
                id,
                () => UserItemState()..itemId = id,
              ),
            )
            .toList();
      }

      Future<void> saveStates(List<UserItemState> states) async {
        for (final state in states) {
          userStates[state.itemId] = state;
        }
      }

      Future<int> addRunLog(RunLog log) async => 1;
      Future<void> addAttempts(List<AttemptLog> entries) async {}

      final controller = RunController(
        deckBuilderService: _buildDeckBuilder(deckSize: 30),
        settings: const RunSettings(),
        timerService: RunTimerService.fake(),
        fetchUserStates: fetchStates,
        saveUserStates: saveStates,
        addRunLog: addRunLog,
        addAttemptLogs: addAttempts,
      );

      await controller.initialize();

      controller.onTileTapped(0, TileColumn.left);
      controller.onTileTapped(0, TileColumn.right);

      final state = controller.state;
      expect(state.progress, 1);
      expect(state.selection, isNull);
    });

    test('persists SRS data and logs on completion', () async {
      final userStates = <String, UserItemState>{};
      Future<List<UserItemState>> fetchStates(Iterable<String> ids) async {
        return ids
            .map(
              (id) => userStates.putIfAbsent(
                id,
                () => UserItemState()..itemId = id,
              ),
            )
            .toList();
      }

      Future<void> saveStates(List<UserItemState> states) async {
        for (final state in states) {
          userStates[state.itemId] = state;
        }
      }

      final runLogs = <RunLog>[];
      Future<int> addRunLog(RunLog log) async {
        runLogs.add(log);
        return runLogs.length;
      }

      final attempts = <AttemptLog>[];
      Future<void> addAttempts(List<AttemptLog> entries) async {
        attempts.addAll(entries);
      }

      final controller = RunController(
        deckBuilderService: _buildDeckBuilder(deckSize: 20),
        settings: const RunSettings(rows: 2, targetMatches: 3),
        timerService: RunTimerService.fake(),
        fetchUserStates: fetchStates,
        saveUserStates: saveStates,
        addRunLog: addRunLog,
        addAttemptLogs: addAttempts,
      );

      await controller.initialize();

      final leftId = controller.state.board[0].left.pairId;
      controller.onTileTapped(0, TileColumn.left);
      controller.onTileTapped(1, TileColumn.right);

      controller.onTileTapped(0, TileColumn.left);
      controller.onTileTapped(0, TileColumn.right);
      controller.onTileTapped(1, TileColumn.left);
      controller.onTileTapped(1, TileColumn.right);
      controller.onTileTapped(0, TileColumn.left);
      controller.onTileTapped(0, TileColumn.right);

      await Future<void>.delayed(Duration.zero);

      expect(runLogs, isNotEmpty);
      expect(attempts.length, greaterThanOrEqualTo(3));
      expect(userStates[leftId]?.wrongCount, greaterThanOrEqualTo(1));
      expect(runLogs.first.troubleDetected, contains(leftId));
    });
  });
}
