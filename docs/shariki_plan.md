Spec: “Color Lines / Lines 98” Mini-Game in Flutter
1. Context and Goal

This feature is a faithful implementation of the classic Color Lines / Lines 98 game, embedded as a new screen inside an existing Flutter app that already has at least one running game.

Color Lines / Lines 98 basic rules (for reference):

The board is a 9×9 grid.

Some cells contain colored balls.

On each player turn:

The player selects one ball and moves it to an empty cell, but only if there is a continuous path of empty cells connecting source and destination (4-way adjacency: up/down/left/right).

If this move creates any line of 5 or more balls of the same color (horizontal, vertical, or diagonal), that entire line disappears and the player scores points.

If the move does not create such a line, the game automatically spawns 3 new balls on the board (colors are shown in a preview).

The game ends when no empty cells remain on the board.

The goal is to implement this mini-game:

In Flutter + Dart.

As a self-contained feature module (separate files under lib/).

Exposed as a dedicated screen/route (e.g. /lines98).

With all core mechanics matching the above description.

2. High-Level Outline (Short Version)

This is the outline. After this section, the rest of the document provides a much more verbose, detailed plan.

Architecture

Create a feature folder, e.g. lib/features/lines98/.

Separate:

Pure data models and configuration.

Game state and controller (logic).

UI widgets and screen.

Core Data Model

Enums: LinesColor, LinesPhase.

Immutable types: LinesCell, LinesBoard, LinesPreviewSlot, LinesGameState.

Config constants: board size, initial number of balls, balls per spawn, line length.

Game Logic

LinesGameController (extends ChangeNotifier):

Maintains LinesGameState.

Handles:

New game initialization.

Cell taps (selection vs move).

Pathfinding (BFS) to validate moves.

Executing moves.

Detecting and removing lines.

Spawning balls from preview and generating new preview.

Game-over detection.

UI

LinesGameScreen:

Injects controller.

Shows:

Score.

Preview of upcoming balls.

9×9 board widget.

New Game / Back buttons.

LinesBoardWidget:

Renders grid.

Visual states for empty, ball, preview ball, selected cell.

LinesPreviewWidget:

Renders next 3 colors.

Optional: LinesScoreWidget for score + “Game Over” message.

Integration

Add a route to the existing app for LinesGameScreen.

Add a navigation entry from the main menu to reach this game.

Optionally plug into existing XP/achievements systems (not required for basic implementation).

3. Detailed Plan for Codex (Verbose Version)

The rest of this document is the detailed instruction text that Codex should follow step by step to implement the feature.

Treat this as a design spec + task breakdown.

3.1. Feature Folder and Files

Create a new feature folder:

lib/features/lines98/

Inside it, create these Dart files:

lines_models.dart

Enums, core data types, configuration constants.

lines_game_state.dart

Immutable LinesGameState class.

lines_game_controller.dart

LinesGameController with all game logic and state changes.

lines_board_widget.dart

Stateless widget to render the 9×9 grid and handle taps.

lines_preview_widget.dart

Stateless widget to render the 3 upcoming ball colors.

lines_game_screen.dart

Stateful or Provider-based widget that owns the controller and builds the complete game UI.

(Optional) lines_score_widget.dart

Widget to render score and game-over controls.

3.2. Data Models and Enums
3.2.1. Colors and Phases

In lines_models.dart:

Define a color enum:

enum LinesColor {
  red,
  green,
  blue,
  yellow,
  purple,
  cyan,
  orange,
}


Define a phase enum:

enum LinesPhase {
  idle,          // waiting for player to select a ball
  ballSelected,  // a ball is selected, waiting for destination cell
  animatingMove, // (optional) in case we add animations later
  spawning,      // spawning new balls, removing lines, etc.
  gameOver,      // no moves possible, board full
}


The animation phase can be used later; for now you can set it but not necessarily implement animations.

3.2.2. Config Constants

Still in lines_models.dart, define configuration:

class LinesConfig {
  static const int boardSize = 9;
  static const int initialBalls = 5;
  static const int spawnPerTurn = 3;
  static const int lineLength = 5;
  static const List<LinesColor> availableColors = [
    LinesColor.red,
    LinesColor.green,
    LinesColor.blue,
    LinesColor.yellow,
    LinesColor.purple,
    LinesColor.cyan,
    LinesColor.orange,
  ];
}

