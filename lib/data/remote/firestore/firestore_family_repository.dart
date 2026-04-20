import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../features/family/family_account_membership.dart';
import '../../repositories/remote_family_repository.dart';
import 'firestore_family_paths.dart';

class FirestoreFamilyRepository implements RemoteFamilyRepository {
  FirestoreFamilyRepository(this._firestore);

  final FirebaseFirestore _firestore;

  @override
  Future<void> ensureFamilyExists({
    required String familyId,
    required String ownerUserId,
    required String ownerDisplayName,
  }) async {
    final familyRef = _firestore.doc(FirestoreFamilyPaths.family(familyId));

    await familyRef.set({
      'familyId': familyId,
      'createdBy': ownerUserId,
      'createdAt': FieldValue.serverTimestamp(),
      'name': 'Rodina $ownerDisplayName',
    }, SetOptions(merge: true));
  }

  @override
  Future<FamilyInvitationDraft> createInvitation({
    required String familyId,
    required String createdBy,
    required String code,
    required DateTime createdAt,
    required DateTime expiresAt,
  }) async {
    final invitation = FamilyInvitationDraft(
      familyId: familyId,
      code: code,
      createdBy: createdBy,
      createdAt: createdAt,
      expiresAt: expiresAt,
    );

    final inviteRef = _firestore
        .collection(FirestoreFamilyPaths.familyInvitations(familyId))
        .doc(code);

    await inviteRef.set({
      'familyId': familyId,
      'code': code,
      'createdBy': createdBy,
      'createdAt': Timestamp.fromDate(createdAt),
      'expiresAt': Timestamp.fromDate(expiresAt),
      'status': 'pending',
    });

    return invitation;
  }

  @override
  Future<void> upsertMembership(FamilyAccountMembership membership) async {
    final memberRef = _firestore
        .collection(FirestoreFamilyPaths.familyMembers(membership.familyId))
        .doc(membership.userId);

    await memberRef.set({
      'familyId': membership.familyId,
      'uid': membership.userId,
      'role': membership.role.name,
      'status': membership.status.name,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}
