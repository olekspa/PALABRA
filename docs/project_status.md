# Palabra Project Status — v7.351

_Last updated: 2025-11-06_

## Snapshot
- **Build target:** Palabra Arcade — a web-first Spanish vocabulary trainer with a multi-game hub (Word Match today, listening drills and other puzzles next) plus streak XP, powerups, and the number-listening bonus.
- **Current release:** 7.351 (forced Spanish course, multi-profile selector, offline audio library, remote profile API sync enabled on the LXC host).
- **Deployment:** Static web bundle served from the Proxmox LXC (nginx). `deploy_palabra_web` handles fetch, build, rsync, and reload.
- **Persistence:** In-memory store persisted to shared_preferences for offline dev; production builds hit the FastAPI profile sync (`/api`) on the LXC so every profile/state change is written server-side; Piper-generated audio assets bundled in `assets/audio`.

## Recent Highlights
- Introduced the Palabra Arcade hub so additional mini-games can ship alongside Word Match without disrupting the existing loop.
- Added a multi-profile selector with create/rename/delete flows and HUD polish.
- Tuned XP/streak logic, powerup rewards, and the bonus number drill with pre-generated audio.
- Reworked deck difficulty scaling (15 → 50 matches per CEFR milestone) and CEFR gating logic.
- Bundled Piper `es_MX-claude-high` audio for vocabulary and numbers 1–100 as default fallbacks.
- Implemented web speech + asset tiered TTS with caching, unlock gestures, and Safari-friendly flow.
- Deployed and enabled in production the FastAPI profile service plus web client sync so profiles follow the learner across devices.
- Changed the run-time TTS flow to prefer bundled MP3 assets for every vocabulary item before falling back to Web Speech so pronunciation quality stays consistent across runs.

## Active Focus
1. **Mini-game expansion:** Ship the listening-drill module scaffold (shared vocab assets, progress tracking, routing) so additional puzzles can follow Word Match.
2. **Profile + Arcade polish:** Improve long-list UX, add deletion safeguards, expose keyboard flows, and make the hub feel at home on tablets/desktops.
3. **Powerups & FX:** Finish Row Blaster activation, expand toolbar feedback, and add celebration visuals that apply across every mini-game.
4. **QA automation:** Lock in browser smoke tests and widget coverage so the growing surface area stays regression-free (telemetry design is parked until the new games land).

## Near-Term Priorities (Next 2 Sprints)
1. Implement listening-drill data models, controllers, and a placeholder UI that reuses the existing vocabulary assets.
2. Harden profile UX (long lists, keyboard support, analytics events) now that it is the gateway into the Arcade hub.
3. Ship Row Blaster + new powerups with art, tuning, and shared celebration FX.
4. Add accessibility passes (focus order, semantic labels, high-contrast tweaks) across hub, Word Match, and the drill surfaces.
5. Automate smoke tests in CI and document QA sign-off before onboarding more mini-games.

## Backlog Themes
- Celebration visuals and audio stingers for tier checkpoints and finish screens.
- LMS/device gating (replace forced Spanish flag with real detection).
- Localization and copy externalization (en/es at launch).
- Persistence migrations, schema versioning, and in-app data reset tools.
- Powerup economy (store view, pricing, inventory history).
- Daily/weekly challenges, missions, and curated vocabulary packs.

## Risks & Watchlist
- **Profile scaling:** current UI assumes a short list; large households may hit cramped layouts. _Mitigation:_ design large-list patterns during polish.
- **Audio size:** bundled Piper MP3s increase build weight. _Mitigation:_ monitor build artifacts and consider progressive loading.
- **Remote profile availability:** if the FastAPI service goes down, browsers fall back to local storage and risk divergence. _Mitigation:_ add health checks and graceful reconnection logic.
- **Manual version bumps:** human error can desync Gate version display. _Mitigation:_ consider a pre-commit hook or task runner.

## Quality & Testing
- `flutter test` covers profile logic, deck building, run flow, finish stats, and number drills.
- Integration smoke test (`test/integration/web_flow_smoke_test.dart`) validates Gate → Pre-run → Run → Finish.
- Manual regression checklist: profile creation, powerup earn/use, number drill timing, TTS fallback, deployment smoke test.
- Pending: widget coverage for profile actions, automated browser smoke test, accessibility audit.

## Operational Notes
- Store Piper `.onnx` models under `tool/`; only generated audio lives in the repo.
- Use `StorePersistence.clear()` or browser storage tools to reset local data during QA; remote profiles can be reset via the FastAPI admin endpoint.
- Deploy script assumes `origin/master`; merge feature branches before releasing.
- Environment flags:
  - `PALABRA_FORCE_COURSE=spanish` (default) keeps gate course detection deterministic.
  - `PALABRA_TTS_DEV_PANEL=true` exposes runtime sliders for speech tuning.

## Looking Ahead
- Extend the backend sync on the LXC cluster (telemetry + profile backup) once the new mini-games settle.
- Expand drills (listening, verbs, phrases, conjugation challenges) using the shared game registry.
- Introduce seasonal events, streak keeps, and mission-based progression to extend retention.
