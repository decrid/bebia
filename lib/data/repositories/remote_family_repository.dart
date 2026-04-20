import '../../features/family/family_account_membership.dart';

class FamilyInvitationDraft {
  const FamilyInvitationDraft({
    required this.familyId,
    required this.code,
    required this.createdBy,
    required this.createdAt,
    required this.expiresAt,
  });

  final String familyId;
  final String code;
  final String createdBy;
  final DateTime createdAt;
  final DateTime expiresAt;
}

abstract class RemoteFamilyRepository {
  Future<void> ensureFamilyExists({
    required String familyId,
    required String ownerUserId,
    required String ownerDisplayName,
  });

  Future<void> upsertMembership(FamilyAccountMembership membership);

  Future<FamilyInvitationDraft> createInvitation({
    required String familyId,
    required String createdBy,
    required String code,
    required DateTime createdAt,
    required DateTime expiresAt,
  });
}
