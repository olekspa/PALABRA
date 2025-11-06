// Web implementation relies on browser APIs that are still under evaluation.
// ignore_for_file: public_member_api_docs, deprecated_member_use, avoid_web_libraries_in_flutter

import 'dart:async';
import 'dart:collection';
import 'dart:html' as html;

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:just_audio/just_audio.dart';

import 'package:palabra/feature_run/application/tts/run_tts_config.dart';
import 'package:palabra/feature_run/application/tts/run_tts_service.dart';

const Duration _kDebounceDuration = Duration(milliseconds: 250);
const Duration _kSpeechTimeout = Duration(seconds: 6);
const String _kVoiceStorageKey = 'palabra_tts_voice_v1';

class _QueuedUtterance {
  _QueuedUtterance({
    required this.text,
    this.itemId,
  });

  final String text;
  final String? itemId;
}

@immutable
class _SpeechVoice {
  const _SpeechVoice({
    required this.name,
    required this.locale,
  });

  final String name;
  final String locale;

  String get normalizedLocale =>
      locale.replaceAll('_', '-').toLowerCase().trim();

  bool get isSpanish => normalizedLocale.startsWith('es');

  @override
  bool operator ==(Object other) {
    return other is _SpeechVoice &&
        name == other.name &&
        locale == other.locale;
  }

  @override
  int get hashCode => Object.hash(name, locale);
}

class _TtsCancelledException implements Exception {
  const _TtsCancelledException();
}

class _RunTtsServiceWeb implements RunTtsService {
  _RunTtsServiceWeb(this._ref) : _flutterTts = FlutterTts() {
    _currentConfig = _ref.read(runTtsConfigProvider);
    _configSubscription = _ref.listen<RunTtsConfig>(
      runTtsConfigProvider,
      (previous, next) {
        _currentConfig = next;
        if (_initialized) {
          unawaited(_applyConfig(next));
        }
      },
    );
    _hydrateCachedVoice();
    _speechSupported = _detectSpeechSupport();
    if (!_speechSupported) {
      _updateVoiceLabel(null);
    }
  }

  final Ref _ref;
  final FlutterTts _flutterTts;
  final AudioPlayer _audioPlayer = AudioPlayer();

  late RunTtsConfig _currentConfig;
  ProviderSubscription<RunTtsConfig>? _configSubscription;

  final Queue<_QueuedUtterance> _queue = Queue<_QueuedUtterance>();
  final Map<String, bool> _assetAvailability = <String, bool>{};

  List<_SpeechVoice> _voices = <_SpeechVoice>[];
  _SpeechVoice? _selectedVoice;
  String? _cachedVoiceName;
  _QueuedUtterance? _lastSuccessfulUtterance;

  Completer<void>? _initializeCompleter;
  Completer<void>? _speakCompleter;
  StreamSubscription<html.Event>? _voiceChangedSubscription;
  StreamSubscription<html.Event>? _visibilitySubscription;

  bool _speechSupported = false;
  bool _initialized = false;
  bool _userGestureSeen = false;
  bool _unlockAttempted = false;
  bool _drainingQueue = false;
  bool _isSpeaking = false;
  bool _resumeAfterVisibility = false;
  bool _telemetryLogged = false;
  bool _voicesUnavailable = false;
  bool _voicesEventObserved = false;

  int _errorCount = 0;
  int _timeoutCount = 0;

  DateTime? _lastRequestAt;

  @override
  bool get isSupported => _speechSupported && !_voicesUnavailable;

  @override
  Future<void> onUserGesture() async {
    if (!isSupported) {
      return;
    }
    if (_userGestureSeen) {
      return;
    }
    _userGestureSeen = true;
    await _ensureInitialized();
    await _performUnlockIfNeeded();
  }

