enum NumberDrillPhase { loading, running, completed }

class NumberDrillState {
  const NumberDrillState({
    required this.phase,
    required this.gridNumbers,
    required this.clearedNumbers,
    required this.activeNumber,
    required this.completedCount,
    required this.mistakes,
    required this.goal,
    required this.millisecondsElapsed,
    required this.audioBusy,
  });

  factory NumberDrillState.loading({int goal = 5}) {
    return NumberDrillState(
      phase: NumberDrillPhase.loading,
      gridNumbers: const <int>[],
      clearedNumbers: const <int>{},
      activeNumber: null,
      completedCount: 0,
      mistakes: 0,
      goal: goal,
      millisecondsElapsed: 0,
      audioBusy: false,
    );
  }

  factory NumberDrillState.running({
    required List<int> gridNumbers,
    required int goal,
    required int activeNumber,
  }) {
    return NumberDrillState(
      phase: NumberDrillPhase.running,
      gridNumbers: List<int>.unmodifiable(gridNumbers),
      clearedNumbers: <int>{},
      activeNumber: activeNumber,
      completedCount: 0,
      mistakes: 0,
      goal: goal,
      millisecondsElapsed: 0,
      audioBusy: false,
    );
  }

  final NumberDrillPhase phase;
  final List<int> gridNumbers;
  final Set<int> clearedNumbers;
  final int? activeNumber;
  final int completedCount;
  final int mistakes;
  final int goal;
  final int millisecondsElapsed;
  final bool audioBusy;

  bool get isRunning => phase == NumberDrillPhase.running;
  bool get isCompleted => phase == NumberDrillPhase.completed;

  NumberDrillState copyWith({
    NumberDrillPhase? phase,
    List<int>? gridNumbers,
    Set<int>? clearedNumbers,
    bool mergeCleared = false,
    int? activeNumber,
    bool clearActive = false,
    int? completedCount,
    int? mistakes,
    int? goal,
    int? millisecondsElapsed,
    bool? audioBusy,
  }) {
    final mergedCleared = mergeCleared && clearedNumbers != null
        ? {...this.clearedNumbers, ...clearedNumbers}
        : clearedNumbers ?? this.clearedNumbers;
    return NumberDrillState(
      phase: phase ?? this.phase,
      gridNumbers: gridNumbers != null
          ? List<int>.unmodifiable(gridNumbers)
          : this.gridNumbers,
      clearedNumbers: mergedCleared,
      activeNumber: clearActive ? null : (activeNumber ?? this.activeNumber),
      completedCount: completedCount ?? this.completedCount,
      mistakes: mistakes ?? this.mistakes,
      goal: goal ?? this.goal,
      millisecondsElapsed: millisecondsElapsed ?? this.millisecondsElapsed,
      audioBusy: audioBusy ?? this.audioBusy,
    );
  }
}
