# Palabra v7.0 — Project Status

## Active Focus
- Ship a web-only beta that runs reliably in Chrome/Edge with high-fidelity visuals and feedback.
- Keep runtime state in memory/`shared_preferences` while planning migrations, profile support, and LXC-hosted persistence.
- Ensure the Gate → Pre-run → Run → Number Drill → Finish flow exposes new telemetry (streaks, number mastery, averages) on first load.
- Harden the sequential CEFR progression (A1 → B2) so users must master a tier before advancing, and surface XP/powerup inventory accurately during runs.
- Prepare documentation and infra notes for the upcoming Proxmox-hosted persistence/API service (currently offline).

## Beta Demo Task List
- [x] Replace Isar models/repositories with in-memory services seeded from JSON assets.
- [x] Remove Isar packages/tooling from `pubspec.yaml` and codebase.
- [ ] Verify Gate → Run → Finish on Chrome after refactor.
- [x] Document web beta instructions (build, serve, data reset behaviour). See `docs/web_beta_instructions.md`.

## Web Beta Hosting Notes
- After refactor, build with `flutter build web` (or `flutter run -d chrome`) to produce the SPA under `build/web`.
- Inside WSL prefer `flutter run -d web-server` and open the printed URL via `wslview` (or copy/paste into Windows Chrome/Edge) to avoid remote-debugging issues.
- Serve the `build/web` directory with any static server (`python -m http.server`, nginx, etc.). Progress persists via `shared_preferences`; clearing browser storage resets the profile.
- For LAN testing, expose the server’s IP:port; mobile devices join the same network and browse to `http://<pc-ip>:<port>/`.
- Flutter SDK now lives under `~/flutter` inside WSL; ensure terminals export `PATH="$HOME/flutter/bin:$PATH"` before running `flutter`.
- Planned upgrade: host the SPA + future persistence API on a Proxmox LXC node. Until then, keep expectations scoped to client-side storage.

- Animated gradient + sparkle background applied app-wide.
- RunController emits audio/haptics (platform aware), match celebrations, and mismatch penalties.
- Offline speech fallback now ships with Piper-generated MP3s for all vocabulary items and numbers 1–100 (`assets/audio/spanish*`), keeping pronunciation available when Web Speech APIs fail.
- Core run loop retuned to a progressive match goal (15 → 50) with tier pauses at 12/30 and dynamic copy updates across gate/pre-run/run surfaces.
- Sequential level gating keeps learners on their active CEFR deck until every pair is mastered, with progress persisted per level and surfaced on the pre-run screen.
- XP is now earned on every correct match, streak bonuses are tracked, and clean runs grant powerups plus celebratory finish copy.
- A bonus number drill launches after each successful run, awarding extra XP based on time and mistakes while updating number mastery per profile.
- Tier pauses and run completion now trigger confetti overlays and celebratory states.
- Finish screen now surfaces inventory deltas, streaks, averages, and total run telemetry.
- Gate → Pre-run → Run flow with device/course gating, row blaster toggle, and interactive board UI.
- Pause overlays for tier breaks and finish summary screen pulling from the latest run log.
- Repository scaffolding, Isar removal, deck-building logic, and vocabulary seeding pipeline with tests.
- Web smoke test covers Gate → Pre-run → Run → Finish with provider overrides for deterministic decks.
- Gate screen honours feature-flagged device/course detection with environment overrides.
- Lightweight SharedPreferences persistence keeps user meta, run logs, and attempts across refreshes.

## Backlog & Risks
- Power-up visuals (Row Blaster/Time Extend art) and store polish still pending.
- Real LMS course detection still stubbed on the gate screen.
- Content validation beyond vocabulary (powerups/config) not in place.
- Persistence migrations, multi-profile support, and remote sync unimplemented.
- Profile selection/management UI not yet surfaced; only a single default profile is active.
- No localization or accessibility audit yet.

