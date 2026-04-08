import '../../data/repositories/timeline_repository.dart';
import '../intelligence/infant_insights_service.dart';
import '../timeline/timeline_item.dart';
import 'crying_analysis_result.dart';

class CryingAnalysisService {
  CryingAnalysisService(this._repository, this._insights);

  final TimelineRepository _repository;
  final InfantInsightsService _insights;

  Future<CryingAnalysisResult?> analyzeLatestCrying() async {
    final items = await _repository.getAll();

    final lastCrying = _insights.getLastByType(items, EventType.crying);
    final lastFeeding = _insights.getLastByType(items, EventType.feeding);
    final lastSleep = _insights.getLastByType(items, EventType.sleep);
    final lastDiaper = _insights.getLastByType(items, EventType.diaper);

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

    final recentCryings = _insights.getLatestItemsByType(
      items,
      EventType.crying,
      5,
    );

    final durationMinutes = lastCrying.cryingDurationMinutes;
    if (durationMinutes != null) {
      if (durationMinutes >= 10) {
        hungerScore += 0.10;
        tiredScore += 0.10;
        diaperScore += 0.10;
        signals.add('pláč trvá déle');
      }

      if (durationMinutes >= 20) {
        hungerScore += 0.10;
        tiredScore += 0.10;
        diaperScore += 0.10;
        signals.add('delší epizoda pláče');
      }
    }

    final feedingSoothingCount = recentCryings
        .where((item) => item.soothingMethod == 'feeding')
        .length;

    if (feedingSoothingCount >= 2) {
      hungerScore += 0.20;
      signals.add('krmení opakovaně pomohlo uklidnit');
    } else if (lastCrying.soothingMethod == 'feeding' &&
        (lastCrying.cryingResolved ?? false)) {
      hungerScore += 0.10;
      signals.add('krmení pomohlo při posledním pláči');
    }

    final soothingResponsiveCount = recentCryings
        .where(
          (item) =>
              item.soothingMethod == 'rocking' ||
              item.soothingMethod == 'carrying',
        )
        .length;

    if (soothingResponsiveCount >= 2) {
      signals.add('dítě reaguje na houpání nebo nošení');
    } else if ((lastCrying.soothingMethod == 'rocking' ||
            lastCrying.soothingMethod == 'carrying') &&
        (lastCrying.cryingResolved ?? false)) {
      signals.add('posledně pomohlo houpání nebo nošení');
    }

    final unresolvedCount = recentCryings
        .where((item) => item.cryingResolved == false)
        .length;

    final resolvedCount = recentCryings
        .where((item) => item.cryingResolved == true)
        .length;

    final scores = {
      'hunger': hungerScore,
      'tired': tiredScore,
      'discomfort': diaperScore,
    };

    final sorted = scores.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final best = sorted.first;

    if (best.value == 0) return null;

    double confidence = best.value;

    if (lastCrying.cryingResolved == false) {
      confidence += 0.10;
      signals.add('dítě se zatím neuklidnilo');
    }

    if (unresolvedCount >= 2) {
      confidence += 0.10;
      signals.add('opakovaně se nedaří rychle uklidnit');
    }

    if (resolvedCount >= 3 && unresolvedCount == 0) {
      confidence -= 0.05;
      signals.add('pláč se v poslední době dařilo uklidnit');
    }

    final nextStep = _buildNextStep(best.key);

    return CryingAnalysisResult(
      probableCause: best.key,
      confidence: confidence.clamp(0.0, 1.0),
      signals: signals,
      nextStepType: nextStep.type,
      nextStepTitle: nextStep.title,
      nextStepDescription: nextStep.description,
    );
  }

  _CryingNextStep _buildNextStep(String probableCause) {
    switch (probableCause) {
      case 'hunger':
        return const _CryingNextStep(
          type: CryingNextStepType.feeding,
          title: 'Zkusit krmení',
          description: 'Nabídni mléko nebo rovnou zapiš krmení.',
        );
      case 'tired':
        return const _CryingNextStep(
          type: CryingNextStepType.sleep,
          title: 'Připravit spánek',
          description: 'Zkus klidné prostředí a jemné uspávání.',
        );
      case 'discomfort':
        return const _CryingNextStep(
          type: CryingNextStepType.diaper,
          title: 'Zkontrolovat plenku',
          description: 'Ověř komfort a případně proveď přebalení.',
        );
      default:
        return const _CryingNextStep(
          type: CryingNextStepType.soothing,
          title: 'Uklidnění a kontakt',
          description: 'Zkus chování, nošení nebo jemné houpání.',
        );
    }
  }
}

class _CryingNextStep {
  const _CryingNextStep({
    required this.type,
    required this.title,
    required this.description,
  });

  final CryingNextStepType type;
  final String title;
  final String description;
}
