import 'package:flutter/foundation.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

import '../timeline/timeline_item.dart';
import 'cry_detection_result.dart';
import 'cry_detection_service.dart';
import 'mock_cry_detection_service.dart';

class RealCryDetectionService implements CryDetectionService {
  RealCryDetectionService(this._fallback);

  static const String _modelAssetPath = 'assets/models/yamnet.tflite';

  final MockCryDetectionService _fallback;

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
      // První krok je pouze bootstrap modelu.
      // Při chybě bezpečně padáme zpět na mock službu.
    }

    return _fallback.detect(cryingItem);
  }

  void dispose() {
    _interpreter?.close();
    _interpreter = null;
    _initializationFuture = null;
    _initializationFailed = false;
  }
}