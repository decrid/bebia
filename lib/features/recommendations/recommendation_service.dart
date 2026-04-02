import '../../data/repositories/timeline_repository.dart';
import '../intelligence/infant_insights_service.dart';
import '../timeline/timeline_item.dart';
import 'recommendation_model.dart';

class RecommendationService {
  RecommendationService(this._repository, this._insights);

  final TimelineRepository _repository;
  final InfantInsightsService _insights;

  Future<List<Recommendation>> getRecommendations() async {
    final items = await _repository.getAll();

    if (items.isEmpty) return [];

    final context = _buildContext(items, DateTime.now());

    final recommendations = <Recommendation?>[
      _buildHungerRecommendation(context),
      _buildTiredRecommendation(context),
      _buildDiaperRecommendation(context),
      _buildSoothingRecommendation(context),
    ].whereType<Recommendation>().toList();

    recommendations.sort((a, b) => b.score.compareTo(a.score));

    return recommendations.take(3).toList();
  }

  _RecommendationContext _buildContext(
    List<TimelineItem> items,
    DateTime now,
  ) {
    final recentCryings = _insights.getRecentEventsByType(
      items,
      EventType.crying,
      30,
      now,
    );

    return _RecommendationContext(
      now: now,
      lastFeeding: _insights.getLastByType(items, EventType.feeding),
      lastSleep: _insights.getLastByType(items, EventType.sleep),
      lastDiaper: _insights.getLastByType(items, EventType.diaper),
      recentCryings: recentCryings,
      averageCryingIntensity: _insights.averageCryingIntensity(recentCryings),
      allItems: items,
    );
  }

  Recommendation? _buildHungerRecommendation(_RecommendationContext context) {
    double score = 0.0;
    final reasons = <String>[];

    final lastFeeding = context.lastFeeding;
    if (lastFeeding == null) return null;

    final feedingDiff = context.now.difference(lastFeeding.time).inMinutes;

    if (feedingDiff >= 120) {
      score += 0.30;
      reasons.add('od posledního krmení uplynuly více než 2 hodiny');
    }
    if (feedingDiff >= 150) score += 0.20;
    if (feedingDiff >= 180) score += 0.20;

    if (lastFeeding.feedingAmountMl != null) {
      final amount = lastFeeding.feedingAmountMl!;

      if (amount <= 60 && feedingDiff >= 60) {
        score += 0.15;
        reasons.add('poslední krmení bylo spíše menší');
      } else if (amount <= 90 && feedingDiff >= 90) {
        score += 0.10;
        reasons.add('poslední krmení nemuselo být plně dostačující');
      }
    }

    if (context.hasRecentCrying) {
      score += 0.20;
      reasons.add('dítě nedávno plakalo');
    }

    if (context.averageCryingIntensity != null &&
        context.averageCryingIntensity! >= 4) {
      score += 0.10;
    }

    final feedingLast = _insights.getLatestItemsByType(
      context.allItems,
      EventType.feeding,
      5,
    );

    if (feedingLast.length >= 3) {
      score += 0.10;
    }

    if (score < 0.40) return null;

    return Recommendation(
      title: 'Možný hlad',
      description: _buildDescription(
        fallback: 'Zkus zkontrolovat, zda není čas na další krmení.',
        reasons: reasons,
      ),
      score: score.clamp(0.0, 1.0),
    );
  }

  Recommendation? _buildTiredRecommendation(_RecommendationContext context) {
    double score = 0.0;
    final reasons = <String>[];

    final lastSleep = context.lastSleep;
    if (lastSleep == null) return null;

    final sleepReferenceTime = lastSleep.sleepEnd ?? lastSleep.time;
    final sleepDiff = context.now.difference(sleepReferenceTime).inMinutes;

    if (sleepDiff >= 75) {
      score += 0.25;
      reasons.add('dítě je delší dobu vzhůru');
    }
    if (sleepDiff >= 90) score += 0.20;
    if (sleepDiff >= 120) score += 0.25;

    if (lastSleep.sleepDurationMinutes != null) {
      final duration = lastSleep.sleepDurationMinutes!;

      if (duration <= 30 && sleepDiff >= 45) {
        score += 0.15;
        reasons.add('poslední spánek byl krátký');
      } else if (duration <= 45 && sleepDiff >= 60) {
        score += 0.10;
        reasons.add('poslední odpočinek mohl být nedostatečný');
      }
    }

    if (context.hasRecentCrying) {
      score += 0.15;
      reasons.add('pláč může souviset s únavou');
    }

    if (context.averageCryingIntensity != null &&
        context.averageCryingIntensity! >= 4) {
      score += 0.10;
    }

    if (_insights.hasShortSleepPattern(context.allItems)) {
      score += 0.15;
      reasons.add('opakované krátké spánky');
    }

    if (score < 0.40) return null;

    return Recommendation(
      title: 'Možná únava',
      description: _buildDescription(
        fallback: 'Zkus klidový režim, uspávání nebo ztišení podnětů.',
        reasons: reasons,
      ),
      score: score.clamp(0.0, 1.0),
    );
  }

