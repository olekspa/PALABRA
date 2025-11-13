/// Placeholder content models for the future listening drill mini-game.
class ListeningDrillPrompt {
  ListeningDrillPrompt({
    required this.id,
    required this.audioAsset,
    required this.correctAnswer,
    required this.distractors,
  });

  final String id;
  final String audioAsset;
  final String correctAnswer;
  final List<String> distractors;
}

/// Tracks per-profile progress for listening drills (stub for future work).
class ListeningDrillProgress {
  ListeningDrillProgress({
    this.sessionsCompleted = 0,
    this.masteredPromptIds = const <String>{},
  });

  final int sessionsCompleted;
  final Set<String> masteredPromptIds;
}
