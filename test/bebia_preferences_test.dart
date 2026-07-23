import 'package:bebia/core/settings/bebia_preferences.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/memory_preferences_store.dart';

void main() {
  group('BebiaPreferences', () {
    test('reads known values and safely falls back for unknown values', () {
      final preferences = BebiaPreferences.fromJson(<String, Object?>{
        'appearance': 'dark',
        'contentDensity': 'future-density',
        'reduceMotion': true,
        'hapticsEnabled': false,
      });

      expect(preferences.appearance, BebiaAppearance.dark);
      expect(preferences.contentDensity, BebiaContentDensity.comfortable);
      expect(preferences.reduceMotion, isTrue);
      expect(preferences.hapticsEnabled, isFalse);
    });

    test('persists every preference across controller reload', () async {
      final store = MemoryPreferencesStore();
      final first = BebiaSettingsController(store: store);
      await first.load();

      expect(await first.setAppearance(BebiaAppearance.dark), isTrue);
      expect(
        await first.setContentDensity(BebiaContentDensity.compact),
        isTrue,
      );
      expect(await first.setReduceMotion(true), isTrue);
      expect(await first.setHapticsEnabled(false), isTrue);

      final reloaded = BebiaSettingsController(store: store);
      await reloaded.load();
      expect(reloaded.preferences, first.preferences);
    });

    test('persists the full system, light and dark appearance cycle', () async {
      final store = MemoryPreferencesStore();
      final controller = BebiaSettingsController(store: store);
      await controller.load();

      expect(controller.preferences.appearance, BebiaAppearance.system);
      expect(await controller.setAppearance(BebiaAppearance.light), isTrue);
      expect(controller.preferences.appearance, BebiaAppearance.light);
      expect(await controller.setAppearance(BebiaAppearance.dark), isTrue);
      expect(controller.preferences.appearance, BebiaAppearance.dark);
      expect(await controller.setAppearance(BebiaAppearance.system), isTrue);

      final reloaded = BebiaSettingsController(store: store);
      await reloaded.load();
      expect(reloaded.preferences.appearance, BebiaAppearance.system);
    });

    test('serializes rapid changes and keeps the last value', () async {
      final store = SerialProbePreferencesStore();
      final controller = BebiaSettingsController(store: store);
      await controller.load();

      final writes = <Future<bool>>[];
      for (var index = 0; index < 60; index++) {
        writes.add(
          controller.setAppearance(
            index.isEven ? BebiaAppearance.dark : BebiaAppearance.light,
          ),
        );
      }
      writes
        ..add(controller.setAppearance(BebiaAppearance.dark))
        ..add(controller.setReduceMotion(true))
        ..add(controller.setHapticsEnabled(false));
      await Future.wait(writes);

      expect(store.maximumConcurrentWrites, 1);
      expect(store.writes.length, 63);
      expect(store.value.appearance, BebiaAppearance.dark);
      expect(store.value.reduceMotion, isTrue);
      expect(store.value.hapticsEnabled, isFalse);

      final reloaded = BebiaSettingsController(store: store);
      await reloaded.load();
      expect(reloaded.preferences, controller.preferences);
    });

    test('keeps the last confirmed value when persistence fails', () async {
      final store = MemoryPreferencesStore(saveError: StateError('disk full'));
      final controller = BebiaSettingsController(store: store);
      await controller.load();

      final saved = await controller.setAppearance(BebiaAppearance.dark);

      expect(saved, isFalse);
      expect(controller.preferences.appearance, BebiaAppearance.system);
      expect(controller.lastError, isNotNull);
    });

    test('an older failure never rolls back a newer queued change', () async {
      final store = FailFirstPreferencesStore();
      final controller = BebiaSettingsController(store: store);
      await controller.load();

      final first = controller.setAppearance(BebiaAppearance.dark);
      final second = controller.setReduceMotion(true);

      expect(await first, isFalse);
      expect(await second, isTrue);
      expect(controller.preferences.appearance, BebiaAppearance.dark);
      expect(controller.preferences.reduceMotion, isTrue);
      expect(store.value, controller.preferences);
      expect(controller.lastError, isNull);
    });

    test('uses safe defaults when preferences cannot be read', () async {
      final controller = BebiaSettingsController(
        store: MemoryPreferencesStore(
          loadError: const FormatException('corrupt preferences'),
        ),
      );

      await controller.load();

      expect(controller.initialized, isTrue);
      expect(controller.preferences, const BebiaPreferences());
      expect(controller.lastError, isNotNull);
    });

    test(
      'reset only writes preferences and leaves other data untouched',
      () async {
        final store = MemoryPreferencesStore(
          value: const BebiaPreferences(appearance: BebiaAppearance.dark),
        );
        final simulatedTimelineIds = <int>[7, 11, 42];
        final controller = BebiaSettingsController(store: store);
        await controller.load();

        expect(await controller.reset(), isTrue);

        expect(store.value, const BebiaPreferences());
        expect(simulatedTimelineIds, <int>[7, 11, 42]);
      },
    );
  });
}
