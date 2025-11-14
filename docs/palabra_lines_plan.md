Spec: “Color Lines / Lines 98” Spanish Vocabulary Mini-Game in Flutter
1. Context and goal

This feature implements a modern variant of the classic Color Lines / Lines 98 puzzle game as a new mini-game inside an existing Flutter app.

Baseline Color Lines / Lines 98 mechanics (for reference):

The board is a 9×9 grid.

Some cells contain colored balls.

On each player turn:

The player selects one existing ball.

The player then selects an empty target cell.

The ball can only move if there is a continuous path of empty cells linking source and destination (4-directional neighbors: up/down/left/right).

If the move creates any line of 5 or more balls of the same color (horizontal, vertical, or diagonal), all balls in such lines disappear and the player scores points.

If the move does not create a qualifying line, the game spawns 3 new balls (colors announced via a preview).

The game ends when no empty cells remain.

Original game also had a competition/high-score column: a little character climbs up a vertical bar as your score grows, visually representing progress against your own high score.

This implementation adds two twists:

Spanish vocabulary quiz on every successful clear:

When the player forms a line and those balls disappear, instead of simply proceeding, the game presents a Spanish word from a vocabulary asset.

The UI shows 6 possible translations (multiple-choice).

The player must pick the correct translation to proceed with the game turn.

The board is effectively “paused” while the quiz is active.

Competition column / character indicator:

The UI includes a vertical “column” with a little character that moves up as the score increases.

The character position reflects current score relative to personal best (high score).

The player is in constant competition with their own high score; the UI should show both current score and best score.

The mini-game must be implemented in Flutter + Dart, as a self-contained feature module, exposed via a dedicated screen/route (e.g. /lines98_vocab).

2. High-level outline (short version)

Architecture

Feature folder: lib/features/lines98_vocab/ (or lines98/ if preferred).

Clear separation:

Core Lines engine (board, balls, moves, lines, preview, scoring).

Spanish vocab quiz layer (question state, options, answer handling).

Competition UI (score + high score + climbing character).

Core data model

Enums:

LinesColor, LinesPhase.

Immutable models:

LinesCell, LinesBoard, LinesPreviewSlot, LinesGameState.

Vocabulary:

VocabEntry, VocabQuestionState.

Config:

Board size, initial balls, balls per spawn, line length, number of colors, number of quiz options (6).

Game logic (LinesGameController)

Maintains LinesGameState.

Handles:

New game initialization.

Cell taps (select vs move).

Pathfinding (BFS).

Move application.

Line detection & scoring.

Quiz triggering when lines are cleared.

Quiz answer handling (block further moves until correct).

Spawning balls from preview & generating new preview.

Game-over detection.

High-score tracking and exposing a normalized “progress percent” for the competition column.

UI

LinesGameScreen:

Injects controller.

Layout area for:

Score + high score + competition column (little guy on a vertical track).

Preview of upcoming balls.

9×9 board widget.

Quiz overlay (word + 6 options) when a question is active.

New Game / Back buttons.

LinesBoardWidget:

Renders grid with balls, previews, and selected cell.

LinesPreviewWidget:

Renders next 3 upcoming ball colors.

LinesScoreAndCompetitionWidget:

Renders numeric score, high score, and the “climbing character” in a column.

LinesQuizOverlayWidget:

Renders current Spanish word, 6 answer buttons, and simple feedback.

Integration

New route added to app router.

Navigation entry added from main menu.

High score persisted via SharedPreferences or app-standard persistence.

3. Detailed plan for Codex

The following sections are meant to be followed step by step by Codex implementing this feature.

3.1. Feature folder and files

Create a new feature folder:

lib/features/lines98_vocab/

Inside this folder create these Dart files:

lines_models.dart

Enums, base data models, config constants, and color mapping utility.

lines_vocab_models.dart

Vocabulary data types and quiz state models.

lines_game_state.dart

Immutable LinesGameState that includes board state, preview, score, quiz state, etc.

lines_game_controller.dart

LinesGameController class implementing all game logic and state transitions.

lines_board_widget.dart

Widget that draws the 9×9 grid and forwards taps.

lines_preview_widget.dart

Widget to display upcoming balls.

lines_score_competition_widget.dart

Widget for score, high score, and the little climbing character on a column.

