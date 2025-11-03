# Palabra — WSL Environment Setup

These are the exact steps used to bring the project fully inside Windows Subsystem for Linux (Ubuntu 24.04), install Flutter 3.35.7, and wire the remaining host integrations.

## 1. Prerequisites
- Windows 11 with WSL2 enabled and an Ubuntu distribution installed.
- Git, curl, unzip (`sudo apt update && sudo apt install git curl unzip`).

## 2. Install Flutter inside WSL
```bash
# clone once
git clone --depth 1 --branch stable https://github.com/flutter/flutter.git ~/flutter

# make the toolchain discoverable for every new shell
echo 'export PATH="$HOME/flutter/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
flutter --version
```
The current repo expects Flutter 3.35.7 (Dart 3.9.2). The version command should match.

## 3. Satisfy Linux build prerequisites
Even if you target Android/web from Windows, build tooling may probe these packages:
```bash
sudo apt install clang cmake ninja-build pkg-config libgtk-3-dev
```

## 4. Bridge Windows SDKs into WSL
- **Chrome / Edge**: install the browser on Windows and expose it to Flutter, e.g.\
  `echo 'export CHROME_EXECUTABLE="/mnt/c/Program Files/Google/Chrome/Application/chrome.exe"' >> ~/.bashrc`
- **Android SDK**: install Android Studio on Windows, then point Flutter at it from WSL:\
  `flutter config --android-sdk "/mnt/c/Users/<you>/AppData/Local/Android/Sdk"`
- Re-run `flutter doctor` to confirm the web and Android toolchains register.

### Recommended way to view the web build
Because WSL2 and Windows run in different network namespaces, the most reliable way to view the Flutter web beta is to let Flutter serve it and open the URL manually in Windows:

```bash
flutter run -d web-server
# copy the printed http://localhost:<port> or run:
wslview http://localhost:<port>
```

The server keeps hot reload in the WSL terminal, while your Windows Chrome/Edge session mirrors the changes. Use the direct Chrome device (`flutter run -d chrome`) only when you are working in a pure Windows shell.

## 5. Project bootstrap
```bash
cd ~/dev/PALABRA_V70
flutter pub get
flutter analyze
flutter test
```

Troubleshooting tips live in `docs/web_beta_instructions.md`. Capture obstacles in `docs/daily.md` so the status page stays current.
