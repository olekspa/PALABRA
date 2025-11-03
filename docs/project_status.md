# Palabra v7.0 — Project Status

## Active Focus
- Ship a web-only beta that runs reliably in Chrome/Edge.
- Remove Isar dependencies; keep all state in memory or browser storage (no persistence guarantees yet).
- Ensure the Gate → Pre-run → Run → Finish loop works on first load with in-memory data.

## Beta Demo Task List
- [x] Replace Isar models/repositories with in-memory services seeded from JSON assets.
- [x] Remove Isar packages/tooling from `pubspec.yaml` and codebase.
- [ ] Verify Gate → Run → Finish on Chrome after refactor.
- [x] Document web beta instructions (build, serve, data reset behaviour). See `docs/web_beta_instructions.md`.

## Web Beta Hosting Notes
- After refactor, build with `flutter build web` (or `flutter run -d chrome`) to produce the SPA under `build/web`.
- Serve the `build/web` directory with any static server (`python -m http.server`, nginx, etc.). Each browser session keeps progress in-memory; refresh resets progress.
- For LAN testing, expose the server’s IP:port; mobile devices join the same network and browse to `http://<pc-ip>:<port>/`.
- Local Flutter SDK on WSL is incomplete (missing Dart binary). Run commands via Windows PowerShell/CMD with the full Flutter install.

## Recently Completed
- Gate → Pre-run → Run flow with device/course gating, row blaster toggle, and interactive board UI.
- Pause overlays for tier breaks and finish summary screen pulling from the latest run log.
- Repository scaffolding, Isar models, deck-building logic, and vocabulary seeding pipeline with tests.
- Run engine now guarantees unique pairs per session and adds red shake feedback on mismatches for clearer UX.
- Web smoke test covers Gate → Pre-run → Run → Finish with provider overrides for deterministic decks.
- Gate screen now honours feature-flagged device/course detection with environment overrides.
- Lightweight SharedPreferences persistence keeps user meta, run logs, and attempts across refreshes.
- Correct matches trigger celebratory visuals + audio to balance the new mismatch feedback.

## Backlog & Risks
- Audio/animation polish and tactile feedback remain undefined.
- Real LMS course detection still stubbed on the gate screen.
- Content validation tooling covers vocabulary only; need similar guardrails for powerups/config.

## Recommended Next Development Tasks
- Wire the new smoke test into CI (or a pre-commit script) so regressions are caught automatically.
- Implement the real LMS course/device detector behind the new provider (replace env defaults).
- Expose a settings/debug option to clear persisted data and handle schema version bumps.
- Extend persistence/telemetry to surface per-run stats in the Finish screen (streaks, averages).
