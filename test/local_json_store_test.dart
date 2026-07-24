import 'dart:convert';
import 'dart:io';

import 'package:bebia/data/local/child_profile_store.dart';
import 'package:bebia/data/local/event_assignment_store.dart';
import 'package:bebia/data/local/family_connection_store.dart';
import 'package:bebia/data/local/isar_service.dart';
import 'package:bebia/data/local/onboarding_store.dart';
import 'package:bebia/data/repositories/child_profile_repository.dart';
import 'package:bebia/data/repositories/event_assignment_repository.dart';
import 'package:bebia/data/repositories/timeline_repository.dart';
import 'package:bebia/features/profile/child_profile.dart';
import 'package:bebia/features/profile/child_profile_controller.dart';
import 'package:bebia/features/timeline/timeline_item.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';

import 'support/initialize_isar_core.dart';

void main() {
  late Directory directory;

  setUp(() async {
    directory = await Directory.systemTemp.createTemp('bebia-json-store-');
  });

  tearDown(() async {
    if (await directory.exists()) {
      await directory.delete(recursive: true);
    }
  });

  File file(String name) {
    return File('${directory.path}${Platform.pathSeparator}$name');
  }

  test(
    'child profile legacy migration is stable and non-destructive',
    () async {
      final profileFile = file(ChildProfileStore.fileName);
      await profileFile.writeAsString(
        jsonEncode(<String, Object?>{
          'name': 'Ema',
          'dateOfBirth': '2026-01-02T00:00:00.000',
          'sex': 'girl',
        }),
      );

      final store = ChildProfileStore(fileResolver: () async => profileFile);
      final first = await store.read();
      final second = await store.read();

      expect(first.profiles.single.id, second.profiles.single.id);
      expect(first.profiles.single.name, 'Ema');
      expect(first.profiles.single.dateOfBirth, DateTime(2026, 1, 2));
      expect(first.profiles.single.sex, 'girl');
      expect(first.activeProfileId, first.profiles.single.id);
      expect(
        first.legacyUnassignedEventsMigrationChildId,
        first.profiles.single.id,
      );
      expect(
        jsonDecode(await profileFile.readAsString()),
        contains('profiles'),
      );

      final failingStore = ChildProfileStore(
        fileResolver: () async => profileFile,
        beforeReplace: () async => throw const FileSystemException('blocked'),
      );
      await expectLater(
        failingStore.write(
          ChildProfilesState(
            profiles: first.profiles,
            activeProfileId: first.activeProfileId,
          ),
        ),
        throwsA(isA<FileSystemException>()),
      );

      final recovered = await store.read();
      expect(recovered.profiles.single.id, first.profiles.single.id);
      expect(recovered.profiles.single.name, 'Ema');
    },
  );

  test(
    'legacy profile load assigns historical unassigned events once',
    () async {
      await initializeIsarCoreForTests();
      final isarDirectory = await Directory.systemTemp.createTemp(
        'bebia-json-store-isar-',
      );
      Isar? isar;
      addTearDown(() async {
        final open = isar;
        if (open != null && open.isOpen) {
          await IsarService.close();
        }
        if (await isarDirectory.exists()) {
          await isarDirectory.delete(recursive: true);
        }
      });

      final openIsar = await Isar.open(
        <CollectionSchema>[TimelineItemSchema],
        directory: isarDirectory.path,
        name: 'bebia_profile_migration',
        inspector: false,
      );
      isar = openIsar;
      IsarService.setInstanceForTesting(openIsar);
      final event = TimelineItem()
        ..id = 700
        ..type = EventType.feeding
        ..time = DateTime(2026, 7, 24, 9)
        ..title = 'Krmení'
        ..subtitle = '90 ml';
      await openIsar.writeTxn(() => openIsar.timelineItems.put(event));

      final profileFile = file(ChildProfileStore.fileName);
      final assignmentsFile = file(EventAssignmentStore.fileName);
      await profileFile.writeAsString(
        jsonEncode(<String, Object?>{
          'name': 'Ema',
          'dateOfBirth': '2026-01-02T00:00:00.000',
        }),
      );

      final timelineRepository = TimelineRepository(
        EventAssignmentRepository(
          EventAssignmentStore(fileResolver: () async => assignmentsFile),
        ),
      );
      final controller = ChildProfileController(
        ChildProfileRepository(
          ChildProfileStore(fileResolver: () async => profileFile),
        ),
        timelineRepository,
      );

      await controller.load();

      final childId = controller.activeProfileId.value;
      expect(childId, isNotNull);
      expect(await timelineRepository.getAll(childId: childId), hasLength(1));
      expect(
        jsonDecode(await profileFile.readAsString()),
        containsPair('unassignedEventsMigrationCompleted', true),
      );

      await timelineRepository.unassignEventsForChild(childId!);
      await controller.load();

      expect(await timelineRepository.getAll(childId: childId), isEmpty);
    },
  );

  test(
    'local JSON stores recover from backup and isolate invalid entries',
    () async {
      final assignmentsFile = file(EventAssignmentStore.fileName);
      await assignmentsFile.writeAsString(
        jsonEncode(<String, Object?>{
          '10': 'child-a',
          'bad-id': 'child-b',
          '11': 42,
        }),
      );
      final assignments = await EventAssignmentStore(
        fileResolver: () async => assignmentsFile,
      ).read();
      expect(assignments, <int, String>{10: 'child-a'});

      final familyFile = file(FamilyConnectionStore.fileName);
      await File('${familyFile.path}.bak').writeAsString(
        jsonEncode(<String, Object?>{
          'familyId': 'family-a',
          'caregivers': <Object?>[],
        }),
      );
      await familyFile.writeAsString('{ broken');
      final family = await FamilyConnectionStore(
        fileResolver: () async => familyFile,
      ).read();
      expect(family.familyId, 'family-a');
      expect(await familyFile.readAsString(), '{ broken');

      final onboardingFile = file(OnboardingStore.fileName);
      final onboarding = OnboardingStore(
        fileResolver: () async => onboardingFile,
      );
      await onboarding.setCompleted(true);
      expect(await onboarding.isCompleted(), isTrue);
    },
  );
}
