import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:palabra/data_core/data_core.dart';
import 'package:palabra/feature_srs/deck_builder/deck_builder_service.dart';

/// Provides a [DeckBuilderService] wired to the local repositories.
final deckBuilderServiceProvider = Provider<DeckBuilderService>((ref) {
  final vocabRepo = ref.watch(vocabRepositoryProvider);
  final progressRepo = ref.watch(userProgressRepositoryProvider);
  final userMetaRepo = ref.watch(userMetaRepositoryProvider);

  return DeckBuilderService(
    vocabularyFetcher: vocabRepo.getByLevel,
    progressFetcher: (itemIds) async {
      final states = await progressRepo.getStates(itemIds);
      return {for (final state in states) state.itemId: state};
    },
    userMetaRepository: userMetaRepo,
  );
});