  @override
  Future<RunTtsPlaybackOutcome> speak({
    required String text,
    String? itemId,
  }) async {
    if (text.trim().isEmpty) {
      return RunTtsPlaybackOutcome.unavailable;
    }

    if (_isDebounced()) {
      return RunTtsPlaybackOutcome.debounced;
    }

    final utterance = _QueuedUtterance(
      text: text,
      itemId: itemId,
    );

    if (!isSupported) {
      final fallbackOutcome = await _attemptAssetOrToast(utterance);
      _logTelemetryOnce(fallbackOutcome);
      return fallbackOutcome;
    }

    _queue.addLast(utterance);

    await _ensureInitialized();
    await _performUnlockIfNeeded();

    return _drainQueue();
  }

  @override
  Future<void> cancel() async {
    try {
      await _flutterTts.stop();
    } on Object {
      // ignore
    }
    try {
      await _audioPlayer.stop();
    } on Object {
      // ignore
    }
  }

  @override
  void dispose() {
    _configSubscription?.close();
    final voiceCancel = _voiceChangedSubscription?.cancel();
    if (voiceCancel != null) {
      unawaited(voiceCancel);
    }
    final visibilityCancel = _visibilitySubscription?.cancel();
    if (visibilityCancel != null) {
      unawaited(visibilityCancel);
    }
    unawaited(cancel());
    unawaited(_audioPlayer.dispose());
  }

  bool _isDebounced() {
    final now = DateTime.now();
    if (_lastRequestAt != null &&
        now.difference(_lastRequestAt!) < _kDebounceDuration) {
      return true;
    }
    _lastRequestAt = now;
    return false;
  }

  Future<void> _ensureInitialized() async {
    if (!isSupported) {
      return;
    }
    if (_initialized) {
      return;
    }
    if (_initializeCompleter != null) {
      await _initializeCompleter!.future;
      return;
    }
    final completer = Completer<void>();
    _initializeCompleter = completer;
    try {
      await _configureFlutterTts();
      await _loadVoices();
      _bindVoiceChangeListener();
      _bindVisibilityListener();
      _initialized = true;
    } finally {
      if (!completer.isCompleted) {
        completer.complete();
      }
      _initializeCompleter = null;
    }
  }

  Future<void> _configureFlutterTts() async {
    _flutterTts.setStartHandler(() {
      _isSpeaking = true;
    });
    _flutterTts.setCompletionHandler(() {
      _isSpeaking = false;
      final completer = _speakCompleter;
      if (completer != null && !completer.isCompleted) {
        completer.complete();
      }
      _speakCompleter = null;
    });
    _flutterTts.setCancelHandler(() {
      _isSpeaking = false;
      final completer = _speakCompleter;
      if (completer != null && !completer.isCompleted) {
        completer.completeError(const _TtsCancelledException());
      }
      _speakCompleter = null;
    });
    _flutterTts.setErrorHandler((message) {
      _isSpeaking = false;
      final completer = _speakCompleter;
      if (completer != null && !completer.isCompleted) {
        completer.completeError(Exception(message ?? 'TTS error'));
      }
      _speakCompleter = null;
      _errorCount += 1;
    });
    try {
      await _flutterTts.awaitSpeakCompletion(true);
    } on Object {
      // Some implementations do not support awaitSpeakCompletion on web.
    }
    await _applyConfig(_currentConfig);
  }

  Future<void> _applyConfig(RunTtsConfig config) async {
    try {
      await _flutterTts.setSpeechRate(config.rate);
    } on Object {
      // ignore unsupported config change
    }
    try {
      await _flutterTts.setPitch(config.pitch);
    } on Object {
      // ignore unsupported config change
    }
  }

  Future<RunTtsPlaybackOutcome> _drainQueue() async {
    if (!_initialized) {
      return RunTtsPlaybackOutcome.queued;
    }
    if (_queue.isEmpty) {
      return RunTtsPlaybackOutcome.queued;
    }
    if (_drainingQueue) {
      return RunTtsPlaybackOutcome.queued;
    }

    _drainingQueue = true;
    RunTtsPlaybackOutcome outcome = RunTtsPlaybackOutcome.queued;
    try {
      while (_queue.isNotEmpty) {
        final utterance = _queue.removeFirst();
        final voice = await _ensureVoiceSelected();
        if (voice == null) {
          if (!_voicesUnavailable) {
            _queue.addFirst(utterance);
            outcome = RunTtsPlaybackOutcome.queued;
            break;
          }
          outcome = await _attemptAssetOrToast(utterance);
          continue;
        }
        outcome = await _speakWithFallbacks(utterance, voice);
      }
    } finally {
      _drainingQueue = false;
    }
    return outcome;
  }

