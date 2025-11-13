import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:palabra/feature_games/data/game_catalog.dart';
import 'package:palabra/feature_games/data/listening_drill_models.dart';

/// Registry of mini-game metadata and associated hooks.
class GameRegistryEntry {
  GameRegistryEntry({
    required this.descriptor,
    this.listeningDrillProgress,
  });

  final GameDescriptor descriptor;
  final ListeningDrillProgress? listeningDrillProgress;
}

/// Provides a list of registered games with their current progress state.
final gameRegistryProvider = Provider<List<GameRegistryEntry>>((ref) {
  // Word Match uses existing run/number drill infrastructure so it only needs
  // the descriptor for now. Listening drill progress will be wired once the
  // feature lands.
  return kGameCatalog
      .map(
        (descriptor) => GameRegistryEntry(
          descriptor: descriptor,
          listeningDrillProgress: descriptor.id == null
              ? ListeningDrillProgress()
              : null,
        ),
      )
      .toList(growable: false);
});
