import 'dart:ui' show FontFeature;

import 'package:flutter/material.dart';

import '../../core/app_services.dart';
import '../../core/design/bebia_theme.dart';
import '../../shared/widgets/bebia_components.dart';
import '../../shared/widgets/bebia_brand_mark.dart';
import '../../shared/widgets/info_label.dart';
import '../../shared/widgets/profile_switcher.dart';
import '../auth/app_account_session.dart';
import '../auth/app_account_setup_screen.dart';
import '../crying/crying_analysis_result.dart';
import '../diaper/diaper_form_screen.dart';
import '../family/family_connection.dart';
import '../family/family_sharing_screen.dart';
import '../feeding/feeding_form_screen.dart';
import '../monetization/monetization_plan_screen.dart';
import '../onboarding/onboarding_flow.dart';
import '../predictions/prediction_model.dart';
import '../profile/child_profile_screen.dart';
import '../recommendations/recommendation_model.dart';
import '../recommendations/recommendations_screen.dart';
import '../sleep/sleep_form_screen.dart';
import '../timeline/timeline_item.dart';

enum _HomeMenuAction { profiles, accountSync, onboarding, connectParent, plus }

class HomeScreen extends StatefulWidget {
  static const routeName = '/home';

  const HomeScreen({
    super.key,
    this.loadData = true,
    this.checkOnboarding = true,
  });

