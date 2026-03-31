import 'package:flutter/material.dart';
import '../../core/app_services.dart';
import '../timeline/timeline_item.dart';
import 'sleep_model.dart';
import 'package:isar_community/isar.dart';

class SleepFormScreen extends StatefulWidget {
  const SleepFormScreen({
    super.key,
    this.existingItem,
  });

  final TimelineItem? existingItem;

  @override
  State<SleepFormScreen> createState() => _SleepFormScreenState();
}

class _SleepFormScreenState extends State<SleepFormScreen> {
  DateTime _selectedTime = DateTime.now();
  final TextEditingController _noteController = TextEditingController();

  bool get _isEdit => widget.existingItem != null;

  @override
  void initState() {
    super.initState();

    final existingItem = widget.existingItem;
    if (existingItem != null) {
      _selectedTime = existingItem.time;
      _noteController.text = existingItem.note ?? '';
    }
  }

  String _formatDateTime(DateTime value) {
    final day = value.day.toString().padLeft(2, '0');
    final month = value.month.toString().padLeft(2, '0');
    final year = value.year.toString();
    final hour = value.hour.toString().padLeft(2, '0');
    final minute = value.minute.toString().padLeft(2, '0');

    return '$day.$month.$year $hour:$minute';
  }

  Future<void> _pickDateTime() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedTime,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (pickedDate == null || !mounted) return;

    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_selectedTime),
    );

    if (pickedTime == null) return;

    setState(() {
      _selectedTime = DateTime(
        pickedDate.year,
        pickedDate.month,
        pickedDate.day,
        pickedTime.hour,
        pickedTime.minute,
      );
    });
  }

  Future<void> _save() async {
    final note = _noteController.text.trim().isEmpty
        ? null
        : _noteController.text.trim();

    final record = SleepRecord(
      id: _selectedTime.millisecondsSinceEpoch.toString(),
      startTime: _selectedTime.subtract(const Duration(hours: 1)),
      endTime: _selectedTime,
      note: note,
    );

    final item = TimelineItem()
      ..id = widget.existingItem?.id ?? Isar.autoIncrement
      ..type = EventType.sleep
      ..time = record.endTime
      ..title = 'Spánek'
      ..subtitle = '1 hodina'
      ..note = note;

    if (_isEdit) {
      await AppServices.timelineController.update(item);
    } else {
      await AppServices.timelineController.add(item);
    }

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
        title: Text(_isEdit ? 'Upravit spánek' : 'Spánek'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              child: ListTile(
                title: const Text('Konec spánku'),
                subtitle: Text(_formatDateTime(_selectedTime)),
                trailing: TextButton(
                  onPressed: _pickDateTime,
                  child: const Text('Změnit'),
                ),
              ),
            ),
            const SizedBox(height: 12),
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
                child: Text(_isEdit ? 'Uložit změny' : 'Uložit'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}