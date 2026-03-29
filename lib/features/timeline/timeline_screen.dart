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

                      return ListTile(
                        title: Text(item.title),
                        subtitle: Text(subtitleParts.join(' • ')),
                        trailing: Text(
                          '${item.time.hour.toString().padLeft(2, '0')}:${item.time.minute.toString().padLeft(2, '0')}',
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