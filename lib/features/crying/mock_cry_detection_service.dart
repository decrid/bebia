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
        modelVersion: 'mock-audio-v1',
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

    double probability = 0.35;
    final signals = <String>[
      'audio vzorek dostupný',
    ];

    final intensity = cryingItem.cryingIntensity;
    if (intensity != null) {
      if (intensity >= 3) {
        probability += 0.15;
        signals.add('vyšší intenzita pláče');
      }
      if (intensity >= 4) {
        probability += 0.15;
        signals.add('velmi vysoká intenzita');
      }
    }

    final duration = cryingItem.cryingDurationMinutes;
    if (duration != null) {
      if (duration >= 1) {
        probability += 0.10;
        signals.add('pláč má měřitelnou délku');
      }
      if (duration >= 5) {
        probability += 0.10;
        signals.add('delší audio kontext');
      }
    }

    if (audio.fileSizeBytes >= 32000) {
      probability += 0.10;
      signals.add('delší audio vzorek');
    }

    probability = probability.clamp(0.0, 0.95).toDouble();

    return CryDetectionResult(
      hasUsableAudio: true,
      cryDetected: probability >= 0.5,
      cryProbability: probability,
      modelVersion: 'mock-audio-v1',
      signals: signals,
    );
  }
}