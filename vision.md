
## Vision

Palabra is a browser-friendly, mobile-ready Spanish vocabulary trainer designed to feel like a rhythm game. The experience is built around rapid English–Spanish matching, gentle pressure from a ticking clock, and visible progress that rewards streaks, accuracy, and consistency. Learners advance through the CEFR ladder (A1 → B2) only after demonstrating mastery, so every run matters and the content stays appropriately challenging.

### What Success Looks Like
- **Fast on every device.** Sessions start instantly, remain responsive in the browser, and survive flaky networks thanks to local storage and offline audio.
- **Mastery over memorization.** The system continually promotes learned words, surfaces trouble items, and adjusts match targets so proficiency grows level by level.
- **Confidence through feedback.** XP, streak indicators, celebrations, and post-run stats make improvement obvious and motivate another attempt.
- **Inclusive audio.** Web Speech API provides native voices when possible; high-quality Piper clips for every vocabulary item ensure pronunciation never disappears.

### Experience Pillars
1. **Match:** Five-row dual-column boards highlight clear pairings, predictable gestures, and immediate confirmation or correction.
2. **Master:** Difficulty ramps from 15 matches to 50 across each CEFR milestone, only unlocking the next tier once the current deck is mastered. Powerups reward clean runs and streaks.
3. **Celebrate:** Tier checkpoints pause the clock, deliver XP bonuses, and set goals for the next push. Finish screens summarize gains, and bonus number drills reinforce listening skills.

### Current Feature Set
- Sequential CEFR progression with profile-aware tracking of learned, trouble, and fresh vocabulary.
- XP, streak, and powerup systems with clean-run rewards and manual activations (time extend available today).
- Bonus number drill mini-game using pre-generated Spanish audio for numbers 1–100 and speed-based scoring.
- Full offline audio library with Piper-generated clips; automatic Web Speech fallback and voice caching on supported browsers.
- Profile selector for local multi-learner households; each profile keeps its own progression, XP, inventories, and drill history.
- Web-first deployment workflow targeting an LXC-hosted nginx origin, with a simple CLI deploy script.

### Design Principles
- **Offline-first:** Assets, progress, and audio live locally; network calls are optional enhancements.
- **Deterministic decks:** Every refill maintains solvable boards, enforces family spacing, and respects trouble item limits.
- **Short-session friendly:** 60-second timers, 4×4 number grids, and celebratory checkpoints make Palabra ideal for quick practice.
- **Transparency:** HUD elements show match goals, XP gains, streaks, and available powerups so learners understand how to improve.

### Roadmap Themes
- **Profile polish:** Long lists, deep links, and parental controls for shared devices.
- **Powerup variety:** Additional boosts (row blaster, hint windows) tied to higher XP thresholds.
- **Telemetry & cloud sync:** Optional backend to sync progress across devices while keeping offline support intact.
- **Accessibility & localization:** Broader language support for UI copy, screen-reader affordances, and adjustable tile density.
- **Community & curriculum:** Layered missions, daily challenges, and curated vocabulary packs beyond the base CEFR decks.

Palabra delivers quick, satisfying study loops today while laying the groundwork for a richer language-learning arcade built on mastery, momentum, and delightful feedback.*** End Patch

Owns routes. Gate → Pre-run → Run → Finish.

Owns lifecycle hooks. On background, pause timer and input. On foreground, resume.

Design system and rendering
Color seed derived from course and userId. This yields consistent gradients.

Typography scale respects OS text size. No text below 11 sp.

Components:

Tile: rounded rect. Seeded gradient. Text centered. Two lines max.

Top bar: timer, progress ticks, powerup indicators.

Pause overlay: dim layer. Text. Button.

Confetti: light particle emitter. Adaptive density by device class.

Gate
Reads device type using platform API.

Reads course from local profile. Spanish only for this mode.

Returns a boolean guard to the router with a short reason if blocked.

Data core
VocabItem holds content. Immutable after import.

UserItemState holds training state. Updated on run events.

UserMeta holds economy and level. Updated on finish and missions.

AttemptLog records every resolution. Used for tuning and audit.

RunLog records per-run summary. Used for economy and QA.

Content pipeline
Validates IDs and levels.

