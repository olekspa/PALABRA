import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:palabra/app/app.dart';
import 'package:palabra/data_core/models/number_drill_progress.dart';
import 'package:palabra/data_core/models/user_item_state.dart';
import 'package:palabra/data_core/models/user_meta.dart';
import 'package:palabra/data_core/models/vocab_item.dart';
import 'package:palabra/data_core/repositories/user_meta_repository.dart';
import 'package:palabra/data_core/providers/repository_providers.dart';
import 'package:palabra/feature_gate/application/gate_detection_service.dart';
import 'package:just_audio/just_audio.dart';
import 'package:palabra/feature_numbers/application/number_drill_controller.dart';
import 'package:palabra/feature_numbers/services/number_audio_service.dart';
import 'package:palabra/feature_numbers/services/number_pool_service.dart';
import 'package:palabra/feature_numbers/models/number_drill_models.dart';
import 'package:palabra/feature_run/application/run_controller.dart';
import 'package:palabra/feature_run/application/run_feedback_service.dart';
import 'package:palabra/feature_run/application/run_settings.dart';
import 'package:palabra/feature_run/application/timer_service.dart';
import 'package:palabra/feature_run/presentation/run_screen.dart';
import 'package:palabra/feature_srs/deck_builder/deck_builder_providers.dart';
import 'package:palabra/feature_srs/deck_builder/deck_builder_service.dart';
import 'package:palabra/feature_run/application/tts/run_tts_service.dart'
    as run_tts;
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues(const <String, Object>{});

  testWidgets('Gate → Pre-run → Run → Finish smoke flow (web)', (
    WidgetTester tester,
  ) async {
    final fakeMeta = UserMeta()
      ..preferredRows = 4
      ..timeExtendTokens = 0
      ..rowBlasterCharges = 0;

    final deckItems = List<VocabItem>.generate(
      6,
      (index) => VocabItem(
        itemId: 'deck_$index',
        english: 'English $index',
        spanish: 'Spanish $index',
        level: 'a1',
      ),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          runRowsProvider.overrideWith((ref) => 4),
          runSettingsProvider.overrideWith(
            (ref) => const RunSettings(
              rows: 4,
              targetMatches: 1,
              minTargetMatches: 1,
              runDurationMs: 60000,
              timeExtendDurationMs: 1000,
              maxTimeExtendsPerRun: 0,
              refillBatchSize: 1,
              refillStepDelayMs: 0,
            ),
          ),
          userMetaRepositoryProvider.overrideWithValue(
            _TestUserMetaRepository(fakeMeta),
          ),
          runTimerServiceProvider.overrideWithValue(RunTimerService.fake()),
          runFeedbackServiceProvider.overrideWithValue(
            const _TestRunFeedbackService(),
          ),
          numberPoolServiceProvider.overrideWithValue(
            _StubNumberPoolService(),
          ),
          numberAudioServiceProvider.overrideWithValue(
            _StubNumberAudioService(),
          ),
          deckBuilderServiceProvider.overrideWithValue(
            _StaticDeckBuilderService(deckItems),
          ),
          gateDetectionServiceProvider.overrideWithValue(
            _TestGateDetectionService(
              GateDetectionResult(
                deviceLabel: 'Web Browser',
                isSupportedDevice: true,
                courseId: 'spanish',
              ),
            ),
          ),
        ],
        child: const PalabraApp(),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250));

    // Gate screen → Pre-run.
    expect(find.text('Palabra'), findsOneWidget);
    await tester.tap(find.text('Continue'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250));

    // Pre-run → Run.
    expect(find.text('Ready to run?'), findsOneWidget);
    await tester.ensureVisible(find.text('Start'));
    await tester.tap(find.text('Start'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250));

    // Match the first pair to complete the run.
    expect(find.byType(RunScreen), findsOneWidget);
    final runContext = tester.element(find.byType(RunScreen));
    final container = ProviderScope.containerOf(runContext, listen: false);
    final runState = container.read(runControllerProvider);
    final activeRow = runState.board.firstWhere(
      (row) => row.left.pairId.isNotEmpty,
      orElse: () => throw StateError('No active rows'),
    );
    final pairId = activeRow.left.pairId;
    final englishText = activeRow.left.text;
    final spanishText = runState.board
        .map((row) => row.right)
        .firstWhere((tile) => tile.pairId == pairId)
        .text;

    await tester.tap(find.text(englishText));
    await tester.pump();
    await tester.tap(find.text(spanishText));
    await tester.pump();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // Number drill should appear.
    expect(find.text('Number drill'), findsOneWidget);
    final drillContext = tester.element(find.text('Number drill'));
    final drillContainer = ProviderScope.containerOf(
      drillContext,
      listen: false,
    );

    for (var i = 0; i < 5; i++) {
      final drillState = drillContainer.read(numberDrillControllerProvider);
      final active = drillState.activeNumber;
      expect(active, isNotNull);
      final tileFinder = find.descendant(
        of: find.byType(GridView),
        matching: find.text('${active!}'),
      );
      expect(tileFinder, findsWidgets);
      await tester.tap(tileFinder.first);
      await tester.pump(const Duration(milliseconds: 200));
    }

    await tester.pump(const Duration(milliseconds: 200));
    await tester.pump();
    expect(find.text('Bonus complete!'), findsOneWidget);
    await tester.tap(find.text('Continue'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // Finish screen should be displayed.
    expect(find.text('Goal achieved!'), findsOneWidget);
    expect(find.text('Play again'), findsOneWidget);
    expect(find.text('Exit to gate'), findsOneWidget);
  });
}

