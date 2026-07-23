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

class SerialProbePreferencesStore implements BebiaPreferencesStore {
  SerialProbePreferencesStore({
    this.value = const BebiaPreferences(),
    this.writeDelay = const Duration(milliseconds: 5),
  });

  BebiaPreferences value;
  final Duration writeDelay;
  int activeWrites = 0;
  int maximumConcurrentWrites = 0;
  final List<BebiaPreferences> writes = <BebiaPreferences>[];

  @override
  Future<BebiaPreferences> load() async => value;

  @override
  Future<void> save(BebiaPreferences preferences) async {
    activeWrites++;
    maximumConcurrentWrites = activeWrites > maximumConcurrentWrites
        ? activeWrites
        : maximumConcurrentWrites;
    await Future<void>.delayed(writeDelay);
    writes.add(preferences);
    value = preferences;
    activeWrites--;
  }
}

class FailFirstPreferencesStore implements BebiaPreferencesStore {
  BebiaPreferences value = const BebiaPreferences();
  int saveCalls = 0;

  @override
  Future<BebiaPreferences> load() async => value;

  @override
  Future<void> save(BebiaPreferences preferences) async {
    saveCalls++;
    if (saveCalls == 1) {
      throw StateError('first write failed');
    }
    value = preferences;
  }
}
