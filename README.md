# Palabra v7.0

Palabra is a high-speed, offline-first Spanish vocabulary trainer built with Flutter 3.35.7 and Dart 3.9. The project is structured for modular feature development, targeting Android/iOS first with desktop/web shells for local testing.

## Repo layout
- `lib/app` — bootstrap, theming, navigation via `go_router` + Riverpod.
- `lib/design_system` — tokens and shared widgets (animated backgrounds, typography, spacing).
- `lib/data_core` — in-memory models, repositories, and store helpers for vocabulary + progress state.
- `lib/feature_*` — feature-specific presentation layers (Gate, Pre-run, Run, Finish now interactive; Pause, Powerups, SRS, Vocabulary in progress).
- `assets/vocabulary` — leveled EN↔ES term lists (to be normalized to the Palabra schema).
- `docs/` — project documentation (`daily.md` for stand-ups, `project_status.md` for active focus and backlog).

## Vocabulary asset schema
Each file under `assets/vocabulary/spanish/{a1,a2,b1,b2}.json` contains an array of entries shaped like:

```json
{
  "id": "a1_0001",
  "en": "tree",
  "es": "árbol",
  "level": "a1",
  "family": "arbol",
  "topic": "core_vocab"
}
```

- `id`: stable unique identifier (`<level>_<zero-padded index>`).
- `en` / `es`: display strings used on tiles.
- `level`: CEFR bucket (`a1`..`b2`), inferred from the filename.
- `family`: slug grouping confusable pairs (currently derived from the Spanish form).
- `topic`: coarse semantic bucket per level (`core_vocab`, `daily_life`, `intermediate_concepts`, `advanced_concepts`).

## Local setup
1. Ensure Flutter stable 3.35.7 is on your `PATH`. In WSL this means cloning `https://github.com/flutter/flutter.git` to `~/flutter` (already present in this workspace) and adding `export PATH="$HOME/flutter/bin:$PATH"` to your shell profile (e.g. `~/.bashrc`), then restarting the terminal.
2. Run `flutter pub get`.
3. Verify the toolchain with `flutter analyze` and `flutter test`.
4. Review `vision.md` for the full product brief and execution plan.

### WSL-specific notes
- Install Chrome/Edge on the Windows side and expose it to WSL (`export CHROME_EXECUTABLE="/mnt/c/Program Files/Google/Chrome/Application/chrome.exe"` when running web builds, adjust the path if you installed a different browser). During day-to-day testing prefer `flutter run -d web-server` and open the served URL in Windows via `wslview http://localhost:<port>` (or copy/paste into Chrome/Edge); this avoids remote-debugging quirks between WSL and Windows.
- Install Android Studio on Windows and point Flutter at that SDK from WSL via `flutter config --android-sdk /mnt/c/Users/<you>/AppData/Local/Android/Sdk` once it is available.
- If you plan to target Linux desktop builds inside WSL, install the native build toolchain (`sudo apt install clang cmake ninja-build pkg-config libgtk-3-dev`).
- The end-to-end walkthrough lives in `docs/wsl_setup.md`.

## Scripts
```bash
flutter analyze        # Static analysis using very_good_analysis
flutter test           # Widget + unit tests
```

## Prototype persistence & telemetry
- User metadata, run logs, and item states persist locally via `shared_preferences` (in-memory fallback on unsupported platforms).
- Clearing app storage resets progress; migrations, multi-profile support, and remote sync are still in planning.
- RunController now records streaks, averages, inventory deltas, and run durations. The Finish screen surfaces these stats for QA.
- A manual reset helper lives in `StorePersistence.clear()` while the settings/debug UI is pending.
- Future milestone: host a central persistence + telemetry service on the Proxmox LXC cluster (static web + API). Docs will be updated once that pipeline ships.

## Versioning
- Current app version: **7.0.0+1**
- Use Conventional Commits (`feat:`, `fix:`, etc.) and follow trunk-based flow with feature branches (`feat/<ticket>`).

## Current highlights
- Animated gradient background with sparkle layer for richer presentation.
- Run loop delivers audio/haptic feedback (where supported), pulse/shake mismatch cues, and celebration overlays.
- Tier pauses and run completion trigger confetti bursts to reinforce milestones.
- Finish screen conveys per-run inventory changes alongside lifetime streak/accuracy stats.
- CI runs static analysis, unit/widget/integration tests (`.github/workflows/ci.yml`).

## Near-term roadmap
1. Confetti/tier celebration FX and power-up visuals.
2. Tile interaction polish (glows, hover states, mismatch pulses).
3. Real LMS/device gating integration.
4. Persistence migration tooling + debug/reset UI.
5. Powerups store UX, content validation, and LXC-hosted persistence pilot.
