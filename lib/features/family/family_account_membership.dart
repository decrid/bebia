enum FamilyMemberRole { owner, parent, caregiver }

enum FamilyMemberStatus { invited, active, removed }

class FamilyAccountMembership {
  const FamilyAccountMembership({
    required this.familyId,
    required this.userId,
    required this.role,
    required this.status,
  });

  final String familyId;
  final String userId;
  final FamilyMemberRole role;
  final FamilyMemberStatus status;
}
