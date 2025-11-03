// ignore_for_file: public_member_api_docs, cascade_invocations

import 'dart:async';
import 'dart:math' show max;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:palabra/data_core/data_core.dart';
import 'package:palabra/feature_run/application/run_settings.dart';
import 'package:palabra/feature_run/application/run_state.dart';
import 'package:palabra/feature_run/application/timer_service.dart';
import 'package:palabra/feature_srs/deck_builder/deck_builder_providers.dart';
import 'package:palabra/feature_srs/deck_builder/deck_builder_service.dart';

typedef FetchUserStates =
    Future<List<UserItemState>> Function(Iterable<String> itemIds);
typedef SaveUserStates = Future<void> Function(List<UserItemState> states);
typedef AddRunLog = Future<int> Function(RunLog log);
typedef AddAttemptLogs = Future<void> Function(List<AttemptLog> attempts);

class RunController extends StateNotifier<RunState> {
  RunController({
    required DeckBuilderService deckBuilderService,
    required RunSettings settings,
    required RunTimerService timerService,
    required FetchUserStates fetchUserStates,
    required SaveUserStates saveUserStates,
    required AddRunLog addRunLog,
    required AddAttemptLogs addAttemptLogs,
  }) : _deckBuilderService = deckBuilderService,
       _settings = settings,
       _timerService = timerService,
       _fetchUserStates = fetchUserStates,
       _saveUserStates = saveUserStates,
       _addRunLog = addRunLog,
       _addAttemptLogs = addAttemptLogs,
       super(RunState.loading(rows: settings.rows));

  final DeckBuilderService _deckBuilderService;
  final RunSettings _settings;
  final RunTimerService _timerService;
  final FetchUserStates _fetchUserStates;
  final SaveUserStates _saveUserStates;
  final AddRunLog _addRunLog;
  final AddAttemptLogs _addAttemptLogs;

  final List<VocabItem> _deckQueue = <VocabItem>[];
  final Map<String, VocabItem> _vocabLookup = <String, VocabItem>{};
  final Map<String, UserItemState> _itemStates = <String, UserItemState>{};
  final List<AttemptLog> _attempts = <AttemptLog>[];
  final Set<String> _troubleDetected = <String>{};
  final List<String> _learnedPromotions = <String>[];
  final List<_PendingReinsert> _reinsertQueue = <_PendingReinsert>[];
  final Map<String, int> _troubleAppearances = <String, int>{};

  DeckBuildResult? _deckResult;
  DateTime _runStartedAt = DateTime.now();
  int _cursor = 0;
  int _timeExtendsUsed = 0;
  bool _runFinished = false;

  Future<void> initialize() async {
    state = RunState.loading(rows: _settings.rows);
    _resetSession();

    _deckResult = await _deckBuilderService.buildDeck();
    _deckQueue
      ..clear()
      ..addAll(_deckResult!.items);
    _cursor = 0;

    _vocabLookup
      ..clear()
      ..addEntries(_deckQueue.map((item) => MapEntry(item.itemId, item)));

    await _loadUserStates();

    final initialBoard = <BoardRow>[];
    for (var i = 0; i < _settings.rows; i++) {
      final item = _drawNextPair();
      if (item == null) {
        break;
      }
      initialBoard.add(_createRow(item));
    }

    state = RunState.ready(
      rows: _settings.rows,
      board: initialBoard,
      deckRemaining: _deckQueue.length - _cursor,
      millisecondsRemaining: _settings.runDurationMs,
    );
    _startTimer();
  }

  void onTileTapped(int row, TileColumn column) {
    final current = state;
    if (!current.isReady || current.isResolving || current.inputLocked) {
      return;
    }

    final tile = current.tileAt(row, column);
    final newSelection = TileSelection(
      column: column,
      row: row,
      pairId: tile.pairId,
    );

    final existing = current.selection;
    if (existing == null) {
      state = current.copyWith(selection: newSelection);
      return;
    }

    if (existing.column == newSelection.column) {
      return;
    }

    final leftSelection = existing.column == TileColumn.left
        ? existing
        : newSelection;
    final rightSelection = existing.column == TileColumn.right
        ? existing
        : newSelection;

    final updatedProgress = leftSelection.pairId == rightSelection.pairId
        ? current.progress + 1
        : current.progress;
    _logAttempt(
      first: existing,
      second: newSelection,
      correct: leftSelection.pairId == rightSelection.pairId,
      resultingProgress: updatedProgress,
    );

    if (leftSelection.pairId == rightSelection.pairId) {
      _handleCorrect(leftSelection.pairId);
      _resolveMatch(leftSelection, rightSelection);
    } else {
      _handleWrong(leftSelection.pairId);
      state = current.copyWith(clearSelection: true);
    }
  }

