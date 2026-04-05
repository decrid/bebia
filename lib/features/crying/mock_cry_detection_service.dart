import '../timeline/timeline_item.dart';
import 'audio_preprocessing_service.dart';
import 'cry_detection_result.dart';

class MockCryDetectionService {
  MockCryDetectionService(this._audioPreprocessingService);

  final AudioPreprocessingService _audioPreprocessingService;

  Future<CryDetectionResult> detect(TimelineItem cryingItem) async {
    final audio = await _audioPreprocessingService.prepare(
      cryingItem.audioSamplePath,
    );

    if (!audio.hasUsableAudio || audio.features == null) {
      return CryDetectionResult(
        hasUsableAudio: false,
        cryDetected: false,
        cryProbability: 0.0,
        modelVersion: 'mock-audio-v3',
        signals: [
          if (cryingItem.audioSamplePath == null ||
              cryingItem.audioSamplePath!.trim().isEmpty)
            'bez audio vzorku'
          else if (!audio.fileExists)
            'audio soubor nebyl nalezen'
          else
            'audio vzorek není dostatečně použitelný',
        ],
      );
    }

    final features = audio.features!;

    double probability = 0.0;
    final signals = <String>[
      'audio vzorek analyzován ze signálu',
    ];

    if (features.durationMs >= 700) {
      probability += 0.08;
      signals.add('dostatečná délka vzorku');
    }

    if (features.durationMs >= 1500) {
      probability += 0.07;
      signals.add('delší zachycený úsek');
    }

    if (features.rms >= 0.03) {
      probability += 0.15;
      signals.add('vyšší průměrná energie signálu');
    } else {
      signals.add('nízká průměrná energie signálu');
    }

    if (features.peakAmplitude >= 0.20) {
      probability += 0.10;
      signals.add('výrazné špičky hlasitosti');
    }

    if (features.activeFrameRatio >= 0.35) {
      probability += 0.15;
      signals.add('vyšší podíl aktivních rámců');
    } else {
      signals.add('vyšší podíl tichých částí');
    }

    if (features.zeroCrossingRate >= 0.03 &&
        features.zeroCrossingRate <= 0.18) {
      probability += 0.12;
      signals.add('zero crossing rate v očekávaném rozsahu');
    } else {
      signals.add('zero crossing rate mimo očekávaný rozsah');
    }

    final intensity = cryingItem.cryingIntensity;
    if (intensity != null) {
      if (intensity >= 4) {
        probability += 0.10;
        signals.add('ručně zadaná vysoká intenzita');
      } else if (intensity == 3) {
        probability += 0.05;
        signals.add('ručně zadaná střední intenzita');
      }
    }

    final duration = cryingItem.cryingDurationMinutes;
    if (duration != null && duration >= 3) {
      probability += 0.06;
      signals.add('ručně zadané delší trvání');
    }

    if ((cryingItem.cryingResolved ?? false) == false) {
      probability += 0.04;
      signals.add('dítě se zatím neuklidnilo');
    }

    probability = probability.clamp(0.0, 0.95).toDouble();

    final cryDetected = probability >= 0.62;

    if (!cryDetected) {
      signals.add('signál zatím není dost silný pro potvrzení pláče');
    }

    return CryDetectionResult(
      hasUsableAudio: true,
      cryDetected: cryDetected,
      cryProbability: probability,
      modelVersion: 'mock-audio-v3',
      signals: signals,
    );
  }
}