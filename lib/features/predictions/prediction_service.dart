import '../../data/repositories/timeline_repository.dart';
import '../intelligence/infant_insights_service.dart';
import '../profile/child_profile_controller.dart';
import '../timeline/timeline_item.dart';
import 'prediction_model.dart';
import 'rhythm_profile_service.dart';

class PredictionService {
  PredictionService(
    this._repository,
    this._rhythmProfileService,
    this._insights,
    this._childProfileController,
  );

  final TimelineRepository _repository;
  final RhythmProfileService _rhythmProfileService;
  final InfantInsightsService _insights;
  final ChildProfileController _childProfileController;

  Future<List<Prediction>> getPredictions() async {
    final items = await _repository.getAll(
      childId: _childProfileController.activeProfileId.value,
    );

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
    final intervals = _insights.intervalsInMinutes(feedings);

    final predictedMinutes = intervals.isEmpty
        ? personalizedIntervalMinutes.toDouble()
        : _insights.average(intervals);
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
    final intervals = _insights.awakeWindowsInMinutes(sleeps);

    final predictedMinutes = intervals.isEmpty
        ? personalizedAwakeWindowMinutes.toDouble()
        : _insights.average(intervals);
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
    final intervals = _insights.intervalsInMinutes(diapers);

    final predictedMinutes = intervals.isEmpty
        ? personalizedIntervalMinutes.toDouble()
        : _insights.average(intervals);
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
}
