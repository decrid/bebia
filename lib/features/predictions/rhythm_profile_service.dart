import '../../data/repositories/timeline_repository.dart';
import '../timeline/timeline_item.dart';
import 'rhythm_profile.dart';

class RhythmProfileService {
  RhythmProfileService(this._repository);

  final TimelineRepository _repository;

  Future<RhythmProfile> getProfile() async {
    final items = await _repository.getAll();

    final feedingItems = items
        .where((item) => item.type == EventType.feeding)
        .take(8)
        .toList();

    final sleepItems = items
        .where((item) => item.type == EventType.sleep)
        .take(8)
        .toList();

    final diaperItems = items
        .where((item) => item.type == EventType.diaper)
        .take(8)
        .toList();

    final feedingIntervals = _intervalsInMinutes(feedingItems);
    final awakeWindows = _awakeWindowsInMinutes(sleepItems);
    final diaperIntervals = _intervalsInMinutes(diaperItems);

    return RhythmProfile(
      feedingIntervalMinutes: _resolveAverage(
        values: feedingIntervals,
        fallback: 150,
        min: 60,
        max: 300,
      ),
      awakeWindowMinutes: _resolveAverage(
        values: awakeWindows,
        fallback: 90,
        min: 30,
        max: 240,
      ),
      diaperIntervalMinutes: _resolveAverage(
        values: diaperIntervals,
        fallback: 180,
        min: 60,
        max: 360,
      ),
    );
  }

  List<int> _intervalsInMinutes(List<TimelineItem> items) {
    final intervals = <int>[];

    for (var i = 0; i < items.length - 1; i++) {
      final newer = items[i];
      final older = items[i + 1];
      final diff = newer.time.difference(older.time).inMinutes;

      if (diff > 0) {
        intervals.add(diff);
      }
    }

    return intervals;
  }

  List<int> _awakeWindowsInMinutes(List<TimelineItem> sleepItems) {
    final windows = <int>[];

    for (var i = 0; i < sleepItems.length - 1; i++) {
      final newerSleep = sleepItems[i];
      final olderSleep = sleepItems[i + 1];

      final olderSleepEnd = olderSleep.sleepEnd ?? olderSleep.time;
      final newerSleepStart = newerSleep.sleepStart ?? newerSleep.time;

      final diff = newerSleepStart.difference(olderSleepEnd).inMinutes;

      if (diff > 0) {
        windows.add(diff);
      }
    }

    return windows;
  }

  int _resolveAverage({
    required List<int> values,
    required int fallback,
    required int min,
    required int max,
  }) {
    if (values.isEmpty) return fallback;

    final sum = values.fold<int>(0, (total, value) => total + value);
    final average = (sum / values.length).round();

    if (average < min) return min;
    if (average > max) return max;

    return average;
  }
}