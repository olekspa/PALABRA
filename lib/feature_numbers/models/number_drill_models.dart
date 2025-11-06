import 'dart:math';

import 'package:palabra/data_core/models/number_drill_progress.dart';

/// Static configuration for the number drill mini-game.
class NumberDrillConfig {
  const NumberDrillConfig({
    this.gridSize = 4,
    this.roundGoal = 5,
    this.numbersPerGrid = 16,
    this.minNumber = 1,
    this.maxNumber = 100,
    this.assetRoot = 'assets/audio/spanish_numbers',
    this.difficultyBuckets = const [20, 35, 50, 70, 85, 100],
  }) : assert(gridSize * gridSize == numbersPerGrid);

  final int gridSize;
  final int roundGoal;
  final int numbersPerGrid;
  final int minNumber;
  final int maxNumber;
  final String assetRoot;
  final List<int> difficultyBuckets;

  /// Returns an appropriate max number based on stored progress and level.
  int resolveMaxNumber({
    required NumberDrillProgress progress,
    required String levelId,
  }) {
    final levelIndex = _levelIndex(levelId);
    final bucketIndex = min(
      difficultyBuckets.length - 1,
      progress.drillsCompleted ~/ 5,
    );
    final baseBucket = difficultyBuckets[bucketIndex];
    final levelBonus = levelIndex * 10;
    final unlockedClamp = max(progress.highestNumberUnlocked, minNumber);
    return min(maxNumber, max(baseBucket + levelBonus, unlockedClamp));
  }

  /// Builds the asset path for a given numeric value.
  String assetFor(int value) {
    final normalized = value.clamp(minNumber, maxNumber);
    final suffix = normalized.toString().padLeft(3, '0');
    return '$assetRoot/num_$suffix.mp3';
  }

  int _levelIndex(String levelId) {
    switch (levelId.toLowerCase()) {
      case 'a2':
        return 1;
      case 'b1':
        return 2;
      case 'b2':
        return 3;
      default:
        return 0;
    }
  }
}

/// Seed data used to start a drill round (grid + prompt queue).
class NumberDrillSeed {
  NumberDrillSeed({
    required this.gridNumbers,
    required this.promptQueue,
  }) : assert(gridNumbers.length == 16),
       assert(promptQueue.isNotEmpty);

  final List<int> gridNumbers;
  final List<int> promptQueue;
}
