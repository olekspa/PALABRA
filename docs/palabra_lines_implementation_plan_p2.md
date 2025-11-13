# Palabra Lines Implementation Plan – Part 2 (Vocabulary & Quiz Layer)

## Goal
Add the Spanish vocabulary twist outlined in `docs/palabra_lines_plan.md` §§3.7 & 4.5 so every cleared line pauses the board and challenges the player with a six-option translation quiz whose difficulty scales with combo size.

## Dependencies
- Part 1 controller hooks (`activeQuestion`, quiz phase gating).
- `VocabRepository` + already-loaded assets (`assets/vocabulary/spanish/a1-b2.json` ensured during bootstrap).
- Knowledge of the active user profile level (via `UserMeta` or run-level context) to weight question difficulty.

## Tasks
1. **Vocabulary service**
   - Create `PalabraLinesVocabService` under `feature_palabra_lines/application/` (or `data/` if preferred).
   - Fetch vocabulary lists grouped by CEFR level once (cache in-memory).
   - Provide API: `VocabEntry drawWord({required DifficultyTier tier})`, `List<String> distractorsFor(...)`.
2. **Difficulty mapping**
   - Define `DifficultyTier` enum or helper (e.g., `basic`, `intermediate`, `advanced`).
   - Map cleared-ball count to tier: e.g., 5→player’s current CEFR level, 6→next tier, ≥7→highest available (per twist request).
   - If vocab pool for a tier is exhausted, gracefully fall back to nearest tier.
3. **Quiz state models**
   - Implement `VocabEntry` (spanish, english, level, maybe audio id for future use).
   - Implement `PalabraLinesQuestionState` with `entry`, `options`, `correctIndex`, `wrongAttempts`.
   - Extend `PalabraLinesGameState` (from Part 1) to store `PalabraLinesQuestionState? activeQuestion`.
4. **Controller integration**
   - Inject `PalabraLinesVocabService` + optional callback for analytics.
   - In `_handleLinesCleared`, call `_maybeCreateVocabQuestion(clearedCount)` and switch `phase` to `quiz`.
   - Freeze board interactions by leaving selection null and ensuring `onCellTap` checks `phase != PalabraLinesPhase.quiz`.
5. **Quiz resolution**
   - Implement `onQuizOptionTap(int index)`:
     - Ignore taps when no active question.
     - If incorrect: increment `wrongAttempts`, optionally expose stream for UI to flash red (actual styling in Part 3).
     - If correct: clear `activeQuestion`, set `phase` back to `idle` (or `gameOver` if state says so), regenerate preview if necessary.
6. **Edge cases**
   - When no vocabulary data exists (unlikely), skip quiz but log warning.
   - Ensure quiz does not trigger for lines created solely by spawn logic (matches spec §3.5.6).
7. **Testing**
   - Unit tests to confirm difficulty tier selection, option shuffling, and gating behavior (board taps ignored during quiz).

## Deliverables
- Vocabulary service wired into the controller with deterministic difficulty progression.
- Quiz state transitions fully handled without UI yet.
- Unit tests covering tier mapping and quiz answer paths.

## Notes & Risks
- Must keep quiz generation fast; consider pre-shuffling lists or caching.
- Wrong answers currently loop until correct; consider instrumentation for penalties later but keep scope limited here.
- Coordinate with future audio assets (Spanish word pronunciation) though not in scope for this part.

