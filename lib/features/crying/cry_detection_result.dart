class CryDetectionResult {
  const CryDetectionResult({
    required this.hasUsableAudio,
    required this.cryDetected,
    required this.cryProbability,
    required this.modelVersion,
    required this.signals,
  });

  final bool hasUsableAudio;
  final bool cryDetected;
  final double cryProbability;
  final String modelVersion;
  final List<String> signals;
}
