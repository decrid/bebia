import '../data/repositories/timeline_repository.dart';
import '../features/recommendations/recommendation_service.dart';
import '../features/timeline/timeline_controller.dart';

class AppServices {
  static final TimelineRepository timelineRepository = TimelineRepository();

  static final TimelineController timelineController =
      TimelineController(timelineRepository);

  static final RecommendationService recommendationService =
      RecommendationService(timelineRepository);
}