Normalizes diacritics in Spanish.

Blocks duplicate families that collide across levels unless intentional.

Writes import counts per level into a lightweight report for the dev menu.

SRS engine
Learned:

Needs three clean matches across three runs. Only one credit per run.

Learned items skip the next three runs. Retest once. If correct, skip five more.

Trouble:

Two misses in one run. Or one miss in two runs back-to-back.

Reinserts inside the current run 4 to 6 items later. Then sits at the top of the next run.

Hard cap of three appearances per run.

All updates are deterministic. No time input. Only counters and run index.

Deck builder
Inputs: UserMeta.approxLevel. UserItemState for each id. The VocabItem set.

Produces an ordered queue. Front segment is trouble. Middle is level mix. Tail is fresh.

Enforces family spacing in a rolling window of five. Exception allowed when a family has explicit targeted practice. Not in MVP.

Guarantees size ≥100 to ensure safe refills.

Board engine
Maintains left[] and right[] arrays for row slots.

On correct:

Remove both elements. Pull next pair. Insert EN into the left hole. Insert ES into the right hole. Animate in.

On wrong:

Shake both. Clear selection. Do not modify the deck position.

Solvability check:

The set of pairIds in left equals the set in right at every tick.

If a mismatch occurs, perform a right-side swap or delay refill until a complete pair is ready.

Run controller and timer
Counts down. Emits Tick. Emits TierReached at 12 and 30.

Freezes timer and input during tier pauses. The board state object is untouched.

On timeout:

If Time Extend exists and progress <50, emit ExtendOffer.

On accept, add 60 seconds and resume. On decline, finish with secured XP.

Interaction and motion
Tap down scale is 0.98 for 80 ms. Tap up restores 1.0 with a subtle spring.

Selected shows a 2 to 3 px border and a background lift.

Correct plays green flash then scale+fade then refill.

Wrong plays red flash then shake then reset.

Haptics:

Success notification on correct.

Error notification on wrong.

Confetti:

Small burst at tiers. Larger burst at 50.

Powerups and economy
Inventory lives in UserMeta.

Row Blaster:

Toggle at Pre-run only. If active, rows=4 for this run. Last row collapses with a height tween in 150 ms.

Earn +1 on flawless runs. Also +1 per three runs completed in a day.

Time Extend:

Available only at timeout and if progress <50.

Adds one minute per token. Max two uses per run.

Earn +1 for any run completed in under 1:30. Also +1 from the daily mission.

Progress and rewards
XP:

+5 when you reach 12. Stored immediately.

+10 when you reach 30. Cumulative +15. Stored immediately.

+25 when you reach 50. Total +40. Stored on finish.

Streak:

Increments on any finished run. Resets on a missed day.

Finish summary:

Shows result, XP, learned items, and a replay button.

Telemetry and export
AttemptLog records every resolution. Includes runId, time remaining, row, column, item ids, and result.

RunLog records rows used, extend uses, deck mix counts, learned promotions, trouble detections.

Dev menu exports the last N runs and attempts to JSON for QA.

QA and dev tools
Dev menu shows content counts, version, inventory, level override, seed override, and export buttons.

Auto-play test mode runs a deterministic script to reach 50 for performance tests.

Confetti intensity slider helps test low-end devices.

Accessibility and localization
Screen readers announce “English: the house” or “Spanish: la casa.”

Tap targets are at least 44 dp high.

Color contrast meets AA. Gradients adjust if needed.

Text scales up to 1.4 without layout break.

Packaging and platform
Release and debug flavors. Icons and splash generated from vectors.

CI blocks weekly size growth beyond 10 percent.

State checkpoints prevent progress loss on crashes.

Rules and invariants summary

Two columns at all times. Left English. Right Spanish.

No reshuffle during a run. Only two slots change after a correct.

Timer pauses exactly at 12 and 30. The board remains unchanged during the pause.

Wrong answers never cost time, hearts, or XP.

Board solvability holds at all times. No orphan tiles.

Fresh items ≤20% of a run. Families spaced across five-pair windows.

Learned promotion needs three clean runs. Trouble repeats within the run and at the start of the next run.

Acceptance checklist for MVP

60 FPS under rapid taps on a mid-range device.

