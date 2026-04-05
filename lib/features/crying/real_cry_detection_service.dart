import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../timeline/timeline_item.dart';
import 'cry_detection_result.dart';
import 'cry_detection_service.dart';
import 'mock_cry_detection_service.dart';

class RealCryDetectionService implements CryDetectionService {
  RealCryDetectionService(this._fallback);

  final MockCryDetectionService _fallback;

  static const MethodChannel _channel = MethodChannel(
    'bebia/audio_classifier',
  );

  @override
  Future<CryDetectionResult> detect(TimelineItem cryingItem) async {
    final audioPath = cryingItem.audioSamplePath;

    if (defaultTargetPlatform != TargetPlatform.android ||
        audioPath == null ||
        audioPath.trim().isEmpty) {
      return _fallback.detect(cryingItem);
    }

    try {
      final result = await _channel.invokeMapMethod<String, dynamic>(
        'classifyAudioFile',
        {
          'audioPath': audioPath,
          'cryThreshold': 0.60,
        },
      );

      if (result == null) {
        return _fallback.detect(cryingItem);
      }

      final rawSignals = (result['signals'] as List<dynamic>? ?? const [])
          .map((item) => item.toString())
          .toList();

      final topCategories =
          (result['topCategories'] as List<dynamic>? ?? const [])
              .whereType<Map>()
              .take(3)
              .map((entry) {
                final name = entry['name']?.toString() ?? 'unknown';
                final score = (entry['score'] as num?)?.toDouble();
                if (score == null) {
                  return name;
                }
                return '$name (${(score * 100).round()} %)';
              })
              .toList();

      final signals = <String>[
        ...rawSignals,
        if (topCategories.isNotEmpty)
          'top kategorie: ${topCategories.join(', ')}',
      ];

      return CryDetectionResult(
        hasUsableAudio: (result['hasUsableAudio'] as bool?) ?? true,
        cryDetected: (result['cryDetected'] as bool?) ?? false,
        cryProbability: (result['cryProbability'] as num?)?.toDouble() ?? 0.0,
        modelVersion:
            result['modelVersion']?.toString() ?? 'yamnet-v1',
        signals: signals,
      );
    } on PlatformException {
      return _fallback.detect(cryingItem);
    } catch (_) {
      return _fallback.detect(cryingItem);
    }
  }
}