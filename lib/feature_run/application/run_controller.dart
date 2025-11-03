// ignore_for_file: public_member_api_docs, cascade_invocations

import 'dart:async';
import 'dart:math';

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
    required UserMetaRepository userMetaRepository,
  }) : _deckBuilderService = deckBuilderService,
       _settings = settings,
       _timerService = timerService,
       _fetchUserStates = fetchUserStates,
       _saveUserStates = saveUserStates,
       _addRunLog = addRunLog,
       _addAttemptLogs = addAttemptLogs,
       _userMetaRepository = userMetaRepository,
       super(RunState.loading(rows: settings.rows));

  final DeckBuilderService _deckBuilderService;
  final RunSettings _settings;
  final RunTimerService _timerService;
  final FetchUserStates _fetchUserStates;
  final SaveUserStates _saveUserStates;
  final AddRunLog _addRunLog;
  final AddAttemptLogs _addAttemptLogs;
  final UserMetaRepository _userMetaRepository;

  final List<VocabItem> _deckQueue = <VocabItem>[];
  final Map<String, VocabItem> _vocabLookup = <String, VocabItem>{};
  final Map<String, UserItemState> _itemStates = <String, UserItemState>{};
  final List<AttemptLog> _attempts = <AttemptLog>[];
  final Set<String> _troubleDetected = <String>{};
  final List<String> _learnedPromotions = <String>[];
  final List<int> _pendingRefillRows = <int>[];
  final Random _random = Random();
  bool _refillSequenceActive = false;
  int _placeholderSalt = 0;
  int _mismatchSalt = 0;
  Timer? _mismatchTimer;
  int _celebrationSalt = 0;
  Timer? _celebrationTimer;

  DeckBuildResult? _deckResult;
  DateTime _runStartedAt = DateTime.now();
  int _cursor = 0;
  int _timeExtendsUsed = 0;
  bool _runFinished = false;
  UserMeta? _userMeta;

  Future<void> initialize() async {
    state = RunState.loading(rows: _settings.rows);
    _resetSession();

    await _loadUserMeta();
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

    _randomizeRightColumn(initialBoard);
    final balancedBoard = _ensureBoardInvariant(initialBoard);

    state = RunState.ready(
      rows: _settings.rows,
      board: balancedBoard,
      deckRemaining: _remainingPairs,
      millisecondsRemaining: _settings.runDurationMs,
      timeExtendTokens: _userMeta?.timeExtendTokens ?? 0,
      timeExtendsUsed: _timeExtendsUsed,
    );
    _startTimer(_settings.runDurationMs);
  }

  void onTileTapped(int row, TileColumn column) {
    final current = state;
    if (!current.isReady || current.isResolving || current.inputLocked) {
      return;
    }

    final tile = current.tileAt(row, column);
    if (tile.pairId.isEmpty) {
      return;
    }
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
      _triggerMismatchEffect(leftSelection, rightSelection);
    }
  }

  @override
  void dispose() {
    _timerService.stop();
    _cancelMismatchTimer();
    _cancelCelebrationTimer();
    super.dispose();
  }

  Future<void> resumeFromPause() async {
    if (!state.inputLocked || _runFinished) {
      return;
    }
    state = state.copyWith(inputLocked: false);
    _timerService.resume();
  }

  Future<void> _loadUserMeta() async {
    _userMeta = await _userMetaRepository.getOrCreate();
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
    _vocabLookup.clear();
    _deckResult = null;
    _runStartedAt = DateTime.now();
    _runFinished = false;
    _timeExtendsUsed = 0;
    _pendingRefillRows.clear();
    _refillSequenceActive = false;
    _cancelMismatchTimer();
    _mismatchSalt = 0;
    _cancelCelebrationTimer();
    _celebrationSalt = 0;
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
    _ensureItemState(itemId)
      ..seenCount += 1
      ..correctStreak = 0
      ..wrongCount += 1
      ..troubleAt = DateTime.now()
      ..lastSeenAt = DateTime.now();

    _troubleDetected.add(itemId);
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
    _clearMismatchEffect();
    final updatedBoard = List<BoardRow>.from(state.board);

    updatedBoard[leftSelection.row] = _emptyRow(leftSelection.row);
    _pendingRefillRows.add(leftSelection.row);
    final balancedBoard = _ensureBoardInvariant(updatedBoard);

    final celebration = CelebrationEffect(token: ++_celebrationSalt);
    _cancelCelebrationTimer();
    state = state.copyWith(
      board: balancedBoard,
      progress: state.progress + 1,
      clearSelection: true,
      deckRemaining: _remainingPairs,
      celebrationEffect: celebration,
    );
    _scheduleCelebrationClear(celebration);
    _maybeRefillPending();
    _checkTierPause();
  }

  void _triggerMismatchEffect(
    TileSelection leftSelection,
    TileSelection rightSelection,
  ) {
    final effect = MismatchEffect(
      token: ++_mismatchSalt,
      left: leftSelection,
      right: rightSelection,
    );
    _cancelMismatchTimer();
    state = state.copyWith(
      mismatchEffect: effect,
      clearSelection: true,
    );
    _mismatchTimer = Timer(const Duration(milliseconds: 320), () {
      if (!mounted || _runFinished) {
        return;
      }
      if (state.mismatchEffect?.token == effect.token) {
        state = state.copyWith(clearMismatch: true);
      }
    });
  }

  void _clearMismatchEffect() {
    if (state.mismatchEffect == null) {
      return;
    }
    _cancelMismatchTimer();
    state = state.copyWith(clearMismatch: true);
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
    if (_cursor >= _deckQueue.length) {
      return null;
    }
    final item = _deckQueue[_cursor];
    _cursor += 1;
    return item;
  }

  void _startTimer(int durationMs) {
    _timerService.start(
      durationMs: durationMs,
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
    if (_shouldOfferTimeExtend()) {
      state = state.copyWith(
        inputLocked: true,
        showingTimeExtendOffer: true,
      );
      return;
    }
    await _finalizeTimeout();
  }

  bool _shouldOfferTimeExtend() {
    final meta = _userMeta;
    if (meta == null) {
      return false;
    }
    if (state.progress >= _settings.targetMatches) {
      return false;
    }
    if (_timeExtendsUsed >= _settings.maxTimeExtendsPerRun) {
      return false;
    }
    return meta.timeExtendTokens > 0;
  }

  Future<void> acceptTimeExtend() async {
    if (!state.showingTimeExtendOffer || !_shouldOfferTimeExtend()) {
      return;
    }
    final meta = _userMeta;
    if (meta == null || meta.timeExtendTokens <= 0) {
      await _finalizeTimeout();
      return;
    }

    meta.timeExtendTokens -= 1;
    _timeExtendsUsed += 1;

    final baseRemaining = max(0, state.millisecondsRemaining);
    final updatedRemaining = baseRemaining + _settings.timeExtendDurationMs;

    state = state.copyWith(
      showingTimeExtendOffer: false,
      inputLocked: false,
      millisecondsRemaining: updatedRemaining,
      timeExtendTokens: meta.timeExtendTokens,
      timeExtendsUsed: _timeExtendsUsed,
    );

    await _userMetaRepository.save(meta);
    _startTimer(updatedRemaining);
  }

  Future<void> declineTimeExtend() async {
    if (!state.showingTimeExtendOffer) {
      return;
    }
    await _finalizeTimeout();
  }

  Future<void> _finalizeTimeout() async {
    if (_runFinished) {
      return;
    }
    _timerService.stop();
    state = state.copyWith(
      inputLocked: true,
      phase: RunPhase.completed,
      showingTimeExtendOffer: false,
    );
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
    _refillSequenceActive = false;
    _clearMismatchEffect();
    _clearCelebrationEffect();
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

  void _maybeRefillPending({bool force = false}) {
    if (_pendingRefillRows.isEmpty || !_canContinueRefill()) {
      return;
    }

    final remainingPairs = _remainingPairs;
    final shouldStart = force ||
        _pendingRefillRows.length >= _settings.refillBatchSize ||
        remainingPairs < _settings.refillBatchSize;
    if (!shouldStart || _refillSequenceActive) {
      return;
    }

    _refillSequenceActive = true;
    unawaited(_drainPendingRefills());
  }

  void _cancelMismatchTimer() {
    _mismatchTimer?.cancel();
    _mismatchTimer = null;
  }

  void _scheduleCelebrationClear(CelebrationEffect effect) {
    _celebrationTimer = Timer(const Duration(milliseconds: 360), () {
      if (!mounted || _runFinished) {
        return;
      }
      if (state.celebrationEffect?.token == effect.token) {
        state = state.copyWith(clearCelebration: true);
      }
    });
  }

  void _cancelCelebrationTimer() {
    _celebrationTimer?.cancel();
    _celebrationTimer = null;
  }

  void _clearCelebrationEffect() {
    if (state.celebrationEffect == null) {
      return;
    }
    _cancelCelebrationTimer();
    state = state.copyWith(clearCelebration: true);
  }

  BoardRow _emptyRow(int rowIndex) {
    return BoardRow(
      left: BoardTile(
        id: 'empty_${rowIndex}_left_${_placeholderSalt++}',
        pairId: '',
        text: '',
        column: TileColumn.left,
      ),
      right: BoardTile(
        id: 'empty_${rowIndex}_right_${_placeholderSalt++}',
        pairId: '',
        text: '',
        column: TileColumn.right,
      ),
    );
  }

  Future<void> _drainPendingRefills() async {
    while (_pendingRefillRows.isNotEmpty && _canContinueRefill()) {
      await _waitForRefillStep();
      final filled = _refillSingleRow();
      if (!filled) {
        break;
      }
    }
    _refillSequenceActive = false;
  }

  Future<void> _waitForRefillStep() async {
    final delayMs = _settings.refillStepDelayMs;
    if (delayMs <= 0) {
      await Future<void>.delayed(Duration.zero);
      return;
    }
    await Future<void>.delayed(Duration(milliseconds: delayMs));
  }

  bool _refillSingleRow() {
    if (_pendingRefillRows.isEmpty) {
      return false;
    }

    final rowIndex = _pendingRefillRows.first;
    final item = _drawNextPair();
    if (item == null) {
      return false;
    }

    final updatedBoard = List<BoardRow>.from(state.board);
    _pendingRefillRows.removeAt(0);
    updatedBoard[rowIndex] = _createRow(item);
    _randomizeRightColumn(updatedBoard);
    final balancedBoard = _ensureBoardInvariant(updatedBoard);

    state = state.copyWith(
      board: balancedBoard,
      deckRemaining: _remainingPairs,
    );
    return true;
  }

  bool _canContinueRefill() {
    return state.phase == RunPhase.ready && !_runFinished;
  }

  int get _remainingPairs {
    return max(0, _deckQueue.length - _cursor);
  }

  List<BoardRow> _ensureBoardInvariant(List<BoardRow> board) {
    if (!_boardHasMismatch(board)) {
      return board;
    }

    final repaired = _repairBoard(board);
    assert(
      !_boardHasMismatch(repaired),
      'Board invariant violated: unmatched pair counts detected.',
    );
    return repaired;
  }

  bool _boardHasMismatch(List<BoardRow> board) {
    final leftCounts = <String, int>{};
    final rightCounts = <String, int>{};
    for (final row in board) {
      final leftId = row.left.pairId;
      if (leftId.isNotEmpty) {
        leftCounts[leftId] = (leftCounts[leftId] ?? 0) + 1;
      }
      final rightId = row.right.pairId;
      if (rightId.isNotEmpty) {
        rightCounts[rightId] = (rightCounts[rightId] ?? 0) + 1;
      }
    }
    if (leftCounts.length != rightCounts.length) {
      return true;
    }
    for (final entry in leftCounts.entries) {
      if (rightCounts[entry.key] != entry.value) {
        return true;
      }
    }
    return false;
  }

  List<BoardRow> _repairBoard(List<BoardRow> board) {
    final updated = List<BoardRow>.from(board);
    final activeRows = <int>[];

    for (var i = 0; i < updated.length; i++) {
      if (updated[i].left.pairId.isEmpty) {
        updated[i] = updated[i].replaceTile(
          TileColumn.right,
          BoardTile(
            id: 'empty_${i}_right_${_placeholderSalt++}',
            pairId: '',
            text: '',
            column: TileColumn.right,
          ),
        );
        continue;
      }
      activeRows.add(i);
    }

    final rightTiles = <BoardTile>[];
    for (final rowIndex in activeRows) {
      final pairId = updated[rowIndex].left.pairId;
      final vocab = _vocabLookup[pairId];
      if (vocab == null) {
        continue;
      }
      rightTiles.add(_buildRightTile(vocab));
    }

    rightTiles.shuffle(_random);
    var cursor = 0;
    for (final rowIndex in activeRows) {
      if (cursor >= rightTiles.length) {
        break;
      }
      updated[rowIndex] = updated[rowIndex].replaceTile(
        TileColumn.right,
        rightTiles[cursor++],
      );
    }
    return updated;
  }

  void _randomizeRightColumn(List<BoardRow> board) {
    final indices = <int>[];
    final tiles = <BoardTile>[];
    for (var i = 0; i < board.length; i++) {
      final tile = board[i].right;
      if (tile.pairId.isEmpty) {
        continue;
      }
      indices.add(i);
      tiles.add(tile);
    }

    if (tiles.length <= 1) {
      return;
    }

    tiles.shuffle(_random);
    for (var i = 0; i < indices.length; i++) {
      final rowIndex = indices[i];
      board[rowIndex] = board[rowIndex].replaceTile(
        TileColumn.right,
        tiles[i],
      );
    }
  }
}

final runTimerServiceProvider = Provider<RunTimerService>((ref) {
  final service = RunTimerService();
  ref.onDispose(service.stop);
  return service;
});

final runControllerProvider =
    StateNotifierProvider.autoDispose<RunController, RunState>((ref) {
      final deckBuilder = ref.watch(deckBuilderServiceProvider);
      final settings = ref.watch(runSettingsProvider);
      final userProgressRepo = ref.watch(userProgressRepositoryProvider);
      final runLogRepo = ref.watch(runLogRepositoryProvider);
      final attemptRepo = ref.watch(attemptLogRepositoryProvider);
      final userMetaRepo = ref.watch(userMetaRepositoryProvider);
      final timerService = ref.watch(runTimerServiceProvider);

      final controller = RunController(
        deckBuilderService: deckBuilder,
        settings: settings,
        timerService: timerService,
        fetchUserStates: userProgressRepo.getStates,
        saveUserStates: userProgressRepo.upsertStates,
        addRunLog: runLogRepo.add,
        addAttemptLogs: attemptRepo.addAll,
        userMetaRepository: userMetaRepo,
      );

      controller.initialize();
      return controller;
    });
