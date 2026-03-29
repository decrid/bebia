import 'package:flutter/material.dart';
import '../../core/app_services.dart';
import 'feeding_model.dart';
import '../timeline/timeline_item.dart';

class FeedingFormScreen extends StatefulWidget {
  const FeedingFormScreen({super.key});

  @override
  State<FeedingFormScreen> createState() => _FeedingFormScreenState();
}

class _FeedingFormScreenState extends State<FeedingFormScreen> {
  String _type = 'breast';
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  Future<void> _save() async {
    final amountText = _amountController.text.trim();
    final parsedAmount = amountText.isEmpty ? null : int.tryParse(amountText);
    final note = _noteController.text.trim().isEmpty
        ? null
        : _noteController.text.trim();

    final record = FeedingRecord(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      time: DateTime.now(),
      type: _type,
      amountMl: parsedAmount,
      note: note,
    );

    final item = TimelineItem()
      ..type = EventType.feeding
      ..time = record.time
      ..title = _type == 'breast' ? 'Kojení' : 'Lahvička'
      ..subtitle = [
        if (record.amountMl != null) '${record.amountMl} ml',
      ].join(' • ')
      ..note = note;

    await AppServices.timelineController.add(item);

    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Krmení'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              initialValue: _type,
              items: const [
                DropdownMenuItem(value: 'breast', child: Text('Kojení')),
                DropdownMenuItem(value: 'bottle', child: Text('Lahvička')),
              ],
              onChanged: (value) {
                setState(() {
                  _type = value!;
                });
              },
              decoration: const InputDecoration(
                labelText: 'Typ krmení',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Množství (ml)',
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