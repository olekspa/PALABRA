class RunLog {
  DateTime startedAt = DateTime.now();
  DateTime? completedAt;
  int tierReached = 1;
  int rowsUsed = 5;
  int timeExtendsUsed = 0;
  List<DeckLevelCount> deckComposition = <DeckLevelCount>[];
  List<String> learnedPromoted = <String>[];
  List<String> troubleDetected = <String>[];
}

class DeckLevelCount {
  DeckLevelCount({this.level = '', this.count = 0});

  String level;
  int count;
}
