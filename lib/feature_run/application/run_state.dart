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
    required this.isResolving,
    required this.deckRemaining,
    required this.millisecondsRemaining,
    required this.pausedAtTier20,
    required this.pausedAtTier50,
    required this.inputLocked,
  });

  factory RunState.loading({required int rows}) {
    return RunState(
      phase: RunPhase.loading,
      rows: rows,
      board: const <BoardRow>[],
      progress: 0,
      selection: null,
      isResolving: false,
      deckRemaining: 0,
      millisecondsRemaining: 105000,
      pausedAtTier20: false,
      pausedAtTier50: false,
      inputLocked: false,
    );
  }

  factory RunState.ready({
    required int rows,
    required List<BoardRow> board,
    required int deckRemaining,
    required int millisecondsRemaining,
  }) {
    return RunState(
      phase: RunPhase.ready,
      rows: rows,
      board: List<BoardRow>.unmodifiable(board),
      progress: 0,
      selection: null,
      isResolving: false,
      deckRemaining: deckRemaining,
      millisecondsRemaining: millisecondsRemaining,
      pausedAtTier20: false,
      pausedAtTier50: false,
      inputLocked: false,
    );
  }

  final RunPhase phase;
  final int rows;
  final List<BoardRow> board;
  final int progress;
  final TileSelection? selection;
  final bool isResolving;
  final int deckRemaining;
  final int millisecondsRemaining;
  final bool pausedAtTier20;
  final bool pausedAtTier50;
  final bool inputLocked;

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
    bool? isResolving,
    int? deckRemaining,
    int? millisecondsRemaining,
    bool? pausedAtTier20,
    bool? pausedAtTier50,
    bool? inputLocked,
  }) {
    return RunState(
      phase: phase ?? this.phase,
      rows: rows,
      board: board != null ? List<BoardRow>.unmodifiable(board) : this.board,
      progress: progress ?? this.progress,
      selection: clearSelection ? null : selection ?? this.selection,
      isResolving: isResolving ?? this.isResolving,
      deckRemaining: deckRemaining ?? this.deckRemaining,
      millisecondsRemaining:
          millisecondsRemaining ?? this.millisecondsRemaining,
      pausedAtTier20: pausedAtTier20 ?? this.pausedAtTier20,
      pausedAtTier50: pausedAtTier50 ?? this.pausedAtTier50,
      inputLocked: inputLocked ?? this.inputLocked,
    );
  }
}
