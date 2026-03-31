import 'package:isar_community/isar.dart';

import '../../features/timeline/timeline_item.dart';
import '../local/isar_service.dart';

class TimelineRepository {
  Isar get _isar => IsarService.instance;

  Future<List<TimelineItem>> getAll() async {
    final items = await _isar.timelineItems.where().sortByTimeDesc().findAll();
    return items;
  }

  Future<void> addItem(TimelineItem item) async {
    await _isar.writeTxn(() async {
      await _isar.timelineItems.put(item);
    });
  }

  Future<void> addItems(List<TimelineItem> items) async {
    await _isar.writeTxn(() async {
      await _isar.timelineItems.putAll(items);
    });
  }

  Future<void> deleteItem(int id) async {
    await _isar.writeTxn(() async {
      await _isar.timelineItems.delete(id);
    });
  }

  Future<void> updateItem(TimelineItem item) async {
    await _isar.writeTxn(() async {
      await _isar.timelineItems.put(item);
    });
  }

  Future<void> clearAll() async {
    await _isar.writeTxn(() async {
      await _isar.timelineItems.clear();
    });
  }

  Future<List<TimelineItem>> getByType(EventType type) async {
    return _isar.timelineItems
        .filter()
        .typeEqualTo(type)
        .sortByTimeDesc()
        .findAll();
  }

  Future<List<TimelineItem>> getFiltered(EventType? type) async {
    if (type == null) {
      return getAll();
    }

    return getByType(type);
  }

  Future<TimelineItem?> getLastByType(EventType type) async {
    return _isar.timelineItems
        .filter()
        .typeEqualTo(type)
        .sortByTimeDesc()
        .findFirst();
  }
}