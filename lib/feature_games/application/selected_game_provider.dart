import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:palabra/feature_games/data/game_catalog.dart';

/// Tracks which game the player last selected. Defaults to Word Match.
final selectedGameProvider = StateProvider<GameId>((ref) {
  return GameId.wordMatch;
});
