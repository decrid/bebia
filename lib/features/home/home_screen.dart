import 'package:flutter/material.dart';
import '../../data/app_memory_store.dart';
import '../recommendations/recommendation_service.dart';

class HomeScreen extends StatelessWidget {
  static const routeName = '/home';

  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bebia'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ValueListenableBuilder(
          valueListenable: AppMemoryStore.timelineItems,
          builder: (context, _, _) {
            final recommendations =
                RecommendationService.getRecommendations();

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Dashboard',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),

                if (recommendations.isEmpty)
                  const Text('Žádná doporučení'),

                ...recommendations.map((rec) => Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: const Icon(Icons.lightbulb_outline),
                        title: Text(rec.title),
                        subtitle: Text(rec.description),
                      ),
                    )),
              ],
            );
          },
        ),
      ),
    );
  }
}