  @override
  void dispose() {
    _timerService.stop();
    super.dispose();
  }

  Future<void> resumeFromPause() async {
    if (!state.inputLocked || _runFinished) {
      return;
    }
    state = state.copyWith(inputLocked: false);
    _timerService.resume();
  }

  void registerTimeExtendUse() {
    _timeExtendsUsed += 1;
  }

  Future<void> _loadUserStates() async {
    final ids = _deckQueue.map((item) => item.itemId).toSet();
    final fetched = await _fetchUserStates(ids);
    _itemStates.clear();
    for (final entry in fetched) {
      _itemStates[entry.itemId] = entry;
    }
    for (final id in ids) {
      _itemStates.putIfAbsent(id, () => UserItemState()..itemId = id);
    }
  }

  void _resetSession() {
    _attempts.clear();
    _troubleDetected.clear();
    _learnedPromotions.clear();
    _reinsertQueue.clear();
    _troubleAppearances.clear();
    _vocabLookup.clear();
    _deckResult = null;
    _runStartedAt = DateTime.now();
    _runFinished = false;
    _timeExtendsUsed = 0;
  }

  BoardRow _createRow(VocabItem item) {
    final left = _buildLeftTile(item);
    final right = _buildRightTile(item);
    return BoardRow(left: left, right: right);
  }

  void _handleCorrect(String itemId) {
    final state = _ensureItemState(itemId)
      ..seenCount += 1
      ..correctStreak += 1
      ..lastSeenAt = DateTime.now();

    if (state.wrongCount == 0 && state.correctStreak >= 3) {
      if (!_learnedPromotions.contains(itemId)) {
        state.learnedAt = DateTime.now();
        _learnedPromotions.add(itemId);
      }
    }
  }

  void _handleWrong(String itemId) {
    final itemState = _ensureItemState(itemId)
      ..seenCount += 1
      ..correctStreak = 0
      ..wrongCount += 1
      ..troubleAt = DateTime.now()
      ..lastSeenAt = DateTime.now();

    _troubleDetected.add(itemId);
    _scheduleTroubleReinsert(itemState.itemId);
  }

  UserItemState _ensureItemState(String itemId) {
    return _itemStates.putIfAbsent(
      itemId,
      () => UserItemState()..itemId = itemId,
    );
  }

  void _resolveMatch(
    TileSelection leftSelection,
    TileSelection rightSelection,
  ) {
    final item = _drawNextPair();
    final updatedBoard = List<BoardRow>.from(state.board);

    if (item != null) {
      updatedBoard[leftSelection.row] = updatedBoard[leftSelection.row]
          .replaceTile(TileColumn.left, _buildLeftTile(item));
      updatedBoard[rightSelection.row] = updatedBoard[rightSelection.row]
          .replaceTile(TileColumn.right, _buildRightTile(item));
    }

    state = state.copyWith(
      board: updatedBoard,
      progress: state.progress + 1,
      clearSelection: true,
      deckRemaining: max(0, _deckQueue.length - _cursor),
    );
    _checkTierPause();
  }

  BoardTile _buildLeftTile(VocabItem item) {
    _vocabLookup[item.itemId] = item;
    return BoardTile(
      id: '${item.itemId}_en',
      pairId: item.itemId,
      text: item.english,
      column: TileColumn.left,
    );
  }

  BoardTile _buildRightTile(VocabItem item) {
    _vocabLookup[item.itemId] = item;
    return BoardTile(
      id: '${item.itemId}_es',
      pairId: item.itemId,
      text: item.spanish,
      column: TileColumn.right,
    );
  }

  VocabItem? _drawNextPair() {
    final pending = _takePendingReinsert();
    if (pending != null) {
      return pending;
    }
    if (_cursor >= _deckQueue.length) {
      return null;
    }
    final item = _deckQueue[_cursor];
    _cursor += 1;
    return item;
  }

  VocabItem? _takePendingReinsert() {
    if (_reinsertQueue.isEmpty) {
      return null;
    }
    for (final entry in _reinsertQueue) {
      entry.remainingDelay -= 1;
    }
    final index = _reinsertQueue.indexWhere(
      (entry) => entry.remainingDelay <= 0,
    );
    if (index == -1) {
      return null;
    }
    return _reinsertQueue.removeAt(index).item;
  }

  void _scheduleTroubleReinsert(String itemId) {
    final item = _vocabLookup[itemId];
    if (item == null) {
      return;
    }
    final currentCount = _troubleAppearances.putIfAbsent(itemId, () => 0);
    if (currentCount >= 3) {
      return;
    }
    if (_reinsertQueue.any((entry) => entry.item.itemId == itemId)) {
      return;
    }
    _troubleAppearances[itemId] = currentCount + 1;
    _reinsertQueue.add(_PendingReinsert(item, 4));
  }

