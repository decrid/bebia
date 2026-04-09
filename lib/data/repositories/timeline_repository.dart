import 'package:isar_community/isar.dart';

import '../../features/timeline/timeline_item.dart';
import '../local/isar_service.dart';
import 'event_assignment_repository.dart';

class TimelineRepository {
  TimelineRepository(this._assignments);

  final EventAssignmentRepository _assignments;

  Isar get _isar => IsarService.instance;

  Future<List<TimelineItem>> getAll({String? childId}) async {
    final items = await _isar.timelineItems.where().sortByTimeDesc().findAll();
    return _filterByChild(items, childId);
  }

  Future<void> addItem(TimelineItem item, {String? childId}) async {
    await _isar.writeTxn(() async {
      await _isar.timelineItems.put(item);
    });

    if (childId == null) {
      await _assignments.unassignEvent(item.id);
    } else {
      await _assignments.assignEvent(item.id, childId);
    }
  }

  Future<void> addItems(List<TimelineItem> items, {String? childId}) async {
    await _isar.writeTxn(() async {
      await _isar.timelineItems.putAll(items);
    });

    for (final item in items) {
      if (childId == null) {
        await _assignments.unassignEvent(item.id);
      } else {
        await _assignments.assignEvent(item.id, childId);
      }
    }
  }

  Future<void> deleteItem(int id) async {
    await _isar.writeTxn(() async {
      await _isar.timelineItems.delete(id);
    });
    await _assignments.unassignEvent(id);
  }

  Future<void> deleteItems(Iterable<int> ids) async {
    final idList = ids.toList();
    await _isar.writeTxn(() async {
      await _isar.timelineItems.deleteAll(idList);
    });
    await _assignments.removeEvents(idList);
  }

  Future<void> updateItem(TimelineItem item, {String? fallbackChildId}) async {
    await _isar.writeTxn(() async {
      await _isar.timelineItems.put(item);
    });

    final existingChildId = await _assignments.getChildIdForEvent(item.id);
    final effectiveChildId = existingChildId ?? fallbackChildId;

    if (effectiveChildId == null) {
      await _assignments.unassignEvent(item.id);
    } else {
      await _assignments.assignEvent(item.id, effectiveChildId);
    }
  }

  Future<void> clearAll() async {
    await _isar.writeTxn(() async {
      await _isar.timelineItems.clear();
    });
    await _assignments.clear();
  }

  Future<List<TimelineItem>> getByType(
    EventType type, {
    String? childId,
  }) async {
    final items = await _isar.timelineItems
        .filter()
        .typeEqualTo(type)
        .sortByTimeDesc()
        .findAll();

    return _filterByChild(items, childId);
  }

  Future<List<TimelineItem>> getFiltered(
    EventType? type, {
    String? childId,
  }) async {
    if (type == null) {
      return getAll(childId: childId);
    }

    return getByType(type, childId: childId);
  }

  Future<TimelineItem?> getLastByType(EventType type, {String? childId}) async {
    final items = await getByType(type, childId: childId);
    if (items.isEmpty) return null;
    return items.first;
  }

  Future<void> unassignEventsForChild(String childId) async {
    await _assignments.unassignEventsForChild(childId);
  }

  Future<void> deleteEventsForChild(String childId) async {
    final ids = await _assignments.getEventIdsForChild(childId);
    if (ids.isEmpty) return;
    await deleteItems(ids);
  }

  Future<List<TimelineItem>> _filterByChild(
    List<TimelineItem> items,
    String? childId,
  ) async {
    final assignments = await _assignments.getAllAssignments();

    return items.where((item) {
      final assignedChildId = assignments[item.id];
      if (childId == null) {
        return assignedChildId == null;
      }
      return assignedChildId == childId;
    }).toList();
  }
}