3.2.3. Cell Model

Each cell knows its coordinates, current big ball, and whether it holds a preview ball.

In lines_models.dart:

class LinesCell {
  final int row;
  final int col;
  final LinesColor? ballColor;      // null if no big ball
  final bool hasPreview;
  final LinesColor? previewColor;   // valid only if hasPreview == true

  const LinesCell({
    required this.row,
    required this.col,
    required this.ballColor,
    required this.hasPreview,
    required this.previewColor,
  });

  LinesCell copyWith({
    LinesColor? ballColor,
    bool? hasPreview,
    LinesColor? previewColor,
  }) {
    return LinesCell(
      row: row,
      col: col,
      ballColor: ballColor ?? this.ballColor,
      hasPreview: hasPreview ?? this.hasPreview,
      previewColor: previewColor ?? this.previewColor,
    );
  }
}

3.2.4. Preview Slot

A preview slot describes one upcoming ball. We will use the “preview on grid” variant:

Colors appear on the board as small balls before they spawn as big balls.

class LinesPreviewSlot {
  final LinesColor color;
  final int row;
  final int col;

  const LinesPreviewSlot({
    required this.color,
    required this.row,
    required this.col,
  });
}

3.2.5. Board Wrapper

Represent the board as a structured object:

class LinesBoard {
  final List<List<LinesCell>> cells;

  const LinesBoard(this.cells);

  LinesCell cellAt(int row, int col) => cells[row][col];

  LinesBoard updateCell(LinesCell newCell) {
    final newRows = List<List<LinesCell>>.generate(
      cells.length,
      (r) => List<LinesCell>.from(cells[r]),
    );
    newRows[newCell.row][newCell.col] = newCell;
    return LinesBoard(newRows);
  }

  Iterable<LinesCell> allCells() sync* {
    for (final row in cells) {
      for (final cell in row) {
        yield cell;
      }
    }
  }
}


Later, the controller will generate an initial LinesBoard with 9×9 LinesCells.

3.3. LinesGameState

In lines_game_state.dart, implement the immutable state object.

Fields:

LinesBoard board;

List<LinesPreviewSlot> preview; (length should normally be 3, but not enforced by type)

int score;

LinesPhase phase;

bool isGameOver;

int? selectedRow;

int? selectedCol;

Example:

class LinesGameState {
  final LinesBoard board;
  final List<LinesPreviewSlot> preview;
  final int score;
  final LinesPhase phase;
  final bool isGameOver;
  final int? selectedRow;
  final int? selectedCol;

  const LinesGameState({
    required this.board,
    required this.preview,
    required this.score,
    required this.phase,
    required this.isGameOver,
    required this.selectedRow,
    required this.selectedCol,
  });

  factory LinesGameState.initial(LinesBoard board) {
    return LinesGameState(
      board: board,
      preview: const [],
      score: 0,
      phase: LinesPhase.idle,
      isGameOver: false,
      selectedRow: null,
      selectedCol: null,
    );
  }

  LinesGameState copyWith({
    LinesBoard? board,
    List<LinesPreviewSlot>? preview,
    int? score,
    LinesPhase? phase,
    bool? isGameOver,
    int? selectedRow,
    int? selectedCol,
  }) {
    return LinesGameState(
      board: board ?? this.board,
      preview: preview ?? this.preview,
      score: score ?? this.score,
      phase: phase ?? this.phase,
      isGameOver: isGameOver ?? this.isGameOver,
      selectedRow: selectedRow,
      selectedCol: selectedCol,
    );
  }
}


Important: In copyWith, treat selectedRow / selectedCol carefully: passing null should reset them; do not fallback to the old value by default if the intention is to clear selection.

3.4. Game Controller

In lines_game_controller.dart:

Create LinesGameController that extends ChangeNotifier:

Holds a private _state and a Random instance.

Provides a LinesGameState get state getter.

All game logic lives here.

3.4.1. Fields and Constructor
class LinesGameController extends ChangeNotifier {
  LinesGameState _state;
  final Random _rng;

  LinesGameController()
      : _rng = Random(),
        _state = LinesGameState.initial(
          LinesBoard(
            List.generate(
              LinesConfig.boardSize,
              (r) => List.generate(
                LinesConfig.boardSize,
                (c) => LinesCell(
                  row: r,
                  col: c,
                  ballColor: null,
                  hasPreview: false,
                  previewColor: null,
                ),
              ),
            ),
          ),
        );

