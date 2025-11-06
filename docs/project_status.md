# Palabra Project Status — v7.345

_Last updated: 2025-11-06_

## Snapshot
- **Build target:** Web-first Spanish vocabulary trainer with timed matching, streak XP, powerups, and a number-listening drill.
- **Current release:** 7.345 (forced Spanish course, multi-profile selector, offline audio library, optional remote profile sync).
- **Deployment:** Static web bundle served from the Proxmox LXC (nginx). `deploy_palabra_web` handles fetch, build, rsync, and reload.
- **Persistence:** In-memory store persisted to shared_preferences; Piper-generated audio assets bundled in `assets/audio`.

## Recent Highlights
- Added a multi-profile selector with create/rename/delete flows and HUD polish.
- Tuned XP/streak logic, powerup rewards, and the bonus number drill with pre-generated audio.
- Reworked deck difficulty scaling (15 → 50 matches per CEFR milestone) and CEFR gating logic.
- Bundled Piper `es_MX-claude-high` audio for vocabulary and numbers 1–100 as default fallbacks.
- Implemented web speech + asset tiered TTS with caching, unlock gestures, and Safari-friendly flow.
- Deployed a lightweight FastAPI profile service plus web client sync so profiles follow the learner across devices when configured.

## Active Focus
1. **Profile polish:** Improve list handling, add deletion safeguards, and surface deep links back into Gate/Run.
2. **Powerups & FX:** Finish Row Blaster activation, expand toolbar feedback, and add celebration visuals.
3. **Telemetry prep:** Define payloads, stand up optional sync endpoints, and keep offline support intact.

## Near-Term Priorities (Next 2 Sprints)
1. Harden profile UX (long lists, keyboard support, analytics events).
2. Ship row blaster + new powerups with art, tuning, and tests.
3. Add accessibility passes (focus order, semantic labels, high-contrast tweaks).
4. Automate smoke tests in CI and document QA sign-off.
5. Draft cloud sync design (API contract, migration story, opt-in toggle).

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
- **No cloud backup:** losing browser storage wipes progress. _Mitigation:_ fast-track optional sync once API is ready.
- **Manual version bumps:** human error can desync Gate version display. _Mitigation:_ consider a pre-commit hook or task runner.

## Quality & Testing
- `flutter test` covers profile logic, deck building, run flow, finish stats, and number drills.
- Integration smoke test (`test/integration/web_flow_smoke_test.dart`) validates Gate → Pre-run → Run → Finish.
- Manual regression checklist: profile creation, powerup earn/use, number drill timing, TTS fallback, deployment smoke test.
- Pending: widget coverage for profile actions, automated browser smoke test, accessibility audit.

## Operational Notes
- Store Piper `.onnx` models under `tool/`; only generated audio lives in the repo.
- Use `StorePersistence.clear()` or browser storage tools to reset local data during QA.
- Deploy script assumes `origin/master`; merge feature branches before releasing.
- Environment flags:
  - `PALABRA_FORCE_COURSE=spanish` (default) keeps gate course detection deterministic.
  - `PALABRA_TTS_DEV_PANEL=true` exposes runtime sliders for speech tuning.

## Looking Ahead
- Prototype optional backend sync on the LXC cluster (telemetry + profile backup).
- Expand drills (verbs, phrases, conjugation challenges) once core loop stabilizes.
- Introduce seasonal events, streak keeps, and mission-based progression to extend retention.
