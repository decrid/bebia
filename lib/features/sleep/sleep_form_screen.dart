import 'package:flutter/material.dart';
import '../../data/app_memory_store.dart';
import '../timeline/timeline_item.dart';
import 'sleep_model.dart';

class SleepFormScreen extends StatefulWidget {
  const SleepFormScreen({super.key});

  @override
  State<SleepFormScreen> createState() => _SleepFormScreenState();
}

class _SleepFormScreenState extends State<SleepFormScreen> {
  final TextEditingController _noteController = TextEditingController();

  void _save() {
    final now = DateTime.now();

    final record = SleepRecord(
      id: now.millisecondsSinceEpoch.toString(),
      startTime: now.subtract(const Duration(hours: 1)),
      endTime: now,
      note: _noteController.text.trim().isEmpty
          ? null
          : _noteController.text.trim(),
    );

    final current = List<TimelineItem>.from(AppMemoryStore.timelineItems.value);

    final item = TimelineItem()
      ..type = EventType.sleep
      ..time = record.endTime
      ..title = 'Spánek'
      ..subtitle = [
        '1 hodina',
        if (record.note != null) record.note!,
      ].join(' • ');

    current.add(item);
    AppMemoryStore.timelineItems.value = current;

    Navigator.pop(context);
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Spánek'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text('Pro MVP: uloží se spánek 1 hodina zpět'),
            const SizedBox(height: 12),
            TextField(
              controller: _noteController,
              decoration: const InputDecoration(
                labelText: 'Poznámka',
                border: OutlineInputBorder(),
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _save,
                child: const Text('Uložit'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}