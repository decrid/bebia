import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../core/platform/bebia_platform_bridge.dart';
import '../../data/repositories/timeline_repository.dart';
import '../profile/child_profile_controller.dart';
import '../timeline/timeline_item.dart';

class BebiaWidgetSnapshotService {
  BebiaWidgetSnapshotService(
    this._repository,
    this._profileController,
    this._platformBridge,
  );

  final TimelineRepository _repository;
  final ChildProfileController _profileController;
  final BebiaPlatformBridge _platformBridge;

  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;
    _repository.setMutationObserver(sync);
    _profileController.activeProfileId.addListener(_handleProfileChange);
    await _platformBridge.initialize();
    await sync();
  }

  Future<void> sync() async {
    try {
      final items = await _repository.getAll(
        childId: _profileController.activeProfileId.value,
      );
      final snapshot = buildBebiaWidgetSnapshot(items);
      await _platformBridge.syncWidgetSnapshot(snapshot);
    } on Object catch (error) {
      debugPrint('Bebia widget snapshot could not be refreshed: $error');
    }
  }

  void _handleProfileChange() {
    unawaited(sync());
  }
}

@visibleForTesting
Map<String, Object?> buildBebiaWidgetSnapshot(
  List<TimelineItem> items, {
  DateTime? now,
}) {
  TimelineItem? latest(EventType type) {
    TimelineItem? result;
    for (final item in items) {
      if (item.type != type) continue;
      if (result == null || item.time.isAfter(result.time)) result = item;
    }
    return result;
  }

  String feedingDetail(TimelineItem item) {
    final type = switch (item.feedingType) {
      'breast' => 'Kojení',
      'bottle' => 'Láhev',
      _ => 'Krmení',
    };
    final amount = item.feedingAmountMl;
    return amount == null ? type : '$type · $amount ml';
  }

  String durationLabel(int? minutes) {
    if (minutes == null || minutes <= 0) return 'Zaznamenáno';
    if (minutes < 60) return '$minutes min';
    final hours = minutes ~/ 60;
    final rest = minutes % 60;
    return rest == 0 ? '$hours h' : '$hours h $rest min';
  }

  String detail(TimelineItem item) {
    return switch (item.type) {
      EventType.feeding => feedingDetail(item),
      EventType.sleep =>
        item.sleepEnd == null
            ? 'Právě probíhá'
            : durationLabel(item.sleepDurationMinutes),
      EventType.diaper => switch (item.diaperType) {
        'wet' => 'Mokrá plena',
        'poop' => 'Stolice',
        'both' => 'Mokrá plena i stolice',
        _ => 'Přebaleno',
      },
      EventType.crying =>
        item.cryingDurationMinutes == null
            ? 'Zaznamenáno'
            : durationLabel(item.cryingDurationMinutes),
    };
  }

  Map<String, Object?>? eventPayload(TimelineItem? item) {
    if (item == null) return null;
    return <String, Object?>{
      'time': item.time.millisecondsSinceEpoch,
      'detail': detail(item),
    };
  }

  return <String, Object?>{
    'updatedAt': (now ?? DateTime.now()).millisecondsSinceEpoch,
    'feeding': eventPayload(latest(EventType.feeding)),
    'sleep': eventPayload(latest(EventType.sleep)),
    'diaper': eventPayload(latest(EventType.diaper)),
    'crying': eventPayload(latest(EventType.crying)),
  };
}
