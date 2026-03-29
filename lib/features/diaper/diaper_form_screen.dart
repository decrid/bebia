import 'package:flutter/material.dart';
import '../../core/app_services.dart';
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

  Future<void> _save() async {
    final now = DateTime.now();
    final note = _noteController.text.trim().isEmpty
        ? null
        : _noteController.text.trim();

    final record = DiaperRecord(
      id: now.millisecondsSinceEpoch.toString(),
      time: now,
      type: _type,
      note: note,
    );

    final diaperLabel = _type == 'wet'
        ? 'Mokrá'
        : _type == 'poop'
            ? 'Stolice'
            : 'Oboje';

    final item = TimelineItem()
      ..type = EventType.diaper
      ..time = record.time
      ..title = 'Přebalení'
      ..subtitle = diaperLabel
      ..note = note;

    await AppServices.timelineController.add(item);

    if (!mounted) return;
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
              decoration: const InputDecoration(
                labelText: 'Typ přebalení',
                border: OutlineInputBorder(),
              ),
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