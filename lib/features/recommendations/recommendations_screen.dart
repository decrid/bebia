import 'package:flutter/material.dart';

import '../../core/app_services.dart';
import '../predictions/prediction_model.dart';
import 'recommendation_model.dart';

class RecommendationsScreen extends StatefulWidget {
  const RecommendationsScreen({super.key});

  static const routeName = '/recommendations';

  @override
  State<RecommendationsScreen> createState() => _RecommendationsScreenState();
}

class _RecommendationsScreenState extends State<RecommendationsScreen> {
  late Future<_RecommendationsData> _futureData;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    _futureData = _fetchData();
  }

  Future<_RecommendationsData> _fetchData() async {
    final recommendationsFuture = AppServices.recommendationService
        .getRecommendations();
    final predictionsFuture = AppServices.predictionService.getPredictions();

    final recommendations = await recommendationsFuture;
    final predictions = await predictionsFuture;

    return _RecommendationsData(
      recommendations: recommendations,
      predictions: predictions,
    );
  }

  Future<void> _refresh() async {
    setState(_loadData);
    await _futureData;
  }

  Color _scoreColor(double score) {
    if (score >= 0.8) return Colors.redAccent;
    if (score >= 0.55) return Colors.orange;
    return Colors.blueGrey;
  }

  String _scoreLabel(double score) {
    if (score >= 0.8) return 'Vysoká priorita';
    if (score >= 0.55) return 'Střední priorita';
    return 'Nízká priorita';
  }

  String _timeLabel(DateTime? time) {
    if (time == null) return 'Bez odhadu';
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  String _windowLabel(DateTime? time) {
    if (time == null) return 'Později';

    final minutes = time.difference(DateTime.now()).inMinutes;
    if (minutes <= 15) return 'Teď';
    if (minutes <= 60) return 'Do hodiny';
    return 'Později';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Asistent doporučení')),
      body: FutureBuilder<_RecommendationsData>(
        future: _futureData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return RefreshIndicator(
              onRefresh: _refresh,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(24),
                children: [
                  const SizedBox(height: 120),
                  const Icon(Icons.error_outline, size: 52),
                  const SizedBox(height: 12),
                  Text(
                    'Nepodařilo se načíst asistenta doporučení.',
                    style: Theme.of(context).textTheme.titleMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text('${snapshot.error}', textAlign: TextAlign.center),
                ],
              ),
            );
          }

          final data = snapshot.data;
          final recommendations =
              data?.recommendations ?? const <Recommendation>[];
          final predictions = data?.predictions ?? const <Prediction>[];

          if (recommendations.isEmpty && predictions.isEmpty) {
            return RefreshIndicator(
              onRefresh: _refresh,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(24),
                children: const [
                  SizedBox(height: 120),
                  Icon(Icons.lightbulb_outline, size: 56),
                  SizedBox(height: 12),
                  Text(
                    'Zatím nejsou k dispozici doporučení ani predikce.',
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Co bude následovat a co udělat teď',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(height: 6),
                        Text(
                          'Nejdříve odhady událostí, potom konkrétní kroky podle priority.',
                        ),
                      ],
                    ),
                  ),
                ),
                if (predictions.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  _SectionTitle(title: 'Nejbližší odhady'),
                  const SizedBox(height: 8),
                  ...predictions
                      .take(3)
                      .map(
                        (prediction) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: _InfoCard(
                            icon: Icons.schedule_outlined,
                            title: prediction.title,
                            subtitle:
                                'Čas ${_timeLabel(prediction.predictedTime)} • jistota ${(prediction.confidence * 100).round()} %',
                            badge: _windowLabel(prediction.predictedTime),
                            color: Colors.teal,
                          ),
                        ),
                      ),
                ],
                if (recommendations.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  _SectionTitle(title: 'Doporučené kroky'),
                  const SizedBox(height: 8),
                  ...recommendations.map((item) {
                    final color = _scoreColor(item.score);

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _InfoCard(
                        icon: Icons.tips_and_updates_outlined,
                        title: item.title,
                        subtitle: item.description,
                        badge: _scoreLabel(item.score),
                        color: color,
                      ),
                    );
                  }),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}

class _RecommendationsData {
  const _RecommendationsData({
    required this.recommendations,
    required this.predictions,
  });

  final List<Recommendation> recommendations;
  final List<Prediction> predictions;
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(
        context,
      ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.badge,
    required this.color,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String badge;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundColor: color.withValues(alpha: 0.12),
              foregroundColor: color,
              child: Icon(icon),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 4),
                  Text(subtitle),
                  const SizedBox(height: 8),
                  Chip(
                    label: Text(badge),
                    visualDensity: VisualDensity.compact,
                    side: BorderSide.none,
                    backgroundColor: colorScheme.surfaceContainerHighest,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
