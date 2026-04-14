import 'package:flutter/material.dart';

import '../../core/app_services.dart';
import '../crying/crying_analysis_result.dart';
import '../diaper/diaper_form_screen.dart';
import '../family/family_sharing_screen.dart';
import '../feeding/feeding_form_screen.dart';
import '../monetization/monetization_plan_screen.dart';
import '../onboarding/onboarding_flow.dart';
import '../predictions/prediction_model.dart';
import '../profile/child_profile.dart';
import '../profile/child_profile_screen.dart';
import '../recommendations/recommendation_model.dart';
import '../recommendations/recommendations_screen.dart';
import '../sleep/sleep_form_screen.dart';
import '../timeline/timeline_item.dart';
import '../../shared/widgets/info_label.dart';

enum _HomeMenuAction { profiles, onboarding, connectParent, monetization }

class HomeScreen extends StatefulWidget {
  static const routeName = '/home';

  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<Recommendation>> _futureRecommendations;
  late Future<CryingAnalysisResult?> _futureCryingAnalysis;
  late Future<List<Prediction>> _futurePredictions;
  late Future<_HomeOverview> _futureOverview;
  bool _didCheckOnboarding = false;

  @override
  void initState() {
    super.initState();
    _loadRecommendations();
    _loadCryingAnalysis();
    _loadPredictions();
    _loadOverview();
    AppServices.childProfileController.activeProfileId.addListener(
      _handleChildProfileChanged,
    );
    AppServices.timelineController.revision.addListener(_handleTimelineChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _maybeOpenOnboarding();
    });
  }

  @override
  void dispose() {
    AppServices.childProfileController.activeProfileId.removeListener(
      _handleChildProfileChanged,
    );
    AppServices.timelineController.revision.removeListener(
      _handleTimelineChanged,
    );
    super.dispose();
  }

  void _loadRecommendations() {
    _futureRecommendations = AppServices.recommendationService
        .getRecommendations();
  }

  void _loadCryingAnalysis() {
    _futureCryingAnalysis = AppServices.cryingAnalysisService
        .analyzeLatestCrying();
  }

  void _loadPredictions() {
    _futurePredictions = AppServices.predictionService.getPredictions();
  }

  void _loadOverview() {
    _futureOverview = _buildOverview();
  }

  Future<_HomeOverview> _buildOverview() async {
    final items = await AppServices.timelineRepository.getAll(
      childId: AppServices.childProfileController.activeProfileId.value,
    );
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final todayItems = items
        .where((item) => !item.time.isBefore(todayStart))
        .toList();
    final family = AppServices.familyConnectionController.state.value;
    final profile = AppServices.childProfileController.activeProfile;

    String readinessTitle;
    String readinessText;
    if (todayItems.isEmpty) {
      readinessTitle = 'Začni dnešním prvním záznamem';
      readinessText =
          'První zápisy rychle odemknou hodnotu predikcí, doporučení i přehledu rytmu dne.';
    } else if (todayItems.length < 4) {
      readinessTitle = 'Bebia se už chytá dnešního rytmu';
      readinessText =
          'Ještě pár zápisů a doporučení budou působit jistěji i konkrétněji.';
    } else {
      readinessTitle = 'Dnešní přehled je dobře rozběhnutý';
      readinessText =
          'Data už dávají smysluplný kontext pro další kroky i AI nápovědu.';
    }

    return _HomeOverview(
      totalToday: todayItems.length,
      feedingsToday: todayItems
          .where((item) => item.type == EventType.feeding)
          .length,
      sleepsToday:
          todayItems.where((item) => item.type == EventType.sleep).length,
      diapersToday:
          todayItems.where((item) => item.type == EventType.diaper).length,
      cryingsToday:
          todayItems.where((item) => item.type == EventType.crying).length,
      lastEventTime: items.isEmpty ? null : items.first.time,
      readinessTitle: readinessTitle,
      readinessText: readinessText,
      setupProgress: [
        profile != null,
        todayItems.isNotEmpty,
        family.isConnected || family.caregivers.length >= 2,
      ].where((done) => done).length,
      hasProfile: profile != null,
      hasFamilyPrepared: family.isConnected || family.hasInvite,
    );
  }

  Future<void> _refresh() async {
    setState(() {
      _loadRecommendations();
      _loadCryingAnalysis();
      _loadPredictions();
    });

    await Future.wait([
      _futureRecommendations,
      _futureCryingAnalysis,
      _futurePredictions,
      _futureOverview,
    ]);
  }

  void _handleChildProfileChanged() {
    if (!mounted) return;
    _refresh();
  }

  void _handleTimelineChanged() {
    if (!mounted) return;
    _refresh();
  }

  Future<void> _openForm(Widget screen) async {
    await Navigator.push(context, MaterialPageRoute(builder: (_) => screen));

    if (!mounted) return;
    await _refresh();
  }

  String _formatPredictionTime(DateTime? time) {
    if (time == null) return '-';

    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  String _predictionWindowLabel(DateTime? time) {
    if (time == null) return 'Bez odhadu';

    final diff = time.difference(DateTime.now()).inMinutes;
    if (diff <= 15) return 'Teď';
    if (diff <= 60) return 'Do hodiny';
    return 'Později';
  }

  String _recommendationPriorityLabel(double score) {
    if (score >= 0.8) return 'Vysoká priorita';
    if (score >= 0.55) return 'Střední priorita';
    return 'Nízká priorita';
  }

  String _cryingCauseLabel(String cause) {
    switch (cause) {
      case 'hunger':
        return 'hlad';
      case 'tired':
        return 'únava';
      case 'discomfort':
        return 'diskomfort';
      case 'other':
        return 'jiné';
      case 'unknown':
        return 'nevím';
      default:
        return cause;
    }
  }

  String _confidenceLabel(double confidence) {
    if (confidence >= 0.8) return 'Vysoká jistota';
    if (confidence >= 0.55) return 'Střední jistota';
    return 'Nižší jistota';
  }

  Color _confidenceColor(BuildContext context, double confidence) {
    if (confidence >= 0.8) return Colors.redAccent;
    if (confidence >= 0.55) return Colors.orange;
    return Theme.of(context).colorScheme.primary;
  }

  Future<void> _handleAnalysisNextStep(CryingAnalysisResult analysis) async {
    switch (analysis.nextStepType) {
      case CryingNextStepType.feeding:
        await _openForm(const FeedingFormScreen());
        return;
      case CryingNextStepType.sleep:
        await _openForm(const SleepFormScreen());
        return;
      case CryingNextStepType.diaper:
        await _openForm(const DiaperFormScreen());
        return;
      case CryingNextStepType.soothing:
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tip: zkuste chování, nošení nebo jemné houpání.'),
          ),
        );
        return;
    }
  }

  Widget _buildSignalChips(List<String> signals) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: signals.map((signal) => InfoLabel(label: signal)).toList(),
    );
  }

  Future<void> _openChildProfile() async {
    await showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const ChildProfileScreen(),
    );

    if (!mounted) return;
    await _refresh();
  }

  Future<void> _openFamilySharing() async {
    await showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const FamilySharingScreen(),
    );

    if (!mounted) return;
    await _refresh();
  }

  Future<void> _openOnboarding({bool markCompleted = false}) async {
    await Navigator.push<void>(
      context,
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => OnboardingFlow(
          onCreateProfile: () {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                _openChildProfile();
              }
            });
          },
          onConnectParent: () {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                _openFamilySharing();
              }
            });
          },
        ),
      ),
    );

    if (markCompleted) {
      await AppServices.onboardingStore.setCompleted(true);
    }

    if (!mounted) return;
    await _refresh();
  }

  Future<void> _maybeOpenOnboarding() async {
    if (_didCheckOnboarding || !mounted) return;
    _didCheckOnboarding = true;

    final completed = await AppServices.onboardingStore.isCompleted();
    if (!mounted || completed) return;

    await _openOnboarding(markCompleted: true);
  }

  Future<void> _openMonetizationPlan() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const MonetizationPlanScreen()),
    );
  }

  void _handleMenuAction(_HomeMenuAction action) {
    switch (action) {
      case _HomeMenuAction.profiles:
        _openChildProfile();
        return;
      case _HomeMenuAction.onboarding:
        _openOnboarding();
        return;
      case _HomeMenuAction.connectParent:
        _openFamilySharing();
        return;
      case _HomeMenuAction.monetization:
        _openMonetizationPlan();
        return;
    }
  }

  String _ageLabel(DateTime dateOfBirth) {
    final now = DateTime.now();
    int months =
        (now.year - dateOfBirth.year) * 12 + now.month - dateOfBirth.month;
    if (now.day < dateOfBirth.day) {
      months -= 1;
    }

    if (months <= 0) {
      final days = now.difference(dateOfBirth).inDays.clamp(0, 31);
      return '$days dní';
    }

    final years = months ~/ 12;
    final remainingMonths = months % 12;

    if (years == 0) {
      return '$months měs.';
    }

    if (remainingMonths == 0) {
      return '$years r.';
    }

    return '$years r. $remainingMonths měs.';
  }

  @override
  Widget build(BuildContext context) {
    final profile = AppServices.childProfileController.activeProfile;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bebia'),
        actions: [
          PopupMenuButton<_HomeMenuAction>(
            tooltip: 'Menu',
            onSelected: _handleMenuAction,
            itemBuilder: (context) => const [
              PopupMenuItem(
                value: _HomeMenuAction.profiles,
                child: ListTile(
                  leading: Icon(Icons.child_care_outlined),
                  title: Text('Profily'),
                ),
              ),
              PopupMenuItem(
                value: _HomeMenuAction.onboarding,
                child: ListTile(
                  leading: Icon(Icons.map_outlined),
                  title: Text('Průvodce'),
                ),
              ),
              PopupMenuItem(
                value: _HomeMenuAction.connectParent,
                child: ListTile(
                  leading: Icon(Icons.group_add_outlined),
                  title: Text('Připojení s druhým rodičem'),
                ),
              ),
              PopupMenuItem(
                value: _HomeMenuAction.monetization,
                child: ListTile(
                  leading: Icon(Icons.workspace_premium_outlined),
                  title: Text('Monetization plan'),
                ),
              ),
            ],
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 110),
          children: [
            _HeroPanel(
              eyebrow: profile == null ? 'Dnes' : profile.name,
              title: 'Co je teď důležité',
              subtitle: _heroSubtitle(profile),
            ),
            const SizedBox(height: 14),
            FutureBuilder<_HomeOverview>(
              future: _futureOverview,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Card(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: Text(
                        'Souhrn dne se nepodarilo nacist: ${snapshot.error}',
                      ),
                    ),
                  );
                }

                final overview = snapshot.data!;

                return Column(
                  children: [
                    _TodayOverviewCard(
                      overview: overview,
                      ageLabel: profile == null
                          ? null
                          : _ageLabel(profile.dateOfBirth),
                    ),
                    const SizedBox(height: 14),
                    _QuickHomeActions(
                      onFeedingTap: () => _openForm(const FeedingFormScreen()),
                      onSleepTap: () => _openForm(const SleepFormScreen()),
                      onDiaperTap: () => _openForm(const DiaperFormScreen()),
                      onFamilyTap: _openFamilySharing,
                    ),
                    if (overview.setupProgress < 3) ...[
                      const SizedBox(height: 14),
                      _SetupNudgeCard(
                        overview: overview,
                        onOpenProfiles: _openChildProfile,
                        onOpenFamily: _openFamilySharing,
                        onOpenFeeding: () =>
                            _openForm(const FeedingFormScreen()),
                      ),
                    ],
                    const SizedBox(height: 14),
                    _MonetizationNudgeCard(onTap: _openMonetizationPlan),
                    const SizedBox(height: 22),
                  ],
                );
              },
            ),
            FutureBuilder<CryingAnalysisResult?>(
              future: _futureCryingAnalysis,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Card(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: Text(
                        'Analýzu pláče se nepodařilo načíst: ${snapshot.error}',
                      ),
                    ),
                  );
                }

                final analysis = snapshot.data;
                if (analysis == null) {
                  return const _EmptyInsightCard(
                    text:
                        'Jakmile pridas zaznam place, zobrazi se tady AI souhrn.',
                  );
                }

                final confidenceColor = _confidenceColor(
                  context,
                  analysis.confidence,
                );

                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CircleAvatar(
                              radius: 25,
                              backgroundColor: confidenceColor.withValues(
                                alpha: 0.14,
                              ),
                              foregroundColor: confidenceColor,
                              child: const Icon(Icons.psychology_alt_outlined),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Pravděpodobná příčina: ${_cryingCauseLabel(analysis.probableCause)}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Jistota ${(analysis.confidence * 100).round()} % • ${_confidenceLabel(analysis.confidence)}',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodyMedium,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        if (analysis.signals.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          const Text(
                            'Rozhodující signály',
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 8),
                          _buildSignalChips(analysis.signals.take(4).toList()),
                        ],
                        const SizedBox(height: 16),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(18),
                            color: Theme.of(context)
                                .colorScheme
                                .primaryContainer
                                .withValues(alpha: 0.42),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                analysis.nextStepTitle,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(analysis.nextStepDescription),
                              const SizedBox(height: 12),
                              Align(
                                alignment: Alignment.centerLeft,
                                child: FilledButton.tonalIcon(
                                  onPressed: () =>
                                      _handleAnalysisNextStep(analysis),
                                  icon: const Icon(Icons.arrow_forward_rounded),
                                  label: const Text('Provést krok'),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 22),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Expanded(
                  child: _SectionHeader(
                    title: 'Asistent dne',
                    subtitle: 'Doporučení a nejbližší odhady pro dnešek.',
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
            const SizedBox(height: 10),
            FutureBuilder<List<Prediction>>(
              future: _futurePredictions,
              builder: (context, predictionSnapshot) {
                if (predictionSnapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Card(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  );
                }

                return FutureBuilder<List<Recommendation>>(
                  future: _futureRecommendations,
                  builder: (context, recommendationSnapshot) {
                    if (recommendationSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const Card(
                        child: Padding(
                          padding: EdgeInsets.all(24),
                          child: Center(child: CircularProgressIndicator()),
                        ),
                      );
                    }

                    if (predictionSnapshot.hasError ||
                        recommendationSnapshot.hasError) {
                      final error =
                          predictionSnapshot.error ??
                          recommendationSnapshot.error;
                      return Card(
                        child: Padding(
                          padding: const EdgeInsets.all(18),
                          child: Text('Asistenta se nepodařilo načíst: $error'),
                        ),
                      );
                    }

                    final predictions = (predictionSnapshot.data ?? []).take(2);
                    final recommendations = (recommendationSnapshot.data ?? [])
                        .take(2);

                    final items = <_AssistantAgendaItem>[
                      ...predictions.map(
                        (prediction) => _AssistantAgendaItem(
                          icon: Icons.schedule_outlined,
                          title: prediction.title,
                          subtitle:
                              'Odhad ${_formatPredictionTime(prediction.predictedTime)} • jistota ${(prediction.confidence * 100).round()} %',
                          badge: _predictionWindowLabel(
                            prediction.predictedTime,
                          ),
                          tint: const Color(0xFFE6F7F4),
                        ),
                      ),
                      ...recommendations.map(
                        (recommendation) => _AssistantAgendaItem(
                          icon: Icons.lightbulb_outline,
                          title: recommendation.title,
                          subtitle: recommendation.description,
                          badge: _recommendationPriorityLabel(
                            recommendation.score,
                          ),
                          tint: const Color(0xFFFFF3E7),
                        ),
                      ),
                    ];

                    if (items.isEmpty) {
                      return const _EmptyInsightCard(
                        text: 'Zatím nejsou k dispozici žádné kroky asistenta.',
                      );
                    }

                    final colorScheme = Theme.of(context).colorScheme;

                    return Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        gradient: LinearGradient(
                          colors: [
                            colorScheme.primaryContainer.withValues(
                              alpha: 0.22,
                            ),
                            colorScheme.surface,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        border: Border.all(
                          color: Theme.of(
                            context,
                          ).colorScheme.outlineVariant.withValues(alpha: 0.16),
                        ),
                      ),
                      child: Column(
                        children: items
                            .map(
                              (item) => Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: _AssistantAgendaCard(item: item),
                              ),
                            )
                            .toList(),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  String _heroSubtitle(ChildProfile? profile) {
    if (profile == null) {
      return 'AI pohled na poslední pláč a nejbližší očekávání.';
    }

    return 'Věk ${_ageLabel(profile.dateOfBirth)} • aktivní profil dítěte.';
  }
}

class _HomeOverview {
  const _HomeOverview({
    required this.totalToday,
    required this.feedingsToday,
    required this.sleepsToday,
    required this.diapersToday,
    required this.cryingsToday,
    required this.lastEventTime,
    required this.readinessTitle,
    required this.readinessText,
    required this.setupProgress,
    required this.hasProfile,
    required this.hasFamilyPrepared,
  });

  final int totalToday;
  final int feedingsToday;
  final int sleepsToday;
  final int diapersToday;
  final int cryingsToday;
  final DateTime? lastEventTime;
  final String readinessTitle;
  final String readinessText;
  final int setupProgress;
  final bool hasProfile;
  final bool hasFamilyPrepared;
}

class _SetupStep {
  const _SetupStep({
    required this.title,
    required this.onTap,
  });

  final String title;
  final VoidCallback onTap;
}

class _TodayOverviewCard extends StatelessWidget {
  const _TodayOverviewCard({
    required this.overview,
    required this.ageLabel,
  });

  final _HomeOverview overview;
  final String? ageLabel;

  String _formatTime(DateTime? value) {
    if (value == null) return '-';
    final hour = value.hour.toString().padLeft(2, '0');
    final minute = value.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Pulse dne',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        overview.readinessTitle,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                InfoLabel(label: '${overview.setupProgress}/3 pripraveno'),
              ],
            ),
            const SizedBox(height: 8),
            Text(overview.readinessText),
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (ageLabel != null) InfoLabel(label: 'Vek $ageLabel'),
                InfoLabel(label: 'Dnes ${overview.totalToday} zaznamu'),
                InfoLabel(label: 'Posledni zapis ${_formatTime(overview.lastEventTime)}'),
                InfoLabel(
                  label: overview.hasFamilyPrepared
                      ? 'Rodina pripravena'
                      : 'Sdileni zatim chybi',
                ),
              ],
            ),
            const SizedBox(height: 16),
            GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 1.45,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _MiniMetricCard(
                  icon: Icons.local_drink_outlined,
                  label: 'Krmeni',
                  value: overview.feedingsToday,
                  tint: const Color(0xFFEAF8F7),
                ),
                _MiniMetricCard(
                  icon: Icons.bedtime_outlined,
                  label: 'Spanek',
                  value: overview.sleepsToday,
                  tint: const Color(0xFFE9F3FB),
                ),
                _MiniMetricCard(
                  icon: Icons.baby_changing_station_outlined,
                  label: 'Prebaleni',
                  value: overview.diapersToday,
                  tint: const Color(0xFFFFF3E7),
                ),
                _MiniMetricCard(
                  icon: Icons.campaign_outlined,
                  label: 'Plac',
                  value: overview.cryingsToday,
                  tint: const Color(0xFFF7EDF8),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniMetricCard extends StatelessWidget {
  const _MiniMetricCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.tint,
  });

  final IconData icon;
  final String label;
  final int value;
  final Color tint;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        color: tint,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: colorScheme.primary),
          const Spacer(),
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 2),
          Text(
            '$value',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
          ),
        ],
      ),
    );
  }
}

