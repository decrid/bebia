class CryingAnalysisResult {
  final String probableCause;
  final double confidence;
  final List<String> signals;

  CryingAnalysisResult({
    required this.probableCause,
    required this.confidence,
    required this.signals,
  });
}