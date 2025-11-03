# Palabra v7.0

Palabra is a high-speed, offline-first Spanish vocabulary trainer built with Flutter 3.35.7 and Dart 3.9. The project is structured for modular feature development, targeting Android/iOS first with desktop/web shells for local testing.

## Repo layout
- `lib/app` — bootstrap, theming, navigation via `go_router` + Riverpod.
- `lib/design_system` — tokens and shared widgets (gradient backgrounds, typography, spacing).
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

## Versioning
- Current app version: **7.0.0+1**
- Use Conventional Commits (`feat:`, `fix:`, etc.) and follow trunk-based flow with feature branches (`feat/<ticket>`).

## Next steps
- Stay aligned with the feature brief in `vision.md` and the working backlog in `docs/project_status.md`.
- Finalise the web in-memory data layer and prepare beta instructions.
- Expand widget/state tests (especially around the run controller and deck builder) once the new screens settle.
- When adding modules, keep files under 1,000 LOC and favor additional sub-packages where necessary.
