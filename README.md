# Palabra v7.0

Palabra is a high-speed, offline-first Spanish vocabulary trainer built with Flutter 3.35.7 and Dart 3.9. The project is structured for modular feature development, targeting Android/iOS first with desktop/web shells for local testing.

## Repo layout
- `lib/app` — bootstrap, theming, navigation via `go_router` + Riverpod.
- `lib/design_system` — tokens and shared widgets (gradient backgrounds, typography, spacing).
- `lib/data_core` — Isar models, repositories, and database lifecycle providers.
- `lib/feature_*` — feature-specific presentation layers stubbed for Gate, Pre-run, Run, Pause, Finish, Powerups, SRS, and Vocabulary.
- `tool/content_cli` — CLI utilities for validating and ingesting local vocabulary JSON into Isar.
- `assets/vocabulary` — leveled EN↔ES term lists (to be normalized to the Palabra schema).
- `docs/` — project documentation, including daily progress logs (create `docs/daily.md` for stand-ups).

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
1. Ensure Flutter stable 3.35.7 is installed (`.tool-versions` provided for asdf).
2. Run `flutter pub get` and `dart pub get` inside `tool/content_cli`.
3. Verify the toolchain with `flutter analyze` and `flutter test`.
4. Review `vision.md` for the full product brief and execution plan.

## Scripts
```bash
flutter analyze        # Static analysis using very_good_analysis
flutter test           # Widget + unit tests
dart pub get           # Install CLI deps (run inside tool/content_cli)
dart run tool/content_cli/bin/content_cli.dart validate  # Validate vocabulary JSON
dart run tool/content_cli/bin/content_cli.dart ingest    # Import vocabulary into local Isar (build/isar)
```

## Versioning
- Current app version: **7.0.0+1**
- Use Conventional Commits (`feat:`, `fix:`, etc.) and follow trunk-based flow with feature branches (`feat/<ticket>`).

## Next steps
Refer to the open tasks in `vision.md` and the daily log in `docs/daily.md` for active priorities. When adding new modules, keep files under 1,000 LOC and favor additional sub-packages where necessary.