  LinesGameState get state => _state;

  void _updateState(LinesGameState newState) {
    _state = newState;
    notifyListeners();
  }
}


You can refine the initial board creation into a helper function if desired.

3.4.2. Public Methods

void startNewGame()

void onCellTap(int row, int col)

Optional later:

void undo() (not required initially).

3.4.3. startNewGame

Purpose: reset everything, lay out initial balls, generate first preview.

Algorithm:

Create a fresh empty LinesBoard with all cells empty.

Place LinesConfig.initialBalls big balls at random empty cells:

For each ball:

Find all empty cells.

Choose one at random.

Choose a random LinesColor.

Set that cell’s ballColor to that color.

Generate the first preview:

Call _generatePreview(board) (returns new board plus preview list).

Construct new LinesGameState with:

The updated board.

The preview list.

score = 0.

phase = LinesPhase.idle.

isGameOver = false.

selectedRow = null, selectedCol = null.

Call _updateState.

3.4.4. onCellTap

Handles both select and move.

Logic:

If state.isGameOver, return.

If state.phase is not idle and not ballSelected, ignore the tap (for now).

Read cell = state.board.cellAt(row, col).

Case 1: No selection yet (state.selectedRow == null):

If cell.ballColor != null:

Update state:

selectedRow = row, selectedCol = col.

phase = LinesPhase.ballSelected.

Notify listeners.

Case 2: A ball is already selected:

If the tapped cell also has a ball (cell.ballColor != null):

Change selection to the newly tapped ball:

Update selectedRow, selectedCol accordingly.

Else the tapped cell is a potential destination:

Validate a path from the selected cell to this cell:

Use _findPath (BFS).

If no path exists:

Optionally clear selection or keep it; minimal implementation can keep selection.

If path exists:

Call _applyMove(fromRow, fromCol, toRow, toCol).

3.4.5. Pathfinding: _findPath

Implement BFS to enforce the classic Lines 98 path rule:

Only move in 4 directions (up, down, left, right).

The path must pass exclusively through cells without big balls.

For simplicity:

Treat hasPreview == true as blocked for walking but allowed as a destination that will be overwritten; or

Optionally treat them as walkable and allow the ball to end there while clearing preview.

Algorithm:

Represent positions as Point<int> (or a custom CellCoord class).

Initialize a queue with start position.

Maintain a visited set and a cameFrom map to reconstruct path.

While queue not empty:

Dequeue current.

If current == destination, stop and reconstruct path.

Else, generate up to 4 neighbor cells (row±1, col±0), (row±0, col±1) that:

Are inside board bounds.

Are empty enough to step into (no big ball; decide on preview logic).

If BFS finishes without reaching destination, return null.

If path found, return a list of points representing that path.

Note: For minimal gameplay, you can ignore the path details for animation and only use it to verify reachability; the UI can just “teleport” the ball from source to destination.

3.4.6. Applying a Move: _applyMove

Once path is valid:

Retrieve source and destination cells from current board.

movingColor = fromCell.ballColor!.

Build a new board:

From cell: set ballColor = null.

Destination cell:

If hasPreview == true, clear preview flags:

hasPreview = false, previewColor = null.

Set ballColor = movingColor.

Clear selection in state:

selectedRow = null, selectedCol = null.

Set phase = LinesPhase.idle or LinesPhase.animatingMove.

Update state with new board and phase.

Call _handlePostMove(toRow, toCol).

3.4.7. Post-Move: _handlePostMove

After a ball has moved:

Call _findAndRemoveLines([Point(toRow, toCol)]).

This returns:

Updated board.

removedCount.

scoreDelta.

If removedCount > 0:

Update:

board to the updated board with removed balls.

score += scoreDelta.

phase = LinesPhase.idle.

Do not spawn new balls.

Call _updateState and return.

If removedCount == 0:

Call _spawnNewBalls().

3.5. Line Detection: _findAndRemoveLines

This method is responsible for detecting all lines of length ≥ LinesConfig.lineLength (=5) of same color, and removing them.

Approach:

For correctness and simplicity, you can scan the entire board after a move or spawn.

Use four axis directions:

Horizontal: left/right.

Vertical: up/down.

