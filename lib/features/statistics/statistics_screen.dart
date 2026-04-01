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

    final todayItems = items
        .where((e) => e.time.isAfter(todayStart))
        .toList();

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
          break;
      }
    }

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
              _statTile(
                'Spánek',
                '${stats.totalSleepMinutes} min',
              ),

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
  });
}