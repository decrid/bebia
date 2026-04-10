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
          caregivers: nextCaregivers,
        ),
      );
    } catch (e) {
      error.value = 'Nepodařilo se vytvořit pozvánku: $e';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> markConnected() async {
    isLoading.value = true;
    error.value = null;

    try {
      final now = DateTime.now();
      await _persist(state.value.copyWith(connectedAt: now));
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
      await _persist(state.value.copyWith(clearInvite: true));
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
