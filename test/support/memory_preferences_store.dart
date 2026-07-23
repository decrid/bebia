import 'package:bebia/core/settings/bebia_preferences.dart';

class MemoryPreferencesStore implements BebiaPreferencesStore {
  MemoryPreferencesStore({
    this.value = const BebiaPreferences(),
    this.loadError,
    this.saveError,
  });

  BebiaPreferences value;
  Object? loadError;
  Object? saveError;

  @override
  Future<BebiaPreferences> load() async {
    if (loadError != null) throw loadError!;
    return value;
  }

  @override
  Future<void> save(BebiaPreferences preferences) async {
    if (saveError != null) throw saveError!;
    value = preferences;
  }
}