  Recommendation? _buildDiaperRecommendation(_RecommendationContext context) {
    double score = 0.0;
    final reasons = <String>[];

    final lastDiaper = context.lastDiaper;

    if (lastDiaper != null) {
      final diaperDiff = context.now.difference(lastDiaper.time).inMinutes;

      if (diaperDiff >= 120) {
        score += 0.20;
        reasons.add('od posledního přebalení uplynula delší doba');
      }
      if (diaperDiff >= 180) score += 0.20;
      if (diaperDiff >= 240) score += 0.20;

      if (lastDiaper.diaperType == 'poop' || lastDiaper.diaperType == 'both') {
        score += 0.10;
        reasons.add('poslední přebalení zahrnovalo stolici');
      }

      if (context.hasRecentCrying) {
        score += 0.15;
        reasons.add('pláč může souviset s diskomfortem');
      }

      if (context.averageCryingIntensity != null &&
          context.averageCryingIntensity! >= 4) {
        score += 0.10;
      }
    } else if (context.hasRecentCrying) {
      score += 0.20;
      reasons.add('není evidované žádné přebalení a dítě plakalo');
    }

    if (score < 0.35) return null;

    return Recommendation(
      title: 'Možný diskomfort',
      description: _buildDescription(
        fallback: 'Zkontroluj plenku nebo celkový komfort dítěte.',
        reasons: reasons,
      ),
      score: score.clamp(0.0, 1.0),
    );
  }

  Recommendation? _buildSoothingRecommendation(
    _RecommendationContext context,
  ) {
    double score = 0.0;
    final reasons = <String>[];

    if (context.hasRecentCrying) {
      score += 0.25;
      reasons.add('dítě nedávno plakalo');
    }

    if (context.cryingCount >= 2) {
      score += 0.20;
      reasons.add('pláč se opakoval vícekrát za krátkou dobu');
    }

    if (context.cryingCount >= 3) {
      score += 0.20;
    }

    if (context.averageCryingIntensity != null) {
      if (context.averageCryingIntensity! >= 3) {
        score += 0.10;
        reasons.add('pláč byl intenzivnější');
      }
      if (context.averageCryingIntensity! >= 4) {
        score += 0.15;
      }
    }

    final cryingLast60 = _insights.countRecentEvents(
      context.allItems,
      EventType.crying,
      60,
      context.now,
    );

    if (cryingLast60 >= 3) {
      score += 0.25;
      reasons.add('častý pláč v krátkém čase');
    }

    if (score < 0.35) return null;

    return Recommendation(
      title: 'Potřeba uklidnění',
      description: _buildDescription(
        fallback: 'Zkus chování, kontakt, houpání nebo klidné prostředí.',
        reasons: reasons,
      ),
      score: score.clamp(0.0, 1.0),
    );
  }

  String _buildDescription({
    required String fallback,
    required List<String> reasons,
  }) {
    if (reasons.isEmpty) return fallback;
    return '$fallback Důvod: ${reasons.join(', ')}.';
  }
}

class _RecommendationContext {
  const _RecommendationContext({
    required this.now,
    required this.lastFeeding,
    required this.lastSleep,
    required this.lastDiaper,
    required this.recentCryings,
    required this.averageCryingIntensity,
    required this.allItems,
  });

  final DateTime now;
  final TimelineItem? lastFeeding;
  final TimelineItem? lastSleep;
  final TimelineItem? lastDiaper;
  final List<TimelineItem> recentCryings;
  final double? averageCryingIntensity;
  final List<TimelineItem> allItems;

  bool get hasRecentCrying => recentCryings.isNotEmpty;
  int get cryingCount => recentCryings.length;
}