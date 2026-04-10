import 'package:flutter/material.dart';

import '../../core/app_services.dart';
import '../../shared/widgets/info_label.dart';
import '../timeline/timeline_item.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  late Future<_Stats> _future;

  @override
  void initState() {
    super.initState();
    _future = _loadStats();
    AppServices.childProfileController.activeProfileId.addListener(
      _handleChildProfileChanged,
    );
    AppServices.timelineController.revision.addListener(_handleTimelineChanged);
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

  Future<_Stats> _loadStats() async {
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

    return _Stats(
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
      _future = _loadStats();
    });
    await _future;
  }

  void _handleChildProfileChanged() {
    if (!mounted) return;
    _refresh();
  }

  void _handleTimelineChanged() {
    if (!mounted) return;
    _refresh();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Statistiky')),
      body: FutureBuilder<_Stats>(
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
                        'Vzorce a trendy',
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Vyhodnocení dne. Surovou historii a úpravy najdeš v Přehledu.',
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
                  title: 'Dnes',
                  subtitle: 'Souhrn hlavních metrik za dnešek.',
                ),
                const SizedBox(height: 10),
                GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.06,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _MetricCard(
                      label: 'Celkem ml',
                      value: '${stats.totalMl}',
                      suffix: 'ml',
                      icon: Icons.local_drink_outlined,
                      tint: const Color(0xFFEAF8F7),
                    ),
                    _MetricCard(
                      label: 'Spánek',
                      value: '${stats.totalSleepMinutes}',
                      suffix: 'min',
                      icon: Icons.bedtime_outlined,
                      tint: const Color(0xFFE9F3FB),
                    ),
                    _MetricCard(
                      label: 'Průměr pláče',
                      value:
                          stats.averageCryingDurationMinutes?.toString() ?? '-',
                      suffix: stats.averageCryingDurationMinutes == null
                          ? ''
                          : 'min',
                      icon: Icons.campaign_outlined,
                      tint: const Color(0xFFFFF1E8),
                    ),
                    _MetricCard(
                      label: 'Uklidnění',
                      value: stats.cryingResolvedRate?.toString() ?? '-',
                      suffix: stats.cryingResolvedRate == null ? '' : '%',
                      icon: Icons.favorite_border,
                      tint: const Color(0xFFF4F0FF),
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
            const Spacer(),
            Text(label, style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 6),
            RichText(
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

class _Stats {
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

  _Stats({
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