class _StaticDeckBuilderService extends DeckBuilderService {
  _StaticDeckBuilderService(this._items)
    : super(
        vocabularyFetcher: (_) async => const <VocabItem>[],
        progressFetcher: (_) async => <String, UserItemState>{},
        userMetaRepository: UserMetaRepository(),
        config: DeckBuilderConfig(deckSize: 6),
      );

  final List<VocabItem> _items;

  @override
  Future<DeckBuildResult> buildDeck() async {
    return DeckBuildResult(
      items: _items,
      freshCount: _items.length,
      troubleCount: 0,
    );
  }
}

class _TestUserMetaRepository extends UserMetaRepository {
  _TestUserMetaRepository(this._meta);

  UserMeta _meta;

  @override
  Future<UserMeta> getOrCreate() async => _meta;

  @override
  Future<void> save(UserMeta meta) async {
    _meta = meta;
  }
}

class _StubNumberPoolService extends NumberPoolService {
  _StubNumberPoolService() : super();

  @override
  NumberDrillSeed buildSeed({
    required NumberDrillProgress progress,
    required String levelId,
  }) {
    return NumberDrillSeed(
      gridNumbers: List<int>.generate(16, (index) => index + 1),
      promptQueue: const <int>[1, 2, 3, 4, 5],
    );
  }
}

class _StubNumberAudioService extends NumberAudioService {
  _StubNumberAudioService()
    : super(
        audioPlayer: AudioPlayer(),
        ttsService: _StubRunTtsService(),
      );

  @override
  Future<bool> play(int value) async => true;

  @override
  Future<void> stop() async {}
}

class _StubRunTtsService extends run_tts.RunTtsService {
  @override
  bool get isSupported => false;

  @override
  Future<void> onUserGesture() async {}

  @override
  Future<run_tts.RunTtsPlaybackOutcome> speak({
    required String text,
    String? itemId,
  }) async {
    return run_tts.RunTtsPlaybackOutcome.audioAsset;
  }

  @override
  Future<void> cancel() async {}

  @override
  void dispose() {}
}

class _TestRunFeedbackService extends RunFeedbackService {
  const _TestRunFeedbackService();

  @override
  Future<void> onMatch({required int tier}) async {}

  @override
  Future<void> onMismatch() async {}

  @override
  Future<void> onTierPause({required int tier}) async {}

  @override
  Future<void> onRunComplete({
    required int tierReached,
    required bool success,
  }) async {}
}

class _TestGateDetectionService extends GateDetectionService {
  _TestGateDetectionService(this._result);

  final GateDetectionResult _result;

  @override
  Future<GateDetectionResult> detect() async => _result;
}
