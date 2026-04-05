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

    if (!audio.hasUsableAudio) {
      return CryDetectionResult(
        hasUsableAudio: false,
        cryDetected: false,
        cryProbability: 0.0,
        modelVersion: 'mock-audio-v2',
        signals: [
          if (cryingItem.audioSamplePath == null ||
              cryingItem.audioSamplePath!.trim().isEmpty)
            'bez audio vzorku'
          else if (!audio.fileExists)
            'audio soubor nebyl nalezen'
          else
            'audio vzorek je příliš krátký nebo prázdný',
        ],
      );
    }

    double probability = 0.10;
    final signals = <String>[
      'audio vzorek dostupný',
    ];

    final intensity = cryingItem.cryingIntensity;
    if (intensity != null) {
      if (intensity >= 4) {
        probability += 0.15;
        signals.add('velmi vysoká intenzita');
      } else if (intensity == 3) {
        probability += 0.05;
        signals.add('střední intenzita');
      }
    }

    final duration = cryingItem.cryingDurationMinutes;
    if (duration != null) {
      if (duration >= 3) {
        probability += 0.10;
        signals.add('pláč má delší trvání');
      }
      if (duration >= 10) {
        probability += 0.15;
        signals.add('výrazně delší epizoda');
      }
    }

    if (audio.fileSizeBytes >= 32000) {
      probability += 0.05;
      signals.add('delší audio vzorek');
    }

    if ((cryingItem.cryingResolved ?? false) == false) {
      probability += 0.05;
      signals.add('dítě se zatím neuklidnilo');
    }

    probability = probability.clamp(0.0, 0.90).toDouble();

    final cryDetected = probability >= 0.70;

    if (!cryDetected) {
      signals.add('mock pipeline zatím nemá dost silných signálů pro potvrzení pláče');
    }

    return CryDetectionResult(
      hasUsableAudio: true,
      cryDetected: cryDetected,
      cryProbability: probability,
      modelVersion: 'mock-audio-v2',
      signals: signals,
    );
  }
}