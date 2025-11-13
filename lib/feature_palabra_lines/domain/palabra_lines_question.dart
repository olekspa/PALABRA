/// Difficulty band used to scale quiz questions.
enum PalabraLinesDifficultyTier {
  base,
  intermediate,
  advanced,
}

/// Immutable vocabulary entry sourced from the shared assets.
class PalabraLinesVocabEntry {
  const PalabraLinesVocabEntry({
    required this.id,
    required this.spanish,
    required this.english,
    required this.level,
  });

  final String id;
  final String spanish;
  final String english;
  final String level;
}

/// Quiz question displayed after clearing a line.
class PalabraLinesQuestionState {
  const PalabraLinesQuestionState({
    required this.entry,
    required this.options,
    required this.correctIndex,
    this.wrongAttempts = 0,
  });

  final PalabraLinesVocabEntry entry;
  final List<String> options;
  final int correctIndex;
  final int wrongAttempts;

  PalabraLinesQuestionState markWrongAttempt() {
    return PalabraLinesQuestionState(
      entry: entry,
      options: options,
      correctIndex: correctIndex,
      wrongAttempts: wrongAttempts + 1,
    );
  }
}
