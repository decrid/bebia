import 'package:flutter/material.dart';
import '../../core/app_services.dart';
import '../crying/crying_form_screen.dart';
import '../diaper/diaper_form_screen.dart';
import '../feeding/feeding_form_screen.dart';
import '../sleep/sleep_form_screen.dart';
import 'timeline_item.dart';

class TimelineScreen extends StatefulWidget {
  const TimelineScreen({super.key});

  static const routeName = '/timeline';

  @override
  State<TimelineScreen> createState() => _TimelineScreenState();
}

class _TimelineScreenState extends State<TimelineScreen> {
  @override
  void initState() {
    super.initState();
    AppServices.timelineController.load();
  }

  Future<void> _openEditForm(TimelineItem item) async {
    Widget screen;

    switch (item.type) {
      case EventType.feeding:
        screen = FeedingFormScreen(existingItem: item);
        break;
      case EventType.sleep:
        screen = SleepFormScreen(existingItem: item);
        break;
      case EventType.diaper:
        screen = DiaperFormScreen(existingItem: item);
        break;
      case EventType.crying:
        screen = CryingFormScreen(existingItem: item);
        break;
    }

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => screen,
      ),
    );

    if (!mounted) return;
    await AppServices.timelineController.load();
  }

  String _formatTime(DateTime time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  String _formatDayLabel(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final target = DateTime(date.year, date.month, date.day);

    if (target == today) {
      return 'Dnes';
    }

    if (target == yesterday) {
      return 'Včera';
    }

    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();

    return '$day.$month.$year';
  }

  List<_TimelineListEntry> _buildEntries(List<TimelineItem> items) {
    final entries = <_TimelineListEntry>[];
    String? currentDayLabel;

    for (final item in items) {
      final dayLabel = _formatDayLabel(item.time);

      if (dayLabel != currentDayLabel) {
        currentDayLabel = dayLabel;
        entries.add(_TimelineHeaderEntry(dayLabel));
      }

      entries.add(_TimelineItemEntry(item));
    }

    return entries;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Timeline'),
      ),
      body: ValueListenableBuilder<bool>(
        valueListenable: AppServices.timelineController.isLoading,
        builder: (context, isLoading, child) {
          if (isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          return ValueListenableBuilder<String?>(
            valueListenable: AppServices.timelineController.error,
            builder: (context, error, child) {
              if (error != null) {
                return Center(
                  child: Text(error),
                );
              }

              return ValueListenableBuilder<List<TimelineItem>>(
                valueListenable: AppServices.timelineController.items,
                builder: (context, items, child) {
                  if (items.isEmpty) {
                    return const Center(
                      child: Text('Zatím žádné záznamy'),
                    );
                  }

                  final entries = _buildEntries(items);

                  return ListView.builder(
                    itemCount: entries.length,
                    itemBuilder: (context, index) {
                      final entry = entries[index];

                      if (entry is _TimelineHeaderEntry) {
                        return Padding(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                          child: Text(
                            entry.title,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        );
                      }

                      final item = (entry as _TimelineItemEntry).item;

                      final subtitleParts = <String>[
                        if (item.subtitle.isNotEmpty) item.subtitle,
                        if (item.note != null && item.note!.isNotEmpty)
                          item.note!,
                      ];

                      return Dismissible(
                        key: ValueKey(item.id),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          color: Colors.red,
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        confirmDismiss: (direction) async {
                          return await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Smazat záznam?'),
                              content: const Text('Tuto akci nelze vrátit.'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context, false),
                                  child: const Text('Zrušit'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: const Text('Smazat'),
                                ),
                              ],
                            ),
                          );
                        },
                        onDismissed: (_) {
                          AppServices.timelineController.delete(item.id);
                        },
                        child: ListTile(
                          onTap: () => _openEditForm(item),
                          title: Text(item.title),
                          subtitle: subtitleParts.isEmpty
                              ? null
                              : Text(subtitleParts.join(' • ')),
                          trailing: Text(_formatTime(item.time)),
                        ),
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

abstract class _TimelineListEntry {}

class _TimelineHeaderEntry extends _TimelineListEntry {
  _TimelineHeaderEntry(this.title);

  final String title;
}

class _TimelineItemEntry extends _TimelineListEntry {
  _TimelineItemEntry(this.item);

  final TimelineItem item;
}