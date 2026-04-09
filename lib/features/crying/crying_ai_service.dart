import '../../data/repositories/timeline_repository.dart';
import '../profile/child_profile_controller.dart';
import '../timeline/timeline_item.dart';
import 'ai_crying_analysis_result.dart';
import 'cry_detection_service.dart';

class CryingAiService {
  CryingAiService(
    this._repository,
    this._cryDetectionService,
    this._childProfileController,
  );

  final TimelineRepository _repository;
  final CryDetectionService _cryDetectionService;
  final ChildProfileController _childProfileController;

  Future<AiCryingAnalysisResult> analyzeCryingItem(
    TimelineItem cryingItem,
  ) async {
    final audioDetection = await _cryDetectionService.detect(cryingItem);
    final items = await _repository.getAll(
      childId: _childProfileController.activeProfileId.value,
    );

    final mergedItems = <TimelineItem>[
      cryingItem,
      ...items.where((item) => item.id != cryingItem.id),
    ]..sort((a, b) => b.time.compareTo(a.time));

    final referenceTime = cryingItem.time;

    final lastFeeding = _getLastEventBefore(
      mergedItems,
      EventType.feeding,
      referenceTime,
    );
    final lastSleep = _getLastEventBefore(
      mergedItems,
      EventType.sleep,
      referenceTime,
    );
    final lastDiaper = _getLastEventBefore(
      mergedItems,
      EventType.diaper,
      referenceTime,
    );

    final recentCryings = mergedItems
        .where(
          (item) =>
              item.type == EventType.crying &&
              !item.time.isAfter(referenceTime),
        )
        .take(5)
        .toList();

    double hungerScore = 0;
    double tiredScore = 0;
    double diaperScore = 0;

    final signals = <String>[...audioDetection.signals];

    if (lastFeeding != null) {
      final diff = referenceTime.difference(lastFeeding.time).inMinutes;
      if (diff > 120) {
        hungerScore += 0.5;
        signals.add('dlouhá doba od krmení');
      }
    }

    if (lastSleep != null) {
      final ref = lastSleep.sleepEnd ?? lastSleep.time;
      final diff = referenceTime.difference(ref).inMinutes;

      if (diff > 90) {
        tiredScore += 0.5;
        signals.add('dlouhá doba bez spánku');
      }
    }

    if (lastDiaper != null) {
      final diff = referenceTime.difference(lastDiaper.time).inMinutes;

      if (diff > 180) {
        diaperScore += 0.5;
        signals.add('dlouho bez přebalení');
      }
    }

    final durationMinutes = cryingItem.cryingDurationMinutes;
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
    } else if (cryingItem.soothingMethod == 'feeding' &&
        (cryingItem.cryingResolved ?? false)) {
      hungerScore += 0.10;
      signals.add('krmení pomohlo při tomto pláči');
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
    } else if ((cryingItem.soothingMethod == 'rocking' ||
            cryingItem.soothingMethod == 'carrying') &&
        (cryingItem.cryingResolved ?? false)) {
      signals.add('houpání nebo nošení pomohlo při tomto pláči');
    }

    final unresolvedCount = recentCryings
        .where((item) => item.cryingResolved == false)
        .length;

    final scores = {
      'hunger': hungerScore,
      'tired': tiredScore,
      'discomfort': diaperScore,
    };

    if (audioDetection.hasUsableAudio) {
      final audioBoost = (audioDetection.cryProbability * 0.2).clamp(0.0, 0.2);
      scores.updateAll((key, value) => value + audioBoost);
    }

    if (!audioDetection.cryDetected && audioDetection.hasUsableAudio) {
      signals.add('audio zatím pláč nepotvrdilo s vysokou jistotou');
    }

    final sorted = scores.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final best = sorted.first;

    double confidence = best.value;

    if (cryingItem.cryingResolved == false) {
      confidence += 0.10;
      signals.add('dítě se zatím neuklidnilo');
    }

    if (unresolvedCount >= 2) {
      confidence += 0.10;
      signals.add('opakovaně se nedaří rychle uklidnit');
    }

    confidence = confidence.clamp(0.0, 1.0);

    return AiCryingAnalysisResult(
      cryDetected: audioDetection.cryDetected,
      cryProbability: audioDetection.cryProbability,
      probableCause: best.key,
      confidence: confidence,
      signals: signals,
      modelVersion: audioDetection.modelVersion,
    );
  }

  TimelineItem? _getLastEventBefore(
    List<TimelineItem> items,
    EventType type,
    DateTime referenceTime,
  ) {
    for (final item in items) {
      if (item.type == type && !item.time.isAfter(referenceTime)) {
        return item;
      }
    }
    return null;
  }
}
