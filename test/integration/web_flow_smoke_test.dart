import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:palabra/app/app.dart';
import 'package:palabra/data_core/models/user_item_state.dart';
import 'package:palabra/data_core/models/user_meta.dart';
import 'package:palabra/data_core/models/vocab_item.dart';
import 'package:palabra/data_core/repositories/user_meta_repository.dart';
import 'package:palabra/data_core/providers/repository_providers.dart';
import 'package:palabra/feature_run/application/run_controller.dart';
import 'package:palabra/feature_run/application/run_settings.dart';
import 'package:palabra/feature_run/application/timer_service.dart';
import 'package:palabra/feature_run/presentation/run_screen.dart';
import 'package:palabra/feature_srs/deck_builder/deck_builder_providers.dart';
import 'package:palabra/feature_srs/deck_builder/deck_builder_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues(const <String, Object?>{});

  testWidgets('Gate → Pre-run → Run → Finish smoke flow (web)',
      (WidgetTester tester) async {
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
          runRowsProvider.overrideWith((ref) => StateController<int>(4)),
          runSettingsProvider.overrideWith(
            (ref) => const RunSettings(
              rows: 4,
              targetMatches: 1,
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
          deckBuilderServiceProvider.overrideWithValue(
            _StaticDeckBuilderService(deckItems),
          ),
        ],
        child: const PalabraApp(),
      ),
    );

    await tester.pumpAndSettle();

    // Gate screen → Pre-run.
    expect(find.text('Palabra'), findsOneWidget);
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    // Pre-run → Run.
    expect(find.text('Ready to run?'), findsOneWidget);
    await tester.tap(find.text('Start'));
    await tester.pumpAndSettle();

    // Match the first pair to complete the run.
    expect(find.byType(RunScreen), findsOneWidget);
    final runContext = tester.element(find.byType(RunScreen));
    final container = ProviderScope.containerOf(runContext, listen: false);
    final runState = container.read(runControllerProvider);
    final activeRow = runState.board
        .firstWhere(
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
    await tester.pumpAndSettle();

    // Finish screen should be displayed.
    expect(find.text('Nice work!'), findsOneWidget);
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
