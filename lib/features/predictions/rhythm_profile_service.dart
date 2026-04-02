import '../../data/repositories/timeline_repository.dart';
import '../intelligence/infant_insights_service.dart';
import '../timeline/timeline_item.dart';
import 'rhythm_profile.dart';

class RhythmProfileService {
  RhythmProfileService(this._repository, this._insights);

  final TimelineRepository _repository;
  final InfantInsightsService _insights;

  Future<RhythmProfile> getProfile() async {
    final items = await _repository.getAll();

    final feedingItems = _insights.getLatestItemsByType(
      items,
      EventType.feeding,
      8,
    );
    final sleepItems = _insights.getLatestItemsByType(
      items,
      EventType.sleep,
      8,
    );
    final diaperItems = _insights.getLatestItemsByType(
      items,
      EventType.diaper,
      8,
    );

    final feedingIntervals = _insights.intervalsInMinutes(feedingItems);
    final awakeWindows = _insights.awakeWindowsInMinutes(sleepItems);
    final diaperIntervals = _insights.intervalsInMinutes(diaperItems);

    return RhythmProfile(
      feedingIntervalMinutes: _insights.resolveAverage(
        values: feedingIntervals,
        fallback: 150,
        min: 60,
        max: 300,
      ),
      awakeWindowMinutes: _insights.resolveAverage(
        values: awakeWindows,
        fallback: 90,
        min: 30,
        max: 240,
      ),
      diaperIntervalMinutes: _insights.resolveAverage(
        values: diaperIntervals,
        fallback: 180,
        min: 60,
        max: 360,
      ),
    );
  }
}