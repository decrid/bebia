import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../features/timeline/timeline_item.dart';
import '../../repositories/remote_timeline_repository.dart';
import 'firestore_family_paths.dart';

class FirestoreTimelineRepository implements RemoteTimelineRepository {
  FirestoreTimelineRepository(this._firestore);

  final FirebaseFirestore _firestore;

  @override
  Future<void> deleteItem({
    required String familyId,
    required int itemId,
    required String authorUserId,
  }) async {
    final eventRef = _firestore
        .collection(FirestoreFamilyPaths.familyEvents(familyId))
        .doc(itemId.toString());

    await eventRef.set({
      'deletedAt': FieldValue.serverTimestamp(),
      'updatedBy': authorUserId,
    }, SetOptions(merge: true));
  }

  @override
  Future<void> upsertItem({
    required String familyId,
    required String childId,
    required TimelineItem item,
    required String authorUserId,
  }) async {
    final eventRef = _firestore
        .collection(FirestoreFamilyPaths.familyEvents(familyId))
        .doc(item.id.toString());

    await eventRef.set({
      'eventId': item.id.toString(),
      'familyId': familyId,
      'childId': childId,
      'type': item.type.name,
      'occurredAt': Timestamp.fromDate(item.time),
      'title': item.title,
      'subtitle': item.subtitle,
      'note': item.note,
      'feedingType': item.feedingType,
      'feedingAmountMl': item.feedingAmountMl,
      'sleepStart': _timestampOrNull(item.sleepStart),
      'sleepEnd': _timestampOrNull(item.sleepEnd),
      'sleepDurationMinutes': item.sleepDurationMinutes,
      'diaperType': item.diaperType,
      'cryingIntensity': item.cryingIntensity,
      'cryingDurationMinutes': item.cryingDurationMinutes,
      'soothingMethod': item.soothingMethod,
      'cryingResolved': item.cryingResolved,
      'cryingSource': item.cryingSource,
      'aiCryProbability': item.aiCryProbability,
      'aiProbableCause': item.aiProbableCause,
      'aiConfidence': item.aiConfidence,
      'aiModelVersion': item.aiModelVersion,
      'aiAnalyzedAt': _timestampOrNull(item.aiAnalyzedAt),
      'audioSamplePath': item.audioSamplePath,
      'aiSignalsSerialized': item.aiSignalsSerialized,
      'aiUserConfirmedCry': item.aiUserConfirmedCry,
      'aiUserConfirmedCause': item.aiUserConfirmedCause,
      'aiUserCorrectedCause': item.aiUserCorrectedCause,
      'updatedBy': authorUserId,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Object? _timestampOrNull(DateTime? value) {
    if (value == null) {
      return null;
    }
    return Timestamp.fromDate(value);
  }
}
