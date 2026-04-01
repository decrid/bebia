class Prediction {
  final String title;
  final String description;
  final DateTime? predictedTime;
  final double confidence;

  Prediction({
    required this.title,
    required this.description,
    required this.predictedTime,
    required this.confidence,
  });
}