## Recommended Next Development Tasks
- Ship confetti/tier celebration overlays and power-up art treatments.
- Wire the new smoke test into CI (or a pre-commit script) so regressions are caught automatically.
- Implement the real LMS course/device detector behind the new provider (replace env defaults).
- Expose a settings/debug option to clear persisted data and handle schema version bumps.
- Pilot LXC-hosted persistence API with opt-in builds and migration tooling.
- Externalize copy & begin localization scaffolding (en/es) while adding accessibility pass.

## Release Candidate Task List (easiest → hardest)
1. Align documentation with current app behaviour (web guide, README, status notes).
2. Expand automated coverage and CI integration for deck builder, gate, and run flows.
3. Externalize UI copy and add localization scaffolding for English/Spanish.
4. Surface longitudinal user stats and inventory changes on the Finish screen.
5. Add audio, haptic, and celebratory feedback that matches the tier spec.
6. Replace stubbed LMS/device gating with real detectors behind feature flags.
7. Persist XP, streaks, and powerup inventory adjustments during and after runs.
8. Harden persistence with schema versioning, migrations, and user-reset tooling.
9. Deliver the powerups feature set (store, pricing, consumption feedback).
10. Tighten deck builder heuristics to enforce SRS caps (trouble limits, family spacing).

## Beta 2 Upgrade Task List

### 1. Production LMS/Device Gating
- [ ] Platform integration: wire LMS course/device detection from native/JS bridges into `gateDetectedCourseProvider`.
- [ ] Configuration surface: add build-time env + QA overrides for gating (CLI flags, .env).
- [ ] UI polish: error states, help CTA, copy localization, analytics hooks.
- [ ] Automated coverage: widget tests for new states, integration test for gating flow.
- [ ] Monitoring: log gating failures to telemetry payload.

### 2. Celebration & Powerup Visuals
- [ ] Confetti layer: reusable painter/overlay triggered on tier and run completion.
- [ ] Powerup FX: Row Blaster + Time Extend VFX, iconography, toggle states.
- [ ] Audio layering: hero stingers per tier/powerup, volume mix per platform.
- [ ] Performance budget: profile frame times on Web/iOS; degrade gracefully on low-power.
- [ ] Tests: golden/frame tests for overlays; ensure run controller triggers FX.

### 3. Persistence Tooling & Migrations
- [ ] Versioned store: embed schema version, upgrade path, metadata stamping.
- [ ] Reset/backup UI: settings/debug panel to export, clear, or downgrade save data.
- [ ] Migration scripts: CLI tool to bump versions and run sanity checks.
- [ ] Error handling: fallback strategy for corrupt stores, user messaging.
- [ ] Test matrix: unit tests for migrations, integration tests for reset flows.

### 4. Telemetry & LXC Service Prep
- [ ] Payload schema: define run summary + device metadata envelopes.
- [ ] Sync client: background uploader with retry/cache (stubbed until backend ready).
- [ ] Privacy/filtering: redact PII, respect offline toggle.
- [ ] Ops docs: deployment checklist for LXC API, monitoring plan, API contract.
- [ ] CI validation: ensure telemetry schema stays backward compatible.

### 5. Localization & Accessibility
- [ ] Intl scaffolding: extract strings to ARB, en/es translations, locale switch.
- [ ] Typography updates: ensure glyph support, dynamic text sizing.
- [ ] Accessibility audit: semantics, contrast ratios, focus order, keyboard navigation.
- [ ] QA checklist: screen reader pass (TalkBack/VoiceOver), high contrast mode.
- [ ] Tests: localization snapshot tests, accessibility smoke tests.

### 6. Supporting Enhancements
- [ ] Tile interaction polish: hover/press glows, mismatch pulses tied to feedback service.
- [ ] Documentation: update README, guides, and vision with Beta 2 scope & timelines.
- [ ] Release gating: automate beta build pipeline (CI artifact, change log, smoke tests).
- [ ] Risk tracking: maintain issue list for Beta 2 blockers with owners/ETAs.
