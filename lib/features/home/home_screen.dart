import 'package:flutter/material.dart';
import '../../core/app_services.dart';
import '../crying/crying_analysis_result.dart';
import '../crying/crying_form_screen.dart';
import '../diaper/diaper_form_screen.dart';
import '../feeding/feeding_form_screen.dart';
import '../predictions/prediction_model.dart';
import '../recommendations/recommendation_model.dart';
import '../recommendations/recommendations_screen.dart';
import '../sleep/sleep_form_screen.dart';
import '../timeline/timeline_item.dart';

class HomeScreen extends StatefulWidget {
  static const routeName = '/home';

  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<Recommendation>> _futureRecommendations;
  late Future<CryingAnalysisResult?> _futureCryingAnalysis;
  late Future<List<Prediction>> _futurePredictions;

  @override
  void initState() {
    super.initState();
    _loadRecommendations();
    _loadCryingAnalysis();
    _loadPredictions();
    AppServices.timelineController.load();
  }

  void _loadRecommendations() {
    _futureRecommendations =
        AppServices.recommendationService.getRecommendations();
  }

  void _loadCryingAnalysis() {
    _futureCryingAnalysis =
        AppServices.cryingAnalysisService.analyzeLatestCrying();
  }

  void _loadPredictions() {
    _futurePredictions = AppServices.predictionService.getPredictions();
  }

  Future<void> _refresh() async {
    await AppServices.timelineController.load();

    setState(() {
      _loadRecommendations();
      _loadCryingAnalysis();
      _loadPredictions();
    });

    await Future.wait([
      _futureRecommendations,
      _futureCryingAnalysis,
      _futurePredictions,
    ]);
  }

