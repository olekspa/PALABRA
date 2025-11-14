import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:palabra/data_core/providers/repository_providers.dart';
import 'package:palabra/feature_palabra_lines/application/palabra_lines_controller.dart';
import 'package:palabra/feature_palabra_lines/application/palabra_lines_sfx_player.dart';
import 'package:palabra/feature_palabra_lines/domain/palabra_lines_game_state.dart';

/// Exposes the Palabra Lines controller with real repositories and assets.
final palabraLinesControllerProvider =
    StateNotifierProvider.autoDispose<
      PalabraLinesController,
      PalabraLinesGameState
    >((ref) {
      final vocabRepository = ref.watch(vocabRepositoryProvider);
      final userMetaRepository = ref.watch(userMetaRepositoryProvider);
      final sfxPlayer = PalabraLinesSfxPlayer();
      return PalabraLinesController(
        vocabRepository: vocabRepository,
        userMetaRepository: userMetaRepository,
        assetBundle: rootBundle,
        sfxPlayer: sfxPlayer,
      );
    });
