class ChildProfile {
  const ChildProfile({
    required this.id,
    required this.name,
    required this.dateOfBirth,
    this.sex,
    this.familyId,
    this.linkedToFamilyAt,
  });

  final String id;
  final String name;
  final DateTime dateOfBirth;
  final String? sex;
  final String? familyId;
  final DateTime? linkedToFamilyAt;

  bool get isLinkedToFamily => familyId != null && familyId!.isNotEmpty;

  ChildProfile copyWith({
    String? id,
    String? name,
    DateTime? dateOfBirth,
    String? sex,
    String? familyId,
    DateTime? linkedToFamilyAt,
    bool clearSex = false,
    bool clearFamilyLink = false,
  }) {
    return ChildProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      sex: clearSex ? null : (sex ?? this.sex),
      familyId: clearFamilyLink ? null : (familyId ?? this.familyId),
      linkedToFamilyAt: clearFamilyLink
          ? null
          : (linkedToFamilyAt ?? this.linkedToFamilyAt),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'dateOfBirth': dateOfBirth.toIso8601String(),
      'sex': sex,
      'familyId': familyId,
      'linkedToFamilyAt': linkedToFamilyAt?.toIso8601String(),
    };
  }

  factory ChildProfile.fromJson(Map<String, dynamic> json) {
    return ChildProfile(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      dateOfBirth: DateTime.parse(
        json['dateOfBirth'] as String? ?? DateTime.now().toIso8601String(),
      ),
      sex: json['sex'] as String?,
      familyId: json['familyId'] as String?,
      linkedToFamilyAt: DateTime.tryParse(
        json['linkedToFamilyAt'] as String? ?? '',
      ),
    );
  }
}

class ChildProfilesState {
  const ChildProfilesState({
    required this.profiles,
    required this.activeProfileId,
  });

  final List<ChildProfile> profiles;
  final String? activeProfileId;

  ChildProfile? get activeProfile {
    for (final profile in profiles) {
      if (profile.id == activeProfileId) {
        return profile;
      }
    }
    return null;
  }

  Map<String, dynamic> toJson() {
    return {
      'activeProfileId': activeProfileId,
      'profiles': profiles.map((profile) => profile.toJson()).toList(),
    };
  }

  factory ChildProfilesState.fromJson(Map<String, dynamic> json) {
    final rawProfiles = (json['profiles'] as List<dynamic>? ?? const [])
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList();

    final profiles = rawProfiles.map(ChildProfile.fromJson).toList();
    final activeProfileId = json['activeProfileId'] as String?;

    return ChildProfilesState(
      profiles: profiles,
      activeProfileId: profiles.any((profile) => profile.id == activeProfileId)
          ? activeProfileId
          : (profiles.isNotEmpty ? profiles.first.id : null),
    );
  }

  factory ChildProfilesState.empty() {
    return const ChildProfilesState(profiles: [], activeProfileId: null);
  }
}
