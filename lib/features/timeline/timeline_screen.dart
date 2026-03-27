import 'package:flutter/material.dart';
import '../../data/app_memory_store.dart';
import 'timeline_item.dart';

class TimelineScreen extends StatefulWidget {
  const TimelineScreen({super.key});

  @override
  State<TimelineScreen> createState() => _TimelineScreenState();
}

class _TimelineScreenState extends State<TimelineScreen> {
  String _formatTime(DateTime time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    final day = time.day.toString().padLeft(2, '0');
    final month = time.month.toString().padLeft(2, '0');

    return '$day.$month. $hour:$minute';
  }

  IconData _getIcon(EventType type) {
    switch (type) {
      case EventType.feeding:
        return Icons.local_drink_outlined;
      case EventType.sleep:
        return Icons.bedtime_outlined;
      case EventType.diaper:
        return Icons.baby_changing_station_outlined;
      case EventType.crying:
        return Icons.campaign_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Časová osa'),
      ),
      body: ValueListenableBuilder<List<TimelineItem>>(
        valueListenable: AppMemoryStore.timelineItems,
        builder: (context, items, _) {
          final reversed = items.reversed.toList();

          if (reversed.isEmpty) {
            return const Center(
              child: Text('Zatím nejsou žádné záznamy.'),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: reversed.length,
            itemBuilder: (context, index) {
              final item = reversed[index];

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: Icon(_getIcon(item.type)),
                  title: Text(item.title),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_formatTime(item.time)),
                      Text(item.subtitle),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}