import '../auth/app_account_session.dart';
import '../family/family_connection.dart';
import '../profile/child_profile.dart';
import 'timeline_item.dart';

class TimelineCloudSyncPayload {
  const TimelineCloudSyncPayload({
    required this.familyId,
    required this.childId,
    required this.childName,
    required this.authorUserId,
    required this.items,
    required this.canSync,
    required this.blockers,
  });

  final String? familyId;
  final String? childId;
  final String? childName;
  final String? authorUserId;
  final List<Map<String, Object?>> items;
  final bool canSync;
  final List<String> blockers;
}

class TimelineSyncOperationPreview {
  const TimelineSyncOperationPreview({
    required this.title,
    required this.description,
    required this.isReady,
  });

  final String title;
  final String description;
  final bool isReady;
}

class TimelineSyncPlanPreview {
  const TimelineSyncPlanPreview({
    required this.operations,
    required this.isReady,
    required this.summary,
  });

  final List<TimelineSyncOperationPreview> operations;
  final bool isReady;
  final String summary;
}

class TimelineCloudSyncService {
  const TimelineCloudSyncService();

  TimelineCloudSyncPayload buildPayload({
    required AppAccountSession session,
    required FamilyConnectionState familyState,
    required ChildProfile? activeProfile,
    required List<TimelineItem> items,
  }) {
    final blockers = <String>[];

    if (!session.isSignedIn) {
      blockers.add('Chybí přihlášený rodičovský účet.');
    }
    if (familyState.familyId == null || familyState.familyId!.isEmpty) {
      blockers.add('Rodina ještě nemá své ID.');
    }
    if (!familyState.isConnected) {
      blockers.add('Rodina ještě není aktivní pro sdílení.');
    }
    if (activeProfile == null) {
      blockers.add('Chybí aktivní profil dítěte.');
    } else if (activeProfile.familyId != familyState.familyId) {
      blockers.add('Aktivní dítě není navázané na aktuální rodinu.');
    }
    if (items.isEmpty) {
      blockers.add('Není připravený žádný záznam timeline.');
    }

    final payloadItems = items
        .map(
          (item) => <String, Object?>{
            'itemId': item.id,
            'eventType': item.type.name,
            'time': item.time.toIso8601String(),
            'title': item.title,
            'subtitle': item.subtitle,
            'note': item.note,
          },
        )
        .toList();

    return TimelineCloudSyncPayload(
      familyId: familyState.familyId,
      childId: activeProfile?.id,
      childName: activeProfile?.name,
      authorUserId: session.user?.id,
      items: payloadItems,
      canSync: blockers.isEmpty,
      blockers: blockers,
    );
  }

  TimelineSyncPlanPreview buildPlan(TimelineCloudSyncPayload payload) {
    final hasFamily = payload.familyId != null && payload.familyId!.isNotEmpty;
    final hasChild = payload.childId != null && payload.childId!.isNotEmpty;
    final hasAuthor =
        payload.authorUserId != null && payload.authorUserId!.isNotEmpty;
    final hasItems = payload.items.isNotEmpty;

    final operations = <TimelineSyncOperationPreview>[
      TimelineSyncOperationPreview(
        title: '1. Připravit child scope',
        description:
            'Určit rodinu, dítě a autora, pod kterým se budou události zapisovat.',
        isReady: hasFamily && hasChild && hasAuthor,
      ),
      TimelineSyncOperationPreview(
        title: '2. upsert timeline items',
        description:
            'Zapsat jednotlivé události dítěte do sdílené rodinné timeline.',
        isReady: hasFamily && hasChild && hasAuthor && hasItems,
      ),
    ];

    final isReady =
        payload.canSync && operations.every((operation) => operation.isReady);

    final summary = isReady
        ? 'Timeline už má vše potřebné pro první sdílený sync mezi rodiči.'
        : 'Sekvence syncu timeline je připravená, ale ještě jí chybí některé podmínky.';

    return TimelineSyncPlanPreview(
      operations: operations,
      isReady: isReady,
      summary: summary,
    );
  }
}
