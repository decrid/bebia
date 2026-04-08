enum CryingNextStepType { feeding, sleep, diaper, soothing }

class CryingAnalysisResult {
  final String probableCause;
  final double confidence;
  final List<String> signals;
  final CryingNextStepType nextStepType;
  final String nextStepTitle;
  final String nextStepDescription;

  CryingAnalysisResult({
    required this.probableCause,
    required this.confidence,
    required this.signals,
    required this.nextStepType,
    required this.nextStepTitle,
    required this.nextStepDescription,
  });
}
