// Documentation lint is suppressed because these beta-only helpers change rapidly.
// ignore_for_file: public_member_api_docs, cascade_invocations

import 'dart:async';
import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:palabra/data_core/data_core.dart';
import 'package:palabra/feature_profiles/application/profile_service.dart';
import 'package:palabra/feature_run/application/run_settings.dart';
import 'package:palabra/feature_run/application/run_state.dart';
import 'package:palabra/feature_run/application/timer_service.dart';
import 'package:palabra/feature_run/application/run_feedback_service.dart';
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
    required RunFeedbackService feedbackService,
    required ProfileService profileService,
  }) : _deckBuilderService = deckBuilderService,
       _settings = settings,
       _timerService = timerService,
       _fetchUserStates = fetchUserStates,
       _saveUserStates = saveUserStates,
       _addRunLog = addRunLog,
       _addAttemptLogs = addAttemptLogs,
       _userMetaRepository = userMetaRepository,
       _feedbackService = feedbackService,
       _profileService = profileService,
       super(
         RunState.loading(
           rows: settings.rows,
           targetMatches: settings.targetMatches,
         ),
       );

  final DeckBuilderService _deckBuilderService;
  final RunSettings _settings;
  final RunTimerService _timerService;
  final FetchUserStates _fetchUserStates;
  final SaveUserStates _saveUserStates;
  final AddRunLog _addRunLog;
  final AddAttemptLogs _addAttemptLogs;
  final UserMetaRepository _userMetaRepository;
  final RunFeedbackService _feedbackService;
  static const Map<String, int> _perRunPowerupGrants = <String, int>{
    'hintGlow': 1,
    'freezeTimer': 1,
    'autoMatch': 1,
    'audioEcho': 2,
  };
  static const Map<String, int> _powerupRunLimits = <String, int>{
    'hintGlow': 2,
    'freezeTimer': 1,
    'autoMatch': 1,
    'audioEcho': 2,
  };
  static const Map<String, Duration> _powerupCooldownDurations =
      <String, Duration>{
        'hintGlow': Duration(seconds: 25),
        'audioEcho': Duration(seconds: 15),
      };
  static const Duration _freezeTimerDuration = Duration(seconds: 10);
  static const Duration _hintGlowDuration = Duration(seconds: 2);
  static const Duration _audioEchoHighlightDuration = Duration(seconds: 2);
  final ProfileService _profileService;

  final List<VocabItem> _deckQueue = <VocabItem>[];
  final Map<String, VocabItem> _vocabLookup = <String, VocabItem>{};
  final Map<String, UserItemState> _itemStates = <String, UserItemState>{};
  final List<AttemptLog> _attempts = <AttemptLog>[];
  final Set<String> _troubleDetected = <String>{};
  final List<String> _learnedPromotions = <String>[];
  final List<int> _pendingRefillRows = <int>[];
  final Set<String> _dirtyItemIds = <String>{};
  final Random _random = Random();
  final Set<String> _matchedThisRun = <String>{};
  final List<String> _powerupsEarnedThisRun = <String>[];
  int _xpEarned = 0;
  int _xpBonus = 0;
  int _currentStreak = 0;
  int _bestStreak = 0;
  bool _cleanRun = true;
  bool _refillSequenceActive = false;
  int _placeholderSalt = 0;
  int _mismatchSalt = 0;
  Timer? _mismatchTimer;
  int _celebrationSalt = 0;
  Timer? _celebrationTimer;
  Timer? _progressPersistTimer;
  int _confettiSalt = 0;
  Timer? _confettiTimer;
  String _activeLevelId = 'a1';
  int _tierOneThreshold = 1;
  int _tierTwoThreshold = 1;
  bool _tierOneCelebrated = false;
  bool _tierTwoCelebrated = false;
  final Map<String, DateTime> _powerupCooldowns = <String, DateTime>{};
  final Map<String, int> _powerupUses = <String, int>{};
  Timer? _hintGlowTimer;
  Timer? _audioEchoTimer;
  Timer? _freezeTimer;
  bool _freezeTimerActive = false;
  int _hintGlowSalt = 0;
  int _audioEchoSalt = 0;

  DeckBuildResult? _deckResult;
  DateTime _runStartedAt = DateTime.now();
  int _cursor = 0;
  int _timeExtendsUsed = 0;
  bool _runFinished = false;
  UserMeta? _userMeta;
  int _targetMatches = 50;

  Future<void> initialize() async {
    state = RunState.loading(
      rows: _settings.rows,
      targetMatches: _settings.targetMatches,
    );
    _resetSession();

    await _loadUserMeta();
    _activeLevelId = _userMeta?.activeLevel ?? UserMeta.levelOrder.first;
    final levelProgress = _userMeta?.levelProgress[_activeLevelId];
    _targetMatches = _settings.targetForProgress(levelProgress);
    _tierOneThreshold = _clampThreshold(
      _settings.tierOneThresholdFor(_targetMatches),
      1,
      _targetMatches,
    );
    _tierTwoThreshold = _clampThreshold(
      _settings.tierTwoThresholdFor(_targetMatches),
      _tierOneThreshold + 1,
      max(_targetMatches - 1, _tierOneThreshold + 1),
    );
    if (_userMeta != null) {
      _userMeta!.level = _activeLevelId;
    }
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
    final initialInventory = _userMeta != null
        ? _buildInitialPowerupInventory(_userMeta!)
        : Map<String, int>.from(_perRunPowerupGrants);

    state = RunState.ready(
      rows: _settings.rows,
      board: balancedBoard,
      deckRemaining: _remainingPairs,
      millisecondsRemaining: _settings.runDurationMs,
      targetMatches: _targetMatches,
      tierOneThreshold: _tierOneThreshold,
      tierTwoThreshold: _tierTwoThreshold,
      timeExtendTokens: _userMeta?.timeExtendTokens ?? 0,
      timeExtendsUsed: _timeExtendsUsed,
      powerupInventory: initialInventory,
    );
    _startTimer(_settings.runDurationMs);
  }

  Future<void> _updateMetaAfterRun({
    required RunLog runLog,
    required bool success,
  }) async {
    final meta = _userMeta ?? await _userMetaRepository.getOrCreate();
    meta.totalRuns += 1;
    meta.totalMatches += runLog.matchesCompleted;
    meta.totalAttempts += runLog.attemptCount;
    meta.totalTimeMs += runLog.durationMs;
    meta.lastRunAt = runLog.completedAt ?? DateTime.now();
    meta.lastLearnedDelta = runLog.learnedPromoted.length;
    meta.lastTroubleDelta = runLog.troubleDetected.length;
    if (meta.lastLearnedDelta > 0) {
      meta.learnedCount += meta.lastLearnedDelta;
    }
    if (meta.lastTroubleDelta > 0) {
      meta.troubleCount += meta.lastTroubleDelta;
    }
    if (success) {
      meta.currentStreak += 1;
    } else {
      meta.currentStreak = 0;
    }
    meta.bestStreak = max(
      meta.bestStreak,
      max(meta.currentStreak, runLog.streakMax),
    );
    meta.xp += runLog.xpEarned;
    meta.xpSinceLastReward += runLog.xpEarned;

    final levelProgress = meta.levelProgress[_activeLevelId] ?? LevelProgress();
    levelProgress.recordMasteredItems(_matchedThisRun);
    levelProgress.bestStreak = max(levelProgress.bestStreak, runLog.streakMax);
    if (runLog.cleanRun) {
      levelProgress.cleanRuns += 1;
      levelProgress.lastCleanRunAt = runLog.completedAt ?? DateTime.now();
      _grantPowerup(meta, _settings.cleanRunRewardPowerup);
    }
    if (levelProgress.totalMatches > 0 &&
        levelProgress.matchesCleared >= levelProgress.totalMatches &&
        levelProgress.completedAt == null) {
      levelProgress.completedAt = runLog.completedAt ?? DateTime.now();
    }
    final minTarget = _settings.minTargetMatches;
    final maxTarget = _settings.targetMatches;
    levelProgress.targetMatches =
        max(levelProgress.targetMatches, _targetMatches);

    if (success) {
      final interval = max(1, _settings.successesPerTargetIncrement);
      levelProgress.successRampProgress += 1;
      while (levelProgress.successRampProgress >= interval &&
          levelProgress.targetMatches < maxTarget) {
        levelProgress.successRampProgress -= interval;
        levelProgress.targetMatches += 1;
      }
    } else {
      levelProgress.successRampProgress = 0;
    }

    final clamped = levelProgress.targetMatches.clamp(minTarget, maxTarget);
    levelProgress.targetMatches = clamped is int ? clamped : clamped.round();
    meta.levelProgress[_activeLevelId] = levelProgress;

    for (final entry in _settings.powerupXpThresholds.entries) {
      final powerupId = entry.key;
      final threshold = entry.value;
      if (meta.xp >= threshold && !meta.unlockedPowerups.contains(powerupId)) {
        _grantPowerup(meta, powerupId);
      }
    }

    meta.level = meta.activeLevel;
    _userMeta = meta;
    await _userMetaRepository.save(meta);
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
      _applyMismatchPenalty();
      _triggerMismatchEffect(leftSelection, rightSelection);
    }
  }

  @override
  void dispose() {
    _timerService.stop();
    _cancelMismatchTimer();
    _cancelCelebrationTimer();
    _cancelConfettiTimer();
    unawaited(_flushPendingProgress());
    super.dispose();
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
    _cancelConfettiTimer();
    _confettiSalt = 0;
    _cancelHintGlowTimer();
    _cancelAudioEchoTimer();
    _cancelFreezeTimer();
    _freezeTimerActive = false;
    _dirtyItemIds.clear();
    _cancelProgressPersistTimer();
    _matchedThisRun.clear();
    _powerupsEarnedThisRun.clear();
    _powerupCooldowns.clear();
    _powerupUses.clear();
    _xpEarned = 0;
    _xpBonus = 0;
    _currentStreak = 0;
    _bestStreak = 0;
    _cleanRun = true;
    _tierOneCelebrated = false;
    _tierTwoCelebrated = false;
  }

  BoardRow _createRow(VocabItem item) {
    final left = _buildLeftTile(item);
    final right = _buildRightTile(item);
    return BoardRow(left: left, right: right);
  }

  void _handleCorrect(String itemId, {bool awardXp = true}) {
    final itemState = _ensureItemState(itemId)
      ..seenCount += 1
      ..correctStreak += 1
      ..totalCorrect += 1
      ..lastSeenAt = DateTime.now();

    final wasLearned = itemState.learnedAt != null;
    final learnedThresholdMet =
        itemState.totalCorrect >= _settings.matchesToLearn;
    if (learnedThresholdMet && !wasLearned) {
      itemState.learnedAt = DateTime.now();
      if (!_learnedPromotions.contains(itemId)) {
        _learnedPromotions.add(itemId);
      }
    }
    _markStateDirty(itemId);

    if (awardXp) {
      _currentStreak += 1;
      _bestStreak = max(_bestStreak, _currentStreak);
      var gainedXp = _settings.baseMatchXp;
      final streakBonus = _settings.streakBonusTable[_currentStreak] ?? 0;
      if (streakBonus > 0) {
        _xpBonus += streakBonus;
        gainedXp += streakBonus;
        _triggerConfetti(intensity: 0.35);
      }
      _xpEarned += gainedXp;
    }
    _matchedThisRun.add(itemId);
    state = this.state.copyWith(
      xpEarned: _xpEarned,
      xpBonus: _xpBonus,
      streakCurrent: awardXp ? _currentStreak : state.streakCurrent,
      streakBest: awardXp ? _bestStreak : state.streakBest,
    );
    _evaluatePowerupThresholds();
  }

  void _handleWrong(String itemId) {
    _ensureItemState(itemId)
      ..seenCount += 1
      ..correctStreak = 0
      ..wrongCount += 1
      ..troubleAt = DateTime.now()
      ..lastSeenAt = DateTime.now();

    _troubleDetected.add(itemId);
    _markStateDirty(itemId);
    unawaited(_feedbackService.onMismatch());
    _cleanRun = false;
    _currentStreak = 0;
    state = this.state.copyWith(
      streakCurrent: 0,
      cleanRun: false,
    );
  }

  void _applyMismatchPenalty() {
    final penalty = _settings.mismatchPenaltyMs;
    if (penalty <= 0 || _runFinished || state.phase != RunPhase.ready) {
      return;
    }
    _timerService.reduceBy(penalty);
  }

  void activatePowerup(String powerupId) {
    final canonicalId = _canonicalizePowerupId(powerupId);
    switch (canonicalId) {
      case 'timeExtend':
        _applyManualTimeExtend();
        break;
      case 'hintGlow':
        _activateHintGlow();
        break;
      case 'freezeTimer':
        _activateFreezeTimer();
        break;
      case 'autoMatch':
        _activateAutoMatch();
        break;
      case 'audioEcho':
        _activateAudioEcho();
        break;
    }
  }

  bool isPowerupReady(String powerupId) {
    return _canUsePowerup(powerupId);
  }

  void _applyManualTimeExtend() {
    if (_runFinished) {
      return;
    }
    final meta = _userMeta;
    if (meta == null || meta.timeExtendTokens <= 0) {
      return;
    }
    if (_timeExtendsUsed >= _settings.maxTimeExtendsPerRun) {
      return;
    }
    meta.timeExtendTokens -= 1;
    _setInventoryCount(meta, 'timeExtend', meta.timeExtendTokens);
    _timeExtendsUsed += 1;
    final baseRemaining = max(0, state.millisecondsRemaining);
    _timerService.extendBy(_settings.timeExtendDurationMs);
    final updatedRemaining = baseRemaining + _settings.timeExtendDurationMs;
    final updatedInventory = Map<String, int>.from(state.powerupInventory);
    updatedInventory['timeExtend'] = meta.timeExtendTokens;
    state = state.copyWith(
      millisecondsRemaining: updatedRemaining,
      timeExtendTokens: meta.timeExtendTokens,
      timeExtendsUsed: _timeExtendsUsed,
      powerupInventory: updatedInventory,
    );
    unawaited(_userMetaRepository.save(meta));
  }

  void _activateHintGlow() {
    if (!_canUsePowerup('hintGlow')) {
      return;
    }
    final englishRow = _pickRandomEnglishRow();
    if (englishRow == null) {
      return;
    }
    final pairId = state.board[englishRow].left.pairId;
    final spanishRow = _findRowForPair(pairId, TileColumn.right);
    if (spanishRow == null) {
      return;
    }
    if (!_consumePowerupCharge('hintGlow')) {
      return;
    }
    final effect = HintGlowEffect(
      token: ++_hintGlowSalt,
      englishRow: englishRow,
      spanishRow: spanishRow,
    );
    _cancelHintGlowTimer();
    state = state.copyWith(hintGlowEffect: effect);
    _hintGlowTimer = Timer(_hintGlowDuration, () {
      if (!mounted || _runFinished) {
        return;
      }
      if (state.hintGlowEffect?.token == effect.token) {
        state = state.copyWith(clearHintGlow: true);
      }
    });
    final cooldown = _powerupCooldownDurations['hintGlow'];
    _startCooldown('hintGlow', cooldown);
  }

  void _activateFreezeTimer() {
    if (_freezeTimerActive || !_canUsePowerup('freezeTimer')) {
      return;
    }
    if (!_consumePowerupCharge('freezeTimer')) {
      return;
    }
    _freezeTimerActive = true;
    _timerService.pause();
    state = state.copyWith(isTimerFrozen: true);
    _cancelFreezeTimer();
    _freezeTimer = Timer(_freezeTimerDuration, () {
      if (!_runFinished) {
        _timerService.resume();
      }
      _freezeTimerActive = false;
      if (!mounted) {
        return;
      }
      state = state.copyWith(isTimerFrozen: false);
    });
  }

  void _activateAutoMatch() {
    if (!_canUsePowerup('autoMatch')) {
      return;
    }
    final englishRow = _pickRandomEnglishRow();
    if (englishRow == null) {
      return;
    }
    final englishTile = state.board[englishRow].left;
    final pairId = englishTile.pairId;
    final spanishRow = _findRowForPair(pairId, TileColumn.right);
    if (pairId.isEmpty || spanishRow == null) {
      return;
    }
    if (!_consumePowerupCharge('autoMatch')) {
      return;
    }
    final leftSelection = TileSelection(
      column: TileColumn.left,
      row: englishRow,
      pairId: pairId,
    );
    final rightSelection = TileSelection(
      column: TileColumn.right,
      row: spanishRow,
      pairId: pairId,
    );
    _logAttempt(
      first: leftSelection,
      second: rightSelection,
      correct: true,
      resultingProgress: state.progress + 1,
    );
    _handleCorrect(pairId, awardXp: false);
    _resolveMatch(leftSelection, rightSelection);
  }

  void _activateAudioEcho() {
    if (!_canUsePowerup('audioEcho')) {
      return;
    }
    final spanishRow = _pickRandomSpanishRow();
    if (spanishRow == null) {
      return;
    }
    final spanishTile = state.board[spanishRow].right;
    final pairId = spanishTile.pairId;
    if (pairId.isEmpty) {
      return;
    }
    final englishRow = _findRowForPair(pairId, TileColumn.left);
    if (englishRow == null) {
      return;
    }
    if (!_consumePowerupCharge('audioEcho')) {
      return;
    }
    final effect = AudioEchoEffect(
      token: ++_audioEchoSalt,
      spanishRow: spanishRow,
      englishRow: englishRow,
      spanishText: spanishTile.text,
      pairId: pairId,
    );
    state = state.copyWith(audioEchoEffect: effect);
    _cancelAudioEchoTimer();
    _audioEchoTimer = Timer(_audioEchoHighlightDuration, () {
      if (!mounted || _runFinished) {
        return;
      }
      if (state.audioEchoEffect?.token == effect.token) {
        state = state.copyWith(clearAudioEcho: true);
      }
    });
    final cooldown = _powerupCooldownDurations['audioEcho'];
    _startCooldown('audioEcho', cooldown);
  }

  void _markStateDirty(String itemId) {
    _dirtyItemIds.add(itemId);
    _scheduleProgressPersist();
  }

  void _scheduleProgressPersist() {
    if (_progressPersistTimer?.isActive ?? false) {
      return;
    }
    _progressPersistTimer = Timer(const Duration(seconds: 2), () {
      unawaited(_flushPendingProgress());
    });
  }

  Future<void> _flushPendingProgress() async {
    _cancelProgressPersistTimer();
    if (_dirtyItemIds.isEmpty) {
      return;
    }
    final ids = _dirtyItemIds.toList(growable: false);
    _dirtyItemIds.clear();
    final payload = ids
        .map((id) => _itemStates[id])
        .whereType<UserItemState>()
        .toList(growable: false);
    if (payload.isEmpty) {
      return;
    }
    await _saveUserStates(payload);
  }

  void _cancelProgressPersistTimer() {
    _progressPersistTimer?.cancel();
    _progressPersistTimer = null;
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

    final nextProgress = state.progress + 1;
    final celebration = CelebrationEffect(token: ++_celebrationSalt);
    _cancelCelebrationTimer();
    state = state.copyWith(
      board: balancedBoard,
      progress: nextProgress,
      clearSelection: true,
      deckRemaining: _remainingPairs,
      celebrationEffect: celebration,
    );
    unawaited(
      _feedbackService.onMatch(
        tier: _tierForProgress(nextProgress),
      ),
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
    if (state.progress >= _targetMatches) {
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
    _setInventoryCount(meta, 'timeExtend', meta.timeExtendTokens);
    _timeExtendsUsed += 1;

    final baseRemaining = max(0, state.millisecondsRemaining);
    final updatedRemaining = baseRemaining + _settings.timeExtendDurationMs;

    state = state.copyWith(
      showingTimeExtendOffer: false,
      inputLocked: false,
      millisecondsRemaining: updatedRemaining,
      timeExtendTokens: meta.timeExtendTokens,
      timeExtendsUsed: _timeExtendsUsed,
      powerupInventory: {
        ...state.powerupInventory,
        'timeExtend': max(0, (state.powerupInventory['timeExtend'] ?? 0) - 1),
      },
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
    if (!_tierOneCelebrated && state.progress >= _tierOneThreshold) {
      _handleTierMilestone(tier: 1);
    }
    if (!_tierTwoCelebrated && state.progress >= _tierTwoThreshold) {
      _handleTierMilestone(tier: 2);
    }
    if (state.progress >= _targetMatches) {
      unawaited(_completeRun());
    }
  }

  void _handleTierMilestone({required int tier}) {
    if (_runFinished) {
      return;
    }
    if (tier == 1) {
      _tierOneCelebrated = true;
    } else if (tier == 2) {
      _tierTwoCelebrated = true;
    }
    unawaited(_feedbackService.onTierPause(tier: tier));
    _triggerConfetti(intensity: tier == 2 ? 0.8 : 0.6);
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
    _cancelHintGlowTimer();
    _cancelAudioEchoTimer();
    _cancelFreezeTimer();
    if (_freezeTimerActive) {
      _freezeTimerActive = false;
      _timerService.resume();
    }
    state = state.copyWith(
      clearHintGlow: true,
      clearAudioEcho: true,
      isTimerFrozen: false,
    );
    _refillSequenceActive = false;
    _clearMismatchEffect();
    _clearCelebrationEffect();
    await _flushPendingProgress();
    final completedAt = DateTime.now();
    final durationMs = completedAt.difference(_runStartedAt).inMilliseconds;
    final runLog = RunLog()
      ..startedAt = _runStartedAt
      ..completedAt = completedAt
      ..tierReached = _tierForProgress(state.progress)
      ..levelId = _activeLevelId
      ..rowsUsed = _settings.rows
      ..timeExtendsUsed = _timeExtendsUsed
      ..matchesCompleted = state.progress
      ..attemptCount = _attempts.length
      ..durationMs = durationMs < 0 ? 0 : durationMs
      ..xpEarned = _xpEarned
      ..xpBonus = _xpBonus
      ..streakMax = _bestStreak
      ..cleanRun = success && _cleanRun
      ..deckComposition = _buildDeckComposition()
      ..learnedPromoted = _learnedPromotions.toSet().toList()
      ..troubleDetected = _troubleDetected.toList()
      ..powerupsEarned = _powerupsEarnedThisRun.toSet().toList();

    final runId = await _addRunLog(runLog);
    if (_attempts.isNotEmpty) {
      for (final attempt in _attempts) {
        attempt.runLogId = runId;
      }
      await _addAttemptLogs(_attempts);
    }

    await _saveUserStates(_itemStates.values.toList());
    await _updateMetaAfterRun(runLog: runLog, success: success);
    unawaited(_profileService.pushActiveProfile());
    unawaited(
      _feedbackService.onRunComplete(
        tierReached: runLog.tierReached,
        success: success,
      ),
    );
    _triggerConfetti(intensity: success ? 1.0 : 0.4);
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

  Map<String, int> _buildPowerupInventory(UserMeta meta) {
    final inventory = Map<String, int>.from(meta.powerupInventory);
    inventory['timeExtend'] = meta.timeExtendTokens;
    inventory['rowBlaster'] = meta.rowBlasterCharges;
    return inventory;
  }

  Map<String, int> _buildInitialPowerupInventory(UserMeta meta) {
    final inventory = _buildPowerupInventory(meta);
    for (final entry in _perRunPowerupGrants.entries) {
      if (entry.value <= 0) {
        continue;
      }
      inventory[entry.key] = (inventory[entry.key] ?? 0) + entry.value;
    }
    return inventory;
  }

  void _evaluatePowerupThresholds() {
    final meta = _userMeta;
    if (meta == null) {
      return;
    }
    final totalXp = meta.xp + _xpEarned;
    for (final entry in _settings.powerupXpThresholds.entries) {
      final powerupId = entry.key;
      final threshold = entry.value;
      final alreadyUnlocked =
          meta.unlockedPowerups.contains(powerupId) ||
          _powerupsEarnedThisRun.contains(powerupId);
      if (!alreadyUnlocked && totalXp >= threshold) {
        _grantPowerup(meta, powerupId);
      }
    }
  }

  void _grantPowerup(UserMeta meta, String powerupId) {
    if (powerupId.isEmpty) {
      return;
    }
    final canonicalId = _canonicalizePowerupId(powerupId);
    switch (canonicalId) {
      case 'timeExtend':
        meta.timeExtendTokens += 1;
        _setInventoryCount(meta, canonicalId, meta.timeExtendTokens);
        break;
      case 'rowBlaster':
        meta.rowBlasterCharges += 1;
        _setInventoryCount(meta, canonicalId, meta.rowBlasterCharges);
        break;
      default:
        meta.powerupInventory[canonicalId] =
            (meta.powerupInventory[canonicalId] ?? 0) + 1;
        break;
    }

    meta.unlockedPowerups.add(canonicalId);
    _powerupsEarnedThisRun.add(canonicalId);

    final updatedInventory = Map<String, int>.from(state.powerupInventory);
    if (canonicalId == 'timeExtend') {
      updatedInventory[canonicalId] = meta.timeExtendTokens;
      state = state.copyWith(
        timeExtendTokens: meta.timeExtendTokens,
        powerupInventory: updatedInventory,
      );
    } else if (canonicalId == 'rowBlaster') {
      updatedInventory[canonicalId] = meta.rowBlasterCharges;
      state = state.copyWith(powerupInventory: updatedInventory);
    } else {
      updatedInventory[canonicalId] = (updatedInventory[canonicalId] ?? 0) + 1;
      state = state.copyWith(powerupInventory: updatedInventory);
    }
  }

  String _canonicalizePowerupId(String id) {
    final normalized = id.toLowerCase();
    switch (normalized) {
      case 'timeextend':
      case 'time_extend':
      case 'timeextendtoken':
      case 'timeextendpowerup':
        return 'timeExtend';
      case 'rowblaster':
      case 'row_blaster':
        return 'rowBlaster';
      case 'hintglow':
      case 'hint_glow':
        return 'hintGlow';
      case 'freezetimer':
      case 'freeze_timer':
        return 'freezeTimer';
      case 'automatch':
      case 'auto_match':
        return 'autoMatch';
      case 'audioecho':
      case 'audio_echo':
        return 'audioEcho';
      default:
        return id;
    }
  }

  void _setInventoryCount(UserMeta meta, String id, int count) {
    final canonical = _canonicalizePowerupId(id);
    final next = max(0, count);
    switch (canonical) {
      case 'timeExtend':
        meta.timeExtendTokens = next;
        meta.powerupInventory['timeExtend'] = next;
        break;
      case 'rowBlaster':
        meta.rowBlasterCharges = next;
        meta.powerupInventory['rowBlaster'] = next;
        break;
      default:
        if (next <= 0) {
          meta.powerupInventory.remove(canonical);
        } else {
          meta.powerupInventory[canonical] = next;
        }
        break;
    }
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
    if (progress >= _targetMatches) {
      return 3;
    }
    if (progress >= _tierTwoThreshold) {
      return 2;
    }
    return 1;
  }

  bool _canUsePowerup(String powerupId) {
    final canonical = _canonicalizePowerupId(powerupId);
    if (_runFinished) {
      return false;
    }
    final count = state.powerupInventory[canonical] ?? 0;
    if (count <= 0) {
      return false;
    }
    final limit = _powerupRunLimits[canonical];
    if (limit != null && (_powerupUses[canonical] ?? 0) >= limit) {
      return false;
    }
    final cooldownUntil = _powerupCooldowns[canonical];
    if (cooldownUntil != null && cooldownUntil.isAfter(DateTime.now())) {
      return false;
    }
    return true;
  }

  bool _consumePowerupCharge(String powerupId) {
    final canonical = _canonicalizePowerupId(powerupId);
    final current = state.powerupInventory[canonical] ?? 0;
    if (current <= 0) {
      return false;
    }
    final updatedInventory = Map<String, int>.from(state.powerupInventory);
    updatedInventory[canonical] = current - 1;
    int? updatedTimeExtendTokens;
    if (canonical == 'timeExtend') {
      updatedTimeExtendTokens = max(0, state.timeExtendTokens - 1);
    }
    state = state.copyWith(
      powerupInventory: updatedInventory,
      timeExtendTokens: updatedTimeExtendTokens ?? state.timeExtendTokens,
    );
    final meta = _userMeta;
    if (meta != null) {
      _setInventoryCount(meta, canonical, current - 1);
      unawaited(_userMetaRepository.save(meta));
    }
    _powerupUses[canonical] = (_powerupUses[canonical] ?? 0) + 1;
    return true;
  }

  void _startCooldown(String powerupId, Duration? duration) {
    final canonical = _canonicalizePowerupId(powerupId);
    if (duration == null || duration <= Duration.zero) {
      _powerupCooldowns.remove(canonical);
      return;
    }
    _powerupCooldowns[canonical] = DateTime.now().add(duration);
  }

  int? _pickRandomEnglishRow() {
    final candidates = <int>[];
    for (var i = 0; i < state.board.length; i++) {
      final tile = state.board[i].left;
      if (tile.pairId.isNotEmpty) {
        candidates.add(i);
      }
    }
    if (candidates.isEmpty) {
      return null;
    }
    return candidates[_random.nextInt(candidates.length)];
  }

  int? _pickRandomSpanishRow() {
    final candidates = <int>[];
    for (var i = 0; i < state.board.length; i++) {
      final tile = state.board[i].right;
      if (tile.pairId.isNotEmpty) {
        candidates.add(i);
      }
    }
    if (candidates.isEmpty) {
      return null;
    }
    return candidates[_random.nextInt(candidates.length)];
  }

  int? _findRowForPair(String pairId, TileColumn column) {
    if (pairId.isEmpty) {
      return null;
    }
    for (var i = 0; i < state.board.length; i++) {
      final tile = column == TileColumn.left
          ? state.board[i].left
          : state.board[i].right;
      if (tile.pairId == pairId) {
        return i;
      }
    }
    return null;
  }

  void _maybeRefillPending({bool force = false}) {
    if (_pendingRefillRows.isEmpty || !_canContinueRefill()) {
      return;
    }

    final remainingPairs = _remainingPairs;
    final shouldStart =
        force ||
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

  void _cancelHintGlowTimer() {
    _hintGlowTimer?.cancel();
    _hintGlowTimer = null;
  }

  void _cancelAudioEchoTimer() {
    _audioEchoTimer?.cancel();
    _audioEchoTimer = null;
  }

  void _cancelFreezeTimer() {
    _freezeTimer?.cancel();
    _freezeTimer = null;
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

  void _triggerConfetti({required double intensity}) {
    final clamped = intensity.clamp(0.25, 1.2);
    state = state.copyWith(
      confettiEffect: ConfettiEffect(
        token: ++_confettiSalt,
        intensity: clamped,
      ),
    );
    _cancelConfettiTimer();
    _confettiTimer = Timer(const Duration(milliseconds: 1800), () {
      if (!mounted) {
        return;
      }
      state = state.copyWith(clearConfetti: true);
    });
  }

  void _cancelConfettiTimer() {
    _confettiTimer?.cancel();
    _confettiTimer = null;
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
    _scatterRightTile(updatedBoard, rowIndex);
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

  void _scatterRightTile(List<BoardRow> board, int sourceRowIndex) {
    if (sourceRowIndex < 0 || sourceRowIndex >= board.length) {
      return;
    }
    final sourceTile = board[sourceRowIndex].right;
    if (sourceTile.pairId.isEmpty) {
      return;
    }
    final activeRows = <int>[];
    for (var i = 0; i < board.length; i++) {
      if (board[i].right.pairId.isNotEmpty) {
        activeRows.add(i);
      }
    }
    if (activeRows.length <= 1) {
      return;
    }
    var targetRowIndex = sourceRowIndex;
    var attempts = 0;
    while (attempts < 5 && targetRowIndex == sourceRowIndex) {
      targetRowIndex = activeRows[_random.nextInt(activeRows.length)];
      attempts += 1;
    }
    if (targetRowIndex == sourceRowIndex) {
      targetRowIndex = activeRows.firstWhere(
        (index) => index != sourceRowIndex,
        orElse: () => sourceRowIndex,
      );
    }
    if (targetRowIndex == sourceRowIndex ||
        board[targetRowIndex].right.pairId.isEmpty) {
      return;
    }
    final source = board[sourceRowIndex].right;
    final target = board[targetRowIndex].right;
    board[sourceRowIndex] = board[sourceRowIndex].replaceTile(
      TileColumn.right,
      target,
    );
    board[targetRowIndex] = board[targetRowIndex].replaceTile(
      TileColumn.right,
      source,
    );
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

  int _clampThreshold(int value, int minValue, int maxValue) {
    if (maxValue < minValue) {
      return minValue;
    }
    final clamped = value.clamp(minValue, maxValue);
    if (clamped is int) {
      return clamped;
    }
    return clamped.round();
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
      final feedbackService = ref.watch(runFeedbackServiceProvider);
      final profileService = ref.watch(profileServiceProvider);

      final RunController controller = RunController(
        deckBuilderService: deckBuilder,
        settings: settings,
        timerService: timerService,
        fetchUserStates: userProgressRepo.getStates,
        saveUserStates: userProgressRepo.upsertStates,
        addRunLog: runLogRepo.add,
        addAttemptLogs: attemptRepo.addAll,
        userMetaRepository: userMetaRepo,
        feedbackService: feedbackService,
        profileService: profileService,
      );

      unawaited(controller.initialize());
      return controller;
    });
