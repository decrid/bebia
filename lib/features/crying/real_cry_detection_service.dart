import 'package:flutter/foundation.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

import '../timeline/timeline_item.dart';
import 'audio_preprocessing_service.dart';
import 'cry_detection_result.dart';
import 'cry_detection_service.dart';
import 'mock_cry_detection_service.dart';

class RealCryDetectionService implements CryDetectionService {
  RealCryDetectionService(
    this._fallback,
    this._audioPreprocessingService,
  );

  static const String _modelAssetPath = 'assets/models/yamnet.tflite';
  static const int _expectedInputLength = 15600;
  static const int _expectedOutputClasses = 521;

  final MockCryDetectionService _fallback;
  final AudioPreprocessingService _audioPreprocessingService;

  Interpreter? _interpreter;
  Future<void>? _initializationFuture;
  bool _initializationFailed = false;

  bool get isInitialized => _interpreter != null;

  Future<void> initialize() {
    return _initializationFuture ??= _initializeInternal();
  }

  Future<void> _initializeInternal() async {
    if (_interpreter != null || _initializationFailed) {
      return;
    }

    if (defaultTargetPlatform != TargetPlatform.android) {
      debugPrint(
        'RealCryDetectionService: TFLite bootstrap skipped on '
        '$defaultTargetPlatform.',
      );
      return;
    }

    try {
      debugPrint(
        'RealCryDetectionService: loading TFLite model from '
        '$_modelAssetPath',
      );

      final options = InterpreterOptions()..threads = 2;

      final interpreter = await Interpreter.fromAsset(
        _modelAssetPath,
        options: options,
      );

      _interpreter = interpreter;

      final inputTensors = interpreter.getInputTensors();
      final outputTensors = interpreter.getOutputTensors();

      debugPrint(
        'RealCryDetectionService: TFLite model loaded successfully.',
      );
      debugPrint(
        'RealCryDetectionService: input tensors count = '
        '${inputTensors.length}',
      );
      debugPrint(
        'RealCryDetectionService: output tensors count = '
        '${outputTensors.length}',
      );

      for (var i = 0; i < inputTensors.length; i++) {
        final tensor = inputTensors[i];
        debugPrint(
          'RealCryDetectionService: input[$i] '
          'name=${tensor.name}, '
          'shape=${tensor.shape}, '
          'type=${tensor.type}',
        );
      }

      for (var i = 0; i < outputTensors.length; i++) {
        final tensor = outputTensors[i];
        debugPrint(
          'RealCryDetectionService: output[$i] '
          'name=${tensor.name}, '
          'shape=${tensor.shape}, '
          'type=${tensor.type}',
        );
      }
    } catch (error, stackTrace) {
      _initializationFailed = true;
      debugPrint(
        'RealCryDetectionService: failed to load TFLite model: $error',
      );
      debugPrintStack(stackTrace: stackTrace);
      rethrow;
    }
  }

  @override
  Future<CryDetectionResult> detect(TimelineItem cryingItem) async {
    if (defaultTargetPlatform != TargetPlatform.android) {
      return _fallback.detect(cryingItem);
    }

    try {
      await initialize();
    } catch (_) {
      return _fallback.detect(cryingItem);
    }

    if (_interpreter == null) {
      return _fallback.detect(cryingItem);
    }

    try {
      final audio = await _audioPreprocessingService.prepare(
        cryingItem.audioSamplePath,
      );

      if (!audio.hasUsableAudio ||
          audio.features == null ||
          audio.normalizedSamples == null) {
        debugPrint(
          'RealCryDetectionService: skipping inference - audio not usable.',
        );
        return _fallback.detect(cryingItem);
      }

      final features = audio.features!;
      final normalizedSamples = audio.normalizedSamples!;

      if (features.sampleRate != 16000) {
        debugPrint(
          'RealCryDetectionService: skipping inference - unsupported '
          'sampleRate=${features.sampleRate}, expected 16000.',
        );
        return _fallback.detect(cryingItem);
      }

      final input = _buildModelInput(normalizedSamples);
      final output = List.generate(
        1,
        (_) => List<double>.filled(_expectedOutputClasses, 0.0),
      );

      _interpreter!.run(input, output);

      final scores = output.first;
      final topPredictions = _topPredictions(scores, limit: 5);

      debugPrint(
        'RealCryDetectionService: inference completed for '
        '${cryingItem.audioSamplePath}',
      );
      debugPrint(
        'RealCryDetectionService: model input length=${input.length}, '
        'source samples=${normalizedSamples.length}, '
        'durationMs=${features.durationMs}',
      );

      for (final prediction in topPredictions) {
        debugPrint(
          'RealCryDetectionService: top class #${prediction.index} '
          'score=${prediction.score.toStringAsFixed(4)}',
        );
      }
    } catch (error, stackTrace) {
      debugPrint(
        'RealCryDetectionService: inference probe failed: $error',
      );
      debugPrintStack(stackTrace: stackTrace);
    }

    return _fallback.detect(cryingItem);
  }

  List<double> _buildModelInput(List<double> samples) {
    if (samples.length == _expectedInputLength) {
      return List<double>.from(samples);
    }

    if (samples.length > _expectedInputLength) {
      return samples.sublist(0, _expectedInputLength);
    }

    final padded = List<double>.filled(_expectedInputLength, 0.0);
    for (var i = 0; i < samples.length; i++) {
      padded[i] = samples[i];
    }
    return padded;
  }

  List<_IndexedScore> _topPredictions(
    List<double> scores, {
    required int limit,
  }) {
    final indexed = <_IndexedScore>[];

    for (var i = 0; i < scores.length; i++) {
      indexed.add(
        _IndexedScore(
          index: i,
          score: scores[i],
        ),
      );
    }

    indexed.sort((a, b) => b.score.compareTo(a.score));

    if (indexed.length <= limit) {
      return indexed;
    }

    return indexed.sublist(0, limit);
  }

  void dispose() {
    _interpreter?.close();
    _interpreter = null;
    _initializationFuture = null;
    _initializationFailed = false;
  }
}

class _IndexedScore {
  const _IndexedScore({
    required this.index,
    required this.score,
  });

  final int index;
  final double score;
}