class FirestoreFamilyPaths {
  const FirestoreFamilyPaths._();

  static String family(String familyId) => 'families/$familyId';

  static String familyMembers(String familyId) => 'families/$familyId/members';

  static String familyChildren(String familyId) =>
      'families/$familyId/children';

  static String familyEvents(String familyId) => 'families/$familyId/events';

  static String familyInvitations(String familyId) =>
      'families/$familyId/invitations';
}
