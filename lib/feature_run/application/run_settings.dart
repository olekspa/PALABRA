// ignore_for_file: public_member_api_docs

class RunSettings {
  const RunSettings({
    this.rows = 5,
    this.targetMatches = 90,
    this.runDurationMs = 105000,
  });

  final int rows;
  final int targetMatches;
  final int runDurationMs;
}
