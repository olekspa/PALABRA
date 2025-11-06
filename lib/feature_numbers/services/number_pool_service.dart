import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:palabra/data_core/models/number_drill_progress.dart';
import 'package:palabra/feature_numbers/models/number_drill_models.dart';

final numberPoolServiceProvider = Provider<NumberPoolService>((_) {
  return NumberPoolService();
});

/// Builds number grids and prompt queues for the bonus drill.
class NumberPoolService {
  NumberPoolService({
    NumberDrillConfig config = const NumberDrillConfig(),
    Random? random,
  }) : _config = config,
       _random = random ?? Random();

  final NumberDrillConfig _config;
  final Random _random;

  NumberDrillSeed buildSeed({
    required NumberDrillProgress progress,
    required String levelId,
  }) {
    final maxNumber = _config.resolveMaxNumber(
      progress: progress,
      levelId: levelId,
    );
    final gridNumbers = _buildGridNumbers(progress, maxNumber);
    final promptQueue = _buildPromptQueue(progress, gridNumbers);
    return NumberDrillSeed(
      gridNumbers: gridNumbers,
      promptQueue: promptQueue,
    );
  }

  List<int> _buildGridNumbers(
    NumberDrillProgress progress,
    int maxNumber,
  ) {
    final selected = <int>{};
    final troubleNumbers =
        progress.mistakeCounts.entries
            .where((entry) => entry.key <= maxNumber)
            .toList()
          ..sort((a, b) => b.value.compareTo(a.value));
    for (final entry in troubleNumbers.take(4)) {
      selected.add(entry.key);
      if (selected.length == _config.numbersPerGrid) {
        break;
      }
    }

    var attempts = 0;
    while (selected.length < _config.numbersPerGrid && attempts < 2000) {
      final candidate =
          _random.nextInt(
            maxNumber - _config.minNumber + 1,
          ) +
          _config.minNumber;
      if (selected.contains(candidate)) {
        attempts += 1;
        continue;
      }
      final preferUnmastered =
          selected.length < (_config.numbersPerGrid * 0.75);
      final isMastered = progress.masteredNumbers.contains(candidate);
      if (preferUnmastered && isMastered && _random.nextDouble() < 0.7) {
        attempts += 1;
        continue;
      }
      selected.add(candidate);
    }

    final grid = selected.toList()..shuffle(_random);
    if (grid.length < _config.numbersPerGrid) {
      for (
        var i = 1;
        i <= _config.numbersPerGrid && grid.length < _config.numbersPerGrid;
        i++
      ) {
        if (!grid.contains(i)) {
          grid.add(i);
        }
      }
    }
    return grid;
  }

  List<int> _buildPromptQueue(
    NumberDrillProgress progress,
    List<int> grid,
  ) {
    final weighted = List<int>.from(grid)
      ..sort(
        (a, b) =>
            _promptWeight(progress, b).compareTo(_promptWeight(progress, a)),
      );
    final chosen = weighted.take(_config.roundGoal).toList();
    chosen.shuffle(_random);
    return chosen;
  }

  double _promptWeight(NumberDrillProgress progress, int value) {
    final mistakes = (progress.mistakeCounts[value] ?? 0).toDouble();
    final mastered = progress.masteredNumbers.contains(value) ? 0.0 : 1.0;
    return mistakes * 10 + mastered * 5 + _random.nextDouble();
  }
}
