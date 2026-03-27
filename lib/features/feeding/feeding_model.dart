class FeedingRecord {
  final String id;
  final DateTime time;
  final String type; // breast / bottle
  final int? amountMl;
  final String? note;

  FeedingRecord({
    required this.id,
    required this.time,
    required this.type,
    this.amountMl,
    this.note,
  });
}