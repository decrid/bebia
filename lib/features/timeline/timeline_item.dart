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
}