  Future<_SpeechVoice?> _ensureVoiceSelected() async {
    if (_selectedVoice != null) {
      return _selectedVoice;
    }
    await _loadVoices();
    return _selectedVoice;
  }

  Future<void> _loadVoices() async {
    List<dynamic>? rawVoices;
    try {
      final result = await _flutterTts.getVoices;
      if (result is List) {
        rawVoices = List<dynamic>.from(result);
      }
    } on Object {
      rawVoices = null;
    }
    if (rawVoices == null || rawVoices.isEmpty) {
      if (_voicesEventObserved) {
        _voicesUnavailable = true;
        _selectedVoice = null;
        _updateVoiceLabel(null);
      }
      return;
    }
    _voicesEventObserved = true;
    final voices = <_SpeechVoice>[];
    for (final entry in rawVoices) {
      if (entry is Map) {
        final rawName = entry['name'] ?? entry['voice'] ?? '';
        final rawLocale = entry['locale'] ?? entry['lang'] ?? '';
        if (rawName is String && rawLocale is String) {
          final voice = _SpeechVoice(name: rawName, locale: rawLocale);
          if (voice.isSpanish) {
            voices.add(voice);
          }
        }
      }
    }
    if (voices.isEmpty) {
      _voices = const <_SpeechVoice>[];
      _selectedVoice = null;
      _voicesUnavailable = true;
      _updateVoiceLabel(null);
      return;
    }
    _voicesUnavailable = false;
    _voices = _sortVoices(voices);
    _selectedVoice = _voices.isNotEmpty ? _voices.first : null;
    if (_selectedVoice != null) {
      await _setActiveVoice(_selectedVoice!);
      _updateVoiceLabel(_selectedVoice);
      _persistVoiceName(_selectedVoice!.name);
    }
  }

  List<_SpeechVoice> _sortVoices(List<_SpeechVoice> voices) {
    final deduped = <String, _SpeechVoice>{};
    for (final voice in voices) {
      deduped.putIfAbsent('${voice.name}|${voice.locale}', () => voice);
    }
    final list = deduped.values.toList();
    list.sort((a, b) {
      final delta = _voiceScore(a).compareTo(_voiceScore(b));
      if (delta != 0) {
        return delta;
      }
      return a.name.compareTo(b.name);
    });
    if (_cachedVoiceName != null) {
      final index = list.indexWhere((voice) => voice.name == _cachedVoiceName);
      if (index > 0) {
        final cached = list.removeAt(index);
        list.insert(0, cached);
      }
    }
    return list;
  }

  int _voiceScore(_SpeechVoice voice) {
    final locale = voice.normalizedLocale;
    if (locale == 'es-es') {
      return voice.name.toLowerCase().contains('spain') ? 0 : 1;
    }
    if (locale == 'es-mx') {
      return 2;
    }
    if (locale.startsWith('es')) {
      return 3;
    }
    return 10;
  }

  Future<RunTtsPlaybackOutcome> _speakWithFallbacks(
    _QueuedUtterance utterance,
    _SpeechVoice startingVoice,
  ) async {
    final attempted = <String>{};
    for (final voice in _voiceCandidates(startingVoice)) {
      final key = '${voice.name}|${voice.locale}';
      if (!attempted.add(key)) {
        continue;
      }
      final success = await _attemptSpeak(utterance, voice);
      if (success) {
        if (_selectedVoice != voice) {
          _selectedVoice = voice;
          _persistVoiceName(voice.name);
          _updateVoiceLabel(voice);
        }
        final outcome = identical(voice, startingVoice)
            ? RunTtsPlaybackOutcome.success
            : RunTtsPlaybackOutcome.fallbackVoice;
        _logTelemetryOnce(outcome);
        return outcome;
      }
    }
    final fallbackOutcome = await _attemptAssetOrToast(utterance);
    _logTelemetryOnce(fallbackOutcome);
    return fallbackOutcome;
  }

