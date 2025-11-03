# Palabra v7.0 — Project Status

## Active Focus
- Ship a web-only beta that runs reliably in Chrome/Edge.
- Remove Isar dependencies; keep all state in memory or browser storage (no persistence guarantees yet).
- Ensure the Gate → Pre-run → Run → Finish loop works on first load with in-memory data.

## Beta Demo Task List
- [x] Replace Isar models/repositories with in-memory services seeded from JSON assets.
- [x] Remove Isar packages/tooling from `pubspec.yaml` and codebase.
- [ ] Verify Gate → Run → Finish on Chrome after refactor.
- [ ] Document web beta instructions (build, serve, data reset behaviour).

## Web Beta Hosting Notes
- After refactor, build with `flutter build web` (or `flutter run -d chrome`) to produce the SPA under `build/web`.
- Serve the `build/web` directory with any static server (`python -m http.server`, nginx, etc.). Each browser session keeps progress in-memory; refresh resets progress.
- For LAN testing, expose the server’s IP:port; mobile devices join the same network and browse to `http://<pc-ip>:<port>/`.
- Local Flutter SDK on WSL is incomplete (missing Dart binary). Run commands via Windows PowerShell/CMD with the full Flutter install.

## Recently Completed
- Gate → Pre-run → Run flow with device/course gating, row blaster toggle, and interactive board UI.
- Pause overlays for tier breaks and finish summary screen pulling from the latest run log.
- Repository scaffolding, Isar models, deck-building logic, and vocabulary seeding pipeline with tests.

## Backlog & Risks
- Audio/animation polish and tactile feedback remain undefined.
- Real LMS course detection still stubbed on the gate screen.
- Content validation tooling covers vocabulary only; need similar guardrails for powerups/config.
