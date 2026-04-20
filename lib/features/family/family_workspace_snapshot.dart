import '../profile/child_profile.dart';
import 'family_connection.dart';

class FamilyWorkspaceSnapshot {
  const FamilyWorkspaceSnapshot({
    required this.familyId,
    required this.ownerUserId,
    required this.ownerDisplayName,
    required this.inviteStatus,
    required this.members,
    required this.children,
  });

  final String? familyId;
  final String? ownerUserId;
  final String? ownerDisplayName;
  final FamilyInviteStatus inviteStatus;
  final List<FamilyWorkspaceMember> members;
  final List<FamilyWorkspaceChild> children;

  bool get hasFamily => familyId != null && familyId!.isNotEmpty;
}

class FamilyWorkspaceMember {
  const FamilyWorkspaceMember({
    required this.id,
    required this.name,
    required this.roleLabel,
    required this.isOwner,
  });

  final String id;
  final String name;
  final String roleLabel;
  final bool isOwner;
}

class FamilyWorkspaceChild {
  const FamilyWorkspaceChild({
    required this.id,
    required this.name,
    required this.isLinkedToCurrentFamily,
    required this.linkedFamilyId,
    required this.linkedAt,
  });

  final String id;
  final String name;
  final bool isLinkedToCurrentFamily;
  final String? linkedFamilyId;
  final DateTime? linkedAt;

  factory FamilyWorkspaceChild.fromProfile({
    required ChildProfile profile,
    required String? currentFamilyId,
  }) {
    return FamilyWorkspaceChild(
      id: profile.id,
      name: profile.name,
      isLinkedToCurrentFamily:
          currentFamilyId != null && profile.familyId == currentFamilyId,
      linkedFamilyId: profile.familyId,
      linkedAt: profile.linkedToFamilyAt,
    );
  }
}
