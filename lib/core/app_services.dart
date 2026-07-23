import 'package:cloud_firestore/cloud_firestore.dart';
import '../data/local/child_profile_store.dart';
import '../data/local/event_assignment_store.dart';
import '../data/local/family_connection_store.dart';
import '../data/remote/firestore/firestore_family_repository.dart';
import '../data/remote/firestore/firestore_timeline_repository.dart';
import '../data/local/onboarding_store.dart';
import '../data/repositories/child_profile_repository.dart';
import '../data/repositories/event_assignment_repository.dart';
import '../data/repositories/family_connection_repository.dart';
import '../data/repositories/remote_family_repository.dart';
import '../data/repositories/remote_timeline_repository.dart';
import '../data/repositories/timeline_repository.dart';
import 'firebase/firebase_bootstrap_service.dart';
import '../features/auth/app_account_controller.dart';
import '../features/crying/audio_preprocessing_service.dart';
import '../features/crying/crying_ai_service.dart';
import '../features/crying/crying_analysis_service.dart';
import '../features/crying/mock_cry_detection_service.dart';
import '../features/crying/real_cry_detection_service.dart';
import '../features/family/family_connection_controller.dart';
import '../features/family/family_cloud_sync_service.dart';
import '../features/family/family_remote_sync_executor.dart';
import '../features/family/family_test_sync_service.dart';
import '../features/family/family_sync_orchestration_service.dart';
import '../features/family/family_sync_strategy.dart';
import '../features/family/family_workspace_service.dart';
import '../features/intelligence/infant_insights_service.dart';
import '../features/monetization/monetization_service.dart';
import '../features/predictions/prediction_service.dart';
import '../features/predictions/rhythm_profile_service.dart';
import '../features/profile/child_profile_controller.dart';
import '../features/recommendations/recommendation_service.dart';
import '../features/timeline/timeline_controller.dart';
import '../features/timeline/timeline_cloud_sync_service.dart';

class AppServices {
  static const FirebaseBootstrapService firebaseBootstrapService =
      FirebaseBootstrapService();
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
  static final FirebaseFirestore? firestore =
      firebaseBootstrapService.isConfigured ? FirebaseFirestore.instance : null;
  static final RemoteFamilyRepository? remoteFamilyRepository =
      firestore == null ? null : FirestoreFamilyRepository(firestore!);
  static final RemoteTimelineRepository? remoteTimelineRepository =
      firestore == null ? null : FirestoreTimelineRepository(firestore!);

  static final AppAccountController appAccountController =
      AppAccountController();
  static final ChildProfileController childProfileController =
      ChildProfileController(childProfileRepository, timelineRepository);
  static final FamilyConnectionController familyConnectionController =
      FamilyConnectionController(familyConnectionRepository);
  static const FamilyCloudSyncService familyCloudSyncService =
      FamilyCloudSyncService();
  static const FamilyRemoteSyncExecutor familyRemoteSyncExecutor =
      FamilyRemoteSyncExecutor();
  static const FamilyTestSyncService familyTestSyncService =
      FamilyTestSyncService();
  static const FamilySyncOrchestrationService familySyncOrchestrationService =
      FamilySyncOrchestrationService();
  static const FamilySyncStrategy familySyncStrategy = FamilySyncStrategy();
  static const FamilyWorkspaceService familyWorkspaceService =
      FamilyWorkspaceService();

  static final InfantInsightsService infantInsightsService =
      InfantInsightsService();
  static const MonetizationService monetizationService = MonetizationService();

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
  static const TimelineCloudSyncService timelineCloudSyncService =
      TimelineCloudSyncService();

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
