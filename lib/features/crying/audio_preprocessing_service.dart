import 'dart:io';

import 'audio_preprocessing_result.dart';

class AudioPreprocessingService {
  const AudioPreprocessingService();

  Future<AudioPreprocessingResult> prepare(String? audioSamplePath) async {
    if (audioSamplePath == null || audioSamplePath.trim().isEmpty) {
      return const AudioPreprocessingResult(
        filePath: null,
        fileExists: false,
        fileSizeBytes: 0,
        hasUsableAudio: false,
      );
    }

    final file = File(audioSamplePath);

    final exists = await file.exists();
    if (!exists) {
      return AudioPreprocessingResult(
        filePath: audioSamplePath,
        fileExists: false,
        fileSizeBytes: 0,
        hasUsableAudio: false,
      );
    }

    final fileSizeBytes = await file.length();
    final hasUsableAudio = fileSizeBytes >= 1024;

    return AudioPreprocessingResult(
      filePath: audioSamplePath,
      fileExists: true,
      fileSizeBytes: fileSizeBytes,
      hasUsableAudio: hasUsableAudio,
    );
  }
}