class _QuickHomeActions extends StatelessWidget {
  const _QuickHomeActions({
    required this.onFeedingTap,
    required this.onSleepTap,
    required this.onDiaperTap,
    required this.onFamilyTap,
  });

  final VoidCallback onFeedingTap;
  final VoidCallback onSleepTap;
  final VoidCallback onDiaperTap;
  final VoidCallback onFamilyTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Rychle kroky',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Moderni mobilni aplikace setri cas jednim klepnutim. Tady jsou nejcastejsi akce bez hledani v menu.',
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _ActionChip(
                  icon: Icons.local_drink_outlined,
                  label: 'Krmeni',
                  onTap: onFeedingTap,
                ),
                _ActionChip(
                  icon: Icons.bedtime_outlined,
                  label: 'Spanek',
                  onTap: onSleepTap,
                ),
                _ActionChip(
                  icon: Icons.baby_changing_station_outlined,
                  label: 'Prebaleni',
                  onTap: onDiaperTap,
                ),
                _ActionChip(
                  icon: Icons.group_add_outlined,
                  label: 'Sdileni',
                  onTap: onFamilyTap,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionChip extends StatelessWidget {
  const _ActionChip({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      avatar: Icon(icon, size: 18),
      label: Text(label),
      onPressed: onTap,
    );
  }
}

class _SetupNudgeCard extends StatelessWidget {
  const _SetupNudgeCard({
    required this.overview,
    required this.onOpenProfiles,
    required this.onOpenFamily,
    required this.onOpenFeeding,
  });

  final _HomeOverview overview;
  final VoidCallback onOpenProfiles;
  final VoidCallback onOpenFamily;
  final VoidCallback onOpenFeeding;

  @override
  Widget build(BuildContext context) {
    final steps = <_SetupStep>[
      if (!overview.hasProfile)
        _SetupStep(title: 'Doplnit profil ditete', onTap: onOpenProfiles),
      if (overview.totalToday == 0)
        _SetupStep(title: 'Pridat prvni dnesni zaznam', onTap: onOpenFeeding),
      if (!overview.hasFamilyPrepared)
        _SetupStep(title: 'Pripravit rodinne sdileni', onTap: onOpenFamily),
    ];

    if (steps.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Co jeste zvedne hodnotu aplikace',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Tyto kroky nejsou povinne, ale pomuzou presnejsim odhadum i lepsimu dojmu z prvniho pouziti.',
            ),
            const SizedBox(height: 14),
            ...steps.map(
              (step) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: OutlinedButton.icon(
                  onPressed: step.onTap,
                  icon: const Icon(Icons.arrow_forward_rounded),
                  label: Text(step.title),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MonetizationNudgeCard extends StatelessWidget {
  const _MonetizationNudgeCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        gradient: LinearGradient(
          colors: [
            colorScheme.tertiaryContainer.withValues(alpha: 0.45),
            colorScheme.surface,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.18),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Premium-ready plan',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          const Text(
            'Bebia zatim nema paywall. Ale uz ted je dobry cas rozhodnout, co ma zustat free a co ma byt placena vrstva s realnou hodnotou.',
          ),
          const SizedBox(height: 12),
          FilledButton.tonalIcon(
            onPressed: onTap,
            icon: const Icon(Icons.workspace_premium_outlined),
            label: const Text('Open monetization plan'),
          ),
        ],
      ),
    );
  }
}

class _HeroPanel extends StatelessWidget {
  const _HeroPanel({
    required this.eyebrow,
    required this.title,
    required this.subtitle,
  });

  final String eyebrow;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        gradient: LinearGradient(
          colors: [
            colorScheme.primaryContainer.withValues(alpha: 0.62),
            colorScheme.surface,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            eyebrow,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w800,
              color: colorScheme.primary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Text(subtitle, style: Theme.of(context).textTheme.bodyLarge),
        ],
      ),
    );
  }
}

class _EmptyInsightCard extends StatelessWidget {
  const _EmptyInsightCard({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(padding: const EdgeInsets.all(18), child: Text(text)),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 4),
        Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
      ],
    );
  }
}

class _AssistantAgendaItem {
  const _AssistantAgendaItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.badge,
    required this.tint,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String badge;
  final Color tint;
}

class _AssistantAgendaCard extends StatelessWidget {
  const _AssistantAgendaCard({required this.item});

  final _AssistantAgendaItem item;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        color: Colors.white,
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.16),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundColor: item.tint,
              foregroundColor: colorScheme.primary,
              child: Icon(item.icon),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 4),
                  Text(item.subtitle),
                ],
              ),
            ),
            const SizedBox(width: 8),
            InfoLabel(label: item.badge),
          ],
        ),
      ),
    );
  }
}