  Future<void> _openForm(Widget screen) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => screen,
      ),
    );

    if (!mounted) return;

    await _refresh();
  }

  String _formatTime(DateTime time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  String _formatPredictionTime(DateTime? time) {
    if (time == null) return '-';

    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  String _cryingCauseLabel(String cause) {
    switch (cause) {
      case 'hunger':
        return 'hlad';
      case 'tired':
        return 'únava';
      case 'discomfort':
        return 'diskomfort';
      default:
        return cause;
    }
  }

  IconData _eventIcon(EventType type) {
    switch (type) {
      case EventType.feeding:
        return Icons.local_drink_outlined;
      case EventType.sleep:
        return Icons.bedtime_outlined;
      case EventType.diaper:
        return Icons.baby_changing_station_outlined;
      case EventType.crying:
        return Icons.campaign_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text(
              'Rychlé akce',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            GridView(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 220,
                mainAxisExtent: 72,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              children: [
                _QuickActionCard(
                  title: 'Krmení',
                  icon: Icons.local_drink_outlined,
                  onTap: () => _openForm(const FeedingFormScreen()),
                ),
                _QuickActionCard(
                  title: 'Spánek',
                  icon: Icons.bedtime_outlined,
                  onTap: () => _openForm(const SleepFormScreen()),
                ),
                _QuickActionCard(
                  title: 'Přebalení',
                  icon: Icons.baby_changing_station_outlined,
                  onTap: () => _openForm(const DiaperFormScreen()),
                ),
                _QuickActionCard(
                  title: 'Pláč',
                  icon: Icons.campaign_outlined,
                  onTap: () => _openForm(const CryingFormScreen()),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text(
              'Poslední události',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            ValueListenableBuilder<bool>(
              valueListenable: AppServices.timelineController.isLoading,
              builder: (context, isLoading, child) {
                if (isLoading) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                return ValueListenableBuilder<String?>(
                  valueListenable: AppServices.timelineController.error,
                  builder: (context, error, child) {
                    if (error != null) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(error),
                      );
                    }

                    return ValueListenableBuilder<List<TimelineItem>>(
                      valueListenable: AppServices.timelineController.items,
                      builder: (context, items, child) {
                        if (items.isEmpty) {
                          return const Padding(
                            padding: EdgeInsets.only(top: 8),
                            child: Card(
                              child: Padding(
                                padding: EdgeInsets.all(16),
                                child: Text('Zatím žádné události'),
                              ),
                            ),
                          );
                        }

                        final recentItems = items.take(3).toList();

                        return Column(
                          children: recentItems.map((item) {
                            final subtitleParts = <String>[
                              if (item.subtitle.isNotEmpty) item.subtitle,
                              if (item.note != null && item.note!.isNotEmpty)
                                item.note!,
                            ];

                            return Card(
                              margin: const EdgeInsets.only(top: 8),
                              child: ListTile(
                                leading: Icon(_eventIcon(item.type)),
                                title: Text(item.title),
                                subtitle: subtitleParts.isEmpty
                                    ? null
                                    : Text(subtitleParts.join(' • ')),
                                trailing: Text(_formatTime(item.time)),
                              ),
                            );
                          }).toList(),
                        );
                      },
                    );
                  },
                );
              },
            ),
            const SizedBox(height: 24),
            const Text(
              'Analýza posledního pláče',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            FutureBuilder<CryingAnalysisResult?>(
              future: _futureCryingAnalysis,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.only(top: 16),
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          'Chyba při načítání analýzy pláče: ${snapshot.error}',
                        ),
                      ),
                    ),
                  );
                }

                final analysis = snapshot.data;

                if (analysis == null) {
                  return const Padding(
                    padding: EdgeInsets.only(top: 8),
                    child: Card(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Text(
                          'Zatím není k dispozici žádná analýza pláče.',
                        ),
                      ),
                    ),
                  );
                }

                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Pravděpodobná příčina: ${_cryingCauseLabel(analysis.probableCause)}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Jistota: ${(analysis.confidence * 100).round()} %',
                          ),
                          if (analysis.signals.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Text(
                              'Signály: ${analysis.signals.join(', ')}',
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
            const Text(
              'Predikce',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            FutureBuilder<List<Prediction>>(
              future: _futurePredictions,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.only(top: 16),
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          'Chyba při načítání predikcí: ${snapshot.error}',
                        ),
                      ),
                    ),
                  );
                }

                final predictions = snapshot.data ?? [];

                if (predictions.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.only(top: 8),
                    child: Card(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Text('Zatím není dost dat pro predikce.'),
                      ),
                    ),
                  );
                }

                return Column(
                  children: predictions.map((prediction) {
                    return Card(
                      margin: const EdgeInsets.only(top: 8),
                      child: ListTile(
                        leading: const Icon(Icons.schedule_outlined),
                        title: Text(prediction.title),
                        subtitle: Text(
                          '${prediction.description}\nOdhad: ${_formatPredictionTime(prediction.predictedTime)} • Jistota: ${(prediction.confidence * 100).round()} %',
                        ),
                        isThreeLine: true,
                      ),
                    );
                  }).toList(),
                );
              },
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Doporučení',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const RecommendationsScreen(),
                      ),
                    );
                  },
                  child: const Text('Všechna'),
                ),
              ],
            ),
            FutureBuilder<List<Recommendation>>(
              future: _futureRecommendations,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.only(top: 16),
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      'Chyba při načítání doporučení: ${snapshot.error}',
                    ),
                  );
                }

                final recommendations = snapshot.data ?? [];

                if (recommendations.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.only(top: 8),
                    child: Card(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Text('Žádná doporučení'),
                      ),
                    ),
                  );
                }

                final previewRecommendations = recommendations.take(3).toList();

                return Column(
                  children: previewRecommendations.map((rec) {
                    return Card(
                      margin: const EdgeInsets.only(top: 8),
                      child: ListTile(
                        leading: const Icon(Icons.lightbulb_outline),
                        title: Text(rec.title),
                        subtitle: Text(rec.description),
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

class _QuickActionCard extends StatelessWidget {
  const _QuickActionCard({
    required this.title,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              Icon(icon),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}