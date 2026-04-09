import '../local/event_assignment_store.dart';

class EventAssignmentRepository {
  EventAssignmentRepository(this._store);

  final EventAssignmentStore _store;

  Future<String?> getChildIdForEvent(int eventId) async {
    final assignments = await _store.read();
    return assignments[eventId];
  }

  Future<Map<int, String>> getAllAssignments() => _store.read();

  Future<void> assignEvent(int eventId, String childId) async {
    final assignments = await _store.read();
    assignments[eventId] = childId;
    await _store.write(assignments);
  }

  Future<void> unassignEvent(int eventId) async {
    final assignments = await _store.read();
    assignments.remove(eventId);
    await _store.write(assignments);
  }

  Future<void> removeEvents(Iterable<int> eventIds) async {
    final ids = eventIds.toSet();
    final assignments = await _store.read();
    assignments.removeWhere((key, value) => ids.contains(key));
    await _store.write(assignments);
  }

  Future<void> unassignEventsForChild(String childId) async {
    final assignments = await _store.read();
    assignments.removeWhere((key, value) => value == childId);
    await _store.write(assignments);
  }

  Future<List<int>> getEventIdsForChild(String childId) async {
    final assignments = await _store.read();
    return assignments.entries
        .where((entry) => entry.value == childId)
        .map((entry) => entry.key)
        .toList();
  }

  Future<void> clear() => _store.clear();
}
