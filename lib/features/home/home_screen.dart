import 'package:flutter/material.dart';
import '../../core/app_services.dart';
import '../crying/crying_form_screen.dart';
import '../diaper/diaper_form_screen.dart';
import '../feeding/feeding_form_screen.dart';
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
      appBar: AppBar(
        title: const Text('Bebia'),
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text(
              'Dashboard',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Rychlé akce',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 2.2,
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