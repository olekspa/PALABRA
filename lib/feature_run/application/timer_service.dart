// Lightweight service intentionally omits docs until API stabilizes.
// ignore_for_file: public_member_api_docs

import 'dart:async';

typedef TimerTickCallback = void Function(int remainingMs);
typedef TimerTimeoutCallback = void Function();

class RunTimerService {
  RunTimerService({bool isFake = false}) : _isFake = isFake;

  factory RunTimerService.fake() => RunTimerService(isFake: true);

  final bool _isFake;
  Timer? _timer;
  int _remainingMs = 0;
  bool _isPaused = false;
  TimerTickCallback? _onTick;
  TimerTimeoutCallback? _onTimeout;

  void start({
    required int durationMs,
    required TimerTickCallback onTick,
    required TimerTimeoutCallback onTimeout,
  }) {
    stop();
    _remainingMs = durationMs;
    _isPaused = false;
    _onTick = onTick;
    _onTimeout = onTimeout;

    if (_isFake) {
      return;
    }

    _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (_isPaused) {
        return;
      }
      _remainingMs = (_remainingMs - 100).clamp(0, durationMs);
      _onTick?.call(_remainingMs);
      if (_remainingMs <= 0) {
        stop();
        _onTimeout?.call();
      }
    });
  }

  void tickFake({int decrementMs = 100}) {
    if (!_isFake) {
      return;
    }
    if (_remainingMs <= 0 || _isPaused) {
      return;
    }
    _remainingMs = (_remainingMs - decrementMs).clamp(0, _remainingMs);
    _onTick?.call(_remainingMs);
    if (_remainingMs <= 0) {
      _onTimeout?.call();
    }
  }

  void reduceBy(int milliseconds) {
    if (milliseconds <= 0) {
      return;
    }
    if (_remainingMs <= 0) {
      return;
    }
    final next = _remainingMs - milliseconds;
    _remainingMs = next < 0 ? 0 : next;
    _onTick?.call(_remainingMs);
    if (_remainingMs == 0) {
      stop();
      _onTimeout?.call();
    }
  }

  void extendBy(int milliseconds) {
    if (milliseconds <= 0) {
      return;
    }
    if (_remainingMs <= 0) {
      _remainingMs = milliseconds;
    } else {
      _remainingMs += milliseconds;
    }
    _onTick?.call(_remainingMs);
  }

  void pause() {
    _isPaused = true;
  }

  void resume() {
    _isPaused = false;
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
  }
}
