
Project vision

Build a fast, offline, Spanish-only matching game. Two fixed columns. Left shows English. Right shows Spanish. The player must reach 90 correct matches in 105 seconds. The timer hard-pauses at 20 and 50 correct. Correct pairs disappear in place and both empty slots refill from a prebuilt deck. No reshuffle. Wrong selections have no penalty. The board must always be solvable. The system promotes learned words and repeats trouble words. Powerups exist: Row Blaster reduces rows to four. Time Extend adds 60 seconds at timeout. All assets are local. All graphics are procedural.

Pronunciation remains available offline. Web speech uses the browser API when possible, but every vocabulary item (and core number set 1–100) ships with Piper-generated MP3 fallbacks so learners still hear the word even when speech synthesis is unavailable.

What the game is

A timed EN↔ES word pairing challenge. Each board shows five rows by two columns by default. One English tile per row on the left. One Spanish tile per row on the right. Each English tile has exactly one Spanish match on the board at all times. The player taps one left tile and one right tile to resolve a match. Correct removes both. Wrong shakes both. The game rewards speed and accuracy. The game teaches by hiding mastered items and repeating items the player misses.

Player journey: end-to-end steps

Launch and gate
App launches to the home menu.

Player opens Palabra.

Gate checks device and course.

If device is not iPhone, show “Palabra not available.”

If course is not Spanish, show “Palabra not available for this course.”

If allowed, proceed to Pre-run.

Pre-run screen
Show title “Palabra.”

Show objective “Make 90 correct matches in 1:45.”

Show tier rewards: “20 → 5 XP”, “50 → +10 XP”, “90 → +25 XP.”

Show Row Blaster powerup control.

If inventory ≥1, allow toggle. If zero, show price and disabled state.

Show Time Extend info. This can only be used when time reaches zero during a run.

Show Start. No network needed. All data is local.

Deck build and board fill
Read user level. Default A1 if unknown.

Build a deck of ~100 to 110 pairs using the rules:

Learned items excluded for this run.

Trouble items placed first but capped at 4 to 6.

Level mix by user level.

Fresh items ≤20% of the deck.

Confusable families not repeated within any window of five pairs.

Backfill if short. Same level, then lower level, then learned as last resort.

Choose board rows. Five by default. Four if Row Blaster is active.

Draw N pairs where N equals rows.

Place English parts into unique left rows.

Place Spanish parts into unique right rows.

Repair until each left id has its matching right id on board. No orphan tiles.

Running state
Timer starts at 105 seconds.

Progress starts at 0 of 90. Markers at 20, 50, and 90.

The grid shows N rows with two tiles per row.

Player taps a left tile. Tile scales to 0.98 then returns to 1.0. Tile becomes selected.

Player taps a right tile.

If the pair matches:

Both tiles flash green for 80 ms.

Both scale to 0.9 and fade to 0 over 120 ms.

Both tiles are removed.

Refill both empty slots with the next pair from the deck.

New tiles fade in over 100 ms.

Progress increments by one.

Attempt logged as correct.

If the pair does not match:

Both tiles flash red for 80 ms.

Both shake horizontally for 200 to 250 ms.

Selection clears to idle.

Attempt logged as wrong. Item error counters update.

Selection rules:

Only zero or two tiles can be non-idle at once.

Selection must be one left and one right.

A second tap on the same column is ignored.

Board invariant:

The multiset of pairIds on the left equals the multiset on the right.

If a refill would insert only one side, cancel that insert and wait for the next complete pair.

Tier pauses
At 20 correct:

Freeze timer. Freeze board input. Dim board.

Show “Tier 1 complete. +5 XP secured.”

On Continue, undim, resume timer. Board stays identical. No refill occurs.

At 50 correct:

Same behavior.

Show “Tier 2 complete. +10 XP secured. Total +15 XP.”

Finish conditions
Success:

At 90 correct, stop timer.

Show “You earned 40 XP.” Show learned promotions. Show “Practice again.”

Timeout without 90:

If Time Extend inventory >0:

Offer “Add 60 s?” with one token.

If accepted, add 60 seconds. Resume in place. No reshuffle.

If declined, award the highest secured tier XP. End session.