lines_quiz_overlay_widget.dart

Widget for the Spanish word + 6 translation choices.

lines_game_screen.dart

Top-level screen widget that wires controller and subwidgets together.

If the app has its own feature structure (e.g. lib/features/games/), adapt the root folder path accordingly, but keep the file split.

3.2. Core models and enums (Color Lines engine)
3.2.1. Color and phase enums

In lines_models.dart define:

enum LinesColor {
  red,
  green,
  blue,
  yellow,
  purple,
  cyan,
  orange,
}


and

enum LinesPhase {
  idle,          // waiting for user to select/move a ball
  ballSelected,  // ball chosen, waiting for destination
  animatingMove, // optional use for move animation
  spawning,      // spawning new balls and resolving lines
  quiz,          // vocabulary quiz is active, board is locked
  gameOver,      // board is full, game ended
}


LinesPhase.quiz is used whenever a vocabulary question is active; while in this phase, taps on the board should be ignored and only quiz options are clickable.

3.2.2. Config constants

Still in lines_models.dart, define:

class LinesConfig {
  static const int boardSize = 9;
  static const int initialBalls = 5;
  static const int spawnPerTurn = 3;
  static const int lineLength = 5;
  static const int quizOptionsCount = 6; // always 6 answer choices

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

3.2.3. Cell model

Each grid cell:

class LinesCell {
  final int row;
  final int col;
  final LinesColor? ballColor;    // null if no big ball
  final bool hasPreview;
  final LinesColor? previewColor; // color of preview ball, if any

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

3.2.4. Preview slot

We use the “preview on grid” variant: the three upcoming balls appear as small balls on specific cells.

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

3.2.5. Board wrapper

Wrapper around the 9×9 cells:

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

3.2.6. Color-to-UI mapping helper

Add a helper for mapping LinesColor to Color (used by UI):

Color colorForLinesColor(LinesColor c) {
  switch (c) {
    case LinesColor.red:
      return Colors.red;
    // map others appropriately
  }
}


This may require importing package:flutter/material.dart here or in a UI-specific helper file.

3.3. Vocabulary and quiz models

In lines_vocab_models.dart, define the vocabulary entries and quiz state.

3.3.1. VocabEntry

Assume Spanish-to-English by default. Vocabulary will come from an asset JSON or existing app data.

class VocabEntry {
  final String spanish;   // e.g. "perro"
  final String english;   // correct translation, e.g. "dog"

  const VocabEntry({
    required this.spanish,
    required this.english,
  });
}


If the existing app stores additional metadata (part of speech, frequency, etc.), the model can be extended, but spanish + english is enough for the quiz.

3.3.2. VocabQuestionState

VocabQuestionState encapsulates the current quiz question.

class VocabQuestionState {
  final VocabEntry entry;
  final List<String> options;     // length == LinesConfig.quizOptionsCount
  final int correctIndex;         // index in options list

  const VocabQuestionState({
    required this.entry,
    required this.options,
    required this.correctIndex,
  });
}


Options list always contains exactly one correct translation (entry.english) and 5 distractors. The controller will build this from the vocabulary pool.

3.4. LinesGameState (adds quiz & competition)

In lines_game_state.dart, define:

class LinesGameState {
  final LinesBoard board;
  final List<LinesPreviewSlot> preview;
  final int score;
  final int highScore;        // persisted across sessions
  final LinesPhase phase;
  final bool isGameOver;

  final int? selectedRow;
  final int? selectedCol;

  // Quiz:
  final VocabQuestionState? activeQuestion; // null when no quiz

  const LinesGameState({
    required this.board,
    required this.preview,
    required this.score,
    required this.highScore,
    required this.phase,
    required this.isGameOver,
    required this.selectedRow,
    required this.selectedCol,
    required this.activeQuestion,
  });

  factory LinesGameState.initial(LinesBoard board, {int highScore = 0}) {
    return LinesGameState(
      board: board,
      preview: const [],
      score: 0,
      highScore: highScore,
      phase: LinesPhase.idle,
      isGameOver: false,
      selectedRow: null,
      selectedCol: null,
      activeQuestion: null,
    );
  }

