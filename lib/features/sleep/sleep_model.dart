class SleepRecord {
  final String id;
  final DateTime startTime;
  final DateTime endTime;
  final String? note;

  SleepRecord({
    required this.id,
    required this.startTime,
    required this.endTime,
    this.note,
  });
}