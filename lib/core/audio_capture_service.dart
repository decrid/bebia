import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

abstract interface class AudioCapture {
  Future<bool> hasPermission({bool request = true});

  Future<String> startRecording();

  Future<String?> stopRecording();

  Future<void> cancelRecording();

  Future<void> deleteRecording(String path);

  Future<bool> isRecording();
}

sealed class AudioCaptureException implements Exception {
  const AudioCaptureException(this.message);

  final String message;

  @override
  String toString() => message;
}

final class AudioPermissionDeniedException extends AudioCaptureException {
  const AudioPermissionDeniedException()
    : super('Přístup k mikrofonu nebyl udělen. Povol ho v nastavení aplikace.');
}

final class AudioCaptureStartException extends AudioCaptureException {
  const AudioCaptureStartException(super.message);
}

final class AudioCaptureStopException extends AudioCaptureException {
  const AudioCaptureStopException(super.message);
}

final class AudioCaptureFileException extends AudioCaptureException {
  const AudioCaptureFileException(super.message);
}

class AudioCaptureService implements AudioCapture {
  AudioCaptureService();

  final AudioRecorder _recorder = AudioRecorder();

  @override
  Future<bool> hasPermission({bool request = true}) {
    return _recorder.hasPermission(request: request);
  }

  @override
  Future<String> startRecording() async {
    final hasPermission = await _recorder.hasPermission(request: true);

    if (!hasPermission) {
      throw const AudioPermissionDeniedException();
    }

    try {
      final tempDir = await getTemporaryDirectory();
      final fileName = 'crying_${DateTime.now().millisecondsSinceEpoch}.wav';
      final filePath = p.join(tempDir.path, fileName);

      await _recorder.start(
        const RecordConfig(
          encoder: AudioEncoder.wav,
          sampleRate: 16000,
          numChannels: 1,
        ),
        path: filePath,
      );

      if (!await _recorder.isRecording()) {
        await _recorder.cancel();
        throw const AudioCaptureStartException(
          'Nahrávání se po spuštění nepotvrdilo.',
        );
      }

      return filePath;
    } on AudioCaptureException {
      rethrow;
    } catch (error) {
      try {
        await _recorder.cancel();
      } catch (_) {
        // Původní chyba spuštění má pro volajícího vyšší diagnostickou hodnotu.
      }
      throw AudioCaptureStartException(
        'Mikrofon se nepodařilo spustit: $error',
      );
    }
  }

  @override
  Future<String?> stopRecording() async {
    try {
      final path = await _recorder.stop();
      if (path == null || path.isEmpty) {
        throw const AudioCaptureStopException(
          'Nahrávání skončilo bez použitelného audio souboru.',
        );
      }
      return path;
    } on AudioCaptureException {
      rethrow;
    } catch (error) {
      throw AudioCaptureStopException(
        'Nahrávání se nepodařilo zastavit: $error',
      );
    }
  }

  @override
  Future<void> cancelRecording() async {
    await _recorder.cancel();
  }

  @override
  Future<void> deleteRecording(String path) async {
    final tempDirectory = await getTemporaryDirectory();
    final normalizedRoot = p.normalize(p.absolute(tempDirectory.path));
    final normalizedPath = p.normalize(p.absolute(path));
    final isOwnedRecording =
        p.isWithin(normalizedRoot, normalizedPath) &&
        p.basename(normalizedPath).startsWith('crying_') &&
        p.extension(normalizedPath).toLowerCase() == '.wav';
    if (!isOwnedRecording) {
      throw const AudioCaptureFileException(
        'Audio soubor neleží v bezpečném dočasném prostoru Bebia.',
      );
    }

    final file = File(normalizedPath);
    if (await file.exists()) {
      await file.delete();
    }
  }

  @override
  Future<bool> isRecording() {
    return _recorder.isRecording();
  }

  Future<void> dispose() async {
    await _recorder.dispose();
  }
}
