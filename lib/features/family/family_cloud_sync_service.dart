import '../../data/repositories/remote_family_repository.dart';
import '../auth/app_account_session.dart';
import 'family_account_membership.dart';
import 'family_connection.dart';
import 'family_workspace_snapshot.dart';

class FamilyCloudSyncPayload {
  const FamilyCloudSyncPayload({
    required this.familyDocument,
    required this.memberships,
    required this.children,
    required this.invitation,
    required this.canSync,
    required this.blockers,
  });

  final Map<String, Object?> familyDocument;
  final List<FamilyAccountMembership> memberships;
  final List<Map<String, Object?>> children;
  final FamilyInvitationDraft? invitation;
  final bool canSync;
  final List<String> blockers;
}

class FamilyCloudSyncService {
  const FamilyCloudSyncService();

  FamilyCloudSyncPayload buildPayload({
    required AppAccountSession session,
    required FamilyConnectionState familyState,
    required FamilyWorkspaceSnapshot workspace,
  }) {
    final blockers = <String>[];

    if (!session.isSignedIn) {
      blockers.add('Chybí přihlášený rodičovský účet.');
    }
    if (!workspace.hasFamily) {
      blockers.add('Rodina ještě nemá své ID.');
    }
    if (workspace.children
        .where((child) => child.isLinkedToCurrentFamily)
        .isEmpty) {
      blockers.add('Do aktuální rodiny ještě není přidané žádné dítě.');
    }

    final familyId = workspace.familyId ?? 'family-preview';
    final ownerUserId = workspace.ownerUserId ?? 'preview-owner';
    final ownerDisplayName = workspace.ownerDisplayName ?? 'Rodič';

    final memberships = workspace.members.map((member) {
      final role = member.isOwner
          ? FamilyMemberRole.owner
          : member.roleLabel.toLowerCase().contains('peč')
          ? FamilyMemberRole.caregiver
          : FamilyMemberRole.parent;

      final status = switch (workspace.inviteStatus) {
        FamilyInviteStatus.none => FamilyMemberStatus.invited,
        FamilyInviteStatus.draft => FamilyMemberStatus.invited,
        FamilyInviteStatus.waitingForAcceptance =>
          member.isOwner
              ? FamilyMemberStatus.active
              : FamilyMemberStatus.invited,
        FamilyInviteStatus.accepted => FamilyMemberStatus.active,
        FamilyInviteStatus.connected => FamilyMemberStatus.active,
      };

      return FamilyAccountMembership(
        familyId: familyId,
        userId: member.id,
        role: role,
        status: status,
      );
    }).toList();

    final linkedChildren = workspace.children
        .where((child) => child.isLinkedToCurrentFamily)
        .map(
          (child) => <String, Object?>{
            'childId': child.id,
            'familyId': familyId,
            'name': child.name,
            'linkedAt': child.linkedAt?.toIso8601String(),
          },
        )
        .toList();

    final invitation = familyState.hasInvite
        ? FamilyInvitationDraft(
            familyId: familyId,
            code: familyState.inviteCode!,
            createdBy: ownerUserId,
            createdAt: familyState.inviteCreatedAt ?? DateTime.now(),
            expiresAt: (familyState.inviteCreatedAt ?? DateTime.now()).add(
              const Duration(days: 7),
            ),
          )
        : null;

    return FamilyCloudSyncPayload(
      familyDocument: {
        'familyId': familyId,
        'createdBy': ownerUserId,
        'name': 'Rodina $ownerDisplayName',
        'inviteStatus': workspace.inviteStatus.name,
        'memberCount': memberships.length,
        'childCount': linkedChildren.length,
      },
      memberships: memberships,
      children: linkedChildren,
      invitation: invitation,
      canSync: blockers.isEmpty,
      blockers: blockers,
    );
  }
}