  LinesGameState copyWith({
    LinesBoard? board,
    List<LinesPreviewSlot>? preview,
    int? score,
    int? highScore,
    LinesPhase? phase,
    bool? isGameOver,
    int? selectedRow,
    int? selectedCol,
    VocabQuestionState? activeQuestion,
  }) {
    return LinesGameState(
      board: board ?? this.board,
      preview: preview ?? this.preview,
      score: score ?? this.score,
      highScore: highScore ?? this.highScore,
      phase: phase ?? this.phase,
      isGameOver: isGameOver ?? this.isGameOver,
      selectedRow: selectedRow,
      selectedCol: selectedCol,
      activeQuestion: activeQuestion,
    );
  }
}


Note: selectedRow and selectedCol should allow explicit null resets. Implement copyWith carefully (e.g. with sentinel values or separate methods) so that you can clear selection when needed; simplest is to provide separate clearSelection() helper if necessary.

highScore will be updated when score surpasses previous best and persisted via app mechanisms (e.g. SharedPreferences).

3.5. Game controller (logic + quiz + competition)

In lines_game_controller.dart implement LinesGameController.

3.5.1. Fields and constructor

Fields:

_state: LinesGameState

_rng: Random

_vocab: List<VocabEntry> (loaded from assets or injected)

_prefs or equivalent for persistence (optional, or use a service injected from outside)

Example structure:

class LinesGameController extends ChangeNotifier {
  LinesGameState _state;
  final Random _rng;
  final List<VocabEntry> _vocab;

  LinesGameController(this._vocab, {required int initialHighScore})
      : _rng = Random(),
        _state = LinesGameState.initial(
          _createEmptyBoard(),
          highScore: initialHighScore,
        );

  LinesGameState get state => _state;

