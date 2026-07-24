import 'package:isar_community/isar.dart';

import '../../features/timeline/timeline_item.dart';
import '../local/isar_service.dart';
import 'event_assignment_repository.dart';

class TimelineRepository {
  TimelineRepository(this._assignments);

  final EventAssignmentRepository _assignments;
  Future<void> Function()? _mutationObserver;

  Isar get _isar => IsarService.instance;

  void setMutationObserver(Future<void> Function() observer) {
    _mutationObserver = observer;
  }

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
    await _notifyMutation();
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
    await _notifyMutation();
  }

  Future<void> deleteItem(int id) async {
    await _isar.writeTxn(() async {
      await _isar.timelineItems.delete(id);
    });
    await _assignments.unassignEvent(id);
    await _notifyMutation();
  }

  Future<void> deleteItems(Iterable<int> ids) async {
    final idList = ids.toList();
    await _isar.writeTxn(() async {
      await _isar.timelineItems.deleteAll(idList);
    });
    await _assignments.removeEvents(idList);
    await _notifyMutation();
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
    await _notifyMutation();
  }

  Future<void> clearAll() async {
    await _isar.writeTxn(() async {
      await _isar.timelineItems.clear();
    });
    await _assignments.clear();
    await _notifyMutation();
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
    await _notifyMutation();
  }

  Future<void> assignUnassignedEventsToChild(String childId) async {
    final items = await _isar.timelineItems.where().findAll();
    final assignments = await _assignments.getAllAssignments();
    final nextAssignments = Map<int, String>.from(assignments);
    var changed = false;

    for (final item in items) {
      if (!nextAssignments.containsKey(item.id)) {
        nextAssignments[item.id] = childId;
        changed = true;
      }
    }

    if (!changed) return;
    await _assignments.replaceAll(nextAssignments);
    await _notifyMutation();
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

  Future<void> _notifyMutation() async {
    final observer = _mutationObserver;
    if (observer == null) return;
    try {
      await observer();
    } on Object {
      // Widget data is derived and must never make a database write fail.
    }
  }
}
