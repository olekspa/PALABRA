// Lightweight stub used for platforms without web speech support.
// ignore_for_file: public_member_api_docs

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:palabra/feature_run/application/tts/run_tts_service.dart';

class _NoopRunTtsService implements RunTtsService {
  @override
  bool get isSupported => false;

  @override
  Future<void> cancel() async {}

  @override
  void dispose() {}

  @override
  Future<void> onUserGesture() async {}

  @override
  Future<RunTtsPlaybackOutcome> speak({
    required String text,
    String? itemId,
  }) async {
    return RunTtsPlaybackOutcome.unavailable;
  }
}

RunTtsService createRunTtsService(Ref ref) {
  return _NoopRunTtsService();
}
