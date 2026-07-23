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

    test(
      'persists every user-facing preference across controller reload',
      () async {
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
      },
    );

    test('keeps the previous value when persistence fails', () async {
      final store = MemoryPreferencesStore(saveError: StateError('disk full'));
      final controller = BebiaSettingsController(store: store);
      await controller.load();

      final saved = await controller.setAppearance(BebiaAppearance.dark);

      expect(saved, isFalse);
      expect(controller.preferences.appearance, BebiaAppearance.system);
      expect(controller.lastError, isNotNull);
    });

    test(
      'uses safe defaults when the preferences file cannot be read',
      () async {
        final controller = BebiaSettingsController(
          store: MemoryPreferencesStore(
            loadError: const FormatException('corrupt preferences'),
          ),
        );

        await controller.load();

        expect(controller.initialized, isTrue);
        expect(controller.preferences, const BebiaPreferences());
        expect(controller.lastError, isNotNull);
      },
    );
  });
}
