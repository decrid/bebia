import 'package:flutter/material.dart';
import '../../core/app_services.dart';
import 'recommendation_model.dart';

class RecommendationsScreen extends StatefulWidget {
  const RecommendationsScreen({super.key});

  static const routeName = '/recommendations';

  @override
  State<RecommendationsScreen> createState() => _RecommendationsScreenState();
}

class _RecommendationsScreenState extends State<RecommendationsScreen> {
  late Future<List<Recommendation>> _futureRecommendations;

  @override
  void initState() {
    super.initState();
    _loadRecommendations();
  }

  void _loadRecommendations() {
    _futureRecommendations =
        AppServices.recommendationService.getRecommendations();
  }

  Future<void> _refresh() async {
    setState(() {
      _loadRecommendations();
    });
    await _futureRecommendations;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Doporučení'),
      ),
      body: FutureBuilder<List<Recommendation>>(
        future: _futureRecommendations,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Chyba: ${snapshot.error}'),
            );
          }

          final recommendations = snapshot.data ?? [];

          if (recommendations.isEmpty) {
            return RefreshIndicator(
              onRefresh: _refresh,
              child: ListView(
                children: const [
                  SizedBox(height: 200),
                  Center(child: Text('Zatím žádná doporučení')),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView.builder(
              itemCount: recommendations.length,
              itemBuilder: (context, index) {
                final item = recommendations[index];

                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: ListTile(
                    title: Text('${item.title} (${item.score})'),
                    subtitle: Text(item.description),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}