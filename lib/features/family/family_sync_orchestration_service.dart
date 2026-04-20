import 'family_cloud_sync_service.dart';

enum FamilySyncOperationType {
  ensureFamilyExists,
  upsertMembership,
  createInvitation,
}

class FamilySyncOperationPreview {
  const FamilySyncOperationPreview({
    required this.type,
    required this.title,
    required this.description,
    required this.isReady,
  });

  final FamilySyncOperationType type;
  final String title;
  final String description;
  final bool isReady;
}

class FamilySyncPlanPreview {
  const FamilySyncPlanPreview({
    required this.operations,
    required this.isReady,
    required this.summary,
  });

  final List<FamilySyncOperationPreview> operations;
  final bool isReady;
  final String summary;
}

class FamilySyncOrchestrationService {
  const FamilySyncOrchestrationService();

  FamilySyncPlanPreview buildPlan(FamilyCloudSyncPayload payload) {
    final hasFamily = payload.familyDocument['familyId'] != null;
    final hasMembers = payload.memberships.isNotEmpty;
    final hasInvitation = payload.invitation != null;

    final operations = <FamilySyncOperationPreview>[
      FamilySyncOperationPreview(
        type: FamilySyncOperationType.ensureFamilyExists,
        title: '1. ensureFamilyExists',
        description:
            'Založí nebo doplní rodinný dokument s ID, vlastníkem a názvem rodiny.',
        isReady: hasFamily,
      ),
      FamilySyncOperationPreview(
        type: FamilySyncOperationType.upsertMembership,
        title: '2. upsertMembership',
        description:
            'Zapíše všechny členy rodiny a jejich role do kolekce členství.',
        isReady: hasFamily && hasMembers,
      ),
      FamilySyncOperationPreview(
        type: FamilySyncOperationType.createInvitation,
        title: '3. createInvitation',
        description:
            'Vytvoří backendový záznam pozvánky s kódem, autorem a expirací.',
        isReady: hasFamily && hasInvitation,
      ),
    ];

    final ready =
        payload.canSync && operations.every((operation) => operation.isReady);

    final summary = ready
        ? 'Lokální data už mají vše potřebné pro první backendový sync orchestration.'
        : 'Sekvence backend kroků je připravená, ale ještě jí chybí některé vstupy z lokálních dat.';

    return FamilySyncPlanPreview(
      operations: operations,
      isReady: ready,
      summary: summary,
    );
  }
}
