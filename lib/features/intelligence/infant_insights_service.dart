import '../timeline/timeline_item.dart';

class InfantInsightsService {
  TimelineItem? getLastByType(List<TimelineItem> items, EventType type) {
    for (final item in items) {
      if (item.type == type) {
        return item;
      }
    }
    return null;
  }

  List<TimelineItem> getRecentEventsByType(
    List<TimelineItem> items,
    EventType type,
    int minutes,
    DateTime now,
  ) {
    return items.where((item) {
      return item.type == type &&
          now.difference(item.time).inMinutes <= minutes;
    }).toList();
  }

  int countRecentEvents(
    List<TimelineItem> items,
    EventType type,
    int minutes,
    DateTime now,
  ) {
    return getRecentEventsByType(items, type, minutes, now).length;
  }

  List<TimelineItem> getLatestItemsByType(
    List<TimelineItem> items,
    EventType type,
    int limit,
  ) {
    return items.where((item) => item.type == type).take(limit).toList();
  }

  List<int> intervalsInMinutes(List<TimelineItem> items) {
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

  List<int> awakeWindowsInMinutes(List<TimelineItem> sleepItems) {
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

  bool hasShortSleepPattern(List<TimelineItem> items) {
    final sleeps = getLatestItemsByType(items, EventType.sleep, 3);

    if (sleeps.length < 2) return false;

    final shortSleeps = sleeps
        .where((sleep) => (sleep.sleepDurationMinutes ?? 0) <= 30)
        .length;

    return shortSleeps >= 2;
  }

  double? averageCryingIntensity(List<TimelineItem> cryings) {
    final intensities = cryings
        .map((item) => item.cryingIntensity)
        .whereType<int>()
        .toList();

    if (intensities.isEmpty) return null;

    final sum = intensities.fold<int>(0, (total, value) => total + value);
    return sum / intensities.length;
  }

  int resolveAverage({
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

  double average(List<int> values) {
    final sum = values.fold<int>(0, (total, value) => total + value);
    return sum / values.length;
  }
}
