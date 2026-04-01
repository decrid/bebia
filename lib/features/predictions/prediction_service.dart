import '../../data/repositories/timeline_repository.dart';
import '../timeline/timeline_item.dart';
import 'prediction_model.dart';
import 'rhythm_profile_service.dart';

class PredictionService {
  PredictionService(
    this._repository,
    this._rhythmProfileService,
  );

  final TimelineRepository _repository;
  final RhythmProfileService _rhythmProfileService;

  Future<List<Prediction>> getPredictions() async {
    final items = await _repository.getAll();

    if (items.isEmpty) return [];

    final profile = await _rhythmProfileService.getProfile();

    final predictions = <Prediction?>[
      _predictNextFeeding(items, profile.feedingIntervalMinutes),
      _predictNextSleep(items, profile.awakeWindowMinutes),
      _predictNextDiaper(items, profile.diaperIntervalMinutes),
    ].whereType<Prediction>().toList();

    predictions.sort((a, b) {
      final aTime = a.predictedTime;
      final bTime = b.predictedTime;

      if (aTime == null && bTime == null) return 0;
      if (aTime == null) return 1;
      if (bTime == null) return -1;

      return aTime.compareTo(bTime);
    });

    return predictions;
  }

  Prediction? _predictNextFeeding(
    List<TimelineItem> items,
    int personalizedIntervalMinutes,
  ) {
    final feedings = items.where((e) => e.type == EventType.feeding).toList();

    if (feedings.isEmpty) return null;

    final lastFeeding = feedings.first;
    final intervals = _intervalsInMinutes(feedings);

    final predictedMinutes = intervals.isEmpty
        ? personalizedIntervalMinutes.toDouble()
        : _average(intervals);
    final predictedTime = lastFeeding.time.add(
      Duration(minutes: predictedMinutes.round()),
    );

    return Prediction(
      title: 'Další krmení',
      description: 'Odhad podle personalizovaného rytmu krmení.',
      predictedTime: predictedTime,
      confidence: intervals.length >= 2 ? 0.80 : 0.55,
      signals: [
        if (intervals.isNotEmpty) 'vypočteno z historie krmení',
        if (intervals.isEmpty) 'použit fallback rytmus',
        'interval ~${predictedMinutes.round()} min',
      ],
    );
  }

  Prediction? _predictNextSleep(
    List<TimelineItem> items,
    int personalizedAwakeWindowMinutes,
  ) {
    final sleeps = items.where((e) => e.type == EventType.sleep).toList();

    if (sleeps.isEmpty) return null;

    final lastSleep = sleeps.first;
    final intervals = _awakeWindowsInMinutes(sleeps);

    final predictedMinutes = intervals.isEmpty
        ? personalizedAwakeWindowMinutes.toDouble()
        : _average(intervals);
    final sleepReference = lastSleep.sleepEnd ?? lastSleep.time;
    final predictedTime = sleepReference.add(
      Duration(minutes: predictedMinutes.round()),
    );

    return Prediction(
      title: 'Další spánek',
      description: 'Odhad podle personalizovaného rytmu bdění a spánku.',
      predictedTime: predictedTime,
      confidence: intervals.length >= 2 ? 0.78 : 0.50,
      signals: [
        if (intervals.isNotEmpty) 'vypočteno z awake window',
        if (intervals.isEmpty) 'použit fallback rytmus',
        'okno bdění ~${predictedMinutes.round()} min',
      ],
    );
  }

  Prediction? _predictNextDiaper(
    List<TimelineItem> items,
    int personalizedIntervalMinutes,
  ) {
    final diapers = items.where((e) => e.type == EventType.diaper).toList();

    if (diapers.isEmpty) return null;

    final lastDiaper = diapers.first;
    final intervals = _intervalsInMinutes(diapers);

    final predictedMinutes = intervals.isEmpty
        ? personalizedIntervalMinutes.toDouble()
        : _average(intervals);
    final predictedTime = lastDiaper.time.add(
      Duration(minutes: predictedMinutes.round()),
    );

    return Prediction(
      title: 'Další přebalení',
      description: 'Odhad podle personalizovaného rytmu přebalení.',
      predictedTime: predictedTime,
      confidence: intervals.length >= 2 ? 0.75 : 0.50,
      signals: [
        if (intervals.isNotEmpty) 'vypočteno z historie přebalení',
        if (intervals.isEmpty) 'použit fallback rytmus',
        'interval ~${predictedMinutes.round()} min',
      ],
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

  double _average(List<int> values) {
    final sum = values.fold<int>(0, (total, value) => total + value);
    return sum / values.length;
  }
}