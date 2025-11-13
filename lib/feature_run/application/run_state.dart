// Internal-only state types remain undocumented while mechanics are still shifting.
// ignore_for_file: public_member_api_docs

enum RunPhase { loading, ready, completed }

enum TileColumn { left, right }

class TileSelection {
  const TileSelection({
    required this.column,
    required this.row,
    required this.pairId,
  });

  final TileColumn column;
  final int row;
  final String pairId;
}

class MismatchEffect {
  const MismatchEffect({
    required this.token,
    required this.left,
    required this.right,
  });

  final int token;
  final TileSelection left;
  final TileSelection right;

  bool involves(int row, TileColumn column) {
    return (left.row == row && left.column == column) ||
        (right.row == row && right.column == column);
  }
}

class CelebrationEffect {
  const CelebrationEffect({required this.token});

  final int token;
}

class ConfettiEffect {
  const ConfettiEffect({
    required this.token,
    required this.intensity,
  });

  final int token;
  final double intensity;
}

class HintGlowEffect {
  const HintGlowEffect({
    required this.token,
    required this.englishRow,
    required this.spanishRow,
  });

  final int token;
  final int englishRow;
  final int spanishRow;
}

class AudioEchoEffect {
  const AudioEchoEffect({
    required this.token,
    required this.spanishRow,
    required this.englishRow,
    required this.spanishText,
    required this.pairId,
  });

  final int token;
  final int spanishRow;
  final int englishRow;
  final String spanishText;
  final String pairId;
}

class BoardTile {
  const BoardTile({
    required this.id,
    required this.pairId,
    required this.text,
    required this.column,
  });

  final String id;
  final String pairId;
  final String text;
  final TileColumn column;
}

class BoardRow {
  const BoardRow({required this.left, required this.right});

  final BoardTile left;
  final BoardTile right;

  BoardRow replaceTile(TileColumn column, BoardTile tile) {
    if (column == TileColumn.left) {
      return BoardRow(left: tile, right: right);
    }
    return BoardRow(left: left, right: tile);
  }

  BoardTile tileOf(TileColumn column) {
    return column == TileColumn.left ? left : right;
  }
}

class RunState {
  const RunState({
    required this.phase,
    required this.rows,
    required this.board,
    required this.progress,
    required this.targetMatches,
    required this.tierOneThreshold,
    required this.tierTwoThreshold,
    required this.selection,
    required this.mismatchEffect,
    required this.celebrationEffect,
    required this.confettiEffect,
    required this.hintGlowEffect,
    required this.audioEchoEffect,
    required this.isResolving,
    required this.deckRemaining,
    required this.millisecondsRemaining,
    required this.inputLocked,
    required this.isTimerFrozen,
    required this.timeExtendTokens,
    required this.timeExtendsUsed,
    required this.showingTimeExtendOffer,
    required this.xpEarned,
    required this.xpBonus,
    required this.streakCurrent,
    required this.streakBest,
    required this.cleanRun,
    required this.powerupInventory,
  });

  factory RunState.loading({
    required int rows,
    int targetMatches = 50,
  }) {
    return RunState(
      phase: RunPhase.loading,
      rows: rows,
      board: const <BoardRow>[],
      progress: 0,
      targetMatches: targetMatches,
      tierOneThreshold: 0,
      tierTwoThreshold: 0,
      selection: null,
      mismatchEffect: null,
      celebrationEffect: null,
      confettiEffect: null,
      hintGlowEffect: null,
      audioEchoEffect: null,
      isResolving: false,
      deckRemaining: 0,
      millisecondsRemaining: 60000,
      inputLocked: false,
      isTimerFrozen: false,
      timeExtendTokens: 0,
      timeExtendsUsed: 0,
      showingTimeExtendOffer: false,
      xpEarned: 0,
      xpBonus: 0,
      streakCurrent: 0,
      streakBest: 0,
      cleanRun: true,
      powerupInventory: const <String, int>{},
    );
  }

  factory RunState.ready({
    required int rows,
    required List<BoardRow> board,
    required int deckRemaining,
    required int millisecondsRemaining,
    required int targetMatches,
    required int tierOneThreshold,
    required int tierTwoThreshold,
    int timeExtendTokens = 0,
    int timeExtendsUsed = 0,
    Map<String, int>? powerupInventory,
  }) {
    return RunState(
      phase: RunPhase.ready,
      rows: rows,
      board: List<BoardRow>.unmodifiable(board),
      progress: 0,
      targetMatches: targetMatches,
      tierOneThreshold: tierOneThreshold,
      tierTwoThreshold: tierTwoThreshold,
      selection: null,
      mismatchEffect: null,
      celebrationEffect: null,
      confettiEffect: null,
      hintGlowEffect: null,
      audioEchoEffect: null,
      isResolving: false,
      deckRemaining: deckRemaining,
      millisecondsRemaining: millisecondsRemaining,
      inputLocked: false,
      isTimerFrozen: false,
      timeExtendTokens: timeExtendTokens,
      timeExtendsUsed: timeExtendsUsed,
      showingTimeExtendOffer: false,
      xpEarned: 0,
      xpBonus: 0,
      streakCurrent: 0,
      streakBest: 0,
      cleanRun: true,
      powerupInventory: powerupInventory != null
          ? Map<String, int>.from(powerupInventory)
          : const <String, int>{},
    );
  }