  void _updateState(LinesGameState newState) {
    _state = newState;
    notifyListeners();
  }
}


Implement _createEmptyBoard() as a static helper that builds a 9×9 LinesBoard with empty cells.

High score loading and saving can be handled by the caller (screen or higher-level service) and passed into the controller as initialHighScore plus a callback when highScore changes.

3.5.2. Public methods

Minimum:

void startNewGame();

void onCellTap(int row, int col);

void onQuizOptionTap(int index); – called when user taps one of the 6 translations.

Optional: void resetHighScore() if the app wants a UI for that.

3.5.3. startNewGame

Algorithm:

Build fresh empty LinesBoard.

Place LinesConfig.initialBalls big balls:

Repeatedly:

Compute list of empty cells (ballColor == null).

Pick one at random.

Pick a random LinesColor.

Update that cell.

Generate first preview:

_generatePreview(board) returns:

Updated board with 3 preview balls.

Preview list of LinesPreviewSlot.

Create new LinesGameState:

score = 0

phase = LinesPhase.idle

isGameOver = false

selectedRow/selectedCol = null

activeQuestion = null

highScore stays from previous _state.highScore

_updateState(newState)

3.5.4. onCellTap (board input)

Guard conditions:

If state.isGameOver or state.phase == LinesPhase.gameOver, ignore.

If state.phase == LinesPhase.quiz, ignore board taps (quiz must be answered first).

If state.phase is anything other than idle or ballSelected (e.g. spawning, animatingMove), ignore or queue.

Main behavior:

Get cell = state.board.cellAt(row, col).

Case A: no selection (state.selectedRow == null):

If cell.ballColor != null:

Set selection:

selectedRow = row, selectedCol = col.

phase = LinesPhase.ballSelected.

Update state and notify.

Case B: there is a selection:

If tapped cell has a ball:

Change selection to that ball (update selectedRow/selectedCol).

Else tapped cell is a potential destination:

Validate path with _findPath(from, to):

Accept only if path exists.

If no path: do nothing or show invalid feedback.

If path exists: _applyMove(from, to).

3.5.5. Pathfinding: _findPath

Use BFS:

Nodes are (row, col) indices.

Start = selected cell, goal = tapped cell.

Neighbors: up, down, left, right.

Can move through cells where:

ballColor == null and hasPreview == false.

Optional: allow moving through preview cells if you want; simplest is to treat preview as blocked, but allow ending on a preview cell (which will be overwritten).

If BFS reaches goal, reconstruct path; else return null.

For this implementation we only need to know if a path exists; full path is optional (needed only if you later animate move step by step).

3.5.6. Applying the move: _applyMove

Steps:

Read source and destination cells from board.

movingColor = fromCell.ballColor!.

Build new board:

Source cell: ballColor = null.

Destination cell:

If hasPreview == true:

Clear preview: hasPreview = false, previewColor = null.

Set ballColor = movingColor.

Clear selection: selectedRow = null, selectedCol = null.

Set phase = LinesPhase.idle (or animatingMove if later animating).

Update state with new board and phase.

Call _handlePostMove(toRow, toCol).

3.5.7. Post-move handling: _handlePostMove

After a valid move:

Call _findAndRemoveLines([Point(toRow, toCol)]):

Returns:

updatedBoard

removedCount

scoreDelta (base points for clearing).

If removedCount > 0:

Update board to updatedBoard.

Compute tentative new score: newScore = state.score + scoreDelta.

Determine if high score should update:

If newScore > state.highScore, set newHighScore = newScore and optionally trigger persistence callback.

Generate a vocabulary question via _maybeCreateVocabQuestion() using _vocab:

If no vocab available, you can skip quiz and proceed directly (or treat missing vocab as error).

Set state:

board = updatedBoard

score = newScore

highScore updated if needed

phase = LinesPhase.quiz

activeQuestion = generated question

_updateState(...)

Do not spawn new balls yet; quiz must be resolved first.

If removedCount == 0:

Call _spawnNewBalls().

Note: Exactly one quiz is triggered per move that cleared lines, even if multiple lines are cleared at once. The quiz is associated with that move’s total score gain.

3.6. Line detection: _findAndRemoveLines

Implement a function that finds all same-color lines of length ≥ 5 and removes them.

Outline:

Set<Point<int>> cellsToRemove = {};

For each cell (r, c):

If ballColor == null, skip.

For each of the four directional pairs:

Horizontal, vertical, main diagonal, anti-diagonal.

For each axis:

Walk forward while inside board and same color.

Walk backward while inside board and same color.

Total length = 1 + forwardCount + backwardCount.

If totalLength >= LinesConfig.lineLength, add all those positions to cellsToRemove.

After scanning:

removedCount = cellsToRemove.length.

If removedCount == 0:

Return (board, 0, 0).

Else:

Create a new board where cells in cellsToRemove are set ballColor = null (preview flags normally not present there).

Compute scoreDelta.

Simple: scoreDelta = removedCount.

Or non-linear if desired (but document the rule).

Return (updatedBoard, removedCount, scoreDelta).

Use this after both moves and spawns.

3.7. Vocabulary quiz: _maybeCreateVocabQuestion and onQuizOptionTap
3.7.1. _maybeCreateVocabQuestion

This function selects a random Spanish word and builds multiple choice options (6 translations).

Algorithm:

If _vocab.isEmpty, return null (no quiz).

Pick a random index: correctEntry = _vocab[randomIndex].

Build a list of distractors:

Copy _vocab except the correct entry.

Randomly sample 5 unique english values (or fewer if vocab is small, but strive for 6 total options).

Combine correctEntry.english + distractors into a List<String> options.

Shuffle options.

Determine correctIndex = options.indexOf(correctEntry.english).

Create and return:

VocabQuestionState(
  entry: correctEntry,
  options: options,
  correctIndex: correctIndex,
);


When _handlePostMove sees a non-zero removedCount, it calls this and uses it as activeQuestion.

3.7.2. onQuizOptionTap

This method is called when the user taps one of the 6 option buttons.

Algorithm:

If state.phase != LinesPhase.quiz or state.activeQuestion == null, ignore.

Let question = state.activeQuestion.

Compare tapped index with question.correctIndex.

Case A: correct answer:

Proceed with the game:

Clear activeQuestion (set to null).

Set phase back to:

LinesPhase.idle if game is not over.

Now check if board is full after previous clears and any upcoming spawn:

Actually, spawn has not happened yet; we cleared and then quizzed.

After quiz success, continue normal flow:

If the move had cleared lines, and since we do not spawn new balls when lines were cleared, there is nothing more to do this turn:

Player gets another move immediately.

_updateState(...).

Case B: incorrect answer:

The simplest behavior (for now) is:

Give visual feedback (e.g. mark option red briefly) but do not progress.

Keep phase = LinesPhase.quiz and leave activeQuestion unchanged.

The player must tap until they choose the correct translation to “proceed further,” as requested.

You can also optionally track wrong attempts for future scoring or penalty, but base implementation requires only gating progression on a correct answer.

Future extension (optional): add a per-question penalty, such as subtracting points or spawning an extra ball on the next turn.

3.8. Spawn and preview: _generatePreview and _spawnNewBalls
3.8.1. _generatePreview

Given a board:

Determine empty, non-preview cells:

Cells with ballColor == null and hasPreview == false.

If no empties, return unchanged board + empty preview list.

Determine count = min(LinesConfig.spawnPerTurn, emptyCells.length).

Randomly choose count cells.

For each:

Pick random LinesColor.

Mark the cell: hasPreview = true, previewColor = color.

Add a LinesPreviewSlot(color, row, col) to the preview list.

Return new board and preview list.

3.8.2. _spawnNewBalls

Called when a move did not clear any lines.

Algorithm:

For each LinesPreviewSlot in state.preview:

Get (row, col, color).

If board.cellAt(row, col).ballColor == null:

Convert preview to big ball:

ballColor = color

hasPreview = false

previewColor = null

Track (row, col) in spawnedPositions.

If ballColor != null (player moved onto preview cell):

Skip; that slot is effectively canceled.

After converting all previews:

Clear preview list.

Run _findAndRemoveLines(spawnedPositions):

This may clear additional lines and yield scoreDelta.

If removedCount > 0:

Update score and highScore as usual.

Optionally trigger a quiz here as well:

Base implementation can either:

Trigger a quiz also for lines formed by spawns, or

Only quiz on lines formed by the player’s move.

To keep logic simple and avoid too many quizzes, you can choose to quiz only on player-move clears.

For this spec, choose:

No quiz for spawn-formed lines; just update score.

Check game-over:

If after spawn and clears there are no empty cells (ballColor == null and hasPreview == false), set:

isGameOver = true

phase = LinesPhase.gameOver

Update highScore if needed.

_updateState(...) and return.

If not game over:

Call _generatePreview(updatedBoard) to create new preview small balls:

Update board and preview.

Set phase = LinesPhase.idle.

_updateState(...).

3.9. Game-over detection: _checkGameOver

Utility:

Iterate over all cells.

If any cell has ballColor == null and hasPreview == false, game is not over.

Otherwise, game is over:

isGameOver = true

phase = LinesPhase.gameOver

highScore may be updated if score > highScore.

Call this after spawns and clearing.

3.10. Competition / high score tracking

The original Color Lines had a visual “little guy on a column” that moved up as score increased, comparing to a persistent high score.

Implementation:

LinesGameState already carries:

score

highScore

Add a helper in controller or a small utility:

double get progressTowardHighScore {
  final hs = max(state.highScore, 1); // avoid division by zero
  final clamped = state.score.clamp(0, hs);
  return clamped / hs; // 0.0 to 1.0
}


The UI uses this progress to position the character vertically in the competition widget.

High score persistence:

When score exceeds highScore:

Update highScore in state.

Call a callback or directly use SharedPreferences to persist:

e.g. prefs.setInt('lines98_vocab_high_score', highScore);

On controller creation, load initial highScore from storage and pass it in.

4. Flutter UI details
4.1. LinesGameScreen

In lines_game_screen.dart, implement LinesGameScreen:

StatefulWidget that:

Creates LinesGameController.

Provides it using a state-management pattern already used in the app (e.g. ChangeNotifierProvider, InheritedWidget, etc.).

In initState:

Load high score from persistence (or via dependency injection).

Load vocabulary asset into _vocab list (if not injected).

Instantiate controller with _vocab and initialHighScore.

Call controller.startNewGame().

build method layout:

Scaffold with:

AppBar:

Title: “Lines 98” or “Color Lines”.

Back button to return to main game.

body:

Use AnimatedBuilder, Consumer, or equivalent to listen to controller.state.

Main layout:

Column with:

Score + high score + competition column:

Use LinesScoreCompetitionWidget(state: state, onNewGame: controller.startNewGame).

Preview row:

LinesPreviewWidget(preview: state.preview).

Expanded board:

Expanded(child: LinesBoardWidget(state: state, onCellTap: controller.onCellTap));

If state.phase == LinesPhase.quiz and state.activeQuestion != null:

Overlay LinesQuizOverlayWidget(question: state.activeQuestion!, onOptionTap: controller.onQuizOptionTap);

You can use a Stack in the body to overlay the quiz over the board.

4.2. LinesBoardWidget

In lines_board_widget.dart:

Props:

LinesGameState state

void Function(int row, int col) onCellTap

Behavior:

Use AspectRatio 1:1, then a GridView.builder, Table, or nested Column/Row to build 9×9 cells.

Each cell:

Wrap GestureDetector or InkWell.

On tap: call onCellTap(row, col).

Visuals:

Base square with a border.

If cell.ballColor != null:

Draw a filled circle using colorForLinesColor.

If cell.hasPreview == true and cell.ballColor == null:

Draw a smaller circle to represent a preview ball.

If (row, col) equals state.selectedRow/selectedCol:

Add highlight (e.g. different border color or glow).

Disable taps when state.phase == LinesPhase.quiz by having LinesGameScreen call onCellTap only when phase allows, or by checking phase inside onCellTap.

4.3. LinesPreviewWidget

In lines_preview_widget.dart:

Props:

List<LinesPreviewSlot> preview.

Render:

A Row with up to 3 small colored circles, one per LinesPreviewSlot.

Optionally show placeholders when there are fewer than 3 due to limited empty cells.

4.4. LinesScoreCompetitionWidget

In lines_score_competition_widget.dart:

Props:

LinesGameState state

VoidCallback onNewGame

Layout:

Column or Row that shows:

Text: Score: <state.score>.

Text: Best: <state.highScore>.

A vertical “column” showing a little character:

E.g. SizedBox(width: 40, height: 150, child: Stack(children: [column background, Positioned(bottom: progress * maxHeight, child: Icon(Icons.person))])

progress derived from controller: state.score / max(state.highScore, some baseline).

If state.highScore == 0, treat progress as 0 or use an arbitrary scaling (e.g. 200 points baseline).

A small ElevatedButton or IconButton for “New Game” calling onNewGame.

As score increases, the character moves up the column, giving the same feel as the original Color Lines competition bar: you are always “climbing” towards or past your own best score.

4.5. LinesQuizOverlayWidget

In lines_quiz_overlay_widget.dart:

Props:

VocabQuestionState question

void Function(int index) onOptionTap

Behavior:

Consumes the full screen or overlays on top of the board via Stack.

Show:

A semi-transparent background to dim the board.

Centered card with:

Title: “Translate this word”.

The Spanish word from question.entry.spanish in large text.

A GridView or Column of 6 buttons (for options):

Each button shows one English option.

On tap, call onOptionTap(optionIndex).

You can add visual feedback (e.g. flash red on incorrect) purely in this widget or via additional state in controller.

5. Integration with existing app
5.1. Route

Add a route in the main router:

Example (classic MaterialApp routes):

routes: {
  '/lines98_vocab': (context) => LinesGameScreen(),
  // other routes...
}


If using GoRouter or similar, define an equivalent route.

5.2. Navigation entry

In the app’s main menu or game selection screen, add an entry:

Button example:

ElevatedButton(
  onPressed: () => Navigator.pushNamed(context, '/lines98_vocab'),
  child: const Text('Play Color Lines (Spanish)'),
)

5.3. Vocab asset loading and persistence

Add a JSON file under assets/ (if not already present), for example:

assets/vocab/spanish_words.json

with entries like:

[
  { "spanish": "perro", "english": "dog" },
  { "spanish": "gato", "english": "cat" }
]


Load this asset at app startup or in LinesGameScreen and convert it into a List<VocabEntry>.

For high score persistence:

Use SharedPreferences or standard app storage to:

Load lines98_vocab_high_score on screen init.

6. Availability & launch instructions

- Palabra Lines now ships alongside Word Match in the Arcade hub—tap the “Palabra Lines” card or deep-link to `/palabra-lines` to jump straight into the grid without passing through the Word Match gate/run flow.
- High scores persist per profile via `UserMeta.palabraLinesHighScore`, and quizzes pull from the bundled A1–B2 vocabulary assets loaded through `VocabRepository`.
