import 'dart:io';

import 'package:bebia/core/settings/bebia_preferences.dart';
import 'package:bebia/features/timeline/timeline_item.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';

import 'support/initialize_isar_core.dart';
import 'support/memory_preferences_store.dart';

void main() {
  test('existing Isar data survives reopen and settings reset', () async {
    await initializeIsarCoreForTests();
    final directory = await Directory.systemTemp.createTemp(
      'bebia-isar-safety-',
    );
    Isar? isar;
    addTearDown(() async {
      final openIsar = isar;
      if (openIsar != null && openIsar.isOpen) {
        await openIsar.close();
      }
      if (await directory.exists()) {
        await directory.delete(recursive: true);
      }
    });

    final firstIsar = await Isar.open(
      <CollectionSchema>[TimelineItemSchema],
      directory: directory.path,
      name: 'bebia_data_safety',
      inspector: false,
    );
    isar = firstIsar;
    final original = TimelineItem()
      ..id = 9001
      ..type = EventType.feeding
      ..time = DateTime(2026, 7, 22, 12, 30)
      ..title = 'Existující krmení'
      ..subtitle = '90 ml'
      ..feedingType = 'bottle'
      ..feedingAmountMl = 90;
    await firstIsar.writeTxn(() => firstIsar.timelineItems.put(original));
    await firstIsar.close();
    isar = null;

    final reopenedIsar = await Isar.open(
      <CollectionSchema>[TimelineItemSchema],
      directory: directory.path,
      name: 'bebia_data_safety',
      inspector: false,
    );
    isar = reopenedIsar;
    final reopened = await reopenedIsar.timelineItems.get(9001);
    expect(reopened, isNotNull);
    expect(reopened!.feedingAmountMl, 90);
    expect(reopened.title, 'Existující krmení');

    final settings = BebiaSettingsController(
      store: MemoryPreferencesStore(
        value: const BebiaPreferences(appearance: BebiaAppearance.dark),
      ),
    );
    await settings.load();
    expect(await settings.reset(), isTrue);

    final afterReset = await reopenedIsar.timelineItems.get(9001);
    expect(afterReset, isNotNull);
    expect(afterReset!.title, 'Existující krmení');
  });
}
