// These tests intentionally chain helpers densely; documenting each ignore would be noise.
// ignore_for_file: cascade_invocations

import 'package:flutter_test/flutter_test.dart';
import 'package:palabra/data_core/models/attempt_log.dart';
import 'package:palabra/data_core/models/profile_summary.dart';
import 'package:palabra/data_core/models/run_log.dart';
import 'package:palabra/data_core/models/user_item_state.dart';
import 'package:palabra/data_core/models/user_meta.dart';
import 'package:palabra/data_core/models/vocab_item.dart';
import 'package:palabra/data_core/repositories/user_meta_repository.dart';
import 'package:palabra/feature_run/application/run_controller.dart';
import 'package:palabra/feature_run/application/run_feedback_service.dart';
import 'package:palabra/feature_run/application/run_settings.dart';
import 'package:palabra/feature_run/application/run_state.dart';
import 'package:palabra/feature_run/application/timer_service.dart';
import 'package:palabra/feature_profiles/application/profile_service.dart';
import 'package:palabra/feature_srs/deck_builder/deck_builder_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _InMemoryUserMetaRepository implements UserMetaRepository {
  _InMemoryUserMetaRepository(this._meta);

  UserMeta _meta;

  @override
  Future<UserMeta> getOrCreate({String? profileId}) async => _meta;

  @override
  Future<void> save(UserMeta meta) async {
    _meta = meta;
  }

  @override
  Future<void> deleteProfile(String profileId) async {}

  @override
  Future<List<String>> listProfileIds() async => const <String>[];

  @override
  Future<void> switchProfile(String profileId) async {}
}

class _FakeRunFeedbackService extends RunFeedbackService {
  const _FakeRunFeedbackService();

  @override
  Future<void> onMatch({required int tier}) async {}

  @override
  Future<void> onMismatch() async {}

  @override
  Future<void> onTierPause({required int tier}) async {}

  @override
  Future<void> onRunComplete({
    required int tierReached,
    required bool success,
  }) async {}
}

class _FakeProfileService implements ProfileService {
  const _FakeProfileService();

  ProfileSummary get _summary => ProfileSummary(
        id: 'profile',
        displayName: 'Test Profile',
        createdAt: DateTime(2024, 1, 1),
        lastSeenAt: DateTime(2024, 1, 1),
        level: 'a1',
        totalRuns: 0,
        isActive: true,
      );

  @override
  Future<List<ProfileSummary>> listProfiles() async => <ProfileSummary>[_summary];

  @override
  Future<ProfileSummary> createProfile(String name) async {
    return _summary.copyWith(displayName: name);
  }

  @override
  Future<void> renameProfile(String profileId, String name) async {}

  @override
  Future<void> switchProfile(String profileId) async {}

  @override
  Future<void> deleteProfile(String profileId) async {}

