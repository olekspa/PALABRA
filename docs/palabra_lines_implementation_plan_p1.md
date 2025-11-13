# Palabra Lines Implementation Plan – Part 1 (Core Domain & Controller Scaffolding)

## Goal
Stand up the foundational game logic for Palabra Lines so every later module (vocab quiz, UI, routing) can plug into a stable controller. This stage mirrors the “Core data model” and “Game controller” requirements in `docs/palabra_lines_plan.md` §§2–3 while keeping naming consistent with the new feature.

## Dependencies
- Existing Riverpod setup (`flutter_riverpod` already in use).
- No UI assets required yet (pure logic).
- Reuses shared spacing/color tokens later, but not needed for this step.

## Tasks
1. **Feature scaffolding**
   - Create `lib/feature_palabra_lines/` with `domain/`, `application/`, `presentation/` subfolders.
   - Export a barrel (e.g., `feature_palabra_lines/feature_palabra_lines.dart`) when ready.
2. **Configuration & enums**
   - Define `PalabraLinesConfig` constants (boardSize=9, spawnPerTurn=3, lineLength=5, previewCount=3, initialBalls, color palette).
   - Create `PalabraLinesColor` enum mapping to Material colors for later rendering.
   - Add `PalabraLinesPhase` enum (`idle`, `selecting`, `moving`, `quiz`, `gameOver`).
3. **Board & cell models**
   - Implement immutable `PalabraLinesCell` (fields: `ballColor`, `hasPreview`, `previewColor`).
   - Build `PalabraLinesBoard` to encapsulate grid dimensions, index validation, cloning helpers, `cellAt`, `setCell`, `emptyCells`, `hasEmptyCells`.
   - Add serialization helpers if future persistence/debugging needed.
4. **State model**
   - Create `PalabraLinesPreviewSlot` (color + coordinates).
   - Implement `PalabraLinesGameState` with:
     - `board`, `preview`, `score`, `highScore`, `phase`, `isGameOver`, `selectedRow`, `selectedCol`, `activeQuestion` placeholder (nullable).
     - `initial` factory that seeds an empty board and zeroed counters.
     - `copyWith`/`clearSelection` utilities to manage nullable selection fields (per plan §3.4).
5. **Controller skeleton**
   - Implement `PalabraLinesController extends StateNotifier<PalabraLinesGameState>` in `application/`.
   - Inject `VocabQuestionState? Function(int clearedCount)` placeholder (will be replaced in Part 2).
   - Public API: `startNewGame`, `onCellTap`, `onQuizOptionTap`, getters for preview/high-score progress.
   - Internal helpers: `_createEmptyBoard`, `_seedInitialBalls`, `_generatePreview`, `_findPath` (BFS per §3.5.4), `_applyMove`, `_findAndRemoveLines`, `_spawnNewBalls`, `_checkGameOver`, `_updateScore`.
6. **Pathfinding & line detection**
   - BFS must restrict movement to four-direction adjacency and respect occupied cells except source/destination logic.
   - `_findAndRemoveLines` should detect ≥5 same-color sequences horizontally, vertically, and both diagonals, returning both updated board and list of cleared cells.
7. **State transitions**
   - Ensure controller updates `phase` appropriately (idle → selecting → moving, etc.).
   - When no lines cleared, spawn new balls using preview list, then regenerate preview for next turn.
   - Leave quiz handling stubbed but ensure hooks exist when `_handlePostMove` detects `removedCount > 0`.

## Deliverables
- New feature directory with domain + controller files compiled and lint-clean.
- Passing unit tests for `_findPath` and `_findAndRemoveLines` (smoke coverage acceptable now, more later).
- `startNewGame` produces a playable board in debug logs (UI hookup arrives in Part 3).

## Notes & Risks
- Keep everything immutable; copy-on-write board updates simplify state diffs.
- Document color/preview assumptions inline to guide future UI work.
- Getting this right first avoids major rewrites when introducing the vocab overlay and UI.

