import '../data/repositories/timeline_repository.dart';
import '../features/crying/crying_ai_service.dart';
import '../features/crying/crying_analysis_service.dart';
import '../features/intelligence/infant_insights_service.dart';
import '../features/predictions/prediction_service.dart';
import '../features/predictions/rhythm_profile_service.dart';
import '../features/recommendations/recommendation_service.dart';
import '../features/timeline/timeline_controller.dart';

class AppServices {
  static final TimelineRepository timelineRepository = TimelineRepository();

  static final InfantInsightsService infantInsightsService =
      InfantInsightsService();

  static final TimelineController timelineController =
      TimelineController(timelineRepository);

  static final RecommendationService recommendationService =
      RecommendationService(
        timelineRepository,
        infantInsightsService,
      );

  static final CryingAnalysisService cryingAnalysisService =
      CryingAnalysisService(
        timelineRepository,
        infantInsightsService,
      );

  static final CryingAiService cryingAiService = CryingAiService(
    timelineRepository,
    infantInsightsService,
  );

  static final RhythmProfileService rhythmProfileService =
      RhythmProfileService(
        timelineRepository,
        infantInsightsService,
      );

  static final PredictionService predictionService = PredictionService(
    timelineRepository,
    rhythmProfileService,
    infantInsightsService,
  );
}