Refill latency ≤100 ms after the correct animation ends.

Pauses fire on the exact match count and freeze the board.

Extend adds exactly 60 seconds and resumes without visual glitches.

SRS updates persist across app restarts.

Powerups earn and spend correctly. Inventory never goes negative.

All content is local. App runs with airplane mode on.

Developer notes for reproducibility

Use a run seed composed of contentVersion, userId, runIndex.

Log the seed in RunLog for replay.

Use the seed to order the deck strata and initial row mapping.

Never use wall-clock time in SRS logic.

This document defines the gameplay loop, the user journey, the module contracts, and the invariants. It is sufficient to implement, test, and ship the MVP without ambiguity.
Gameplay loop — exhaustive, implementation-ready
0) Run state you must track

runClock: milliseconds remaining (starts 60000).

progress: correct matches so far (0→50).

tierFlags: pausedAtTierOne, pausedAtTierTwo.

rows: 5 or 4 if Row Blaster active.

deck: ordered queue of ~100–110 pairs; deckPtr index.

boardLeft[rows]: English ids in each row.

boardRight[rows]: Spanish ids in each row.

selected: either null or {col: L|R, row: 0..rows-1, pairId}.

inputLock: idle | resolvingCorrect | resolvingWrong | paused | finished.

inventory: {rowBlaster:int, timeExtend:int, gems:int} for gating UI only.

counters: per-item streaks/errors cached for this run (also persisted).

seed: deterministic seed for any randomness used this run.

Run start sequence
Gate passed and Pre-run Start pressed.

Deck build completes using user level, learned/trouble, family spacing, fresh≤20% rules.

Board init:

Draw rows pairs from deck.

Place EN into boardLeft unique rows using seeded order.

Place ES into boardRight unique rows independently.

Repair pass until every EN on board has its matching ES on board. Never insert one side without the other.

Clock = 60 s. progress=0. inputLock=idle.

UI visible: top bar (timer, tier ticks at 12/30/50, powerup icons), grid (5×2 or 4×2), empty bottom.

Core interaction cycle (one attempt)
This cycle repeats until pause, finish, or timeout.

A) Selection phase

Preconditions: inputLock == idle.

Player taps a tile.

If no selection yet:

If tap is left column: set selected={L,row,pairId}.

If tap is right column: set selected={R,row,pairId}.

Play press micro-interaction (scale 0.98 → 1.0), switch to selected style.

If a selection exists:

If second tap is same column: ignore; keep first selected.

If second tap is other column: capture {secondCol, secondRow, secondPairId} and proceed to resolve.

B) Resolve phase

Freeze further taps by setting inputLock = resolvingCorrect|resolvingWrong for ≤250 ms.

Compare pairId == secondPairId:

Correct path:

Both tiles flash green (~80 ms).

Both tiles scale to 0.9 and fade to 0 (~120 ms). Total animation budget ≤200 ms.

Increment progress++.

Persist AttemptLog entry (correct) with time remaining, rows, ids.

Update per-item counters in memory for SRS (no DB write yet).

Refill:

Pop next pair from deck.

Insert EN into the same left slot and ES into the same right slot just vacated.

If deck cannot supply a full pair, do not insert either side. Trigger deck backfill chain immediately (same level → lower → learned). Resume once a full pair is available.

New tiles fade in (~100 ms). No other rows move.

Set selected=null, inputLock=idle.

Milestone check:

If progress == 12 && !pausedAtTierOne: → Tier pause 1.

Else if progress == 30 && !pausedAtTierTwo: → Tier pause 2.

Else if progress == 50: → Finish success.

Wrong path:

Both tiles flash red (~80 ms).

Both tiles shake horizontally 2–3 oscillations (200–250 ms).

Persist AttemptLog entry (wrong), update run-local error counters.

Clear selection, selected=null, inputLock=idle.

Trouble scheduling: mark the item for reinsert 4–6 pairs later within this run and for front-loading next run (cap to 3 appearances/run).

Tier pause mechanics (at 12 and 30)
Trigger condition: resolve a correct match that makes progress equal exactly 12 or 30.

Immediate actions:

Stop the timer precisely. Record pauseTs.

Set inputLock=paused.