If no token, award secured XP. End session.

After the run
Save XP. Update streak if run finished.

Promote learned items if they met the rule.

Flag trouble items if they met the rule. Place them early in the next deck.

Persist RunLog and AttemptLog.

Update powerup inventory based on earn rules.

Sample playthrough timeline
Perfect five-row run without powerups

00:00 Start. Rows=5. Progress 0/90.

00:23 Reach 20. Pause. Show +5 XP. Resume.

00:58 Reach 50. Pause. Show +15 XP total. Resume.

01:22 Reach 90. Success. Award +40 XP. Show learned list.

Timeout with extend

00:00 Start. Rows=5.

01:45 Progress at 74. Time hits zero. Offer +60 s.

Player accepts. Timer becomes 01:00. Resume.

00:38 later reach 90. Success. Inventory reduced by one extend token.

High error rate with trouble items

Early misses on “pero” vs “perro.”

Each miss logs to AttemptLog. Item flagged as trouble.

The item reinserts 4 to 6 positions later.

Next run begins with that family near the top. Fresh items cap remains ≤20%.

Modules with deeper detail

App shell
Owns startup order. Fonts. DB open. Provider graph.

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
Counts down. Emits Tick. Emits TierReached at 20 and 50.

Freezes timer and input during tier pauses. The board state object is untouched.

On timeout:

If Time Extend exists and progress <90, emit ExtendOffer.

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

Small burst at tiers. Larger burst at 90.

Powerups and economy
Inventory lives in UserMeta.

Row Blaster:

Toggle at Pre-run only. If active, rows=4 for this run. Last row collapses with a height tween in 150 ms.

Earn +1 on flawless runs. Also +1 per three runs completed in a day.

Time Extend:

Available only at timeout and if progress <90.

Adds one minute per token. Max two uses per run.

Earn +1 for any run completed in under 1:30. Also +1 from the daily mission.

Progress and rewards
XP:

+5 when you reach 20. Stored immediately.

+10 when you reach 50. Cumulative +15. Stored immediately.

+25 when you reach 90. Total +40. Stored on finish.

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

Auto-play test mode runs a deterministic script to reach 90 for performance tests.

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

Timer pauses exactly at 20 and 50. The board remains unchanged during the pause.

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

runClock: milliseconds remaining (starts 105000).

progress: correct matches so far (0→90).

tierFlags: pausedAt20, pausedAt50.

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

Clock = 105 s. progress=0. inputLock=idle.

UI visible: top bar (timer, tier ticks at 20/50/90, powerup icons), grid (5×2 or 4×2), empty bottom.

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

If progress == 20 && !pausedAt20: → Tier pause 1.

Else if progress == 50 && !pausedAt50: → Tier pause 2.

Else if progress == 90: → Finish success.

Wrong path:

Both tiles flash red (~80 ms).

Both tiles shake horizontally 2–3 oscillations (200–250 ms).

Persist AttemptLog entry (wrong), update run-local error counters.

Clear selection, selected=null, inputLock=idle.

Trouble scheduling: mark the item for reinsert 4–6 pairs later within this run and for front-loading next run (cap to 3 appearances/run).

Tier pause mechanics (at 20 and 50)
Trigger condition: resolve a correct match that makes progress equal exactly 20 or 50.

Immediate actions:

Stop the timer precisely. Record pauseTs.

Set inputLock=paused.

Dim board; disable all grid hit-testing; keep board arrays unchanged.

Show overlay: “Tier X complete” and secured XP (+5 at 20; cumulative +15 at 50).

Resume:

On “Continue”, hide overlay, undim board.

Do not refill or reshuffle anything.

Resume timer from stored remaining time.

Set inputLock=idle.

Edge constraints:

If the last correct was also the 90th, finish overrides pause.

If multi-touch tries to tap during pause, all taps are ignored.

Timeout and Time Extend
Trigger: runClock reaches 0 while progress < 90.

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
Success (progress == 90 before time ends):

Stop timer. Set inputLock=finished.

Award +40 XP total for the run (5 at 20 +10 at 50 +25 at 90).

Promote learned items that hit the rule (3 clean runs, no item errors).

