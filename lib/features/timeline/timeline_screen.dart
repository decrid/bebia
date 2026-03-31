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
    await AppServices.timelineController.reloadCurrent();
  }

  Future<void> _applyFilter(EventType? type) async {
    await AppServices.timelineController.load(type);
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

  Widget _buildFilterChips(EventType? selectedType) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
      child: Row(
        children: [
          _FilterChipButton(
            label: 'Vše',
            selected: selectedType == null,
            onTap: () => _applyFilter(null),
          ),
          const SizedBox(width: 8),
          _FilterChipButton(
            label: 'Krmení',
            selected: selectedType == EventType.feeding,
            onTap: () => _applyFilter(EventType.feeding),
          ),
          const SizedBox(width: 8),
          _FilterChipButton(
            label: 'Spánek',
            selected: selectedType == EventType.sleep,
            onTap: () => _applyFilter(EventType.sleep),
          ),
          const SizedBox(width: 8),
          _FilterChipButton(
            label: 'Přebalení',
            selected: selectedType == EventType.diaper,
            onTap: () => _applyFilter(EventType.diaper),
          ),
          const SizedBox(width: 8),
          _FilterChipButton(
            label: 'Pláč',
            selected: selectedType == EventType.crying,
            onTap: () => _applyFilter(EventType.crying),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Timeline'),
      ),
      body: Column(
        children: [
          ValueListenableBuilder<EventType?>(
            valueListenable: AppServices.timelineController.selectedFilter,
            builder: (context, selectedType, child) {
              return _buildFilterChips(selectedType);
            },
          ),
          Expanded(
            child: ValueListenableBuilder<bool>(
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
                                padding: const EdgeInsets.fromLTRB(
                                  16,
                                  16,
                                  16,
                                  8,
                                ),
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
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                                child: const Icon(
                                  Icons.delete,
                                  color: Colors.white,
                                ),
                              ),
                              confirmDismiss: (direction) async {
                                return await showDialog<bool>(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text('Smazat záznam?'),
                                    content: const Text(
                                      'Tuto akci nelze vrátit.',
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(context, false),
                                        child: const Text('Zrušit'),
                                      ),
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(context, true),
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
          ),
        ],
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

class _FilterChipButton extends StatelessWidget {
  const _FilterChipButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
    );
  }
}