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
    required this.selection,
    required this.mismatchEffect,
    required this.celebrationEffect,
    required this.isResolving,
    required this.deckRemaining,
    required this.millisecondsRemaining,
    required this.pausedAtTier20,
    required this.pausedAtTier50,
    required this.inputLocked,
    required this.timeExtendTokens,
    required this.timeExtendsUsed,
    required this.showingTimeExtendOffer,
  });

  factory RunState.loading({required int rows}) {
    return RunState(
      phase: RunPhase.loading,
      rows: rows,
      board: const <BoardRow>[],
      progress: 0,
      selection: null,
      mismatchEffect: null,
      celebrationEffect: null,
      isResolving: false,
      deckRemaining: 0,
      millisecondsRemaining: 105000,
      pausedAtTier20: false,
      pausedAtTier50: false,
      inputLocked: false,
      timeExtendTokens: 0,
      timeExtendsUsed: 0,
      showingTimeExtendOffer: false,
    );
  }

  factory RunState.ready({
    required int rows,
    required List<BoardRow> board,
    required int deckRemaining,
    required int millisecondsRemaining,
    int timeExtendTokens = 0,
    int timeExtendsUsed = 0,
  }) {
    return RunState(
      phase: RunPhase.ready,
      rows: rows,
      board: List<BoardRow>.unmodifiable(board),
      progress: 0,
      selection: null,
      mismatchEffect: null,
      celebrationEffect: null,
      isResolving: false,
      deckRemaining: deckRemaining,
      millisecondsRemaining: millisecondsRemaining,
      pausedAtTier20: false,
      pausedAtTier50: false,
      inputLocked: false,
      timeExtendTokens: timeExtendTokens,
      timeExtendsUsed: timeExtendsUsed,
      showingTimeExtendOffer: false,
    );
  }

  final RunPhase phase;
  final int rows;
  final List<BoardRow> board;
  final int progress;
  final TileSelection? selection;
  final MismatchEffect? mismatchEffect;
  final CelebrationEffect? celebrationEffect;
  final bool isResolving;
  final int deckRemaining;
  final int millisecondsRemaining;
  final bool pausedAtTier20;
  final bool pausedAtTier50;
  final bool inputLocked;
  final int timeExtendTokens;
  final int timeExtendsUsed;
  final bool showingTimeExtendOffer;

  bool get isReady => phase == RunPhase.ready;

  BoardTile tileAt(int row, TileColumn column) {
    return board[row].tileOf(column);
  }

  RunState copyWith({
    RunPhase? phase,
    List<BoardRow>? board,
    int? progress,
    TileSelection? selection,
    bool clearSelection = false,
    MismatchEffect? mismatchEffect,
    bool clearMismatch = false,
    CelebrationEffect? celebrationEffect,
    bool clearCelebration = false,
    bool? isResolving,
    int? deckRemaining,
    int? millisecondsRemaining,
    bool? pausedAtTier20,
    bool? pausedAtTier50,
    bool? inputLocked,
    int? timeExtendTokens,
    int? timeExtendsUsed,
    bool? showingTimeExtendOffer,
  }) {
    return RunState(
      phase: phase ?? this.phase,
      rows: rows,
      board: board != null ? List<BoardRow>.unmodifiable(board) : this.board,
      progress: progress ?? this.progress,
      selection: clearSelection ? null : selection ?? this.selection,
      mismatchEffect:
          clearMismatch ? null : mismatchEffect ?? this.mismatchEffect,
      celebrationEffect: clearCelebration
          ? null
          : celebrationEffect ?? this.celebrationEffect,
      isResolving: isResolving ?? this.isResolving,
      deckRemaining: deckRemaining ?? this.deckRemaining,
      millisecondsRemaining:
          millisecondsRemaining ?? this.millisecondsRemaining,
      pausedAtTier20: pausedAtTier20 ?? this.pausedAtTier20,
      pausedAtTier50: pausedAtTier50 ?? this.pausedAtTier50,
      inputLocked: inputLocked ?? this.inputLocked,
      timeExtendTokens: timeExtendTokens ?? this.timeExtendTokens,
      timeExtendsUsed: timeExtendsUsed ?? this.timeExtendsUsed,
      showingTimeExtendOffer:
          showingTimeExtendOffer ?? this.showingTimeExtendOffer,
    );
  }
}
