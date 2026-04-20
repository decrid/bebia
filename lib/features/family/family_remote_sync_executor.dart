import '../../data/repositories/remote_family_repository.dart';
import 'family_cloud_sync_service.dart';
import 'family_sync_orchestration_service.dart';
import 'family_test_sync_service.dart';

class FamilyRemoteSyncExecutionReport {
  const FamilyRemoteSyncExecutionReport({
    required this.wasExecuted,
    required this.isSuccessful,
    required this.summary,
    required this.steps,
  });

  final bool wasExecuted;
  final bool isSuccessful;
  final String summary;
  final List<TestSyncStepResult> steps;
}

class FamilyRemoteSyncExecutor {
  const FamilyRemoteSyncExecutor();

  Future<FamilyRemoteSyncExecutionReport> execute({
    required FamilyCloudSyncPayload payload,
    required FamilySyncPlanPreview plan,
    required bool backendConfigured,
    required RemoteFamilyRepository? remoteRepository,
    bool dryRun = false,
  }) async {
    if (!backendConfigured || remoteRepository == null) {
      return FamilyRemoteSyncExecutionReport(
        wasExecuted: false,
        isSuccessful: false,
        summary:
            'Ostrý backend test nebyl spuštěn, protože Firebase nebo vzdálený repozitář ještě nejsou připravené.',
        steps: [
          TestSyncStepResult(
            title: 'Režim spuštění',
            detail:
                'Aplikace zůstala v kontrolním režimu. Neproběhlo žádné volání do cloudu.',
            status: TestSyncStepStatus.info,
          ),
        ],
      );
    }

    if (!payload.canSync || !plan.isReady) {
      return FamilyRemoteSyncExecutionReport(
        wasExecuted: false,
        isSuccessful: false,
        summary:
            'Ostrý backend test nebyl spuštěn, protože lokální data ještě nejsou připravená pro synchronizaci.',
        steps: [
          TestSyncStepResult(
            title: 'Lokální připravenost',
            detail: [
              ...payload.blockers,
              if (!plan.isReady) plan.summary,
            ].join(' '),
            status: TestSyncStepStatus.blocked,
          ),
        ],
      );
    }

    if (dryRun) {
      return FamilyRemoteSyncExecutionReport(
        wasExecuted: false,
        isSuccessful: true,
        summary:
            'Proběhla pouze kontrolní simulace. Sekvence backend kroků je připravená, ale nic se neodeslalo.',
        steps: const [
          TestSyncStepResult(
            title: 'Kontrolní simulace',
            detail:
                'Všechny vstupy jsou připravené pro backend test, ale zápis do cloudu byl záměrně přeskočen.',
            status: TestSyncStepStatus.info,
          ),
        ],
      );
    }

    final steps = <TestSyncStepResult>[];
    final familyId = payload.familyDocument['familyId'] as String?;
    final ownerUserId = payload.familyDocument['createdBy'] as String?;
    final ownerDisplayName = _readDisplayName(payload);

    if (familyId == null || ownerUserId == null || ownerDisplayName == null) {
      return FamilyRemoteSyncExecutionReport(
        wasExecuted: false,
        isSuccessful: false,
        summary:
            'Ostrý backend test nebyl spuštěn, protože v payloadu chybí identita rodiny nebo vlastníka.',
        steps: const [
          TestSyncStepResult(
            title: 'Payload rodiny',
            detail:
                'Chybí familyId, createdBy nebo název vlastníka potřebný pro založení rodiny v backendu.',
            status: TestSyncStepStatus.blocked,
          ),
        ],
      );
    }

    try {
      await remoteRepository.ensureFamilyExists(
        familyId: familyId,
        ownerUserId: ownerUserId,
        ownerDisplayName: ownerDisplayName,
      );
      steps.add(
        const TestSyncStepResult(
          title: 'ensureFamilyExists',
          detail: 'Rodinný dokument byl úspěšně ověřen nebo založen.',
          status: TestSyncStepStatus.ready,
        ),
      );
    } catch (error) {
      steps.add(
        TestSyncStepResult(
          title: 'ensureFamilyExists',
          detail: 'Zápis rodiny selhal: $error',
          status: TestSyncStepStatus.blocked,
        ),
      );
      return _failedReport(
        steps: steps,
        summary:
            'Backend test skončil při zakládání rodiny. Další kroky se už nespouštěly.',
      );
    }

    for (final membership in payload.memberships) {
      try {
        await remoteRepository.upsertMembership(membership);
        steps.add(
          TestSyncStepResult(
            title: 'upsertMembership ${membership.userId}',
            detail:
                'Člen ${membership.userId} byl zapsán s rolí ${membership.role.name}.',
            status: TestSyncStepStatus.ready,
          ),
        );
      } catch (error) {
        steps.add(
          TestSyncStepResult(
            title: 'upsertMembership ${membership.userId}',
            detail: 'Zápis člena selhal: $error',
            status: TestSyncStepStatus.blocked,
          ),
        );
        return _failedReport(
          steps: steps,
          summary:
              'Backend test skončil při zápisu členů rodiny. Pozvánka se už nevytvářela.',
        );
      }
    }

    if (payload.invitation != null) {
      try {
        final invitation = payload.invitation!;
        await remoteRepository.createInvitation(
          familyId: invitation.familyId,
          createdBy: invitation.createdBy,
          code: invitation.code,
          createdAt: invitation.createdAt,
          expiresAt: invitation.expiresAt,
        );
        steps.add(
          TestSyncStepResult(
            title: 'createInvitation ${invitation.code}',
            detail: 'Pozvánka byla zapsána do backendu.',
            status: TestSyncStepStatus.ready,
          ),
        );
      } catch (error) {
        steps.add(
          TestSyncStepResult(
            title: 'createInvitation ${payload.invitation!.code}',
            detail: 'Zápis pozvánky selhal: $error',
            status: TestSyncStepStatus.blocked,
          ),
        );
        return _failedReport(
          steps: steps,
          summary:
              'Backend test vytvořil rodinu i členy, ale selhal při zápisu pozvánky.',
        );
      }
    } else {
      steps.add(
        const TestSyncStepResult(
          title: 'createInvitation',
          detail:
              'Pozvánka momentálně v payloadu není, takže tento krok byl korektně přeskočen.',
          status: TestSyncStepStatus.info,
        ),
      );
    }

    return FamilyRemoteSyncExecutionReport(
      wasExecuted: true,
      isSuccessful: true,
      summary:
          'Backend test proběhl úspěšně. Rodina, členové i případná pozvánka se podařilo zapsat do remote vrstvy.',
      steps: steps,
    );
  }

  FamilyRemoteSyncExecutionReport _failedReport({
    required List<TestSyncStepResult> steps,
    required String summary,
  }) {
    return FamilyRemoteSyncExecutionReport(
      wasExecuted: true,
      isSuccessful: false,
      summary: summary,
      steps: steps,
    );
  }

  String? _readDisplayName(FamilyCloudSyncPayload payload) {
    final rawName = payload.familyDocument['name'] as String?;
    if (rawName == null || rawName.isEmpty) {
      return null;
    }

    if (rawName.startsWith('Rodina ')) {
      return rawName.substring('Rodina '.length);
    }
    return rawName;
  }
}