Dim board; disable all grid hit-testing; keep board arrays unchanged.

Show overlay: “Tier X complete” and secured XP (+5 at 12; cumulative +15 at 30).

Resume:

On “Continue”, hide overlay, undim board.

Do not refill or reshuffle anything.

Resume timer from stored remaining time.

Set inputLock=idle.

Edge constraints:

If the last correct was also the 50th, finish overrides pause.

If multi-touch tries to tap during pause, all taps are ignored.

Timeout and Time Extend
Trigger: runClock reaches 0 while progress < 50.

Flow:

Set inputLock=paused and freeze board.

If timeExtend > 0: show offer “Add 60 s?”.

Accept:

Decrement inventory.

runClock += 60000.

Smoothly animate timer bar fill.

Set inputLock=idle. Resume where paused. No changes to board or deck.

Decline or no inventory:

Compute secured XP (based on highest reached tier).

Proceed to Finish timeout.

Finish conditions
Success (progress == 50 before time ends):

Stop timer. Set inputLock=finished.

Award +40 XP total for the run (5 at 12 +10 at 30 +25 at 50).

Promote learned items that hit the rule (3 clean runs, no item errors).

Commit RunLog summary and per-item state to DB.

Show summary: XP earned, “Learned today” list, “Practice again”.

Timeout:

Award highest secured tier XP only.

Commit RunLog and update trouble items.

Show summary with progress N/50, XP awarded, option to replay.

Crash safety:

If the app dies mid-run, on next launch you must:

Award up to the last secured tier.

Discard partial run SRS updates.

Mark run as abandoned in logs.

Board solvability guarantees
Invariant: sets of pairIds on left and right are equal at all times.

Enforcement points:

Initial fill uses repair pass until equality holds.

Refill inserts both sides only. If you can’t, insert neither and immediately backfill deck.

Monitoring: after every change, recompute small set equality (size ≤5). If mismatch:

First try a right-column row swap to restore equality.

If not possible, delay insertion until a full pair is available.

Never reshuffle the grid globally.

Input gating and concurrency
While inputLock != idle, ignore grid taps.

Multi-touch: accept first valid cross-column pair; queue nothing else.

Same-column second tap: ignore, keep current selection.

During animations:

Correct/wrong animations run with lock held to prevent double resolves.

Refill triggers only after correct animation completes.

During tier pauses or timeout dialogs: all grid input must be disabled.

Timing, motion, and haptics
Press: scale to 0.98 on down for 80 ms, spring back on up.

Correct: green overlay 80 ms → scale/fade 120 ms → refill fade-in 100 ms.

Wrong: red overlay 80 ms → shake 200–250 ms → reset.

Confetti: small burst at 12 and 30; bigger at 50. Auto-throttle by device.

Haptics: success pulse on correct; error buzz on wrong; none during pauses.

SRS side-effects inside the loop
On each correct:

Credit the item for this run only once toward the “3 clean runs” rule.

On each wrong:

Increment recent error for that item.

If thresholds hit:

Reinsert 4–6 pairs later this run.

Ensure item sits near top of next run’s deck.

Cap to 3 appearances per run.

Commit strategy:

Write per-item states and run summary at finish.

You may buffer attempt logs and flush during tier pauses or finish to avoid hot-path I/O.

Deck consumption and exhaustion
Normal: one deck pair consumed per correct.

Wrong attempts do not consume from deck.

Exhaustion:

If deck empties before reaching 50:

Pull more from the same level strata first.

Then from lower levels.

As a last resort, reintroduce learned items.

Never block progress; never leave an empty slot unpaired.

Variant loops
A) Row Blaster active (4 rows)
Same loop. Only difference:

rows = 4.

Lower vertical scan. Slightly faster perceived matching.

Earned or toggled pre-run only. No mid-run change.

B) High error scenario

Multiple wrong attempts on a family (e.g., pero/perro).

Each wrong triggers 4–6-ahead reinsert; you still enforce family spacing in the window.

Next run deck begins with these items. Fresh items cap stays ≤20%.

C) Extend chain

Timeout at 0 s with progress <50 and at least one token.

Accept extend: +60 s and resume unchanged board.

You may extend twice maximum per run.