  @override
  Future<void> pushActiveProfile() async {}
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

Future<void> _matchPairById(RunController controller, String pairId) async {
  final state = controller.state;
  final leftRow = state.board.indexWhere((row) => row.left.pairId == pairId);
  final rightRow = state.board.indexWhere((row) => row.right.pairId == pairId);

  expect(leftRow, isNot(-1), reason: 'Left tile for $pairId not found');
  expect(rightRow, isNot(-1), reason: 'Right tile for $pairId not found');

  controller.onTileTapped(leftRow, TileColumn.left);
  controller.onTileTapped(rightRow, TileColumn.right);

  await Future<void>.delayed(Duration.zero);
}

Future<void> _matchFirstPair(RunController controller) async {
  const maxAttempts = 40;
  for (var i = 0; i < maxAttempts; i++) {
    final hasActiveRow = controller.state.board.any(
      (row) => row.left.pairId.isNotEmpty,
    );
    if (hasActiveRow) {
      break;
    }
    if (i == maxAttempts - 1) {
      fail('Expected an active row on the board.');
    }
    await Future<void>.delayed(const Duration(milliseconds: 5));
  }

  final pairId = controller.state.board
      .firstWhere((row) => row.left.pairId.isNotEmpty)
      .left
      .pairId;
  await _matchPairById(controller, pairId);
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues(const <String, Object>{});
  });

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
        settings: const RunSettings(refillStepDelayMs: 0),
        timerService: RunTimerService.fake(),
        fetchUserStates: fetchStates,
        saveUserStates: saveStates,
        addRunLog: addRunLog,
        addAttemptLogs: addAttempts,
        userMetaRepository: _InMemoryUserMetaRepository(UserMeta()),
        feedbackService: const _FakeRunFeedbackService(),
        profileService: const _FakeProfileService(),
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
        settings: const RunSettings(refillStepDelayMs: 0),
        timerService: RunTimerService.fake(),
        fetchUserStates: fetchStates,
        saveUserStates: saveStates,
        addRunLog: addRunLog,
        addAttemptLogs: addAttempts,
        userMetaRepository: _InMemoryUserMetaRepository(UserMeta()),
        feedbackService: const _FakeRunFeedbackService(),
        profileService: const _FakeProfileService(),
      );

      await controller.initialize();

      await _matchFirstPair(controller);

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

      final metaRepository = _InMemoryUserMetaRepository(UserMeta());
      final controller = RunController(
        deckBuilderService: _buildDeckBuilder(deckSize: 20),
        settings: const RunSettings(
          rows: 2,
          targetMatches: 3,
          minTargetMatches: 3,
          refillBatchSize: 1,
          refillStepDelayMs: 0,
        ),
        timerService: RunTimerService.fake(),
        fetchUserStates: fetchStates,
        saveUserStates: saveStates,
        addRunLog: addRunLog,
        addAttemptLogs: addAttempts,
        userMetaRepository: metaRepository,
        feedbackService: const _FakeRunFeedbackService(),
        profileService: const _FakeProfileService(),
      );

      await controller.initialize();

      final initialState = controller.state;
      final leftRow = initialState.board.indexWhere(
        (row) => row.left.pairId.isNotEmpty,
      );
      expect(leftRow, isNot(-1));
      final leftId = initialState.board[leftRow].left.pairId;
      final wrongRightRow = initialState.board.indexWhere(
        (row) => row.right.pairId != leftId && row.right.pairId.isNotEmpty,
      );

      expect(wrongRightRow, isNot(-1));

      controller.onTileTapped(leftRow, TileColumn.left);
      controller.onTileTapped(wrongRightRow, TileColumn.right);

      await _matchPairById(controller, leftId);
      await _matchFirstPair(controller);
      await _matchFirstPair(controller);

      await Future<void>.delayed(Duration.zero);

      expect(runLogs, isNotEmpty);
      final summary = runLogs.first;
      expect(attempts.length, greaterThanOrEqualTo(3));
      expect(userStates[leftId]?.wrongCount, greaterThanOrEqualTo(1));
      expect(summary.troubleDetected, contains(leftId));
      expect(summary.matchesCompleted, greaterThanOrEqualTo(3));
      expect(summary.attemptCount, attempts.length);
      expect(summary.durationMs, greaterThan(0));

      final meta = await metaRepository.getOrCreate();
      expect(meta.totalRuns, 1);
      expect(meta.totalMatches, summary.matchesCompleted);
      expect(meta.totalAttempts, summary.attemptCount);
      expect(meta.currentStreak, 1);
      expect(meta.bestStreak, summary.streakMax);
      expect(meta.lastTroubleDelta, summary.troubleDetected.length);
    });

    test('refills pending rows sequentially after batch threshold', () async {
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
        settings: const RunSettings(
          rows: 3,
          refillBatchSize: 3,
          refillStepDelayMs: 5,
        ),
        timerService: RunTimerService.fake(),
        fetchUserStates: fetchStates,
        saveUserStates: saveStates,
        addRunLog: addRunLog,
        addAttemptLogs: addAttempts,
        userMetaRepository: _InMemoryUserMetaRepository(UserMeta()),
        feedbackService: const _FakeRunFeedbackService(),
        profileService: const _FakeProfileService(),
      );

      await controller.initialize();

      final initialPairs = controller.state.board
          .where((row) => row.left.pairId.isNotEmpty)
          .map((row) => row.left.pairId)
          .take(3)
          .toList();

      for (final pairId in initialPairs) {
        await _matchPairById(controller, pairId);
      }

      final stateAfterMatches = controller.state;
      final immediateEmptyCount = stateAfterMatches.board
          .where((row) => row.left.pairId.isEmpty)
          .length;
      expect(immediateEmptyCount, greaterThan(0));

      await Future<void>.delayed(const Duration(milliseconds: 25));

      final stateAfterDelay = controller.state;
      final finalEmptyCount = stateAfterDelay.board
          .where((row) => row.left.pairId.isEmpty)
          .length;
      expect(finalEmptyCount, 0);
    });

    test('wrong match triggers temporary mismatch feedback', () async {
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

      Future<void> saveStates(List<UserItemState> states) async {}
      Future<int> addRunLog(RunLog log) async => 1;
      Future<void> addAttempts(List<AttemptLog> entries) async {}

      final controller = RunController(
        deckBuilderService: _buildDeckBuilder(deckSize: 12),
        settings: const RunSettings(rows: 2, refillStepDelayMs: 0),
        timerService: RunTimerService.fake(),
        fetchUserStates: fetchStates,
        saveUserStates: saveStates,
        addRunLog: addRunLog,
        addAttemptLogs: addAttempts,
        userMetaRepository: _InMemoryUserMetaRepository(UserMeta()),
        feedbackService: const _FakeRunFeedbackService(),
        profileService: const _FakeProfileService(),
      );

      await controller.initialize();

      final initialState = controller.state;
      final leftRow = initialState.board.indexWhere(
        (row) => row.left.pairId.isNotEmpty,
      );
      expect(leftRow, isNot(-1));
      final mismatchRightRow = initialState.board.indexWhere(
        (row) =>
            row.right.pairId != initialState.board[leftRow].left.pairId &&
            row.right.pairId.isNotEmpty,
      );
      expect(mismatchRightRow, isNot(-1));

      controller.onTileTapped(leftRow, TileColumn.left);
      controller.onTileTapped(mismatchRightRow, TileColumn.right);

      expect(controller.state.mismatchEffect, isNotNull);
      await Future<void>.delayed(const Duration(milliseconds: 400));
      expect(controller.state.mismatchEffect, isNull);
    });

    test(
      'matched pair is removed from the session deck after resolution',
      () async {
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

        Future<void> saveStates(List<UserItemState> states) async {}
        Future<int> addRunLog(RunLog log) async => 1;
        Future<void> addAttempts(List<AttemptLog> entries) async {}

        final controller = RunController(
          deckBuilderService: _buildDeckBuilder(deckSize: 16),
          settings: const RunSettings(
            rows: 2,
            refillBatchSize: 1,
            refillStepDelayMs: 0,
          ),
          timerService: RunTimerService.fake(),
          fetchUserStates: fetchStates,
          saveUserStates: saveStates,
        addRunLog: addRunLog,
        addAttemptLogs: addAttempts,
        userMetaRepository: _InMemoryUserMetaRepository(UserMeta()),
        feedbackService: const _FakeRunFeedbackService(),
        profileService: const _FakeProfileService(),
      );

        await controller.initialize();

        final firstPairId = controller.state.board[0].left.pairId;
        final wrongRightRow = controller.state.board.indexWhere(
          (row) =>
              row.right.pairId != firstPairId && row.right.pairId.isNotEmpty,
        );
        expect(wrongRightRow, isNot(-1));

        controller.onTileTapped(0, TileColumn.left);
        controller.onTileTapped(wrongRightRow, TileColumn.right);

        await _matchPairById(controller, firstPairId);
        await Future<void>.delayed(const Duration(milliseconds: 20));

        final currentPairs = controller.state.board
            .expand((row) => [row.left.pairId, row.right.pairId])
            .toList();

        expect(currentPairs, isNot(contains(firstPairId)));
      },
    );

    test('time extend offer consumes token and resumes the run', () async {
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

      Future<void> saveStates(List<UserItemState> states) async {}
      Future<int> addRunLog(RunLog log) async => 1;
      Future<void> addAttempts(List<AttemptLog> entries) async {}

      final metaRepository = _InMemoryUserMetaRepository(
        UserMeta()..timeExtendTokens = 1,
      );
      final fakeTimer = RunTimerService.fake();

      final controller = RunController(
        deckBuilderService: _buildDeckBuilder(deckSize: 12),
        settings: const RunSettings(
          rows: 2,
          targetMatches: 3,
          minTargetMatches: 3,
          runDurationMs: 200,
          timeExtendDurationMs: 60000,
          maxTimeExtendsPerRun: 2,
          refillStepDelayMs: 0,
        ),
        timerService: fakeTimer,
        fetchUserStates: fetchStates,
        saveUserStates: saveStates,
        addRunLog: addRunLog,
        addAttemptLogs: addAttempts,
        userMetaRepository: metaRepository,
        feedbackService: const _FakeRunFeedbackService(),
        profileService: const _FakeProfileService(),
      );

      await controller.initialize();

      fakeTimer.tickFake(decrementMs: 200);
      await Future<void>.delayed(Duration.zero);

      final offerState = controller.state;
      expect(offerState.showingTimeExtendOffer, isTrue);
      expect(offerState.inputLocked, isTrue);
      expect(offerState.timeExtendTokens, 1);

      await controller.acceptTimeExtend();
      await Future<void>.delayed(Duration.zero);

      final resumedState = controller.state;
      expect(resumedState.showingTimeExtendOffer, isFalse);
      expect(resumedState.inputLocked, isFalse);
      expect(resumedState.timeExtendTokens, 0);
      expect(resumedState.timeExtendsUsed, 1);
      expect(resumedState.millisecondsRemaining, 60000);

      final persistedMeta = await metaRepository.getOrCreate();
      expect(persistedMeta.timeExtendTokens, 0);
    });

    test(
      'manual time extend activation consumes a token and adds time',
      () async {
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

        Future<void> saveStates(List<UserItemState> states) async {}
        Future<int> addRunLog(RunLog log) async => 1;
        Future<void> addAttempts(List<AttemptLog> entries) async {}

        final metaRepository = _InMemoryUserMetaRepository(
          UserMeta()..timeExtendTokens = 2,
        );
        final controller = RunController(
          deckBuilderService: _buildDeckBuilder(deckSize: 10),
          settings: const RunSettings(
            rows: 2,
            runDurationMs: 1000,
            timeExtendDurationMs: 30000,
            refillStepDelayMs: 0,
          ),
          timerService: RunTimerService.fake(),
          fetchUserStates: fetchStates,
          saveUserStates: saveStates,
        addRunLog: addRunLog,
        addAttemptLogs: addAttempts,
        userMetaRepository: metaRepository,
        feedbackService: const _FakeRunFeedbackService(),
        profileService: const _FakeProfileService(),
      );

        await controller.initialize();

        final initialRemaining = controller.state.millisecondsRemaining;
        controller.activatePowerup('timeExtend');
        await Future<void>.delayed(Duration.zero);

        expect(
          controller.state.millisecondsRemaining,
          initialRemaining + 30000,
        );
        expect(controller.state.timeExtendTokens, 1);
        expect(controller.state.timeExtendsUsed, 1);
        expect(controller.state.powerupInventory['timeExtend'], 1);

        final meta = await metaRepository.getOrCreate();
        expect(meta.timeExtendTokens, 1);
        expect(meta.powerupInventory['timeExtend'], 1);
      },
    );

    test('manual time extend does nothing when no tokens remain', () async {
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

      Future<void> saveStates(List<UserItemState> states) async {}
      Future<int> addRunLog(RunLog log) async => 1;
      Future<void> addAttempts(List<AttemptLog> entries) async {}

      final controller = RunController(
        deckBuilderService: _buildDeckBuilder(deckSize: 10),
        settings: const RunSettings(
          rows: 2,
          runDurationMs: 1000,
          timeExtendDurationMs: 30000,
          refillStepDelayMs: 0,
        ),
        timerService: RunTimerService.fake(),
        fetchUserStates: fetchStates,
        saveUserStates: saveStates,
        addRunLog: addRunLog,
        addAttemptLogs: addAttempts,
        userMetaRepository: _InMemoryUserMetaRepository(UserMeta()),
        feedbackService: const _FakeRunFeedbackService(),
        profileService: const _FakeProfileService(),
      );

      await controller.initialize();

      final initialState = controller.state;
      controller.activatePowerup('timeExtend');
      await Future<void>.delayed(Duration.zero);

      expect(
        controller.state.millisecondsRemaining,
        initialState.millisecondsRemaining,
      );
      expect(controller.state.timeExtendTokens, 0);
      expect(controller.state.timeExtendsUsed, 0);
    });
  });
}
