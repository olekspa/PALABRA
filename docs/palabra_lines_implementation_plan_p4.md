# Palabra Lines Implementation Plan – Part 4 (Navigation, Persistence, Validation)

## Goal
Hook Palabra Lines into the broader Palabra app—routing, arcade catalog, and saved progress—while adding regression tests so the feature is production-ready per `docs/palabra_lines_plan.md` §5.

## Dependencies
- Parts 1–3 complete and passing tests.
- Access to routing (GoRouter) and user metadata repositories.

## Tasks
1. **Routing**
   - Extend `AppRoute` enum in `lib/app/router/app_router.dart` with `palabraLines('/palabra-lines')`.
   - Add a `GoRoute` entry pointing to `PalabraLinesScreen`.
   - Ensure deep link works (e.g., `context.go(AppRoute.palabraLines.path)`).
2. **Arcade hub integration**
   - Update `GameId` enum + `kGameCatalog` (`lib/feature_games/data/game_catalog.dart`) with a new descriptor:
     - Title “Palabra Lines”.
     - Tagline summarizing the color-line mechanic and vocab quiz.
   - Modify `GameHubScreen` to launch Palabra Lines directly (no Gate) when `descriptor.id == GameId.palabraLines`.
3. **High-score persistence**
   - Add `palabraLinesHighScore` (int, default 0) to `UserMeta` + serialization in `fromJson/toJson` (`lib/data_core/models/user_meta.dart`).
   - Teach `PalabraLinesController` to read/update this via `UserMetaRepository` so the “little guy” column reflects saved progress.
4. **State persistence (optional enhancements)**
   - Consider saving last board snapshot for resume (stretch goal; document if deferred).
5. **Testing**
   - Integration test: pump `PalabraLinesScreen`, simulate a move that creates a quiz, verify overlay shows 6 options and tapping wrong answer keeps overlay.
   - Smoke test for routing: using `GoRouter`, ensure navigating to `AppRoute.palabraLines` renders screen without asserts.
   - Persistence test: mock `UserMetaRepository` to confirm high score updates when surpassing previous best.
6. **Docs & readiness**
   - Update `README.md` “Game Modes” to mention Palabra Lines.
   - Add short entry to `docs/` changelog or feature overview summarizing mechanics and how to run it.

## Deliverables
- Navigable Palabra Lines mode listed in the Arcade hub.
- High score stored per profile and reflected in UI.
- Passing widget/integration tests plus updated documentation.

## Notes & Risks
- Be mindful of existing Gate/run flows; Palabra Lines should not interfere with Word Match providers.
- Persisting high score modifies user metadata schema; ensure backward compatibility by defaulting missing values to zero.
- Keep route path stable for future deep links (`/palabra-lines` rather than `/lines98_vocab` as per naming request).