  Iterable<_SpeechVoice> _voiceCandidates(_SpeechVoice primary) sync* {
    yield primary;
    for (final voice in _voices) {
      if (!identical(voice, primary)) {
        yield voice;
      }
    }
  }

  Future<bool> _attemptSpeak(
    _QueuedUtterance utterance,
    _SpeechVoice voice, {
    bool isUnlockProbe = false,
  }) async {
    try {
      await _setActiveVoice(voice);
    } on Object {
      return false;
    }

    if (isUnlockProbe) {
      try {
        await _flutterTts.speak('\u200B');
        await Future<void>.delayed(const Duration(milliseconds: 120));
        await _flutterTts.stop();
        return true;
      } on Object {
        return false;
      }
    }

    final completer = Completer<void>();
    _speakCompleter = completer;
    try {
      await _flutterTts.stop();
    } on Object {
      // ignore
    }
    try {
      final speakResult = _flutterTts.speak(utterance.text);
      await speakResult;
    } on Object catch (error) {
      if (!completer.isCompleted) {
        completer.completeError(error);
      }
    }

    try {
      await completer.future.timeout(_kSpeechTimeout);
      _lastSuccessfulUtterance = utterance;
      return true;
    } on TimeoutException {
      _timeoutCount += 1;
      await cancel();
      return false;
    } on Object {
      _errorCount += 1;
      return false;
    } finally {
      if (!completer.isCompleted) {
        completer.complete();
      }
      if (identical(_speakCompleter, completer)) {
        _speakCompleter = null;
      }
    }
  }

  Future<void> _setActiveVoice(_SpeechVoice voice) async {
    await _flutterTts.setVoice(<String, String>{
      'name': voice.name,
      'locale': voice.locale,
    });
    try {
      await _flutterTts.setLanguage(voice.locale);
    } on Object {
      // ignore missing locale mapping
    }
    await _applyConfig(_currentConfig);
  }

  Future<RunTtsPlaybackOutcome> _attemptAssetOrToast(
    _QueuedUtterance utterance,
  ) async {
    final assetOutcome = await _playAssetIfAvailable(utterance);
    if (assetOutcome == RunTtsPlaybackOutcome.audioAsset) {
      return assetOutcome;
    }
    return RunTtsPlaybackOutcome.unavailable;
  }

  Future<RunTtsPlaybackOutcome> _playAssetIfAvailable(
    _QueuedUtterance utterance,
  ) async {
    final itemId = utterance.itemId;
    if (itemId == null || itemId.isEmpty) {
      return RunTtsPlaybackOutcome.unavailable;
    }
    final assetPath = 'assets/audio/spanish/$itemId.mp3';
    if (_assetAvailability[assetPath] == false) {
      return RunTtsPlaybackOutcome.unavailable;
    }
    try {
      await _audioPlayer.stop();
      await _audioPlayer.setAsset(assetPath);
      await _audioPlayer.play();
      _assetAvailability[assetPath] = true;
      return RunTtsPlaybackOutcome.audioAsset;
    } on Object {
      _assetAvailability[assetPath] = false;
      return RunTtsPlaybackOutcome.unavailable;
    }
  }

  void _bindVoiceChangeListener() {
    if (_voiceChangedSubscription != null) {
      return;
    }
    try {
      final stream = html.EventStreamProvider<html.Event>(
        'voiceschanged',
      ).forTarget(html.window);
      _voiceChangedSubscription = stream.listen((_) async {
        _voicesEventObserved = true;
        await _loadVoices();
        if (_queue.isNotEmpty) {
          await _drainQueue();
        }
      });
    } on Object {
      // ignore binding failures
    }
  }

  void _bindVisibilityListener() {
    if (_visibilitySubscription != null) {
      return;
    }
    try {
      _visibilitySubscription = html.document.onVisibilityChange.listen((
        _,
      ) async {
        final hidden = html.document.visibilityState == 'hidden';
        if (hidden) {
          _resumeAfterVisibility = _isSpeaking;
          await cancel();
        } else if (_resumeAfterVisibility && _lastSuccessfulUtterance != null) {
          _resumeAfterVisibility = false;
          _queue.addFirst(_lastSuccessfulUtterance!);
          await _drainQueue();
        }
      });
    } on Object {
      // ignore binding failures
    }
  }

