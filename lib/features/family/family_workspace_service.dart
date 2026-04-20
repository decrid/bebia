import '../auth/app_account_session.dart';
import '../profile/child_profile.dart';
import 'family_connection.dart';
import 'family_workspace_snapshot.dart';

class FamilyWorkspaceService {
  const FamilyWorkspaceService();

  FamilyWorkspaceSnapshot buildSnapshot({
    required AppAccountSession session,
    required FamilyConnectionState familyState,
    required List<ChildProfile> childProfiles,
  }) {
    final members = <FamilyWorkspaceMember>[
      if (session.isSignedIn)
        FamilyWorkspaceMember(
          id: session.user!.id,
          name: session.user!.displayName,
          roleLabel: 'Vlastník účtu',
          isOwner: true,
        ),
      ...familyState.caregivers.map(
        (caregiver) => FamilyWorkspaceMember(
          id: caregiver.id,
          name: caregiver.name,
          roleLabel: caregiver.role,
          isOwner: caregiver.isOwner,
        ),
      ),
    ];

    final uniqueMembers = <String, FamilyWorkspaceMember>{};
    for (final member in members) {
      uniqueMembers[member.id] = member;
    }

    return FamilyWorkspaceSnapshot(
      familyId: familyState.familyId,
      ownerUserId: session.user?.id,
      ownerDisplayName: session.user?.displayName,
      inviteStatus: familyState.inviteStatus,
      members: uniqueMembers.values.toList(),
      children: childProfiles
          .map(
            (profile) => FamilyWorkspaceChild.fromProfile(
              profile: profile,
              currentFamilyId: familyState.familyId,
            ),
          )
          .toList(),
    );
  }
}
