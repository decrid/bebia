class AudioPreprocessingResult {
  const AudioPreprocessingResult({
    required this.filePath,
    required this.fileExists,
    required this.fileSizeBytes,
    required this.hasUsableAudio,
  });

  final String? filePath;
  final bool fileExists;
  final int fileSizeBytes;
  final bool hasUsableAudio;
}