Accessibility gameplay path
Focus traversal moves left column then right column per row, cycling.

Screen reader announces: “English: the house. Double-tap to select.” then “Spanish: la casa. Double-tap to match.”

On correct: announce “Correct. 1 of 50.” On wrong: “Try again.”

Pause overlay has semantic focus trap until Continue.

Telemetry cadence inside the loop
Per attempt: log runId, ts, tier, enId, esTappedId, result, row, column, timeRemaining.

Per run end: log rows used, extend count, deck composition counts, learned promotions, trouble detections.

Flush on pause or finish. Export only on developer action.

Performance rules per cycle
Limit rebuilds to the two affected tiles and header counters.

Keep animations GPU-friendly; avoid expensive layout thrash.

Batch DB writes; don’t allocate in hot paths.

Frame budget ≤16.7 ms; animation work must keep p95 <8 ms.

Termination and cleanup
On finish or decline of extend:

Stop timer, mark inputLock=finished.

Persist XP and SRS states atomically.

Reset transient run caches.

Return to summary; from there, Pre-run can start a new deck with updated states.

This is the full gameplay loop to implement. Each step is deterministic, timed, and testable.

USE THIS TEXT AS A GENERAL GUIDELINE TO HELP YOU UNDERSTAND THE PROJECT

# Palabra Product Vision (v7.0)

## 1. Purpose
Palabra is a high-speed, offline Spanish vocabulary trainer. Players tap matching English and Spanish tiles on a fixed 2-column board to clear 50 correct pairs in 60 seconds. The mode feels arcade-fast while quietly tracking mastery and trouble items so future runs adapt to each learner.

## 2. Guiding Pillars
- **Always solvable, never random**: Both columns refill in place with valid pairs; tiles never reshuffle or drift.
- **Speed with memory**: Two pauses (12 & 30 correct) reset attention without altering the board. Wrong answers cost only time; mastery comes from accuracy and flow.
- **Adaptive content**: Learned items fade after 3 perfect appearances; trouble items repeat within and across runs; fresh items stay under 20% of a deck.
- **Offline first**: All data (vocabulary, telemetry, powerups) ships locally. No remote services or analytics in MVP.
- **Delight in execution**: 60 FPS, responsive animations under 250 ms, and a punchy visual identity built on gradients and procedural vectors.

## 3. Player Journey
1. **Gate**: Entry screen confirms Spanish course, surfaces streak/progress, and advertises powerups. (If prerequisites fail, show "Palabra not available".)
2. **Pre-Run**: Displays goal "50 in 1:00", tier rewards (12/30/50), Row Blaster toggle, powerup inventory, Start CTA.
3. **Run**: Default 5x2 grid (Row Blaster makes it 4x2). Timer counts down from 60 seconds. Progress bar marks 12/30/50.
4. **Pauses**: Automatic at 12 and 30 correct. Timer freezes, board locks, XP summary shown. Resume keeps board untouched.
5. **Finish**: Success (+40 XP) at 50 pairs before time expires. On timeout, offer +60 s/time extend if token available; otherwise show completion summary with secured XP.

## 4. Game Rules & Mechanics
- **Board**: Five rows of English tiles on the left, matching Spanish on the right. Selecting one tile per column resolves a pair.
- **Tap guards**: Ignore taps in the same column consecutively; second tap must be opposite column.
- **Correct pair**: Flash green ≤80 ms, scale/fade ≤120 ms, remove both tiles, refill both slots simultaneously.
- **Wrong pair**: Flash red, shake 200–250 ms, reset selection without penalties; timer keeps ticking.
- **Timer**: 60 seconds (1:00). Pauses trigger exactly at 12 and 30 correct pairs; finishing at 50 ends run.
- **Powerups**:
  - *Row Blaster*: optional pre-run toggle, board becomes 4 rows. Goal remains 50 matches.
  - *Time Extend*: offered on timeout when progress <50 and a token exists; adds 60 s, max twice per run.
- **XP**: 5 XP at 12, +10 at 30 (15 total), +25 at 50 (40 total). Failing runs earn the last awarded tier.

