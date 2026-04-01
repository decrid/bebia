import '../../data/repositories/timeline_repository.dart';
import '../timeline/timeline_item.dart';
import 'prediction_model.dart';

class PredictionService {
  PredictionService(this._repository);

  final TimelineRepository _repository;

  Future<List<Prediction>> getPredictions() async {
    final items = await _repository.getAll();

    if (items.isEmpty) return [];

    final predictions = <Prediction?>[
      _predictNextFeeding(items),
      _predictNextSleep(items),
      _predictNextDiaper(items),
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

  Prediction? _predictNextFeeding(List<TimelineItem> items) {
    final feedings = items.where((e) => e.type == EventType.feeding).toList();

    if (feedings.isEmpty) return null;

    final lastFeeding = feedings.first;
    final intervals = _intervalsInMinutes(feedings);

    final predictedMinutes = intervals.isEmpty ? 150 : _average(intervals);
    final predictedTime = lastFeeding.time.add(
      Duration(minutes: predictedMinutes.round()),
    );

    return Prediction(
      title: 'Další krmení',
      description: 'Odhad podle předchozích intervalů krmení.',
      predictedTime: predictedTime,
      confidence: intervals.length >= 2 ? 0.75 : 0.45,
    );
  }

  Prediction? _predictNextSleep(List<TimelineItem> items) {
    final sleeps = items.where((e) => e.type == EventType.sleep).toList();

    if (sleeps.isEmpty) return null;

    final lastSleep = sleeps.first;
    final intervals = _intervalsInMinutes(sleeps);

    final predictedMinutes = intervals.isEmpty ? 90 : _average(intervals);
    final sleepReference = lastSleep.sleepEnd ?? lastSleep.time;
    final predictedTime = sleepReference.add(
      Duration(minutes: predictedMinutes.round()),
    );

    return Prediction(
      title: 'Další spánek',
      description: 'Odhad podle předchozího rytmu spánku.',
      predictedTime: predictedTime,
      confidence: intervals.length >= 2 ? 0.70 : 0.40,
    );
  }

  Prediction? _predictNextDiaper(List<TimelineItem> items) {
    final diapers = items.where((e) => e.type == EventType.diaper).toList();

    if (diapers.isEmpty) return null;

    final lastDiaper = diapers.first;
    final intervals = _intervalsInMinutes(diapers);

    final predictedMinutes = intervals.isEmpty ? 180 : _average(intervals);
    final predictedTime = lastDiaper.time.add(
      Duration(minutes: predictedMinutes.round()),
    );

    return Prediction(
      title: 'Další přebalení',
      description: 'Odhad podle předchozích intervalů přebalení.',
      predictedTime: predictedTime,
      confidence: intervals.length >= 2 ? 0.70 : 0.40,
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

  double _average(List<int> values) {
    final sum = values.fold<int>(0, (total, value) => total + value);
    return sum / values.length;
  }
}