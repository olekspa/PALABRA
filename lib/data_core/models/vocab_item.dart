class VocabItem {
  VocabItem({
    this.itemId = '',
    this.english = '',
    this.spanish = '',
    this.level = '',
    this.family,
    this.topic,
  });

  String itemId;
  String english;
  String spanish;
  String level;
  String? family;
  String? topic;
}
