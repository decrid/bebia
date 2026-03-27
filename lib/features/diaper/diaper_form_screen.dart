import 'package:flutter/material.dart';
import '../../data/app_memory_store.dart';
import '../timeline/timeline_item.dart';
import 'diaper_model.dart';

class DiaperFormScreen extends StatefulWidget {
  const DiaperFormScreen({super.key});

  @override
  State<DiaperFormScreen> createState() => _DiaperFormScreenState();
}

class _DiaperFormScreenState extends State<DiaperFormScreen> {
  String _type = 'wet';
  final TextEditingController _noteController = TextEditingController();

  void _save() {
    final now = DateTime.now();

    final record = DiaperRecord(
      id: now.millisecondsSinceEpoch.toString(),
      time: now,
      type: _type,
      note: _noteController.text.trim().isEmpty
          ? null
          : _noteController.text.trim(),
    );

    final current = List<TimelineItem>.from(AppMemoryStore.timelineItems.value);

    final item = TimelineItem()
      ..type = EventType.diaper
      ..time = record.time
      ..title = 'Přebalení'
      ..subtitle = [
        _type == 'wet'
            ? 'Mokrá'
            : _type == 'poop'
                ? 'Stolice'
                : 'Oboje',
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
        title: const Text('Přebalení'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              initialValue: _type,
              items: const [
                DropdownMenuItem(value: 'wet', child: Text('Mokrá')),
                DropdownMenuItem(value: 'poop', child: Text('Stolice')),
                DropdownMenuItem(value: 'both', child: Text('Oboje')),
              ],
              onChanged: (value) {
                setState(() {
                  _type = value!;
                });
              },
            ),
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