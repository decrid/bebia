import 'family_cloud_sync_service.dart';
import 'family_sync_orchestration_service.dart';
import '../timeline/timeline_cloud_sync_service.dart';

enum TestSyncStepStatus { ready, blocked, info }

class TestSyncStepResult {
  const TestSyncStepResult({
    required this.title,
    required this.detail,
    required this.status,
  });

  final String title;
  final String detail;
  final TestSyncStepStatus status;
}

class FamilyTestSyncReport {
  const FamilyTestSyncReport({
    required this.isReady,
    required this.summary,
    required this.steps,
  });

  final bool isReady;
  final String summary;
  final List<TestSyncStepResult> steps;
}

class FamilyTestSyncService {
  const FamilyTestSyncService();

  FamilyTestSyncReport buildReport({
    required FamilyCloudSyncPayload familyPayload,
    required FamilySyncPlanPreview familyPlan,
    required TimelineCloudSyncPayload timelinePayload,
    required TimelineSyncPlanPreview timelinePlan,
    required bool backendConfigured,
    required bool hasRemoteFamilyRepository,
    required bool hasRemoteTimelineRepository,
  }) {
    final steps = <TestSyncStepResult>[
      TestSyncStepResult(
        title: 'Rodinný payload',
        detail: familyPayload.canSync
            ? 'Rodina, členové i pozvánka jsou připravené pro sync.'
            : familyPayload.blockers.join(' '),
        status: familyPayload.canSync
            ? TestSyncStepStatus.ready
            : TestSyncStepStatus.blocked,
      ),
      TestSyncStepResult(
        title: 'Rodinná orchestrace',
        detail: familyPlan.summary,
        status: familyPlan.isReady
            ? TestSyncStepStatus.ready
            : TestSyncStepStatus.blocked,
      ),
      TestSyncStepResult(
        title: 'Timeline payload',
        detail: timelinePayload.canSync
            ? 'Aktivní dítě a jeho události jsou připravené pro sdílenou timeline.'
            : timelinePayload.blockers.join(' '),
        status: timelinePayload.canSync
            ? TestSyncStepStatus.ready
            : TestSyncStepStatus.blocked,
      ),
      TestSyncStepResult(
        title: 'Timeline orchestrace',
        detail: timelinePlan.summary,
        status: timelinePlan.isReady
            ? TestSyncStepStatus.ready
            : TestSyncStepStatus.blocked,
      ),
      TestSyncStepResult(
        title: 'Backend připravenost',
        detail: backendConfigured
            ? 'Firebase bootstrap je připravený pro další integraci.'
            : 'Firebase ještě není plně dopojený, takže sync zůstává v preview režimu.',
        status: backendConfigured
            ? TestSyncStepStatus.ready
            : TestSyncStepStatus.info,
      ),
      TestSyncStepResult(
        title: 'Remote repozitáře',
        detail: hasRemoteFamilyRepository && hasRemoteTimelineRepository
            ? 'RemoteFamilyRepository i RemoteTimelineRepository jsou dostupné.'
            : 'Některý z remote repozitářů zatím není dostupný pro ostré volání.',
        status: hasRemoteFamilyRepository && hasRemoteTimelineRepository
            ? TestSyncStepStatus.ready
            : TestSyncStepStatus.info,
      ),
    ];

    final isReady =
        familyPayload.canSync &&
        familyPlan.isReady &&
        timelinePayload.canSync &&
        timelinePlan.isReady &&
        backendConfigured &&
        hasRemoteFamilyRepository &&
        hasRemoteTimelineRepository;

    final summary = isReady
        ? 'Test sync prošel. Bebia má všechny klíčové vstupy připravené pro první ostrou backendovou integraci.'
        : 'Test sync odhalil, že architektura je připravená, ale před ostrým syncem ještě chybí některé podmínky nebo backendové napojení.';

    return FamilyTestSyncReport(
      isReady: isReady,
      summary: summary,
      steps: steps,
    );
  }
}
