class CaregiverProfile {
  const CaregiverProfile({
    required this.id,
    required this.name,
    required this.role,
    required this.createdAt,
    this.isOwner = false,
  });

  final String id;
  final String name;
  final String role;
  final DateTime createdAt;
  final bool isOwner;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'role': role,
      'createdAt': createdAt.toIso8601String(),
      'isOwner': isOwner,
    };
  }

  factory CaregiverProfile.fromJson(Map<String, dynamic> json) {
    return CaregiverProfile(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      role: json['role'] as String? ?? 'Rodič',
      createdAt:
          DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
      isOwner: json['isOwner'] == true,
    );
  }
}

class FamilyConnectionState {
  const FamilyConnectionState({
    required this.familyId,
    required this.inviteCode,
    required this.inviteCreatedAt,
    required this.connectedAt,
    required this.caregivers,
  });

  final String? familyId;
  final String? inviteCode;
  final DateTime? inviteCreatedAt;
  final DateTime? connectedAt;
  final List<CaregiverProfile> caregivers;

  bool get hasInvite => inviteCode != null && inviteCode!.isNotEmpty;
  bool get isConnected => connectedAt != null;

  FamilyConnectionState copyWith({
    String? familyId,
    String? inviteCode,
    DateTime? inviteCreatedAt,
    DateTime? connectedAt,
    List<CaregiverProfile>? caregivers,
    bool clearInvite = false,
    bool clearConnectedAt = false,
  }) {
    return FamilyConnectionState(
      familyId: familyId ?? this.familyId,
      inviteCode: clearInvite ? null : (inviteCode ?? this.inviteCode),
      inviteCreatedAt: clearInvite
          ? null
          : (inviteCreatedAt ?? this.inviteCreatedAt),
      connectedAt: clearConnectedAt ? null : (connectedAt ?? this.connectedAt),
      caregivers: caregivers ?? this.caregivers,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'familyId': familyId,
      'inviteCode': inviteCode,
      'inviteCreatedAt': inviteCreatedAt?.toIso8601String(),
      'connectedAt': connectedAt?.toIso8601String(),
      'caregivers': caregivers.map((caregiver) => caregiver.toJson()).toList(),
    };
  }

  factory FamilyConnectionState.fromJson(Map<String, dynamic> json) {
    final rawCaregivers = (json['caregivers'] as List<dynamic>? ?? const [])
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList();

    return FamilyConnectionState(
      familyId: json['familyId'] as String?,
      inviteCode: json['inviteCode'] as String?,
      inviteCreatedAt: DateTime.tryParse(
        json['inviteCreatedAt'] as String? ?? '',
      ),
      connectedAt: DateTime.tryParse(json['connectedAt'] as String? ?? ''),
      caregivers: rawCaregivers.map(CaregiverProfile.fromJson).toList(),
    );
  }

  factory FamilyConnectionState.empty() {
    return const FamilyConnectionState(
      familyId: null,
      inviteCode: null,
      inviteCreatedAt: null,
      connectedAt: null,
      caregivers: [],
    );
  }
}
