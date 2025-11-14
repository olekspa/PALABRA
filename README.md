# Palabra

 Palabra is a fast, arcade-inspired Spanish vocabulary trainer built with Flutter. Learners now choose from a growing slate of mini-games—starting with the signature Palabra Word Match sprint—and race against the clock with streak XP, powerups, and listening drills. The experience runs entirely in the browser, keeps progress locally, and ships with offline pronunciation so practice never stalls.

## Highlights
- **Progressive mastery:** A1 → B2 decks unlock sequentially. Match goals ramp from 15 to 50 within each milestone, and words are marked “learned” after five correct matches across sessions.
- **Profile aware:** A lightweight profile selector works offline per device, and our LXC deployment runs the remote profile API so learners can sign into the same profile from any browser and keep XP, streaks, powerups, and drill history in sync.
- **Rewarding loop:** Tier checkpoints deliver XP bonuses, clean runs award powerups, and the finish screen summarizes gains before launching the number-listening mini-game.
- **Offline audio:** Every vocabulary word and number has a Piper MP3 asset; Web Speech only acts as a fallback when an asset is missing or the user enables the dev TTS panel.
- **Web-first publishing:** A single command builds and deploys the app to an nginx-backed LXC container; everything else lives in the repo.
- **Game hub ready:** The Palabra Arcade hub surfaces current and upcoming mini-games so we can expand beyond Word Match without reworking the core navigation.

## Game Modes
- **Palabra Word Match:** Tap-to-match sprint focused on English ↔ Spanish vocabulary pairs, streak XP, powerups, and the bonus number drill.
- **Palabra Lines:** Color Lines / Lines 98 reborn for phones—guide glowing balls across a 9×9 grid, clear five-in-a-row combos, then ace a six-option Spanish translation quiz to keep the board alive.
- **Coming soon:** Additional listening, verb, and challenge modes are designed into the hub so they can roll out without UX churn.

## Core Flow
1. **Profile selector** – create or choose a learner profile. Progress is stored in shared_preferences per profile.
2. **Arcade hub** – pick a mini-game (Palabra Word Match today, more coming) and hand off to the appropriate gate/run flow.
3. **Gate** – confirm course/device eligibility (forced to Spanish today) and surface the current build number.
4. **Pre-run** – review objectives, active powerups, and deck composition before launching a 60-second round.
5. **Run** – tap-to-match on a five-row (or four with powerups) grid, earning XP for streaks and clean tiers.
6. **Number drill** – a 4×4 grid plays audio for numbers 1–100; match five prompts to earn bonus XP.
7. **Finish** – celebrate progress, review stats, then jump back to Pre-run or the Arcade hub.

## Tech Stack
- **Framework:** Flutter 3.35.7 (Dart 3.9)
- **State:** Riverpod (providers + StateNotifiers)
- **Routing:** go_router
- **Persistence:** shared_preferences via a custom in-memory store layer
- **Audio:** flutter_tts (Web Speech API bridge) + just_audio for Piper fallbacks
- **Testing:** flutter_test with widget, unit, and integration coverage

## Getting Started
1. **Install Flutter**  
   Clone Flutter stable 3.35.7 and export `PATH="$HOME/flutter/bin:$PATH"`. On WSL follow `docs/wsl_setup.md`.
2. **Fetch packages**  
   ```bash
   flutter pub get
   ```
3. **Run static checks & tests**  
   ```bash
   flutter analyze
   flutter test
   ```
4. **Launch on web**  
  ```bash
  flutter run -d chrome \
    --dart-define=PALABRA_FORCE_COURSE=spanish \
    --dart-define=PALABRA_PROFILE_API_BASE=http://192.168.1.175/api \
    --dart-define=PALABRA_PROFILE_API_KEY=<shared-secret>
  ```  
  For WSL, prefer `flutter run -d web-server` and open the provided URL in the Windows browser.
   - Omitting the `PALABRA_PROFILE_API_*` defines keeps progress local to the browser; including them (as we do on the LXC host) enables shared, server-side profiles.

## Local Development Tips
- Export `CHROME_EXECUTABLE` inside WSL to point at the Windows Chrome installation for direct launches.
- Use `flutter run -d chrome --web-renderer canvaskit` when profiling animation-heavy scenes.
- Piper-generated assets live in `assets/audio`; regenerate vocabulary or number clips with tools under `tool/`.
- The active profile and progress data are stored in shared_preferences when remote sync is disabled. Enable the profile API defines (default in our production LXC deploy) to persist everything through the backend instead.

## Testing & Quality
- `flutter test` exercises profile logic, deck building, run flow, finish screen stats, and the new number drill.
- `test/integration/web_flow_smoke_test.dart` walks the Gate → Pre-run → Run → Finish path with seeded data.
- Browser smoke test: `flutter test --platform chrome test/integration/web_flow_smoke_test.dart` (requires Chrome).
- Accessibility suite: `flutter test test/accessibility` uses semantics checks to ensure critical controls expose labels/roles.
- Add new widget tests for UI changes and keep run-time animations short to avoid pump timeouts.

## Release & Deployment
- Application version is surfaced on the Gate screen and must be bumped in `lib/app/app_constants.dart` for every change (current: **7.351**).
- Deploy to the Proxmox LXC container with:
  ```bash
  deploy_palabra_web
  ```
  The script fetches `origin/master`, builds `flutter build web --release`, rsyncs to `/var/www/palabra/`, and reloads nginx.
- Include Piper assets, vocabulary JSON, and other static files in commits; the deployment is static-site only.

## Remote Profile Sync (optional)
Expose (or reuse the existing) FastAPI profile service on the LXC (see `docs/project_status.md`) and provide the API coordinates when running or deploying:

```
--dart-define=PALABRA_PROFILE_API_BASE=http://192.168.1.175/api
--dart-define=PALABRA_PROFILE_API_KEY=$(cat /opt/PALABRA/api/secrets/profile_api_key)
```

When set (as in our live build), the profile selector lists remote profiles, pulls the chosen snapshot, and uploads progress after every run. Leave the defines unset to keep progress device-local for offline testing.

## Repository Layout
- `lib/app` – bootstrap, router, constants (version), and theme entry points.
- `lib/data_core` – in-memory store, models, repositories, and persistence helpers.
- `lib/design_system` – gradient backgrounds, token sets, and shared UI widgets.
- `lib/feature_games` – Palabra Arcade hub, catalog, and shared game-state scaffolding.
- `lib/feature_*` – modular feature packages (gate, prerun, run, finish, number drill, profiles, powerups).
- `assets/` – vocabulary JSON, pre-rendered audio, and static web assets.
- `docs/` – setup guides, project status, and deployment notes.
- `tool/` – Piper automation scripts for vocabulary and number audio generation.

## Working Agreements
- Branch naming: `feat/`, `fix/`, `chore/`, etc., using Conventional Commit prefixes.
- Keep the workspace lint-clean (`flutter analyze`) and add tests alongside new logic.
- Version bump rule: increment the micro component (e.g., 7.350 → 7.351) whenever the repository changes.
- Store Piper `.onnx` models under `tool/` (ignored from commits); generated audio output belongs in `assets/audio`.

## Next Up
- Add the next mini-game (listening drills) using the shared vocabulary assets and the new game registry scaffolding.
- Continue polishing the profile selector (long lists, deletion safeguards, deep links) now that it’s the entry point to the Arcade hub.
- Layer richer audio/visual FX across powerups and celebrations so every game benefits from the same feedback toolkit.
- Introduce optional cloud sync and telemetry once the LXC API service is online.
- Expand accessibility (keyboard navigation, screen reader support) and localize UI copy.
