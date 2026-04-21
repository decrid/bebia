import 'package:flutter/foundation.dart';

import '../../data/repositories/family_connection_repository.dart';
import 'family_connection.dart';

class FamilyConnectionController {
  FamilyConnectionController(this._repository);

  final FamilyConnectionRepository _repository;

  final ValueNotifier<FamilyConnectionState> state =
      ValueNotifier<FamilyConnectionState>(FamilyConnectionState.empty());
  final ValueNotifier<bool> isLoading = ValueNotifier<bool>(false);
  final ValueNotifier<String?> error = ValueNotifier<String?>(null);

  Future<void> load() async {
    isLoading.value = true;
    error.value = null;

    try {
      state.value = await _repository.loadState();
    } catch (e) {
      error.value = 'Nepodařilo se načíst rodinné sdílení: $e';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> createInvite() async {
    isLoading.value = true;
    error.value = null;

    try {
      final now = DateTime.now();
      final familyId =
          state.value.familyId ?? 'family-${now.millisecondsSinceEpoch}';
      final nextCaregivers = state.value.caregivers.isEmpty
          ? [
              CaregiverProfile(
                id: 'caregiver-${now.millisecondsSinceEpoch}',
                name: 'Já',
                role: 'Rodič',
                createdAt: now,
                isOwner: true,
              ),
            ]
          : state.value.caregivers;

      await _persist(
        state.value.copyWith(
          familyId: familyId,
          inviteCode: _generateInviteCode(now),
          inviteCreatedAt: now,
          inviteSharedAt: null,
          inviteAcceptedAt: null,
          connectedAt: null,
          caregivers: nextCaregivers,
        ),
      );
    } catch (e) {
      error.value = 'Nepodařilo se vytvořit pozvánku: $e';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> markInviteShared() async {
    if (!state.value.hasInvite) {
      error.value = 'Nejdřív vytvoř pozvánku.';
      return;
    }

    isLoading.value = true;
    error.value = null;

    try {
      await _persist(
        state.value.copyWith(
          inviteSharedAt: state.value.inviteSharedAt ?? DateTime.now(),
        ),
      );
    } catch (e) {
      error.value = 'Nepodařilo se označit odeslání pozvánky: $e';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> markInviteAccepted() async {
    if (!state.value.hasInvite) {
      error.value = 'Nejdřív vytvoř pozvánku.';
      return;
    }

    isLoading.value = true;
    error.value = null;

    try {
      final now = DateTime.now();
      final hasSecondCaregiver = state.value.caregivers.any(
        (caregiver) => !caregiver.isOwner,
      );
      final nextCaregivers = hasSecondCaregiver
          ? state.value.caregivers
          : [
              ...state.value.caregivers,
              CaregiverProfile(
                id: 'caregiver-accepted-${now.millisecondsSinceEpoch}',
                name: 'Druhý rodič',
                role: 'Rodič',
                createdAt: now,
              ),
            ];

      await _persist(
        state.value.copyWith(
          inviteSharedAt: state.value.inviteSharedAt ?? now,
          inviteAcceptedAt: now,
          caregivers: nextCaregivers,
        ),
      );
    } catch (e) {
      error.value = 'Nepodařilo se označit přijetí pozvánky: $e';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> acceptInviteCode({
    required String inviteCode,
    required String caregiverName,
    required String caregiverRole,
  }) async {
    final normalizedCode = inviteCode.trim().toUpperCase();
    final normalizedName = caregiverName.trim();
    final normalizedRole = caregiverRole.trim();

    if (!state.value.hasInvite) {
      error.value = 'Nejdřív musí existovat pozvánka.';
      return;
    }
    if (normalizedCode.isEmpty) {
      error.value = 'Zadej pozvánkový kód.';
      return;
    }
    if (normalizedCode != state.value.inviteCode) {
      error.value = 'Zadaný kód neodpovídá aktivní pozvánce.';
      return;
    }
    if (normalizedName.isEmpty) {
      error.value = 'Zadej jméno druhého rodiče.';
      return;
    }

    isLoading.value = true;
    error.value = null;

    try {
      final now = DateTime.now();
      final alreadyExists = state.value.caregivers.any(
        (caregiver) =>
            !caregiver.isOwner &&
            caregiver.name.trim().toLowerCase() == normalizedName.toLowerCase(),
      );

      final nextCaregivers = alreadyExists
          ? state.value.caregivers
          : [
              ...state.value.caregivers,
              CaregiverProfile(
                id: 'caregiver-accepted-${now.millisecondsSinceEpoch}',
                name: normalizedName,
                role: normalizedRole.isEmpty ? 'Rodič' : normalizedRole,
                createdAt: now,
              ),
            ];

      await _persist(
        state.value.copyWith(
          inviteSharedAt: state.value.inviteSharedAt ?? now,
          inviteAcceptedAt: now,
          caregivers: nextCaregivers,
        ),
      );
    } catch (e) {
      error.value = 'Nepodařilo se přijmout pozvánku: $e';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> markConnected() async {
    if (!state.value.hasInvite) {
      error.value = 'Nejdřív vytvoř pozvánku.';
      return;
    }

    isLoading.value = true;
    error.value = null;

    try {
      final now = DateTime.now();
      await _persist(
        state.value.copyWith(
          inviteSharedAt: state.value.inviteSharedAt ?? now,
          inviteAcceptedAt: state.value.inviteAcceptedAt ?? now,
          connectedAt: now,
        ),
      );
    } catch (e) {
      error.value = 'Nepodařilo se označit propojení: $e';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> cancelInvite() async {
    isLoading.value = true;
    error.value = null;

    try {
      await _persist(
        state.value.copyWith(clearInvite: true, clearConnectedAt: true),
      );
    } catch (e) {
      error.value = 'Nepodařilo se zrušit pozvánku: $e';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addCaregiver({
    required String name,
    required String role,
  }) async {
    final trimmedName = name.trim();
    if (trimmedName.isEmpty) {
      error.value = 'Zadej jméno pečující osoby.';
      return;
    }

    isLoading.value = true;
    error.value = null;

    try {
      final now = DateTime.now();
      final nextCaregivers = [
        ...state.value.caregivers,
        CaregiverProfile(
          id: 'caregiver-${now.millisecondsSinceEpoch}',
          name: trimmedName,
          role: role.trim().isEmpty ? 'Rodič' : role.trim(),
          createdAt: now,
        ),
      ];

      await _persist(state.value.copyWith(caregivers: nextCaregivers));
    } catch (e) {
      error.value = 'Nepodařilo se přidat pečující osobu: $e';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> removeCaregiver(String caregiverId) async {
    isLoading.value = true;
    error.value = null;

    try {
      final nextCaregivers = state.value.caregivers
          .where(
            (caregiver) => caregiver.id != caregiverId || caregiver.isOwner,
          )
          .toList();
      await _persist(state.value.copyWith(caregivers: nextCaregivers));
    } catch (e) {
      error.value = 'Nepodařilo se odebrat pečující osobu: $e';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _persist(FamilyConnectionState nextState) async {
    await _repository.saveState(nextState);
    state.value = nextState;
  }

  String _generateInviteCode(DateTime now) {
    final raw = now.microsecondsSinceEpoch.toRadixString(36).toUpperCase();
    final padded = raw.padLeft(8, '0');
    return '${padded.substring(padded.length - 8, padded.length - 4)}-'
        '${padded.substring(padded.length - 4)}';
  }

  void dispose() {
    state.dispose();
    isLoading.dispose();
    error.dispose();
  }
}
