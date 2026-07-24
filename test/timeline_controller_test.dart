import 'dart:async';
import 'dart:io';

import 'package:bebia/data/local/child_profile_store.dart';
import 'package:bebia/data/local/event_assignment_store.dart';
import 'package:bebia/data/repositories/child_profile_repository.dart';
import 'package:bebia/data/repositories/event_assignment_repository.dart';
import 'package:bebia/data/repositories/timeline_repository.dart';
import 'package:bebia/features/profile/child_profile.dart';
import 'package:bebia/features/profile/child_profile_controller.dart';
import 'package:bebia/features/timeline/timeline_controller.dart';
import 'package:bebia/features/timeline/timeline_item.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('add reports controller error and rethrows to the caller', () async {
    final controller = _controllerWithRepository(_FailingTimelineRepository());

    final item = TimelineItem()
      ..id = 1
      ..type = EventType.feeding
      ..time = DateTime(2026, 7, 24, 8)
      ..title = 'Krmení'
      ..subtitle = '';

    await expectLater(controller.add(item), throwsA(isA<StateError>()));

    expect(controller.error.value, 'Nepodařilo se uložit záznam.');
    expect(controller.revision.value, 0);
  });

  test('older load result cannot overwrite a newer load result', () async {
    final repository = _ControlledTimelineRepository();
    final controller = _controllerWithRepository(repository);

    final firstLoad = controller.load(EventType.feeding);
    final secondLoad = controller.load(EventType.sleep);

    repository.completeSecond([
      _item(2, EventType.sleep, DateTime(2026, 7, 24, 9)),
    ]);
    await secondLoad;
    expect(controller.items.value.single.id, 2);

    repository.completeFirst([
      _item(1, EventType.feeding, DateTime(2026, 7, 24, 8)),
    ]);
    await firstLoad;

    expect(controller.items.value.single.id, 2);
    expect(controller.selectedFilter.value, EventType.sleep);
  });
}

TimelineController _controllerWithRepository(TimelineRepository repository) {
  final childController = ChildProfileController(
    ChildProfileRepository(
      ChildProfileStore(fileResolver: () async => File('unused')),
    ),
    repository,
  );
  childController.profiles.value = [
    ChildProfile(
      id: 'child-test',
      name: 'Ema',
      dateOfBirth: DateTime(2026, 1, 1),
    ),
  ];
  childController.activeProfileId.value = 'child-test';
  return TimelineController(repository, childController);
}

TimelineItem _item(int id, EventType type, DateTime time) {
  return TimelineItem()
    ..id = id
    ..type = type
    ..time = time
    ..title = type.name
    ..subtitle = '';
}

EventAssignmentRepository _testAssignments() {
  return EventAssignmentRepository(
    EventAssignmentStore(fileResolver: () async => File('unused')),
  );
}

class _FailingTimelineRepository extends TimelineRepository {
  _FailingTimelineRepository() : super(_testAssignments());

  @override
  Future<void> addItem(TimelineItem item, {String? childId}) async {
    throw StateError('write failed');
  }
}

class _ControlledTimelineRepository extends TimelineRepository {
  _ControlledTimelineRepository() : super(_testAssignments());

  final Completer<List<TimelineItem>> _first = Completer<List<TimelineItem>>();
  final Completer<List<TimelineItem>> _second = Completer<List<TimelineItem>>();
  var _calls = 0;

  @override
  Future<List<TimelineItem>> getFiltered(EventType? type, {String? childId}) {
    _calls++;
    return _calls == 1 ? _first.future : _second.future;
  }

  void completeFirst(List<TimelineItem> items) => _first.complete(items);

  void completeSecond(List<TimelineItem> items) => _second.complete(items);
}
