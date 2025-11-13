# Palabra Lines Implementation Plan – Part 3 (UI & UX)

## Goal
Deliver the complete Palabra Lines interface—board, preview, score column, and quiz overlay—true to the interaction rules in `docs/palabra_lines_plan.md` §4 so the mini-game is playable end-to-end with Flutter widgets.

## Dependencies
- Part 1 (controller + state).
- Part 2 (quiz handling).
- Existing design system components (`GradientBackground`, spacing tokens, typography).

## Tasks
1. **Screen shell**
   - Add `PalabraLinesScreen` (ConsumerWidget) under `feature_palabra_lines/presentation/`.
   - Read controller via `StateNotifierProvider` (e.g., `palabraLinesControllerProvider`).
   - Layout major sections using `GradientBackground` → `Scaffold` → `SafeArea`.
2. **Score & competition column**
   - Implement `PalabraLinesScoreColumn` widget:
     - Shows `score`, `best`, and a vertical progress bar with the “little guy” (icon) moving relative to `score / max(best, baseline)` per spec §4.4.
     - Include “New Game” button wired to `controller.startNewGame`.
3. **Preview row**
   - Build `PalabraLinesPreviewWidget` (Row of up to 3 small circles) referencing `state.preview`.
   - Show placeholders when upcoming colors < 3 because the board is nearly full (per plan §4.3).
4. **Board widget**
   - Create `PalabraLinesBoardWidget`:
     - Renders 9×9 grid with `GestureDetector` for taps.
     - Highlights selected cell (maybe glow/border) and preview cells (small dot overlay).
     - Animations optional but keep `AnimatedContainer` for color changes.
     - Disable taps by returning early when `state.phase == PalabraLinesPhase.quiz` or `state.isGameOver`.
5. **Quiz overlay**
   - Implement `PalabraLinesQuizOverlay`:
     - Displayed when `state.activeQuestion != null`.
     - Use `Stack` in `PalabraLinesScreen` to overlay translucent scrim + centered card.
     - Card content: title (“Traduce esta palabra”), Spanish word, six buttons arranged in `GridView` or `Wrap`.
     - Show immediate visual feedback (e.g., color change) on wrong answers.
6. **Game-over state**
   - Show banner or dialog when `state.isGameOver` (phase == `gameOver`), with button to restart.
   - Optionally grey out board.
7. **Responsiveness & accessibility**
   - Support mouse + touch (use `InkWell` or `GestureDetector` with semantics labels).
   - Consider minimum tile size (>=64 px) for web usability.
8. **Widget tests**
   - Verify overlay prevents board taps while quiz is active.
   - Snapshot test ensuring preview + score column render expected text values.

## Deliverables
- Fully functional Palabra Lines UI wired to controller.
- Quiz overlay gating input correctly.
- Basic widget tests covering interaction flow.

## Notes & Risks
- Keep copy localized-ready (strings via constants for future i18n).
- Animations should be subtle to avoid slowing browsers; prefer standard Flutter transitions.
- Ensure color contrast meets accessibility; reuse design system palette.

