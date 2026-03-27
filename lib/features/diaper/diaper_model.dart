class DiaperRecord {
  final String id;
  final DateTime time;
  final String type; // wet / poop / both
  final String? note;

  DiaperRecord({
    required this.id,
    required this.time,
    required this.type,
    this.note,
  });
}