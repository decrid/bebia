import 'audio_capture_service.dart';
import '../data/local/child_profile_store.dart';
import '../data/local/event_assignment_store.dart';
import '../data/local/family_connection_store.dart';
import '../data/local/onboarding_store.dart';
import '../data/repositories/child_profile_repository.dart';
import '../data/repositories/event_assignment_repository.dart';
import '../data/repositories/family_connection_repository.dart';
import '../data/repositories/timeline_repository.dart';
import '../features/crying/audio_preprocessing_service.dart';
import '../features/crying/crying_ai_service.dart';
import '../features/crying/crying_analysis_service.dart';
import '../features/crying/mock_cry_detection_service.dart';
import '../features/crying/real_cry_detection_service.dart';
import '../features/family/family_connection_controller.dart';
import '../features/intelligence/infant_insights_service.dart';
import '../features/predictions/prediction_service.dart';
import '../features/predictions/rhythm_profile_service.dart';
import '../features/profile/child_profile_controller.dart';
import '../features/recommendations/recommendation_service.dart';
import '../features/timeline/timeline_controller.dart';

class AppServices {
  static final OnboardingStore onboardingStore = OnboardingStore();

  static final ChildProfileRepository childProfileRepository =
      ChildProfileRepository(ChildProfileStore());
  static final EventAssignmentRepository eventAssignmentRepository =
      EventAssignmentRepository(EventAssignmentStore());
  static final TimelineRepository timelineRepository = TimelineRepository(
    eventAssignmentRepository,
  );
  static final FamilyConnectionRepository familyConnectionRepository =
      FamilyConnectionRepository(FamilyConnectionStore());

  static final ChildProfileController childProfileController =
      ChildProfileController(childProfileRepository, timelineRepository);
  static final FamilyConnectionController familyConnectionController =
      FamilyConnectionController(familyConnectionRepository);

  static final InfantInsightsService infantInsightsService =
      InfantInsightsService();

  static final AudioCaptureService audioCaptureService = AudioCaptureService();

  static final AudioPreprocessingService audioPreprocessingService =
      const AudioPreprocessingService();

  static final MockCryDetectionService mockCryDetectionService =
      MockCryDetectionService(audioPreprocessingService);

  static final RealCryDetectionService realCryDetectionService =
      RealCryDetectionService(
        mockCryDetectionService,
        audioPreprocessingService,
      );

  static final TimelineController timelineController = TimelineController(
    timelineRepository,
    childProfileController,
  );

  static final RecommendationService recommendationService =
      RecommendationService(
        timelineRepository,
        infantInsightsService,
        childProfileController,
      );

  static final CryingAnalysisService cryingAnalysisService =
      CryingAnalysisService(
        timelineRepository,
        infantInsightsService,
        childProfileController,
      );

  static final CryingAiService cryingAiService = CryingAiService(
    timelineRepository,
    realCryDetectionService,
    childProfileController,
  );

  static final RhythmProfileService rhythmProfileService = RhythmProfileService(
    timelineRepository,
    infantInsightsService,
    childProfileController,
  );

  static final PredictionService predictionService = PredictionService(
    timelineRepository,
    rhythmProfileService,
    infantInsightsService,
    childProfileController,
  );
}
