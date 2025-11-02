import 'package:flutter_test/flutter_test.dart';
import 'package:palabra/data_core/models/user_item_state.dart';
import 'package:palabra/data_core/models/user_meta.dart';
import 'package:palabra/data_core/models/vocab_item.dart';
import 'package:palabra/data_core/repositories/user_meta_repository.dart';
import 'package:palabra/feature_srs/deck_builder/deck_builder_service.dart';

DeckVocabularyFetcher vocabularyFetcher(Map<String, List<VocabItem>> data) {
  return (level) async =>
      List<VocabItem>.from(data[level] ?? const <VocabItem>[]);
}

DeckProgressFetcher progressFetcher(Map<String, UserItemState> states) {
  return (itemIds) async {
    final result = <String, UserItemState>{};
    for (final id in itemIds) {
      final state = states[id];
      if (state != null) {
        result[id] = state;
      }
    }
    return result;
  };
}

class _MemoryUserMetaRepository implements UserMetaRepository {
  _MemoryUserMetaRepository(this._meta);

  UserMeta _meta;

  @override
  Future<UserMeta> getOrCreate() async => _meta;

  @override
  Future<void> save(UserMeta meta) async {
    _meta = meta;
  }
}

UserItemState _state({
  String itemId = '',
  int seenCount = 0,
  int correctStreak = 0,
  int wrongCount = 0,
}) {
  final state = UserItemState()
    ..itemId = itemId
    ..seenCount = seenCount
    ..correctStreak = correctStreak
    ..wrongCount = wrongCount;
  return state;
}

VocabItem _item(String id, String level, {String family = ''}) {
  return VocabItem()
    ..itemId = id
    ..english = '$id-en'
    ..spanish = '$id-es'
    ..level = level
    ..family = family
    ..topic = 'test';
}

void main() {
  test('prioritizes trouble items and respects fresh cap', () async {
    final items = <String, List<VocabItem>>{
      'a1': List.generate(30, (index) {
        final id = 'a1_${(index + 1).toString().padLeft(4, '0')}';
        return _item(id, 'a1');
      }),
      'a2': List.generate(30, (index) {
        final id = 'a2_${(index + 1).toString().padLeft(4, '0')}';
        return _item(id, 'a2');
      }),
    };

    final states = <String, UserItemState>{
      for (var i = 0; i < 20; i++)
        'a1_${(i + 1).toString().padLeft(4, '0')}': _state(
          itemId: 'a1_${(i + 1).toString().padLeft(4, '0')}',
          seenCount: 5,
        ),
      for (var i = 0; i < 10; i++)
        'a2_${(i + 1).toString().padLeft(4, '0')}': _state(
          itemId: 'a2_${(i + 1).toString().padLeft(4, '0')}',
          seenCount: 3,
        ),
      'a1_0001': _state(itemId: 'a1_0001', seenCount: 5, wrongCount: 2),
      'a1_0003': _state(itemId: 'a1_0003', seenCount: 10, correctStreak: 3),
    };

    final service = DeckBuilderService(
      vocabularyFetcher: vocabularyFetcher(items),
      progressFetcher: progressFetcher(states),
      userMetaRepository: _MemoryUserMetaRepository(UserMeta()),
      config: const DeckBuilderConfig(deckSize: 40),
    );

    final result = await service.buildDeck();
    expect(result.items.length, 40);
    expect(result.troubleCount, greaterThan(0));
    expect(result.freshCount, lessThanOrEqualTo(8));
  });

  test('falls back to learned items when insufficient supply', () async {
    final items = <String, List<VocabItem>>{
      'a1': [
        _item('a1_0001', 'a1', family: 'fam'),
        _item('a1_0002', 'a1', family: 'fam'),
      ],
    };
    final states = <String, UserItemState>{
      'a1_0001': _state(itemId: 'a1_0001', seenCount: 10, correctStreak: 3),
      'a1_0002': _state(itemId: 'a1_0002', wrongCount: 1),
    };

    final service = DeckBuilderService(
      vocabularyFetcher: vocabularyFetcher(items),
      progressFetcher: progressFetcher(states),
      userMetaRepository: _MemoryUserMetaRepository(UserMeta()),
      config: const DeckBuilderConfig(deckSize: 5),
    );

    final result = await service.buildDeck();
    expect(result.items, isNotEmpty);
    // Since only one non-learned family exists, duplicates should appear.
    final families = result.items.map((item) => item.family).toSet();
    expect(families.length, lessThan(result.items.length));
  });
}
