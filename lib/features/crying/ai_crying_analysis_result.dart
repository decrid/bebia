class AiCryingAnalysisResult {
  final bool cryDetected;
  final double cryProbability;
  final String? probableCause;
  final double? confidence;
  final List<String> signals;
  final String modelVersion;

  const AiCryingAnalysisResult({
    required this.cryDetected,
    required this.cryProbability,
    required this.probableCause,
    required this.confidence,
    required this.signals,
    required this.modelVersion,
  });
}
