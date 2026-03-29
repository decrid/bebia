import 'package:flutter/material.dart';
import '../../core/app_services.dart';
import '../recommendations/recommendation_model.dart';

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
            FutureBuilder<List<Recommendation>>(
              future: _futureRecommendations,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.only(top: 32),
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Text('Chyba při načítání doporučení: ${snapshot.error}'),
                  );
                }

                final recommendations = snapshot.data ?? [];

                if (recommendations.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.only(top: 16),
                    child: Text('Žádná doporučení'),
                  );
                }

                return Column(
                  children: recommendations.map((rec) {
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
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