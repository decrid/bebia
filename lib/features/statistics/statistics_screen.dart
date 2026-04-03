import 'package:flutter/material.dart';
import '../../core/app_services.dart';
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
  }

  Future<_Stats> _loadStats() async {
    final items = await AppServices.timelineRepository.getAll();

    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);

    final todayItems = items.where((e) => e.time.isAfter(todayStart)).toList();

    int feedingCount = 0;
    int sleepCount = 0;
    int diaperCount = 0;
    int cryingCount = 0;

    int totalMl = 0;
    int totalSleepMinutes = 0;

    TimelineItem? lastFeeding;
    TimelineItem? lastSleep;
    TimelineItem? lastDiaper;
    TimelineItem? lastCrying;

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
          lastFeeding ??= item;
          break;

        case EventType.sleep:
          sleepCount++;
          if (item.sleepDurationMinutes != null) {
            totalSleepMinutes += item.sleepDurationMinutes!;
          }
          lastSleep ??= item;
          break;

        case EventType.diaper:
          diaperCount++;
          lastDiaper ??= item;
          break;

        case EventType.crying:
          cryingCount++;
          lastCrying ??= item;

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
      lastFeeding: lastFeeding,
      lastSleep: lastSleep,
      lastDiaper: lastDiaper,
      lastCrying: lastCrying,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Statistiky')),
      body: FutureBuilder<_Stats>(
        future: _future,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final stats = snapshot.data!;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _sectionTitle('Dnes'),
              _statTile('Krmení', stats.feedingCount.toString()),
              _statTile('Spánek', stats.sleepCount.toString()),
              _statTile('Přebalení', stats.diaperCount.toString()),
              _statTile('Pláč', stats.cryingCount.toString()),
              const SizedBox(height: 16),
              _sectionTitle('Souhrn'),
              _statTile('Celkem ml', '${stats.totalMl} ml'),
              _statTile('Spánek', '${stats.totalSleepMinutes} min'),
              _statTile(
                'Průměrná délka pláče',
                stats.averageCryingDurationMinutes == null
                    ? '-'
                    : '${stats.averageCryingDurationMinutes} min',
              ),
              _statTile(
                'Uklidněné pláče',
                stats.cryingResolvedCount.toString(),
              ),
              _statTile(
                'Neuklidněné pláče',
                stats.cryingUnresolvedCount.toString(),
              ),
              _statTile(
                'Úspěšnost uklidnění',
                stats.cryingResolvedRate == null
                    ? '-'
                    : '${stats.cryingResolvedRate} %',
              ),
              const SizedBox(height: 16),
              _sectionTitle('Co pomáhalo uklidnit'),
              _statTile('Krmení', stats.soothingFeedingCount.toString()),
              _statTile('Houpání', stats.soothingRockingCount.toString()),
              _statTile('Nošení', stats.soothingCarryingCount.toString()),
              _statTile('Dudlík', stats.soothingPacifierCount.toString()),
              _statTile('Jiné', stats.soothingOtherCount.toString()),
              const SizedBox(height: 16),
              _sectionTitle('Poslední události'),
              _lastItem('Krmení', stats.lastFeeding),
              _lastItem('Spánek', stats.lastSleep),
              _lastItem('Přebalení', stats.lastDiaper),
              _lastItem('Pláč', stats.lastCrying),
            ],
          );
        },
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _statTile(String title, String value) {
    return Card(
      child: ListTile(
        title: Text(title),
        trailing: Text(value),
      ),
    );
  }

  Widget _lastItem(String label, TimelineItem? item) {
    if (item == null) {
      return _statTile(label, '-');
    }

    final time =
        '${item.time.hour.toString().padLeft(2, '0')}:${item.time.minute.toString().padLeft(2, '0')}';

    return _statTile(label, time);
  }
}

class _Stats {
  final int feedingCount;
  final int sleepCount;
  final int diaperCount;
  final int cryingCount;
  final int totalMl;
  final int totalSleepMinutes;

  final TimelineItem? lastFeeding;
  final TimelineItem? lastSleep;
  final TimelineItem? lastDiaper;
  final TimelineItem? lastCrying;

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
    required this.lastFeeding,
    required this.lastSleep,
    required this.lastDiaper,
    required this.lastCrying,
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
}