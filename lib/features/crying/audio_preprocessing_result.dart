import 'wav_audio_features.dart';

class AudioPreprocessingResult {
  const AudioPreprocessingResult({
    required this.filePath,
    required this.fileExists,
    required this.fileSizeBytes,
    required this.hasUsableAudio,
    required this.features,
  });

  final String? filePath;
  final bool fileExists;
  final int fileSizeBytes;
  final bool hasUsableAudio;
  final WavAudioFeatures? features;
}