Main diagonal: up-left / down-right.

Anti-diagonal: up-right / down-left.

Implementation outline:

Initialize a Set<Point<int>> cellsToRemove = {}.

For each cell (r, c):

If cell.ballColor == null, skip.

For each of the 4 axis pairs:

Starting from (r, c), count same-color neighbors in the positive direction until color breaks or board ends.

Count same-color neighbors in the negative direction.

Total length = 1 + countPositive + countNegative.

If total length ≥ lineLength:

Add all involved cell coordinates to cellsToRemove.

After scans:

removedCount = cellsToRemove.length.

If removedCount == 0:

Return board unchanged and scoreDelta = 0.

If removedCount > 0:

For each position in cellsToRemove:

Set cell’s ballColor = null (preview flags can stay as they are, but normally no preview will be on those cells).

Compute scoreDelta.

Simple rule: scoreDelta = removedCount.

Or implement a non-linear rule if desired.

Return updated board, removedCount, scoreDelta.

Use this logic both after player moves and after spawn.

3.6. Spawn and Preview: _generatePreview and _spawnNewBalls

We are using the “preview on grid” variant:

The player sees three small balls on specific empty cells.

After a move that does not clear a line:

These small balls turn into big balls (unless the player moved onto those cells).

New preview small balls are then generated.

3.6.1. _generatePreview

Inputs: current board.

Algorithm:

Determine the list of empty cells:

Cells with ballColor == null and hasPreview == false.

If there are 0 empty cells, return an empty preview.

Let count = min(LinesConfig.spawnPerTurn, emptyCells.length).

Shuffle the empty cells or pick random cells without repetition.

For each of the first count cells:

Pick a random LinesColor.

Mark that board cell:

hasPreview = true.

previewColor = chosenColor.

Add a LinesPreviewSlot(color, row, col) to a preview list.

Return:

Updated board.

Preview list.

3.6.2. _spawnNewBalls

After a move that did not clear any line:

Start from current state’s board and preview list.

Initialize a set/list spawnedPositions = [].

For each LinesPreviewSlot in state.preview:

Read (row, col, color).

Get the corresponding cell.

If cell.ballColor == null:

Create a new cell with:

ballColor = color.

hasPreview = false.

previewColor = null.

Add (row, col) to spawnedPositions.

If cell.ballColor != null (player moved onto that cell):

Simply ignore this preview slot (that ball is effectively canceled); fewer than 3 balls will spawn.

If there are fewer empty cells than slots, you naturally spawn fewer balls.

After converting previews:

Clear preview list (preview = []).

Run _findAndRemoveLines(spawnedPositions).

This may clear lines and update score.

Call _checkGameOver() on the resulting board:

If no empty cells remain (all cells have ballColor != null):

Set isGameOver = true, phase = LinesPhase.gameOver.

Do not generate new preview.

Update state and return.

If game is not over:

Call _generatePreview(updatedBoard) to create new preview small balls.

Set phase = LinesPhase.idle.

Update state with new board and preview.

3.7. Game-Over Detection: _checkGameOver

Simple check:

Iterate over all cells in the board.

If any cell has ballColor == null and hasPreview == false, the game is not over.

If no such cell is found, the board is functionally full:

isGameOver = true

phase = LinesPhase.gameOver

You run this after a spawn cycle and line removal.

4. Flutter UI Details
4.1. LinesGameScreen

In lines_game_screen.dart:

Implement LinesGameScreen as a widget that:

Creates a LinesGameController.

Calls startNewGame() in initState.

Uses AnimatedBuilder, ChangeNotifierProvider, or similar to rebuild when controller.state changes.

Layout suggestion:

Scaffold with:

AppBar:

Title: “Lines 98” or “Color Lines”.

Back button to main app.

body: a Column containing:

Top row: Score display + New Game button.

Second row: Preview display.

Expanded area: Board (9×9 grid).

For example:

Top area:

Row with:

Text: “Score: <value>”.

If state.isGameOver, show “Game Over” label.

A “New Game” button that calls controller.startNewGame().

Preview area:

LinesPreviewWidget(preview: state.preview).

Board area:

Expanded(child: LinesBoardWidget(...)).

4.2. LinesBoardWidget

In lines_board_widget.dart:

Props:

final LinesGameState state;

final void Function(int row, int col) onCellTap;

