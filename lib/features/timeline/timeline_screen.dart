import 'package:flutter/material.dart';
import '../../core/app_services.dart';
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

                  return ListView.builder(
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];

                      final subtitleParts = <String>[
                        if (item.subtitle.isNotEmpty) item.subtitle,
                        if (item.note != null && item.note!.isNotEmpty) item.note!,
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
                          title: Text(item.title),
                          subtitle: Text(subtitleParts.join(' • ')),
                          trailing: Text(
                            '${item.time.hour.toString().padLeft(2, '0')}:${item.time.minute.toString().padLeft(2, '0')}',
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
    );
  }
}