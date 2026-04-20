import '../../features/timeline/timeline_item.dart';

abstract class RemoteTimelineRepository {
  Future<void> upsertItem({
    required String familyId,
    required String childId,
    required TimelineItem item,
    required String authorUserId,
  });

  Future<void> deleteItem({
    required String familyId,
    required int itemId,
    required String authorUserId,
  });
}
