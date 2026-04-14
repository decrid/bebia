class Prediction {
  final String title;
  final String description;
  final DateTime? predictedTime;
  final double confidence;

  // NEW
  final List<String> signals;

  Prediction({
    required this.title,
    required this.description,
    required this.predictedTime,
    required this.confidence,
    this.signals = const [],
  });
}