## 5. Content & Adaptation
- **Assets**: JSON files in `assets/vocabulary/spanish/{a1,a2,b1,b2}.json` with entries `{id,en,es,level,family,topic}`.
- **Deck builder**:
  - Mix per user level: beginners skew A1/A2; advanced skew A2/B1 with A1 refreshers. Fresh items ≤20% of deck.
  - Avoid simultaneous confusable families unless intentionally testing them.
  - When deck exhausts, pull more from same level; if empty, backfill with A1 learned items.
- **Spaced repetition**:
  - Learned: 3 consecutive correct runs; retire for at least three runs.
  - Trouble: mark on wrong answers; reinsert 4–6 pairs later and prioritize next runs.
  - Track `seenCount`, `correctStreak`, `wrongCount`, and timestamps per item.

## 6. Technology Stack
- **Framework**: Flutter 3.35.7 (Dart 3.9).
- **State**: Riverpod; all feature controllers exposed via providers.
- **Navigation**: go_router with routes `/gate`, `/mm/prerun`, `/mm/run`, `/mm/finish` (aliases will be updated once final naming is set).
- **Storage**: In-memory store seeded from bundled JSON (web beta resets on refresh; persistence TBD).
- **Tooling**: Very Good Analysis linting; in-memory stores seeded from bundled JSON during app bootstrap.

## 7. Data Model Overview
- `VocabItem`: base content entry.
- `UserItemState`: per-user mastery values (learned/trouble history).
- `UserMeta`: settings, powerup inventory, preferred row count, last run timestamps.
- `RunLog`: session summaries with deck composition, learned promotions, trouble detections.
- `AttemptLog`: every pair attempt (ids, result, tier, row/column, remaining time).

## 8. Telemetry & Privacy
- Telemetry stored locally; optional export as JSON for QA.
- No third-party analytics, accounts, or cloud sync in MVP.
- Only anonymous user GUID stored on device.

## 9. Performance & UX Targets
- 60 FPS on mid-range Android/iOS hardware.
- Animations ≤250 ms; refills ≤100 ms.
- Board interactions stay responsive during rapid two-thumb play.
- Fonts (Noto Sans) maintain readability; wrap multi-word Spanish without shrinking below accessibility thresholds.

## 10. Roadmap Snapshot
**Week 1**: Repo, CI skeleton, app shell, design tokens, data models, vocabulary validator, initial ingestion.

**Week 2**: Deck builder + SRS rules, vocabulary import to in-memory store, repositories with tests.

**Week 3**: Board interactions (tap guards, correct/wrong flows), timer + pauses, run UI, powerup toggles.

**Week 4**: Polish, telemetry export, golden tests, perf validation, packaging (splash/icons).

## 11. Testing Strategy
- **Unit**: Deck mix ratios, SRS transitions, family window enforcement, fallback chains.
- **Widget**: Tap guard flow, correct/wrong animations, pause overlay behavior, board refill integrity.
- **Integration**: Scripted 50-match run, timeout + Time Extend, Row Blaster path.
- **Golden**: Gate, Prerun, Run, Pause, Finish at key DPIs.
- **Performance**: Automated tap stress harness ensuring frame budget compliance.

## 12. Non-Goals (MVP)
- Speech recognition, TTS, or voice input.
- Accounts, cloud save, or remote analytics.
- Dynamic content downloads or non-Spanish languages.

## 13. Glossary
- **Board**: Two-column tile grid visible to the player.
- **Deck**: Ordered queue of pairs available for refills.
- **Family**: Group of confusable Spanish forms.
- **Fresh Item**: Vocabulary entry not yet seen by the user in Palabra.
- **Learned**: Item temporarily retired after three perfect appearances.
- **Trouble**: Item flagged for repeat drilling after mistakes.
- **Tier**: Reward milestones at 12, 30, and 50 matches.
- **Run**: One timed Palabra session.

## 14. Acceptance Criteria Summary
- Board solvable at all times; both tiles refill together in place.
- Pauses freeze timer exactly at 12 and 30 correct answers; board remains untouched.
- Wrong answers never deduct XP or trigger reshuffle.
- Learned/trouble logic persists across sessions (future persistent store; current web beta keeps data per session).
- Powerups function exactly as specified, with clear inventory limits.
- App operates fully offline with packaged assets.