  void _performTelemetryLog(RunTtsPlaybackOutcome outcome) {
    if (_telemetryLogged) {
      return;
    }
    _telemetryLogged = true;
    final voice = _selectedVoice;
    final voiceLabel = voice == null
        ? 'none'
        : '${voice.name} (${voice.locale})';
    final errors = _errorCount;
    final timeouts = _timeoutCount;
    final browser = _describeBrowser();
    debugPrint(
      '[RunTts] browser=$browser voice="$voiceLabel" outcome=$outcome '
      'errors=$errors timeouts=$timeouts',
    );
  }

  void _logTelemetryOnce(RunTtsPlaybackOutcome outcome) {
    _performTelemetryLog(outcome);
  }

  Future<void> _performUnlockIfNeeded() async {
    if (_unlockAttempted || !_initialized || !isSupported) {
      return;
    }
    _unlockAttempted = true;
    if (!_isIosSafari()) {
      return;
    }
    final voice = await _ensureVoiceSelected();
    if (voice == null) {
      return;
    }
    await _attemptSpeak(
      _QueuedUtterance(text: '\u200B'),
      voice,
      isUnlockProbe: true,
    );
  }

  bool _detectSpeechSupport() {
    try {
      return html.window.speechSynthesis != null;
    } on Object {
      return false;
    }
  }

  void _hydrateCachedVoice() {
    try {
      _cachedVoiceName = html.window.localStorage[_kVoiceStorageKey];
    } on Object {
      _cachedVoiceName = null;
    }
  }

  void _persistVoiceName(String name) {
    try {
      html.window.localStorage[_kVoiceStorageKey] = name;
    } on Object {
      // ignore quota/security issues
    }
  }

  void _updateVoiceLabel(_SpeechVoice? voice) {
    final notifier = _ref.read(runTtsVoiceLabelProvider.notifier);
    notifier.state = voice == null ? null : '${voice.name} (${voice.locale})';
  }

  bool _isIosSafari() {
    final ua = html.window.navigator.userAgent.toLowerCase();
    final isiOS =
        ua.contains('iphone') || ua.contains('ipad') || ua.contains('ipod');
    final isSafari =
        ua.contains('safari') &&
        !ua.contains('crios') &&
        !ua.contains('fxios') &&
        !ua.contains('edgios') &&
        !ua.contains('duckduckgo');
    return isiOS && isSafari;
  }

  String _describeBrowser() {
    final ua = html.window.navigator.userAgent;
    if (ua.contains('Edg/')) {
      return 'Edge ${_extractVersion(ua, 'Edg/')}';
    }
    if (ua.contains('CriOS/')) {
      return 'Chrome iOS ${_extractVersion(ua, 'CriOS/')}';
    }
    if (ua.contains('FxiOS/')) {
      return 'Firefox iOS ${_extractVersion(ua, 'FxiOS/')}';
    }
    if (ua.contains('OPR/')) {
      return 'Opera ${_extractVersion(ua, 'OPR/')}';
    }
    if (ua.contains('Chrome/')) {
      return 'Chrome ${_extractVersion(ua, 'Chrome/')}';
    }
    if (ua.contains('Firefox/')) {
      return 'Firefox ${_extractVersion(ua, 'Firefox/')}';
    }
    if (ua.contains('Version/') && ua.contains('Safari/')) {
      return 'Safari ${_extractVersion(ua, 'Version/')}';
    }
    return ua;
  }

  String _extractVersion(String ua, String marker) {
    final index = ua.indexOf(marker);
    if (index == -1) {
      return 'unknown';
    }
    final start = index + marker.length;
    var end = ua.indexOf(' ', start);
    if (end == -1) {
      end = ua.length;
    }
    return ua.substring(start, end);
  }
}

RunTtsService createRunTtsService(Ref ref) {
  return _RunTtsServiceWeb(ref);
}