Commit RunLog summary and per-item state to DB.

Show summary: XP earned, “Learned today” list, “Practice again”.

Timeout:

Award highest secured tier XP only.

Commit RunLog and update trouble items.

Show summary with progress N/90, XP awarded, option to replay.

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

Confetti: small burst at 20 and 50; bigger at 90. Auto-throttle by device.

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

If deck empties before reaching 90:

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

Timeout at 0 s with progress <90 and at least one token.

Accept extend: +60 s and resume unchanged board.

You may extend twice maximum per run.

Accessibility gameplay path
Focus traversal moves left column then right column per row, cycling.

Screen reader announces: “English: the house. Double-tap to select.” then “Spanish: la casa. Double-tap to match.”

On correct: announce “Correct. 1 of 90.” On wrong: “Try again.”

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
Palabra is a high-speed, offline Spanish vocabulary trainer. Players tap matching English and Spanish tiles on a fixed 2-column board to clear 90 correct pairs in 105 seconds. The mode feels arcade-fast while quietly tracking mastery and trouble items so future runs adapt to each learner.

## 2. Guiding Pillars
- **Always solvable, never random**: Both columns refill in place with valid pairs; tiles never reshuffle or drift.
- **Speed with memory**: Two pauses (20 & 50 correct) reset attention without altering the board. Wrong answers cost only time; mastery comes from accuracy and flow.
- **Adaptive content**: Learned items fade after 3 perfect appearances; trouble items repeat within and across runs; fresh items stay under 20% of a deck.
- **Offline first**: All data (vocabulary, telemetry, powerups) ships locally. No remote services or analytics in MVP.
- **Delight in execution**: 60 FPS, responsive animations under 250 ms, and a punchy visual identity built on gradients and procedural vectors.

## 3. Player Journey
1. **Gate**: Entry screen confirms Spanish course, surfaces streak/progress, and advertises powerups. (If prerequisites fail, show "Palabra not available".)
2. **Pre-Run**: Displays goal "90 in 1:45", tier rewards (20/50/90), Row Blaster toggle, powerup inventory, Start CTA.
3. **Run**: Default 5x2 grid (Row Blaster makes it 4x2). Timer counts down from 105 seconds. Progress bar marks 20/50/90.
4. **Pauses**: Automatic at 20 and 50 correct. Timer freezes, board locks, XP summary shown. Resume keeps board untouched.
5. **Finish**: Success (+40 XP) at 90 pairs before time expires. On timeout, offer +60 s/time extend if token available; otherwise show completion summary with secured XP.

## 4. Game Rules & Mechanics
- **Board**: Five rows of English tiles on the left, matching Spanish on the right. Selecting one tile per column resolves a pair.
- **Tap guards**: Ignore taps in the same column consecutively; second tap must be opposite column.
- **Correct pair**: Flash green ≤80 ms, scale/fade ≤120 ms, remove both tiles, refill both slots simultaneously.
- **Wrong pair**: Flash red, shake 200–250 ms, reset selection without penalties; timer keeps ticking.
- **Timer**: 105 seconds (1:45). Pauses triggered exactly at 20 and 50 correct pairs; finishing at 90 ends run.
- **Powerups**:
  - *Row Blaster*: optional pre-run toggle, board becomes 4 rows. Goal remains 90 matches.
  - *Time Extend*: offered on timeout when progress <90 and a token exists; adds 60 s, max twice per run.
- **XP**: 5 XP at 20, +10 at 50 (15 total), +25 at 90 (40 total). Failing runs earn the last awarded tier.

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
- **Integration**: Scripted 90-match run, timeout + Time Extend, Row Blaster path.
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
- **Tier**: Reward milestones at 20, 50, and 90 matches.
- **Run**: One timed Palabra session.

## 14. Acceptance Criteria Summary
- Board solvable at all times; both tiles refill together in place.
- Pauses freeze timer exactly at 20 and 50 correct answers; board remains untouched.
- Wrong answers never deduct XP or trigger reshuffle.
- Learned/trouble logic persists across sessions (future persistent store; current web beta keeps data per session).
- Powerups function exactly as specified, with clear inventory limits.
- App operates fully offline with packaged assets.
