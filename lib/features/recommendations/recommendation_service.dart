import '../../data/repositories/timeline_repository.dart';
import '../timeline/timeline_item.dart';
import 'recommendation_model.dart';

class RecommendationService {
  RecommendationService(this._repository);

  final TimelineRepository _repository;

  Future<List<Recommendation>> getRecommendations() async {
    final items = await _repository.getAll();

    if (items.isEmpty) return [];

    final now = DateTime.now();

    TimelineItem? lastFeeding;
    TimelineItem? lastSleep;
    TimelineItem? lastDiaper;

    final recentCryings = <TimelineItem>[];

    for (final item in items) {
      if (lastFeeding == null && item.type == EventType.feeding) {
        lastFeeding = item;
      }
      if (lastSleep == null && item.type == EventType.sleep) {
        lastSleep = item;
      }
      if (lastDiaper == null && item.type == EventType.diaper) {
        lastDiaper = item;
      }
      if (item.type == EventType.crying &&
          now.difference(item.time).inMinutes <= 30) {
        recentCryings.add(item);
      }
    }

    double hungerScore = 0.0;
    double tiredScore = 0.0;
    double diaperScore = 0.0;
    double soothingScore = 0.0;

    final reasonsHunger = <String>[];
    final reasonsTired = <String>[];
    final reasonsDiaper = <String>[];
    final reasonsSoothing = <String>[];

    final hasRecentCrying = recentCryings.isNotEmpty;
    final cryingCount = recentCryings.length;

    if (lastFeeding != null) {
      final feedingDiff = now.difference(lastFeeding.time).inMinutes;

      if (feedingDiff >= 120) {
        hungerScore += 0.30;
        reasonsHunger.add('od posledního krmení uplynuly více než 2 hodiny');
      }
      if (feedingDiff >= 150) {
        hungerScore += 0.20;
      }
      if (feedingDiff >= 180) {
        hungerScore += 0.20;
      }

      if (hasRecentCrying) {
        hungerScore += 0.20;
        reasonsHunger.add('dítě nedávno plakalo');
      }
    }

    if (lastSleep != null) {
      final sleepDiff = now.difference(lastSleep.time).inMinutes;

      if (sleepDiff >= 75) {
        tiredScore += 0.25;
        reasonsTired.add('dítě je delší dobu vzhůru');
      }
      if (sleepDiff >= 90) {
        tiredScore += 0.20;
      }
      if (sleepDiff >= 120) {
        tiredScore += 0.25;
      }

      if (hasRecentCrying) {
        tiredScore += 0.15;
        reasonsTired.add('pláč může souviset s únavou');
      }
    }

    if (lastDiaper != null) {
      final diaperDiff = now.difference(lastDiaper.time).inMinutes;

      if (diaperDiff >= 120) {
        diaperScore += 0.20;
        reasonsDiaper.add('od posledního přebalení uplynula delší doba');
      }
      if (diaperDiff >= 180) {
        diaperScore += 0.20;
      }
      if (diaperDiff >= 240) {
        diaperScore += 0.20;
      }

      if (hasRecentCrying) {
        diaperScore += 0.15;
        reasonsDiaper.add('pláč může souviset s diskomfortem');
      }
    } else if (hasRecentCrying) {
      diaperScore += 0.20;
      reasonsDiaper.add('není evidované žádné přebalení a dítě plakalo');
    }

    if (hasRecentCrying) {
      soothingScore += 0.25;
      reasonsSoothing.add('dítě nedávno plakalo');
    }

    if (cryingCount >= 2) {
      soothingScore += 0.20;
      reasonsSoothing.add('pláč se opakoval vícekrát za krátkou dobu');
    }

    if (cryingCount >= 3) {
      soothingScore += 0.20;
    }

    final recommendations = <Recommendation>[];

    if (hungerScore >= 0.40) {
      recommendations.add(
        Recommendation(
          title: 'Možný hlad',
          description: _buildDescription(
            fallback: 'Zkus zkontrolovat, zda není čas na další krmení.',
            reasons: reasonsHunger,
          ),
          score: hungerScore.clamp(0.0, 1.0),
        ),
      );
    }

    if (tiredScore >= 0.40) {
      recommendations.add(
        Recommendation(
          title: 'Možná únava',
          description: _buildDescription(
            fallback: 'Zkus klidový režim, uspávání nebo ztišení podnětů.',
            reasons: reasonsTired,
          ),
          score: tiredScore.clamp(0.0, 1.0),
        ),
      );
    }

    if (diaperScore >= 0.35) {
      recommendations.add(
        Recommendation(
          title: 'Možný diskomfort',
          description: _buildDescription(
            fallback: 'Zkontroluj plenku nebo celkový komfort dítěte.',
            reasons: reasonsDiaper,
          ),
          score: diaperScore.clamp(0.0, 1.0),
        ),
      );
    }

    if (soothingScore >= 0.35) {
      recommendations.add(
        Recommendation(
          title: 'Potřeba uklidnění',
          description: _buildDescription(
            fallback: 'Zkus chování, kontakt, houpání nebo klidné prostředí.',
            reasons: reasonsSoothing,
          ),
          score: soothingScore.clamp(0.0, 1.0),
        ),
      );
    }

    recommendations.sort((a, b) => b.score.compareTo(a.score));

    return recommendations.take(3).toList();
  }

  String _buildDescription({
    required String fallback,
    required List<String> reasons,
  }) {
    if (reasons.isEmpty) return fallback;
    return '$fallback Důvod: ${reasons.join(', ')}.';
  }
}