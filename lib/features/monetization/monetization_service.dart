import 'monetization_feature.dart';

class MonetizationService {
  const MonetizationService();

  BebiaPlan get currentPlan => BebiaPlan.free;

  String get recommendedModel => 'freemium_subscription';
  String get plusName => 'Bebia Plus';
  String get plusTagline => 'Calmer days through deeper insight.';

  List<MonetizationFeature> getFeatures() {
    return const [
      MonetizationFeature(
        id: 'tracking_core',
        title: 'Core tracking',
        description: 'Feeding, sleep, diaper, crying, timeline, and editing.',
        includedInFree: true,
        businessReason: 'The app needs a strong free habit loop before asking for money.',
        plusPillar: 'Daily habit',
        launchPhase: 'Now',
        upgradeMoment: 'Never gate this. It creates trust and retention.',
      ),
      MonetizationFeature(
        id: 'profiles_and_sharing',
        title: 'Profiles and basic family setup',
        description: 'Child profile, active child switching, invite preparation, caregivers.',
        includedInFree: true,
        businessReason: 'Basic collaboration increases retention and creates future upgrade potential.',
        plusPillar: 'Care coordination',
        launchPhase: 'Now',
        upgradeMoment: 'Keep basic setup free. Premium can expand coordination later.',
      ),
      MonetizationFeature(
        id: 'ai_daily_assistant',
        title: 'Daily AI assistant',
        description: 'Current lightweight recommendations and next-step guidance.',
        includedInFree: true,
        businessReason: 'Parents need to feel the value before premium positioning will convert.',
        plusPillar: 'Proof of value',
        launchPhase: 'Now',
        upgradeMoment: 'Let users experience an AI win before showing upgrades.',
      ),
      MonetizationFeature(
        id: 'weekly_ai_briefing',
        title: 'Weekly AI briefing',
        description: 'Plain-language weekly summaries of patterns, changes, and likely pressure points.',
        includedInFree: false,
        businessReason: 'This is differentiated, recurring value that fits a subscription best.',
        plusPillar: 'Interpretation',
        launchPhase: 'Phase 1',
        upgradeMoment: 'After 7-10 days of data or after the first strong pattern is found.',
      ),
      MonetizationFeature(
        id: 'predictive_routines',
        title: 'Predictive routines',
        description: 'Wake windows, likely next event windows, and proactive routine coaching.',
        includedInFree: false,
        businessReason: 'This is a clear time-saving layer that can justify monthly recurring payment.',
        plusPillar: 'Prediction',
        launchPhase: 'Phase 1',
        upgradeMoment: 'After the user uses predictions repeatedly or checks timing before logging.',
      ),
      MonetizationFeature(
        id: 'crying_intelligence_history',
        title: 'Crying intelligence history',
        description: 'Cause patterns, confidence trends, and what usually helped in similar moments.',
        includedInFree: false,
        businessReason: 'This turns one-off AI outputs into a reusable system of value.',
        plusPillar: 'Interpretation',
        launchPhase: 'Phase 2',
        upgradeMoment: 'After multiple crying analyses or when a repeated cause pattern emerges.',
      ),
      MonetizationFeature(
        id: 'care_reports',
        title: 'Reports and export',
        description: 'Doctor-friendly summaries, caregiver handoff reports, and shareable exports.',
        includedInFree: false,
        businessReason: 'High-value task completion works well as premium utility.',
        plusPillar: 'Coordination',
        launchPhase: 'Phase 2',
        upgradeMoment: 'Before pediatric visits, handoffs, and travel.',
      ),
      MonetizationFeature(
        id: 'advanced_family_coordination',
        title: 'Advanced family coordination',
        description: 'Smart handoff notes, shared reminders, and role-specific caregiver views.',
        includedInFree: false,
        businessReason: 'This can save real time for households with more than one caregiver.',
        plusPillar: 'Coordination',
        launchPhase: 'Phase 3',
        upgradeMoment: 'When more than one caregiver actively uses the app.',
      ),
    ];
  }

  List<MonetizationFeature> get freeFeatures =>
      getFeatures().where((feature) => feature.includedInFree).toList();

  List<MonetizationFeature> get premiumFeatures =>
      getFeatures().where((feature) => !feature.includedInFree).toList();

  String get positioningSummary {
    return 'Keep the daily logging habit free. Charge for deeper interpretation, proactive guidance, and exports once users already trust the product.';
  }

  List<String> get plusValueProps => const [
        'Understand the day faster',
        'See patterns before they become stressful',
        'Coordinate care with less mental load',
      ];

  List<String> get rolloutPlan => const [
        'Phase 1: Weekly AI briefing and predictive routines',
        'Phase 2: Crying intelligence history and reports/export',
        'Phase 3: Advanced family coordination',
      ];
}
