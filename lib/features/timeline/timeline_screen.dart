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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      AppServices.timelineController.load();
    });
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

    await Navigator.push(context, MaterialPageRoute(builder: (_) => screen));

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

  String _eventTypeLabel(EventType type) {
    switch (type) {
      case EventType.feeding:
        return 'Krmení';
      case EventType.sleep:
        return 'Spánek';
      case EventType.diaper:
        return 'Přebalení';
      case EventType.crying:
        return 'Pláč';
    }
  }

  String _causeLabel(String cause) {
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

  String _nextStepLabelFromCause(String? cause) {
    switch (cause) {
      case 'hunger':
        return 'zkusit krmení';
      case 'tired':
        return 'připravit spánek';
      case 'discomfort':
        return 'zkontrolovat plenku';
      default:
        return 'uklidnění a kontakt';
    }
  }

  String? _soothingMethodLabel(String? method) {
    switch (method) {
      case 'rocking':
        return 'Houpání';
      case 'feeding':
        return 'Krmení';
      case 'carrying':
        return 'Nošení';
      case 'pacifier':
        return 'Dudlík';
      case 'other':
        return 'Jiné';
      default:
        return null;
    }
  }

  List<String> _buildSubtitleParts(TimelineItem item) {
    final parts = <String>[];

    if (item.type == EventType.crying) {
      if (item.cryingDurationMinutes != null) {
        parts.add('${item.cryingDurationMinutes} min');
      }

      final soothingLabel = _soothingMethodLabel(item.soothingMethod);
      if (soothingLabel != null) {
        parts.add('Pomohlo: $soothingLabel');
      }

      if (item.cryingResolved != null) {
        parts.add(item.cryingResolved! ? 'Uklidněno' : 'Bez uklidnění');
      }

      if (item.aiProbableCause != null) {
        final label = _causeLabel(item.aiProbableCause!);
        final confidence = item.aiConfidence;
        if (confidence != null) {
          parts.add('AI: $label (${(confidence * 100).round()} %)');
        } else {
          parts.add('AI: $label');
        }
        parts.add(
          'Další krok: ${_nextStepLabelFromCause(item.aiProbableCause)}',
        );
      }

      if (item.aiUserCorrectedCause != null &&
          item.aiUserCorrectedCause!.trim().isNotEmpty) {
        parts.add('Potvrzeno: ${_causeLabel(item.aiUserCorrectedCause!)}');
      } else if (item.aiUserConfirmedCause == true) {
        parts.add('AI příčina potvrzena');
      }

      if (item.note != null && item.note!.isNotEmpty) {
        parts.add(item.note!);
      }

      return parts;
    }

    if (item.subtitle.isNotEmpty) {
      parts.add(item.subtitle);
    }

    if (item.note != null && item.note!.isNotEmpty) {
      parts.add(item.note!);
    }

    return parts;
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

  _TimelineDaySummary _buildTodaySummary(List<TimelineItem> items) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final todayItems = items.where((item) {
      final day = DateTime(item.time.year, item.time.month, item.time.day);
      return day == today;
    }).toList();

    final todayCryings = todayItems
        .where((item) => item.type == EventType.crying)
        .toList();

    final unresolvedCryings = todayCryings
        .where((item) => item.cryingResolved == false)
        .length;

    final aiConfidences = todayCryings
        .map((item) => item.aiConfidence)
        .whereType<double>()
        .toList();

    final avgAiConfidence = aiConfidences.isEmpty
        ? null
        : aiConfidences.reduce((a, b) => a + b) / aiConfidences.length;

    return _TimelineDaySummary(
      totalEvents: todayItems.length,
      cryingEvents: todayCryings.length,
      unresolvedCryings: unresolvedCryings,
      averageAiConfidence: avgAiConfidence,
    );
  }

  Widget _buildFilterChips(EventType? selectedType) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 6),
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
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Přehled událostí')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: const LinearGradient(
                  colors: [Color(0xFFF1F9F7), Color(0xFFFFFFFF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Jemný denní přehled',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Klepnutím záznam upravíš. U pláče uvidíš přímo i stručný AI kontext.',
                  ),
                ],
              ),
            ),
          ),
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
                  return const Center(child: CircularProgressIndicator());
                }

                return ValueListenableBuilder<String?>(
                  valueListenable: AppServices.timelineController.error,
                  builder: (context, error, child) {
                    if (error != null) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Text(error),
                        ),
                      );
                    }

                    return ValueListenableBuilder<List<TimelineItem>>(
                      valueListenable: AppServices.timelineController.items,
                      builder: (context, items, child) {
                        if (items.isEmpty) {
                          return const Center(
                            child: Text(
                              'Zatím nejsou k dispozici žádné záznamy.',
                            ),
                          );
                        }

                        final entries = _buildEntries(items);
                        final summary = _buildTodaySummary(items);

                        return ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 4, 16, 110),
                          itemCount: entries.length + 1,
                          itemBuilder: (context, index) {
                            if (index == 0) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: _TimelineSummaryCard(summary: summary),
                              );
                            }

                            final entry = entries[index - 1];

                            if (entry is _TimelineHeaderEntry) {
                              return Padding(
                                padding: const EdgeInsets.fromLTRB(4, 18, 4, 8),
                                child: Text(
                                  entry.title,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              );
                            }

                            final item = (entry as _TimelineItemEntry).item;
                            final subtitleParts = _buildSubtitleParts(item);
                            final isCrying = item.type == EventType.crying;

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: Dismissible(
                                key: ValueKey(item.id),
                                direction: DismissDirection.endToStart,
                                background: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.red,
                                    borderRadius: BorderRadius.circular(24),
                                  ),
                                  alignment: Alignment.centerRight,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
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
                                  AppServices.timelineController.delete(
                                    item.id,
                                  );
                                },
                                child: Card(
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(24),
                                    onTap: () => _openEditForm(item),
                                    child: Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              CircleAvatar(
                                                backgroundColor: isCrying
                                                    ? colorScheme
                                                          .tertiaryContainer
                                                    : colorScheme
                                                          .secondaryContainer,
                                                foregroundColor: isCrying
                                                    ? colorScheme
                                                          .onTertiaryContainer
                                                    : colorScheme
                                                          .onSecondaryContainer,
                                                child: Icon(
                                                  _iconFor(item.type),
                                                ),
                                              ),
                                              const SizedBox(width: 12),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      _eventTypeLabel(
                                                        item.type,
                                                      ),
                                                      style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.w700,
                                                        fontSize: 16,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 2),
                                                    Text(
                                                      _formatTime(item.time),
                                                      style: Theme.of(
                                                        context,
                                                      ).textTheme.bodyMedium,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              const Icon(
                                                Icons.chevron_right_rounded,
                                              ),
                                            ],
                                          ),
                                          if (subtitleParts.isNotEmpty) ...[
                                            const SizedBox(height: 14),
                                            Wrap(
                                              spacing: 8,
                                              runSpacing: 8,
                                              children: subtitleParts
                                                  .map(
                                                    (part) => Chip(
                                                      label: Text(part),
                                                      visualDensity:
                                                          VisualDensity.compact,
                                                    ),
                                                  )
                                                  .toList(),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
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

  IconData _iconFor(EventType type) {
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

class _TimelineDaySummary {
  const _TimelineDaySummary({
    required this.totalEvents,
    required this.cryingEvents,
    required this.unresolvedCryings,
    required this.averageAiConfidence,
  });

  final int totalEvents;
  final int cryingEvents;
  final int unresolvedCryings;
  final double? averageAiConfidence;
}

class _TimelineSummaryCard extends StatelessWidget {
  const _TimelineSummaryCard({required this.summary});

  final _TimelineDaySummary summary;

  @override
  Widget build(BuildContext context) {
    final confidence = summary.averageAiConfidence;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            Chip(
              label: Text('Dnes ${summary.totalEvents} záznamů'),
              visualDensity: VisualDensity.compact,
            ),
            Chip(
              label: Text('Pláč ${summary.cryingEvents}x'),
              visualDensity: VisualDensity.compact,
            ),
            Chip(
              label: Text('Neuklidněno ${summary.unresolvedCryings}x'),
              visualDensity: VisualDensity.compact,
            ),
            if (confidence != null)
              Chip(
                label: Text('AI jistota ${(confidence * 100).round()} %'),
                visualDensity: VisualDensity.compact,
              ),
          ],
        ),
      ),
    );
  }
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
