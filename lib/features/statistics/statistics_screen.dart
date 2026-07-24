import 'package:flutter/material.dart';

import '../../core/app_services.dart';
import '../../core/design/bebia_theme.dart';
import '../../shared/widgets/info_label.dart';
import '../../shared/widgets/profile_switcher.dart';
import '../auth/app_account_session.dart';
import '../family/family_connection.dart';
import '../profile/child_profile.dart';
import '../timeline/timeline_item.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key, this.loadStats});

  final Future<StatisticsSnapshot> Function()? loadStats;

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  late Future<StatisticsSnapshot> _future;

  @override
  void initState() {
    super.initState();
    _future = _loadStatsForView();
    AppServices.childProfileController.activeProfileId.addListener(
      _handleChildProfileChanged,
    );
    AppServices.timelineController.revision.addListener(_handleTimelineChanged);
    AppServices.appAccountController.session.addListener(_handleContextChanged);
    AppServices.familyConnectionController.state.addListener(
      _handleContextChanged,
    );
  }

  @override
  void dispose() {
    AppServices.childProfileController.activeProfileId.removeListener(
      _handleChildProfileChanged,
    );
    AppServices.timelineController.revision.removeListener(
      _handleTimelineChanged,
    );
    AppServices.appAccountController.session.removeListener(
      _handleContextChanged,
    );
    AppServices.familyConnectionController.state.removeListener(
      _handleContextChanged,
    );
    super.dispose();
  }

  Future<StatisticsSnapshot> _loadStats() async {
    final items = await AppServices.timelineRepository.getAll(
      childId: AppServices.childProfileController.activeProfileId.value,
    );

    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);

    final todayItems = items.where((e) => e.time.isAfter(todayStart)).toList();

    int feedingCount = 0;
    int sleepCount = 0;
    int diaperCount = 0;
    int cryingCount = 0;

    int totalMl = 0;
    int totalSleepMinutes = 0;

    int totalCryingDurationMinutes = 0;
    int cryingDurationCount = 0;
    int cryingResolvedCount = 0;
    int cryingUnresolvedCount = 0;

    int soothingFeedingCount = 0;
    int soothingRockingCount = 0;
    int soothingCarryingCount = 0;
    int soothingPacifierCount = 0;
    int soothingOtherCount = 0;

    for (final item in todayItems) {
      switch (item.type) {
        case EventType.feeding:
          feedingCount++;
          if (item.feedingAmountMl != null) {
            totalMl += item.feedingAmountMl!;
          }
          break;
        case EventType.sleep:
          sleepCount++;
          if (item.sleepDurationMinutes != null) {
            totalSleepMinutes += item.sleepDurationMinutes!;
          }
          break;
        case EventType.diaper:
          diaperCount++;
          break;
        case EventType.crying:
          cryingCount++;

          if (item.cryingDurationMinutes != null) {
            totalCryingDurationMinutes += item.cryingDurationMinutes!;
            cryingDurationCount++;
          }

          if (item.cryingResolved == true) {
            cryingResolvedCount++;
          } else if (item.cryingResolved == false) {
            cryingUnresolvedCount++;
          }

          switch (item.soothingMethod) {
            case 'feeding':
              soothingFeedingCount++;
              break;
            case 'rocking':
              soothingRockingCount++;
              break;
            case 'carrying':
              soothingCarryingCount++;
              break;
            case 'pacifier':
              soothingPacifierCount++;
              break;
            case 'other':
              soothingOtherCount++;
              break;
          }

          break;
      }
    }

    final averageCryingDurationMinutes = cryingDurationCount == 0
        ? null
        : (totalCryingDurationMinutes / cryingDurationCount).round();

    final cryingResolvedRate = cryingCount == 0
        ? null
        : ((cryingResolvedCount / cryingCount) * 100).round();

    return StatisticsSnapshot(
      feedingCount: feedingCount,
      sleepCount: sleepCount,
      diaperCount: diaperCount,
      cryingCount: cryingCount,
      totalMl: totalMl,
      totalSleepMinutes: totalSleepMinutes,
      averageCryingDurationMinutes: averageCryingDurationMinutes,
      cryingResolvedCount: cryingResolvedCount,
      cryingUnresolvedCount: cryingUnresolvedCount,
      cryingResolvedRate: cryingResolvedRate,
      soothingFeedingCount: soothingFeedingCount,
      soothingRockingCount: soothingRockingCount,
      soothingCarryingCount: soothingCarryingCount,
      soothingPacifierCount: soothingPacifierCount,
      soothingOtherCount: soothingOtherCount,
    );
  }

  Future<void> _refresh() async {
    setState(() {
      _future = _loadStatsForView();
    });
    await _future;
  }

  Future<StatisticsSnapshot> _loadStatsForView() {
    return widget.loadStats?.call() ?? _loadStats();
  }

  void _handleChildProfileChanged() {
    if (!mounted) return;
    _refresh();
  }

  void _handleTimelineChanged() {
    if (!mounted) return;
    _refresh();
  }

  void _handleContextChanged() {
    if (!mounted) return;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final session = AppServices.appAccountController.session.value;
    final familyState = AppServices.familyConnectionController.state.value;
    final activeProfile = AppServices.childProfileController.activeProfile;
    final usesLargeText = MediaQuery.textScalerOf(context).scale(1) >= 1.5;
    final profileBarHeight = usesLargeText ? 116.0 : 92.0;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(profileBarHeight),
        child: AppBar(
          automaticallyImplyLeading: false,
          toolbarHeight: profileBarHeight,
          titleSpacing: 0,
          title: const ProfileSwitcher(
            embedded: true,
            padding: EdgeInsets.fromLTRB(16, 12, 16, 12),
          ),
        ),
      ),
      body: FutureBuilder<StatisticsSnapshot>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline, size: 52),
                    const SizedBox(height: 12),
                    const Text(
                      'Statistiky se nepodařilo načíst.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: _refresh,
                      child: const Text('Zkusit znovu'),
                    ),
                  ],
                ),
              ),
            );
          }

          final stats = snapshot.data!;

          if (stats.isEmptyDay) {
            return RefreshIndicator(
              onRefresh: _refresh,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _StatisticsFamilyContextCard(
                    session: session,
                    familyState: familyState,
                    activeProfile: activeProfile,
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          colorScheme.primaryContainer.withValues(alpha: 0.55),
                          colorScheme.surface,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Dnes ještě není nic zapsané',
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'Začni prvním záznamem a statistiky se začnou postupně doplňovat.',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 110),
              children: [
                _StatisticsFamilyContextCard(
                  session: session,
                  familyState: familyState,
                  activeProfile: activeProfile,
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    gradient: LinearGradient(
                      colors: [
                        colorScheme.primaryContainer.withValues(alpha: 0.55),
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
                        'Dnes v číslech',
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Rychlý souhrn péče podle dnešních záznamů.',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 18),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          _HighlightChip(
                            label: 'Krmení',
                            value: stats.feedingCount.toString(),
                          ),
                          _HighlightChip(
                            label: 'Spánek',
                            value: stats.sleepCount.toString(),
                          ),
                          _HighlightChip(
                            label: 'Přebalení',
                            value: stats.diaperCount.toString(),
                          ),
                          _HighlightChip(
                            label: 'Pláč',
                            value: stats.cryingCount.toString(),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                _SectionTitle(
                  title: 'Podrobnosti',
                  subtitle: 'Množství, délka a průběh.',
                ),
                const SizedBox(height: 10),
                _AdaptiveMetricGrid(
                  key: const Key('statistics-metric-grid'),
                  children: [
                    _MetricCard(
                      label: 'Celkem ml',
                      value: '${stats.totalMl}',
                      suffix: 'ml',
                      icon: Icons.local_drink_outlined,
                      tint: context.bebia.feeding.withValues(alpha: .14),
                    ),
                    _MetricCard(
                      label: 'Spánek',
                      value: '${stats.totalSleepMinutes}',
                      suffix: 'min',
                      icon: Icons.bedtime_outlined,
                      tint: context.bebia.sleep.withValues(alpha: .14),
                    ),
                    _MetricCard(
                      label: 'Průměr pláče',
                      value:
                          stats.averageCryingDurationMinutes?.toString() ?? '-',
                      suffix: stats.averageCryingDurationMinutes == null
                          ? ''
                          : 'min',
                      icon: Icons.campaign_outlined,
                      tint: context.bebia.crying.withValues(alpha: .14),
                    ),
                    _MetricCard(
                      label: 'Uklidnění',
                      value: stats.cryingResolvedRate?.toString() ?? '-',
                      suffix: stats.cryingResolvedRate == null ? '' : '%',
                      icon: Icons.favorite_border,
                      tint: context.bebia.success.withValues(alpha: .14),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _SectionTitle(
                  title: 'Co dnes pomáhalo',
                  subtitle: 'Jen metody, které se objevily v záznamech pláče.',
                ),
                const SizedBox(height: 10),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        if (stats.soothingFeedingCount > 0)
                          _CalmChip(
                            label: 'Krmení',
                            count: stats.soothingFeedingCount,
                          ),
                        if (stats.soothingRockingCount > 0)
                          _CalmChip(
                            label: 'Houpání',
                            count: stats.soothingRockingCount,
                          ),
                        if (stats.soothingCarryingCount > 0)
                          _CalmChip(
                            label: 'Nošení',
                            count: stats.soothingCarryingCount,
                          ),
                        if (stats.soothingPacifierCount > 0)
                          _CalmChip(
                            label: 'Dudlík',
                            count: stats.soothingPacifierCount,
                          ),
                        if (stats.soothingOtherCount > 0)
                          _CalmChip(
                            label: 'Jiné',
                            count: stats.soothingOtherCount,
                          ),
                        if (stats.soothingFeedingCount == 0 &&
                            stats.soothingRockingCount == 0 &&
                            stats.soothingCarryingCount == 0 &&
                            stats.soothingPacifierCount == 0 &&
                            stats.soothingOtherCount == 0)
                          const Text(
                            'Zatím nejsou k dispozici data o uklidnění.',
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, required this.subtitle});

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

class _AdaptiveMetricGrid extends StatelessWidget {
  const _AdaptiveMetricGrid({required this.children, super.key});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final textScale = MediaQuery.textScalerOf(context).scale(1);
        final singleColumn = constraints.maxWidth < 380 || textScale >= 1.5;
        const spacing = 12.0;
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

class _StatisticsFamilyContextCard extends StatelessWidget {
  const _StatisticsFamilyContextCard({
    required this.session,
    required this.familyState,
    required this.activeProfile,
  });

  final AppAccountSession session;
  final FamilyConnectionState familyState;
  final ChildProfile? activeProfile;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final hasFamily =
        familyState.familyId != null && familyState.familyId!.isNotEmpty;
    final activeProfileLinked =
        activeProfile != null &&
        activeProfile!.familyId == familyState.familyId;

    final title = !session.isSignedIn
        ? 'Statistiky běží bez rodinného účtu'
        : !hasFamily
        ? 'Statistiky ještě nejsou navázané na rodinu'
        : activeProfile == null
        ? 'Vyber dítě pro sdílené statistiky'
        : activeProfileLinked
        ? 'Statistiky patří do sdílené rodiny'
        : 'Aktivní dítě ještě není ve sdílené rodině';

    final subtitle = !session.isSignedIn
        ? 'Souhrny fungují lokálně, ale zatím nejsou připravené pro sdílení mezi rodiči.'
        : !hasFamily
        ? 'Rodinný prostor ještě není aktivní, takže dnešní čísla zůstávají pouze na tomto zařízení.'
        : activeProfile == null
        ? 'Jakmile vybereš dítě, budou statistiky jednoznačně patřit do sdílené rodiny.'
        : activeProfileLinked
        ? 'Aktivní profil dítěte je správně navázaný na aktuální rodinu, takže statistiky dávají smysl i pro budoucí synchronizaci.'
        : 'Statistiky se počítají pro aktivní dítě, ale toto dítě zatím není přiřazené do aktuální rodiny.';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: colorScheme.surface,
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.18),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 12,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                title,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
              ),
              InfoLabel(
                label: activeProfileLinked ? 'Sdílená rodina' : 'Lokální režim',
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(subtitle),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (session.isSignedIn)
                InfoLabel(label: 'Rodič ${session.user!.displayName}'),
              if (hasFamily) InfoLabel(label: 'Rodina ${familyState.familyId}'),
              if (activeProfile != null)
                InfoLabel(label: 'Dítě ${activeProfile!.name}'),
              if (familyState.hasInvite)
                InfoLabel(
                  label:
                      'Pozvánka ${_inviteStatusLabel(familyState.inviteStatus)}',
                ),
            ],
          ),
        ],
      ),
    );
  }

  String _inviteStatusLabel(FamilyInviteStatus status) {
    switch (status) {
      case FamilyInviteStatus.none:
        return 'bez pozvánky';
      case FamilyInviteStatus.draft:
        return 'návrh';
      case FamilyInviteStatus.waitingForAcceptance:
        return 'čeká';
      case FamilyInviteStatus.accepted:
        return 'přijatá';
      case FamilyInviteStatus.connected:
        return 'aktivní';
    }
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.label,
    required this.value,
    required this.suffix,
    required this.icon,
    required this.tint,
  });

  final String label;
  final String value;
  final String suffix;
  final IconData icon;
  final Color tint;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundColor: tint,
              foregroundColor: colorScheme.primary,
              child: Icon(icon),
            ),
            const SizedBox(height: 16),
            Text(label, style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 6),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: RichText(
                text: TextSpan(
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.w800,
                  ),
                  children: [
                    TextSpan(text: value),
                    if (suffix.isNotEmpty)
                      TextSpan(
                        text: ' $suffix',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HighlightChip extends StatelessWidget {
  const _HighlightChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return InfoLabel(label: '$label $value', fontWeight: FontWeight.w800);
  }
}

class _CalmChip extends StatelessWidget {
  const _CalmChip({required this.label, required this.count});

  final String label;
  final int count;

  @override
  Widget build(BuildContext context) {
    return InfoLabel(label: '$label $count×');
  }
}

class StatisticsSnapshot {
  final int feedingCount;
  final int sleepCount;
  final int diaperCount;
  final int cryingCount;
  final int totalMl;
  final int totalSleepMinutes;

  final int? averageCryingDurationMinutes;
  final int cryingResolvedCount;
  final int cryingUnresolvedCount;
  final int? cryingResolvedRate;

  final int soothingFeedingCount;
  final int soothingRockingCount;
  final int soothingCarryingCount;
  final int soothingPacifierCount;
  final int soothingOtherCount;

  const StatisticsSnapshot({
    required this.feedingCount,
    required this.sleepCount,
    required this.diaperCount,
    required this.cryingCount,
    required this.totalMl,
    required this.totalSleepMinutes,
    required this.averageCryingDurationMinutes,
    required this.cryingResolvedCount,
    required this.cryingUnresolvedCount,
    required this.cryingResolvedRate,
    required this.soothingFeedingCount,
    required this.soothingRockingCount,
    required this.soothingCarryingCount,
    required this.soothingPacifierCount,
    required this.soothingOtherCount,
  });

  bool get isEmptyDay =>
      feedingCount == 0 &&
      sleepCount == 0 &&
      diaperCount == 0 &&
      cryingCount == 0;
}