  final bool loadData;
  final bool checkOnboarding;

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
    _reloadData();
    AppServices.childProfileController.activeProfileId.addListener(_refresh);
    AppServices.timelineController.revision.addListener(_refresh);
    AppServices.appAccountController.session.addListener(_refresh);
    AppServices.familyConnectionController.state.addListener(_refresh);
    if (widget.checkOnboarding) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => _maybeOpenOnboarding(),
      );
    }
  }

  @override
  void dispose() {
    AppServices.childProfileController.activeProfileId.removeListener(_refresh);
    AppServices.timelineController.revision.removeListener(_refresh);
    AppServices.appAccountController.session.removeListener(_refresh);
    AppServices.familyConnectionController.state.removeListener(_refresh);
    super.dispose();
  }

  void _reloadData() {
    if (!widget.loadData) {
      _futureRecommendations = Future<List<Recommendation>>.value(
        const <Recommendation>[],
      );
      _futureCryingAnalysis = Future<CryingAnalysisResult?>.value();
      _futurePredictions = Future<List<Prediction>>.value(const <Prediction>[]);
      _futureOverview = Future<_HomeOverview>.value(
        const _HomeOverview(
          totalToday: 0,
          lastEventTime: null,
          lastFeeding: null,
          lastSleep: null,
          lastDiaper: null,
          lastCrying: null,
          readinessTitle: 'Začni dnešním prvním záznamem',
        ),
      );
      return;
    }

    _futureRecommendations = AppServices.recommendationService
        .getRecommendations();
    _futureCryingAnalysis = AppServices.cryingAnalysisService
        .analyzeLatestCrying();
    _futurePredictions = AppServices.predictionService.getPredictions();
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

    String readinessTitle;
    if (todayItems.isEmpty) {
      readinessTitle = 'Začni dnešním prvním záznamem';
    } else if (todayItems.length < 4) {
      readinessTitle = 'Dnešní rytmus se začíná skládat';
    } else {
      readinessTitle = 'Dnešní přehled je aktuální';
    }

    return _HomeOverview(
      totalToday: todayItems.length,
      lastEventTime: items.isEmpty ? null : items.first.time,
      lastFeeding: _lastOfType(items, EventType.feeding),
      lastSleep: _lastOfType(items, EventType.sleep),
      lastDiaper: _lastOfType(items, EventType.diaper),
      lastCrying: _lastOfType(items, EventType.crying),
      readinessTitle: readinessTitle,
    );
  }

  TimelineItem? _lastOfType(List<TimelineItem> items, EventType type) {
    for (final item in items) {
      if (item.type == type) return item;
    }
    return null;
  }

  Future<void> _refresh() async {
    if (!mounted) return;
    setState(_reloadData);
    await Future.wait([
      _futureRecommendations,
      _futureCryingAnalysis,
      _futurePredictions,
      _futureOverview,
    ]);
  }

  Future<void> _openForm(Widget screen) async {
    await Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
    if (!mounted) return;
    await _refresh();
  }

  Future<void> _openChildProfile() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ChildProfileScreen()),
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
              if (mounted) _openChildProfile();
            });
          },
          onConnectParent: () {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) _openFamilySharing();
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

  Future<void> _openPlusScreen() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const MonetizationPlanScreen()),
    );
  }

  Future<void> _openAccountSetup() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AppAccountSetupScreen()),
    );
  }

  void _handleMenuAction(_HomeMenuAction action) {
    switch (action) {
      case _HomeMenuAction.profiles:
        _openChildProfile();
        return;
      case _HomeMenuAction.accountSync:
        _openAccountSetup();
        return;
      case _HomeMenuAction.onboarding:
        _openOnboarding();
        return;
      case _HomeMenuAction.connectParent:
        _openFamilySharing();
        return;
      case _HomeMenuAction.plus:
        _openPlusScreen();
        return;
    }
  }

  String _formatTime(DateTime? value) {
    if (value == null) return '-';
    final hour = value.hour.toString().padLeft(2, '0');
    final minute = value.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  String _relativeTime(DateTime? value) {
    if (value == null) return '—';
    final difference = DateTime.now().difference(value);
    if (difference.isNegative || difference.inMinutes < 1) return 'právě teď';
    if (difference.inMinutes < 60) return 'před ${difference.inMinutes} min';
    if (difference.inHours < 24) return 'před ${difference.inHours} h';
    if (difference.inDays == 1) return 'včera';
    return 'před ${difference.inDays} d';
  }

  String _ageLabel(DateTime dateOfBirth) {
    final now = DateTime.now();
    int months =
        (now.year - dateOfBirth.year) * 12 + now.month - dateOfBirth.month;
    if (now.day < dateOfBirth.day) months -= 1;

    if (months <= 0) {
      final days = now.difference(dateOfBirth).inDays.clamp(0, 31);
      return '$days dní';
    }

    final years = months ~/ 12;
    final remainingMonths = months % 12;
    if (years == 0) return '$months měs.';
    if (remainingMonths == 0) return '$years r.';
    return '$years r. $remainingMonths měs.';
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
    if (confidence >= 0.8) return context.bebia.danger;
    if (confidence >= 0.55) return context.bebia.warning;
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

  @override
  Widget build(BuildContext context) {
    final profile = AppServices.childProfileController.activeProfile;
    final accountSession = AppServices.appAccountController.session.value;
    final familyState = AppServices.familyConnectionController.state.value;
    final profileBarHeight = MediaQuery.textScalerOf(context).scale(1) >= 1.5
        ? 116.0
        : 92.0;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        toolbarHeight: profileBarHeight,
        titleSpacing: 0,
        title: const ProfileSwitcher(
          embedded: true,
          padding: EdgeInsets.fromLTRB(16, 12, 8, 12),
        ),
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
                value: _HomeMenuAction.accountSync,
                child: ListTile(
                  leading: Icon(Icons.cloud_sync_outlined),
                  title: Text('Účet a synchronizace'),
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
                  title: Text('Rodinné sdílení'),
                ),
              ),
              PopupMenuItem(
                value: _HomeMenuAction.plus,
                child: ListTile(
                  leading: Icon(Icons.workspace_premium_outlined),
                  title: Text('Bebia Plus'),
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
              title: 'Péče v klidu a přehledně',
              subtitle: profile == null
                  ? 'Začněte prvním záznamem dne.'
                  : '${_ageLabel(profile.dateOfBirth)} · dnešní přehled',
            ),
            const SizedBox(height: 14),
            _FamilyStatusBanner(
              session: accountSession,
              familyState: familyState,
              onOpenAccountSetup: _openAccountSetup,
              onOpenFamilySharing: _openFamilySharing,
            ),
            const SizedBox(height: 14),
            FutureBuilder<_HomeOverview>(
              future: _futureOverview,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const _LoadingCard();
                }
                if (snapshot.hasError) {
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: Text(
                        'Souhrn dne se nepodařilo načíst: ${snapshot.error}',
                      ),
                    ),
                  );
                }
                return _TodayOverviewCard(
                  overview: snapshot.data!,
                  ageLabel: profile == null
                      ? null
                      : _ageLabel(profile.dateOfBirth),
                  formatTime: _formatTime,
                  relativeTime: _relativeTime,
                );
              },
            ),
            const SizedBox(height: 22),
            _SectionHeader(
              title: 'Co může pomoci',
              subtitle: profile == null
                  ? 'Po prvních záznamech se objeví jemné doporučení.'
                  : 'Nejdůležitější signál z posledního pláče.',
            ),
            const SizedBox(height: 10),
            FutureBuilder<CryingAnalysisResult?>(
              future: _futureCryingAnalysis,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const _LoadingCard();
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
                        'Jakmile přidáš záznam pláče, zobrazí se tady AI souhrn.',
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
                                    _cryingCauseLabel(
                                      analysis.probableCause,
                                    ).toUpperCase(),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${(analysis.confidence * 100).round()} % · ${_confidenceLabel(analysis.confidence)}',
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
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
                              FilledButton.tonalIcon(
                                onPressed: () =>
                                    _handleAnalysisNextStep(analysis),
                                icon: const Icon(Icons.arrow_forward_rounded),
                                label: const Text('Otevřít'),
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
                    title: 'Další krok',
                    subtitle: 'Nejbližší odhad a jedno praktické doporučení.',
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
                  return const _LoadingCard();
                }

                return FutureBuilder<List<Recommendation>>(
                  future: _futureRecommendations,
                  builder: (context, recommendationSnapshot) {
                    if (recommendationSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const _LoadingCard();
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

                    final items = <_AssistantAgendaItem>[
                      ...(predictionSnapshot.data ?? [])
                          .take(1)
                          .map(
                            (prediction) => _AssistantAgendaItem(
                              icon: Icons.schedule_outlined,
                              title: prediction.title,
                              subtitle:
                                  'Odhad ${_formatTime(prediction.predictedTime)} • jistota ${(prediction.confidence * 100).round()} %',
                              badge: _predictionWindowLabel(
                                prediction.predictedTime,
                              ),
                              tint: context.bebia.success.withValues(
                                alpha: .14,
                              ),
                            ),
                          ),
                      ...(recommendationSnapshot.data ?? [])
                          .take(1)
                          .map(
                            (recommendation) => _AssistantAgendaItem(
                              icon: Icons.lightbulb_outline,
                              title: recommendation.title,
                              subtitle: recommendation.description,
                              badge: _recommendationPriorityLabel(
                                recommendation.score,
                              ),
                              tint: context.bebia.warning.withValues(
                                alpha: .14,
                              ),
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
                          color: colorScheme.outlineVariant.withValues(
                            alpha: 0.16,
                          ),
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
}

class _HomeOverview {
  const _HomeOverview({
    required this.totalToday,
    required this.lastEventTime,
    required this.lastFeeding,
    required this.lastSleep,
    required this.lastDiaper,
    required this.lastCrying,
    required this.readinessTitle,
  });

  final int totalToday;
  final DateTime? lastEventTime;
  final TimelineItem? lastFeeding;
  final TimelineItem? lastSleep;
  final TimelineItem? lastDiaper;
  final TimelineItem? lastCrying;
  final String readinessTitle;
}

class _FamilyStatusBanner extends StatelessWidget {
  const _FamilyStatusBanner({
    required this.session,
    required this.familyState,
    required this.onOpenAccountSetup,
    required this.onOpenFamilySharing,
  });

  final AppAccountSession session;
  final FamilyConnectionState familyState;
  final Future<void> Function() onOpenAccountSetup;
  final Future<void> Function() onOpenFamilySharing;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final title = !session.isSignedIn
        ? 'Rodinné sdílení'
        : switch (familyState.inviteStatus) {
            FamilyInviteStatus.none => 'Rodina čeká na založení',
            FamilyInviteStatus.draft => 'Pozvánka je připravená',
            FamilyInviteStatus.waitingForAcceptance => 'Čeká na přijetí',
            FamilyInviteStatus.accepted => 'Pozvánka přijata',
            FamilyInviteStatus.connected => 'Rodina je propojená',
          };

    final subtitle = !session.isSignedIn
        ? 'Připojte druhého rodiče, až budete připraveni.'
        : switch (familyState.inviteStatus) {
            FamilyInviteStatus.none => 'Vytvořte rodinu a pozvánku.',
            FamilyInviteStatus.draft => 'Odešlete kód druhému rodiči.',
            FamilyInviteStatus.waitingForAcceptance => 'Kód byl sdílen.',
            FamilyInviteStatus.accepted => 'Dokončete propojení.',
            FamilyInviteStatus.connected => 'Péči můžete spravovat společně.',
          };

    final label = !session.isSignedIn
        ? 'Krok 1'
        : switch (familyState.inviteStatus) {
            FamilyInviteStatus.none => 'Krok 2',
            FamilyInviteStatus.draft => 'Návrh',
            FamilyInviteStatus.waitingForAcceptance => 'Čeká',
            FamilyInviteStatus.accepted => 'Přijato',
            FamilyInviteStatus.connected => 'Připraveno',
          };

    return BebiaCard(
      padding: const EdgeInsets.all(BebiaSpace.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: colorScheme.secondaryContainer,
                foregroundColor: colorScheme.primary,
                child: const Icon(Icons.groups_2_outlined),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              InfoLabel(label: label),
            ],
          ),
          const SizedBox(height: 10),
          Text(subtitle),
          const SizedBox(height: 14),
          if (!session.isSignedIn)
            FilledButton.tonalIcon(
              onPressed: () {
                onOpenAccountSetup();
              },
              icon: const Icon(Icons.manage_accounts_outlined),
              label: const Text('Otevřít účet'),
            )
          else
            FilledButton.tonalIcon(
              onPressed: () {
                onOpenFamilySharing();
              },
              icon: const Icon(Icons.family_restroom_outlined),
              label: Text(
                familyState.isConnected
                    ? 'Zobrazit rodinu'
                    : 'Dokončit sdílení',
              ),
            ),
        ],
      ),
    );
  }
}

class _TodayOverviewCard extends StatelessWidget {
  const _TodayOverviewCard({
    required this.overview,
    required this.ageLabel,
    required this.formatTime,
    required this.relativeTime,
  });

  final _HomeOverview overview;
  final String? ageLabel;
  final String Function(DateTime?) formatTime;
  final String Function(DateTime?) relativeTime;

  @override
  Widget build(BuildContext context) {
    return BebiaCard(
      padding: const EdgeInsets.all(BebiaSpace.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Pulse dne',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              InfoLabel(label: '${overview.totalToday} dnes'),
            ],
          ),
          const SizedBox(height: BebiaSpace.xs),
          Text(
            overview.readinessTitle,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: context.bebia.mutedText),
          ),
          const SizedBox(height: BebiaSpace.md),
          _HomeMetricGrid(
            children: [
              _MiniMetricCard(
                icon: Icons.local_drink_outlined,
                label: 'Krmení',
                value: relativeTime(overview.lastFeeding?.time),
                meta: _feedingMeta(overview.lastFeeding),
                color: context.bebia.feeding,
              ),
              _MiniMetricCard(
                icon: Icons.bedtime_outlined,
                label: 'Spánek',
                value: relativeTime(
                  overview.lastSleep?.sleepStart ?? overview.lastSleep?.time,
                ),
                meta: _sleepMeta(overview.lastSleep),
                color: context.bebia.sleep,
              ),
              _MiniMetricCard(
                icon: Icons.baby_changing_station_outlined,
                label: 'Přebalení',
                value: relativeTime(overview.lastDiaper?.time),
                meta: _diaperMeta(overview.lastDiaper),
                color: context.bebia.diaper,
              ),
              _MiniMetricCard(
                icon: Icons.graphic_eq_rounded,
                label: 'Pláč',
                value: relativeTime(overview.lastCrying?.time),
                meta: _cryingMeta(overview.lastCrying),
                color: context.bebia.crying,
              ),
            ],
          ),
          if (ageLabel != null || overview.lastEventTime != null) ...[
            const SizedBox(height: BebiaSpace.md),
            Wrap(
              spacing: BebiaSpace.xs,
              runSpacing: BebiaSpace.xs,
              children: [
                if (ageLabel != null) InfoLabel(label: ageLabel!),
                if (overview.lastEventTime != null)
                  InfoLabel(
                    label:
                        'Poslední zápis ${formatTime(overview.lastEventTime)}',
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  String _feedingMeta(TimelineItem? item) {
    if (item == null) return 'Bez záznamu';
    final type = item.feedingType == 'breast'
        ? 'Kojení'
        : item.feedingType == 'bottle'
        ? 'Láhev'
        : 'Zaznamenáno';
    return item.feedingAmountMl == null
        ? type
        : '$type · ${item.feedingAmountMl} ml';
  }

  String _sleepMeta(TimelineItem? item) {
    if (item == null) return 'Bez záznamu';
    if (item.sleepEnd == null) return 'Právě probíhá';
    final minutes = item.sleepDurationMinutes;
    return minutes == null ? 'Ukončeno' : '$minutes min';
  }

  String _diaperMeta(TimelineItem? item) {
    return switch (item?.diaperType) {
      'wet' => 'Mokrá plena',
      'poop' => 'Stolice',
      'both' => 'Mokrá i stolice',
      _ => item == null ? 'Bez záznamu' : 'Zaznamenáno',
    };
  }

  String _cryingMeta(TimelineItem? item) {
    if (item == null) return 'Bez záznamu';
    final minutes = item.cryingDurationMinutes;
    return minutes == null ? 'Zaznamenáno' : '$minutes min';
  }
}

class _HomeMetricGrid extends StatelessWidget {
  const _HomeMetricGrid({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final singleColumn =
            constraints.maxWidth < 380 ||
            MediaQuery.textScalerOf(context).scale(1) >= 1.5;
        const spacing = 10.0;
        final itemWidth = singleColumn
            ? constraints.maxWidth
            : (constraints.maxWidth - spacing) / 2;
        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: children
              .map((child) => SizedBox(width: itemWidth, child: child))
              .toList(),
        );
      },
    );
  }
}

class _MiniMetricCard extends StatelessWidget {
  const _MiniMetricCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.meta,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final String meta;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 118),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(BebiaRadius.medium),
        color: color.withValues(alpha: .1),
        border: Border.all(color: color.withValues(alpha: .2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: BebiaIconSize.small),
              const SizedBox(width: BebiaSpace.xs),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelLarge,
                ),
              ),
            ],
          ),
          const SizedBox(height: BebiaSpace.sm),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          const SizedBox(height: 2),
          Text(
            meta,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: context.bebia.mutedText),
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
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const BebiaBrandMark(size: 48),
              const SizedBox(width: BebiaSpace.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      eyebrow,
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      title,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: context.bebia.mutedText),
          ),
        ],
      ),
    );
  }
}

class _LoadingCard extends StatelessWidget {
  const _LoadingCard();

  @override
  Widget build(BuildContext context) {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Center(child: CircularProgressIndicator()),
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
        color: colorScheme.surface,
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
                  const SizedBox(height: 8),
                  InfoLabel(label: item.badge),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
