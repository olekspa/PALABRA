# Palabra Web Beta — Build & QA Guide

This guide describes how to assemble, serve, and manually verify the web beta in a local environment. The flow targets Flutter 3.35.7 and Dart 3.9 as defined in the repository toolchain.

## Prerequisites
- Flutter stable 3.35.7 installed and on `PATH`.
- Chrome or Edge (latest stable) for local testing.
- Python 3 (optional) for running a simple static file server.

Confirm the toolchain:
```bash
flutter --version
flutter doctor
flutter pub get
```

## Build Targets
### Iterating in a browser
```bash
flutter run -d web-server
# Once the URL prints, open it from Windows:
wslview http://localhost:<port>
```
Flutter keeps hot reload active in the WSL terminal, and the Windows browser reflects changes immediately. This avoids the remote-debugging handshake between WSL and Windows Chrome that can block `flutter run -d chrome`.

If you are developing directly from a Windows shell (not WSL), you can still use `flutter run -d chrome` for the classic auto-launch workflow.

### Producing a Release Build
```bash
flutter build web --release
```
Artifacts land under `build/web`. Copy this directory to any static host.

## Local Hosting
To smoke-test the release output without the Flutter toolchain, serve the compiled assets:
```bash
cd build/web
python -m http.server 8080
```
Visit `http://localhost:8080/` in Chrome/Edge. For LAN testing, replace `localhost` with the host machine IP and ensure firewalls allow inbound traffic.

## Manual QA Checklist
1. **Cold start**: Load the app; verify the Gate screen appears with platform/course checks stubbed.
2. **Pre-run**: Start a session, toggle Row Blaster, and confirm that the UI reflects the selected row count.
3. **Run loop**: Match tiles until at least three pairs resolve, ensuring the board refills gradually and always offers valid matches.
4. **Tier pause**: Reach 20 matches using the debug deck (if available) and confirm the pause overlay appearance and resume behavior.
5. **Finish screen**: Let the timer expire or reach the target; verify the summary pulls the latest run log.
6. **Refresh**: Reload the page and confirm that run history and settings persist (SharedPreferences-backed). Clear browser storage to simulate a fresh profile until in-app reset tooling lands or the hosted persistence service is ready.

Record findings (pass/fail, device/browser, timestamp) in `docs/daily.md` or the project tracker.

## Known Limitations
- Persistence relies on `shared_preferences`; schema migrations and multi-profile handling are not yet implemented. Clearing site data resets progress. An LXC-hosted service is on the roadmap but not yet available.
- Confetti/tier celebration FX and power-up art are still in progress (audio/haptics exist but are platform-dependent).
- Course/device gating relies on stubbed values until LMS integration lands.

## Troubleshooting
- **Flutter tool cannot find Dart SDK**: Ensure your WSL shell exports `PATH="$HOME/flutter/bin:$PATH"` (log out/in after editing `~/.bashrc`), then re-run the command.
- **Blank page after build**: Clear the browser cache, then re-run `flutter build web --release`.
- **Glitchy board refills**: Confirm you are on the latest `master` and that `flutter pub get` has been executed.
