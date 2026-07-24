import 'package:bebia/features/timeline/timeline_item.dart';
import 'package:bebia/features/widgets/bebia_widget_snapshot_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('widget snapshot keeps only latest non-sensitive care data', () {
    final olderFeeding = TimelineItem()
      ..id = 1
      ..type = EventType.feeding
      ..time = DateTime(2026, 1, 1, 8)
      ..title = 'Krmení'
      ..subtitle = ''
      ..note = 'soukromá poznámka'
      ..feedingType = 'breast';
    final latestFeeding = TimelineItem()
      ..id = 2
      ..type = EventType.feeding
      ..time = DateTime(2026, 1, 1, 10)
      ..title = 'Lahvička'
      ..subtitle = '90 ml'
      ..note = 'další soukromá poznámka'
      ..feedingType = 'bottle'
      ..feedingAmountMl = 90
      ..audioSamplePath = '/private/audio.wav'
      ..aiModelVersion = 'internal-model'
      ..aiSignalsSerialized = 'private signal';
    final diaper = TimelineItem()
      ..id = 3
      ..type = EventType.diaper
      ..time = DateTime(2026, 1, 1, 9)
      ..title = 'Přebalení'
      ..subtitle = 'Mokrá plena'
      ..note = 'nezveřejnit'
      ..diaperType = 'wet';

    final snapshot = buildBebiaWidgetSnapshot([
      olderFeeding,
      diaper,
      latestFeeding,
    ], now: DateTime(2026, 1, 1, 11));

    expect(snapshot['feeding'], <String, Object?>{
      'time': latestFeeding.time.millisecondsSinceEpoch,
      'detail': 'Láhev · 90 ml',
    });
    expect(snapshot['diaper'], <String, Object?>{
      'time': diaper.time.millisecondsSinceEpoch,
      'detail': 'Mokrá plena',
    });
    expect(snapshot.toString(), isNot(contains('soukromá')));
    expect(snapshot.toString(), isNot(contains('nezveřejnit')));
    expect(snapshot.toString(), isNot(contains('/private/audio.wav')));
    expect(snapshot.toString(), isNot(contains('internal-model')));
    expect(snapshot.toString(), isNot(contains('private signal')));
    expect(snapshot, isNot(contains('childName')));
  });
}