  final RunPhase phase;
  final int rows;
  final List<BoardRow> board;
  final int progress;
  final int targetMatches;
  final int tierOneThreshold;
  final int tierTwoThreshold;
  final TileSelection? selection;
  final MismatchEffect? mismatchEffect;
  final CelebrationEffect? celebrationEffect;
  final ConfettiEffect? confettiEffect;
  final HintGlowEffect? hintGlowEffect;
  final AudioEchoEffect? audioEchoEffect;
  final bool isResolving;
  final int deckRemaining;
  final int millisecondsRemaining;
  final bool inputLocked;
  final bool isTimerFrozen;
  final int timeExtendTokens;
  final int timeExtendsUsed;
  final bool showingTimeExtendOffer;
  final int xpEarned;
  final int xpBonus;
  final int streakCurrent;
  final int streakBest;
  final bool cleanRun;
  final Map<String, int> powerupInventory;

  bool get isReady => phase == RunPhase.ready;

  BoardTile tileAt(int row, TileColumn column) {
    return board[row].tileOf(column);
  }

  RunState copyWith({
    RunPhase? phase,
    List<BoardRow>? board,
    int? progress,
    int? targetMatches,
    int? tierOneThreshold,
    int? tierTwoThreshold,
    TileSelection? selection,
    bool clearSelection = false,
    MismatchEffect? mismatchEffect,
    bool clearMismatch = false,
    CelebrationEffect? celebrationEffect,
    bool clearCelebration = false,
    ConfettiEffect? confettiEffect,
    bool clearConfetti = false,
    HintGlowEffect? hintGlowEffect,
    bool clearHintGlow = false,
    AudioEchoEffect? audioEchoEffect,
    bool clearAudioEcho = false,
    bool? isResolving,
    int? deckRemaining,
    int? millisecondsRemaining,
    bool? inputLocked,
    bool? isTimerFrozen,
    int? timeExtendTokens,
    int? timeExtendsUsed,
    bool? showingTimeExtendOffer,
    int? xpEarned,
    int? xpBonus,
    int? streakCurrent,
    int? streakBest,
    bool? cleanRun,
    Map<String, int>? powerupInventory,
  }) {
    return RunState(
      phase: phase ?? this.phase,
      rows: rows,
      board: board != null ? List<BoardRow>.unmodifiable(board) : this.board,
      progress: progress ?? this.progress,
      targetMatches: targetMatches ?? this.targetMatches,
      tierOneThreshold: tierOneThreshold ?? this.tierOneThreshold,
      tierTwoThreshold: tierTwoThreshold ?? this.tierTwoThreshold,
      selection: clearSelection ? null : selection ?? this.selection,
      mismatchEffect: clearMismatch
          ? null
          : mismatchEffect ?? this.mismatchEffect,
      celebrationEffect: clearCelebration
          ? null
          : celebrationEffect ?? this.celebrationEffect,
      confettiEffect: clearConfetti
          ? null
          : confettiEffect ?? this.confettiEffect,
      hintGlowEffect: clearHintGlow
          ? null
          : hintGlowEffect ?? this.hintGlowEffect,
      audioEchoEffect: clearAudioEcho
          ? null
          : audioEchoEffect ?? this.audioEchoEffect,
      isResolving: isResolving ?? this.isResolving,
      deckRemaining: deckRemaining ?? this.deckRemaining,
      millisecondsRemaining:
          millisecondsRemaining ?? this.millisecondsRemaining,
      inputLocked: inputLocked ?? this.inputLocked,
      isTimerFrozen: isTimerFrozen ?? this.isTimerFrozen,
      timeExtendTokens: timeExtendTokens ?? this.timeExtendTokens,
      timeExtendsUsed: timeExtendsUsed ?? this.timeExtendsUsed,
      showingTimeExtendOffer:
          showingTimeExtendOffer ?? this.showingTimeExtendOffer,
      xpEarned: xpEarned ?? this.xpEarned,
      xpBonus: xpBonus ?? this.xpBonus,
      streakCurrent: streakCurrent ?? this.streakCurrent,
      streakBest: streakBest ?? this.streakBest,
      cleanRun: cleanRun ?? this.cleanRun,
      powerupInventory: powerupInventory != null
          ? Map<String, int>.from(powerupInventory)
          : this.powerupInventory,
    );
  }
}
