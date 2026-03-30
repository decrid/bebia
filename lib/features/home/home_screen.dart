import 'package:flutter/material.dart';
import '../../core/app_services.dart';
import '../recommendations/recommendation_model.dart';
import '../recommendations/recommendations_screen.dart';

class HomeScreen extends StatefulWidget {
  static const routeName = '/home';

  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<Recommendation>> _futureRecommendations;

  @override
  void initState() {
    super.initState();
    _loadRecommendations();
    AppServices.timelineController.load();
  }

  void _loadRecommendations() {
    _futureRecommendations =
        AppServices.recommendationService.getRecommendations();
  }

  Future<void> _refresh() async {
    await AppServices.timelineController.load();

    setState(() {
      _loadRecommendations();
    });

    await _futureRecommendations;
  }

  Color _scoreColor(double score) {
    if (score >= 0.8) return Colors.red;
    if (score >= 0.5) return Colors.orange;
    return Colors.blue;
  }

  String _scoreLabel(double score) {
    if (score >= 0.8) return 'Vysoká priorita';
    if (score >= 0.5) return 'Střední priorita';
    return 'Informace';
  }

  Color _withAlpha(Color color, double opacity) {
    return Color.fromARGB(
      (opacity * 255).round(),
      (color.r * 255).round().clamp(0, 255),
      (color.g * 255).round().clamp(0, 255),
      (color.b * 255).round().clamp(0, 255),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bebia'),
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              'Dashboard',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 20),

            Row(
              children: [
                Expanded(
                  child: Text(
                    'Doporučení',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                TextButton(
                  onPressed: () async {
                    await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const RecommendationsScreen(),
                      ),
                    );

                    if (!mounted) return;

                    setState(() {
                      _loadRecommendations();
                    });
                  },
                  child: const Text('Zobrazit vše'),
                ),
              ],
            ),
            const SizedBox(height: 8),

            FutureBuilder<List<Recommendation>>(
              future: _futureRecommendations,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 32),
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.error_outline,
                            color: Colors.redAccent,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Chyba při načítání doporučení:\n${snapshot.error}',
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final recommendations = snapshot.data ?? [];

                if (recommendations.isEmpty) {
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.lightbulb_outline,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Text(
                              'Zatím nejsou k dispozici žádná doporučení.',
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final topRecommendations = recommendations.take(2).toList();

                return Column(
                  children: topRecommendations.map((item) {
                    final color = _scoreColor(item.score);

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CircleAvatar(
                                  backgroundColor: _withAlpha(color, 0.12),
                                  foregroundColor: color,
                                  child: const Icon(
                                    Icons.tips_and_updates_outlined,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    item.title,
                                    style: Theme.of(
                                      context,
                                    ).textTheme.titleMedium,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(item.description),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                Chip(
                                  label: Text(_scoreLabel(item.score)),
                                  avatar: Icon(
                                    Icons.flag_outlined,
                                    size: 18,
                                    color: color,
                                  ),
                                ),
                                Chip(
                                  label: Text(
                                    'Skóre: ${item.score.toStringAsFixed(2)}',
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}