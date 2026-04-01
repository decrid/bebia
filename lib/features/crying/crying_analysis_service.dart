import '../../data/repositories/timeline_repository.dart';
import '../timeline/timeline_item.dart';
import 'crying_analysis_result.dart';

class CryingAnalysisService {
  CryingAnalysisService(this._repository);

  final TimelineRepository _repository;

  Future<CryingAnalysisResult?> analyzeLatestCrying() async {
    final items = await _repository.getAll();

    TimelineItem? lastCrying;
    TimelineItem? lastFeeding;
    TimelineItem? lastSleep;
    TimelineItem? lastDiaper;

    for (final item in items) {
      if (lastCrying == null && item.type == EventType.crying) {
        lastCrying = item;
      }
      if (lastFeeding == null && item.type == EventType.feeding) {
        lastFeeding = item;
      }
      if (lastSleep == null && item.type == EventType.sleep) {
        lastSleep = item;
      }
      if (lastDiaper == null && item.type == EventType.diaper) {
        lastDiaper = item;
      }
    }

    if (lastCrying == null) return null;

    final now = DateTime.now();

    double hungerScore = 0;
    double tiredScore = 0;
    double diaperScore = 0;

    final signals = <String>[];

    if (lastFeeding != null) {
      final diff = now.difference(lastFeeding.time).inMinutes;
      if (diff > 120) {
        hungerScore += 0.5;
        signals.add('dlouhá doba od krmení');
      }
    }

    if (lastSleep != null) {
      final ref = lastSleep.sleepEnd ?? lastSleep.time;
      final diff = now.difference(ref).inMinutes;

      if (diff > 90) {
        tiredScore += 0.5;
        signals.add('dlouhá doba bez spánku');
      }
    }

    if (lastDiaper != null) {
      final diff = now.difference(lastDiaper.time).inMinutes;

      if (diff > 180) {
        diaperScore += 0.5;
        signals.add('dlouho bez přebalení');
      }
    }

    final scores = {
      'hunger': hungerScore,
      'tired': tiredScore,
      'discomfort': diaperScore,
    };

    final sorted = scores.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final best = sorted.first;

    if (best.value == 0) return null;

    return CryingAnalysisResult(
      probableCause: best.key,
      confidence: best.value,
      signals: signals,
    );
  }
}