Responsibilities:

Render a 9×9 grid of tappable cells.

Each cell is typically a GestureDetector or InkWell that calls onCellTap(row, col).

Visual behavior:

Empty cell:

Draw a square with background color matching app theme.

Big ball:

Draw a circle with a color mapped from LinesColor to a Color.

Preview ball:

Draw a smaller circle in the center or with a different style (e.g. smaller radius).

Selected cell:

Add a highlight (e.g. border, glow, or overlay) if (row, col) matches state.selectedRow/selectedCol.

Use GridView.builder, Table, or nested Column/Row to produce the 9×9 structure; an AspectRatio wrapper helps keep it square.

4.3. LinesPreviewWidget

In lines_preview_widget.dart:

Props:

final List<LinesPreviewSlot> preview;

Render:

A Row with up to 3 circular indicators, each using the same color mapping as big balls.

Optionally show placeholders if fewer than 3 preview slots exist.

4.4. Color Mapping

Create a helper method (can be in lines_models.dart or a UI file):

Color colorForLinesColor(LinesColor c, BuildContext context) {
  switch (c) {
    case LinesColor.red:
      return Colors.red;
    // etc...
  }
}


Use consistent colors for both balls on the board and preview icons.

5. Integration with Existing App
5.1. Routing

In the main app (for example, main.dart or wherever routes are defined):

Add a route:

routes: {
  '/lines98': (context) => LinesGameScreen(),
  // other routes...
}


If using GoRouter or another routing solution, define a new route accordingly.

5.2. Navigation Entry

In the main game menu or wherever appropriate, add an option that navigates to this mini-game:

Example:

ElevatedButton(
  onPressed: () => Navigator.pushNamed(context, '/lines98'),
  child: const Text('Play Lines 98'),
)

5.3. Optional: Existing Systems

If the existing app has:

XP / coins / achievements:

You can later add hooks in LinesGameController to notify the app whenever:

A game finishes.

A score threshold is reached.

Sound / music:

You can add calls in _handlePostMove, _spawnNewBalls, and _findAndRemoveLines to play sound effects via existing sound system.

These integrations are not required for the core implementation and can be added in later iterations.

6. Implementation Milestones (Step-by-Step Tasks for Codex)

Codex should implement the feature in stages:

Module Setup

Create the lines98 feature folder and the listed Dart files.

Add route /lines98 and skeleton LinesGameScreen.

Data Models

Implement LinesColor, LinesPhase, LinesConfig.

Implement LinesCell, LinesPreviewSlot, and LinesBoard.

Game State

Implement LinesGameState with initial and copyWith.

Controller Skeleton

Implement LinesGameController with:

_state, _rng, state getter, _updateState().

Empty startNewGame() and onCellTap() method bodies.

New Game Logic

Implement:

Creation of empty LinesBoard.

Placement of initial balls.

Generation of first preview (with small balls on board).

State reset fields.

Wire startNewGame() to LinesGameScreen and call it in initState.

Board Widget

Implement LinesBoardWidget:

Display a 9×9 grid.

For each cell, show:

Big ball if ballColor != null.

Small ball icon if hasPreview == true.

Highlight if selected.

Call onCellTap(row, col) on tap.

Preview Widget

Implement LinesPreviewWidget to show next three colors.

Cell Tap Logic

Implement onCellTap selection logic:

Select ball on first tap.

Reselect if player taps another ball.

Attempt move when a selected ball and an empty cell (or allowed preview cell) are tapped.

Pathfinding

Implement _findPath using BFS.

Use _findPath in _applyMove logic to validate moves.

Move and Post-Move

Implement _applyMove.

Implement _handlePostMove:

Call _findAndRemoveLines.

Branch between immediate extra move vs spawn.

Line Detection & Scoring

Implement _findAndRemoveLines with 4 directions, line length ≥ 5.

Implement a simple scoring rule (e.g. +1 per removed ball).

Spawn & Game Over

Implement _generatePreview and _spawnNewBalls.

Implement _checkGameOver.

Game Over UI

Update LinesGameScreen to:

Show “Game Over” when appropriate.

Offer a “Play Again” button to call startNewGame().

Polish

Improve visuals:

Use theming, better colors, paddings.

Add subtle animations if desired (e.g., scale-in when balls appear).

Add basic code comments explaining each method.