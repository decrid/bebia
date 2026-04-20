import 'package:flutter/foundation.dart';

import '../../data/repositories/child_profile_repository.dart';
import '../../data/repositories/timeline_repository.dart';
import 'child_profile.dart';

class ChildProfileController {
  ChildProfileController(this._repository, this._timelineRepository);

  final ChildProfileRepository _repository;
  final TimelineRepository _timelineRepository;

  final ValueNotifier<List<ChildProfile>> profiles =
      ValueNotifier<List<ChildProfile>>([]);
  final ValueNotifier<String?> activeProfileId = ValueNotifier<String?>(null);
  final ValueNotifier<bool> isLoading = ValueNotifier<bool>(false);
  final ValueNotifier<String?> error = ValueNotifier<String?>(null);

  ChildProfile? get activeProfile {
    final currentId = activeProfileId.value;
    for (final profile in profiles.value) {
      if (profile.id == currentId) {
        return profile;
      }
    }
    return null;
  }

  bool get hasProfiles => profiles.value.isNotEmpty;

  Future<void> load() async {
    isLoading.value = true;
    error.value = null;

    try {
      final state = await _repository.loadState();
      profiles.value = state.profiles;
      activeProfileId.value = state.activeProfileId;
    } catch (e) {
      error.value = 'Nepodařilo se načíst profily dětí: $e';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> saveProfile(ChildProfile profile) async {
    isLoading.value = true;
    error.value = null;

    try {
      final updatedProfiles = [...profiles.value];
      final existingIndex = updatedProfiles.indexWhere(
        (item) => item.id == profile.id,
      );

      final isCreating = existingIndex < 0;

      if (existingIndex >= 0) {
        updatedProfiles[existingIndex] = profile;
      } else {
        updatedProfiles.add(profile);
      }

      final nextActiveId = isCreating
          ? profile.id
          : (activeProfileId.value ?? profile.id);
      await _persist(updatedProfiles, nextActiveId);
    } catch (e) {
      error.value = 'Nepodařilo se uložit profil dítěte: $e';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> setActiveProfile(String profileId) async {
    isLoading.value = true;
    error.value = null;

    try {
      await _persist(profiles.value, profileId);
    } catch (e) {
      error.value = 'Nepodařilo se přepnout aktivní dítě: $e';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> assignProfileToFamily({
    required String profileId,
    required String familyId,
  }) async {
    isLoading.value = true;
    error.value = null;

    try {
      final now = DateTime.now();
      final updatedProfiles = profiles.value.map((profile) {
        if (profile.id != profileId) {
          return profile;
        }
        return profile.copyWith(familyId: familyId, linkedToFamilyAt: now);
      }).toList();

      await _persist(updatedProfiles, activeProfileId.value);
    } catch (e) {
      error.value = 'Nepodařilo se přidat dítě do rodiny: $e';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> removeProfileFromFamily(String profileId) async {
    isLoading.value = true;
    error.value = null;

    try {
      final updatedProfiles = profiles.value.map((profile) {
        if (profile.id != profileId) {
          return profile;
        }
        return profile.copyWith(clearFamilyLink: true);
      }).toList();

      await _persist(updatedProfiles, activeProfileId.value);
    } catch (e) {
      error.value = 'Nepodařilo se odebrat dítě z rodiny: $e';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteProfile(
    String profileId, {
    required bool deleteEvents,
  }) async {
    isLoading.value = true;
    error.value = null;

    try {
      if (deleteEvents) {
        await _timelineRepository.deleteEventsForChild(profileId);
      } else {
        await _timelineRepository.unassignEventsForChild(profileId);
      }

      final updatedProfiles = profiles.value
          .where((profile) => profile.id != profileId)
          .toList();

      String? nextActiveId = activeProfileId.value;
      if (nextActiveId == profileId) {
        nextActiveId = updatedProfiles.isNotEmpty
            ? updatedProfiles.first.id
            : null;
      }

      await _persist(updatedProfiles, nextActiveId);
    } catch (e) {
      error.value = 'Nepodařilo se smazat profil dítěte: $e';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _persist(
    List<ChildProfile> nextProfiles,
    String? nextActiveId,
  ) async {
    final state = ChildProfilesState(
      profiles: nextProfiles,
      activeProfileId: nextActiveId,
    );
    await _repository.saveState(state);
    profiles.value = nextProfiles;
    activeProfileId.value = nextActiveId;
  }

  void dispose() {
    profiles.dispose();
    activeProfileId.dispose();
    isLoading.dispose();
    error.dispose();
  }
}
