import 'package:isar_community/isar.dart';

part 'timeline_item.g.dart';

enum EventType {
  feeding,
  sleep,
  diaper,
  crying,
}

@collection
class TimelineItem {
  Id id = Isar.autoIncrement;

  @enumerated
  late EventType type;

  late DateTime time;
  late String title;
  late String subtitle;
  String? note;

  // Feeding
  String? feedingType; // breast, bottle
  int? feedingAmountMl;

  // Sleep
  DateTime? sleepStart;
  DateTime? sleepEnd;
  int? sleepDurationMinutes;

  // Diaper
  String? diaperType; // wet, poop, both

  // Crying
  int? cryingIntensity; // 1-5
  int? cryingDurationMinutes;
  String? soothingMethod; // rocking, feeding, carrying, pacifier, other
  bool? cryingResolved;
}