  void _startTimer() {
    _timerService.start(
      durationMs: _settings.runDurationMs,
      onTick: (remaining) {
        if (_runFinished) {
          return;
        }
        state = state.copyWith(millisecondsRemaining: remaining);
      },
      onTimeout: () => unawaited(_handleTimeout()),
    );
  }

  Future<void> _handleTimeout() async {
    if (_runFinished) {
      return;
    }
    _timerService.stop();
    state = state.copyWith(inputLocked: true, phase: RunPhase.completed);
    await _finishRun(success: false);
  }

  void _checkTierPause() {
    if (!state.pausedAtTier20 && state.progress == 20) {
      _enterPause(pausedAt20: true);
    } else if (!state.pausedAtTier50 && state.progress == 50) {
      _enterPause(pausedAt50: true);
    } else if (state.progress >= _settings.targetMatches) {
      unawaited(_completeRun());
    }
  }

  void _enterPause({bool pausedAt20 = false, bool pausedAt50 = false}) {
    _timerService.pause();
    state = state.copyWith(
      inputLocked: true,
      pausedAtTier20: pausedAt20 || state.pausedAtTier20,
      pausedAtTier50: pausedAt50 || state.pausedAtTier50,
    );
  }

  Future<void> _completeRun() async {
    if (_runFinished) {
      return;
    }
    _timerService.stop();
    state = state.copyWith(phase: RunPhase.completed, inputLocked: true);
    await _finishRun(success: true);
  }

  Future<void> _finishRun({required bool success}) async {
    if (_runFinished) {
      return;
    }
    _runFinished = true;
    final runLog = RunLog()
      ..startedAt = _runStartedAt
      ..completedAt = DateTime.now()
      ..tierReached = _tierForProgress(state.progress)
      ..rowsUsed = _settings.rows
      ..timeExtendsUsed = _timeExtendsUsed
      ..deckComposition = _buildDeckComposition()
      ..learnedPromoted = _learnedPromotions.toSet().toList()
      ..troubleDetected = _troubleDetected.toList();

    final runId = await _addRunLog(runLog);
    if (_attempts.isNotEmpty) {
      for (final attempt in _attempts) {
        attempt.runLogId = runId;
      }
      await _addAttemptLogs(_attempts);
    }

    await _saveUserStates(_itemStates.values.toList());
  }

  List<DeckLevelCount> _buildDeckComposition() {
    final result = _deckResult;
    if (result == null) {
      return const [];
    }
    final counts = <String, int>{};
    for (final item in result.items) {
      counts[item.level] = (counts[item.level] ?? 0) + 1;
    }
    return counts.entries
        .map(
          (entry) => DeckLevelCount()
            ..level = entry.key
            ..count = entry.value,
        )
        .toList();
  }

  void _logAttempt({
    required TileSelection first,
    required TileSelection second,
    required bool correct,
    required int resultingProgress,
  }) {
    final left = first.column == TileColumn.left ? first : second;
    final right = first.column == TileColumn.right ? first : second;
    final attempt = AttemptLog()
      ..runLogId = 0
      ..tier = _tierForProgress(resultingProgress)
      ..row = second.row
      ..column = second.column == TileColumn.left ? 0 : 1
      ..timeRemainingMs = state.millisecondsRemaining
      ..timestamp = DateTime.now()
      ..englishItemId = left.pairId
      ..spanishItemId = right.pairId
      ..correct = correct;
    _attempts.add(attempt);
  }

  int _tierForProgress(int progress) {
    if (progress >= 90) {
      return 3;
    }
    if (progress >= 50) {
      return 2;
    }
    return 1;
  }
}

final runControllerProvider =
    StateNotifierProvider.autoDispose<RunController, RunState>((ref) {
      final deckBuilder = ref.watch(deckBuilderServiceProvider);
      final settings = ref.watch(runSettingsProvider);
      final userProgressRepo = ref.watch(userProgressRepositoryProvider);
      final runLogRepo = ref.watch(runLogRepositoryProvider);
      final attemptRepo = ref.watch(attemptLogRepositoryProvider);
      final timerService = RunTimerService();

      final controller = RunController(
        deckBuilderService: deckBuilder,
        settings: settings,
        timerService: timerService,
        fetchUserStates: userProgressRepo.getStates,
        saveUserStates: userProgressRepo.upsertStates,
        addRunLog: runLogRepo.add,
        addAttemptLogs: attemptRepo.addAll,
      );

      controller.initialize();
      ref.onDispose(timerService.stop);
      return controller;
    });

class _PendingReinsert {
  _PendingReinsert(this.item, this.remainingDelay);

  final VocabItem item;
  int remainingDelay;
}
