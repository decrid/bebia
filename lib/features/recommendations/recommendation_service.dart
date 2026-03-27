import '../../data/app_memory_store.dart';
import '../timeline/timeline_item.dart';
import 'recommendation_model.dart';

class RecommendationService {
  static List<Recommendation> getRecommendations() {
    final items = AppMemoryStore.timelineItems.value;

    if (items.isEmpty) return [];

    final now = DateTime.now();

    TimelineItem? lastFeeding;
    TimelineItem? lastSleep;
    TimelineItem? lastCrying;

    for (final item in items.reversed) {
      if (lastFeeding == null && item.type == EventType.feeding) {
        lastFeeding = item;
      }
      if (lastSleep == null && item.type == EventType.sleep) {
        lastSleep = item;
      }
      if (lastCrying == null && item.type == EventType.crying) {
        lastCrying = item;
      }
    }

    final recommendations = <Recommendation>[];

    // 🍼 HLAD
    if (lastFeeding != null) {
      final diff = now.difference(lastFeeding.time);

      if (diff.inMinutes > 150) {
        recommendations.add(
          Recommendation(
            title: 'Možná hlad',
            description: 'Od posledního krmení uplynulo více než 2.5 hodiny.',
          ),
        );
      }
    }

    // 😴 ÚNAVA
    if (lastSleep != null) {
      final diff = now.difference(lastSleep.time);

      if (diff.inMinutes > 90) {
        recommendations.add(
          Recommendation(
            title: 'Možná únava',
            description: 'Dítě je dlouho vzhůru.',
          ),
        );
      }
    }

    // 😢 PLÁČ ANALÝZA
    if (lastCrying != null) {
      final cryingDiff = now.difference(lastCrying.time);

      if (cryingDiff.inMinutes < 10) {
        if (lastFeeding != null &&
            now.difference(lastFeeding.time).inMinutes > 120) {
          recommendations.add(
            Recommendation(
              title: 'Pláč → hlad',
              description: 'Pláč může souviset s hladem.',
            ),
          );
        } else if (lastSleep != null &&
            now.difference(lastSleep.time).inMinutes > 90) {
          recommendations.add(
            Recommendation(
              title: 'Pláč → únava',
              description: 'Dítě může být přetažené.',
            ),
          );
        }
      }
    }

    // pokud máme specifické doporučení (pláč), filtruj obecné
    final hasCryingSpecific = recommendations.any((r) =>
        r.title.contains('Pláč'));

    if (hasCryingSpecific) {
      return recommendations
          .where((r) => r.title.contains('Pláč'))
          .toList();
    }

    return recommendations;
  }
}