import 'package:flutter/material.dart';
import 'package:isar_community/isar.dart';
import '../../core/app_services.dart';
import 'feeding_model.dart';
import '../timeline/timeline_item.dart';

class FeedingFormScreen extends StatefulWidget {
  const FeedingFormScreen({
    super.key,
    this.existingItem,
  });

  final TimelineItem? existingItem;

  @override
  State<FeedingFormScreen> createState() => _FeedingFormScreenState();
}

class _FeedingFormScreenState extends State<FeedingFormScreen> {
  String _type = 'breast';
  DateTime _selectedTime = DateTime.now();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  bool get _isEdit => widget.existingItem != null;

  @override
  void initState() {
    super.initState();

    final existingItem = widget.existingItem;
    if (existingItem != null) {
      _selectedTime = existingItem.time;
      _noteController.text = existingItem.note ?? '';

      if (existingItem.feedingType != null) {
        _type = existingItem.feedingType!;
      } else if (existingItem.title == 'Lahvička') {
        _type = 'bottle';
      } else {
        _type = 'breast';
      }

      if (existingItem.feedingAmountMl != null) {
        _amountController.text = existingItem.feedingAmountMl.toString();
      } else {
        final subtitle = existingItem.subtitle.trim();
        if (subtitle.endsWith(' ml')) {
          _amountController.text = subtitle.replaceAll(' ml', '').trim();
        }
      }
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
    final amountText = _amountController.text.trim();
    final parsedAmount = amountText.isEmpty ? null : int.tryParse(amountText);
    final note = _noteController.text.trim().isEmpty
        ? null
        : _noteController.text.trim();

    final record = FeedingRecord(
      id: _selectedTime.millisecondsSinceEpoch.toString(),
      time: _selectedTime,
      type: _type,
      amountMl: parsedAmount,
      note: note,
    );

    final item = TimelineItem()
      ..id = widget.existingItem?.id ?? Isar.autoIncrement
      ..type = EventType.feeding
      ..time = record.time
      ..title = _type == 'breast' ? 'Kojení' : 'Lahvička'
      ..subtitle = [
        if (record.amountMl != null) '${record.amountMl} ml',
      ].join(' • ')
      ..note = note
      ..feedingType = record.type
      ..feedingAmountMl = record.amountMl;

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
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? 'Upravit krmení' : 'Krmení'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              child: ListTile(
                title: const Text('Čas události'),
                subtitle: Text(_formatDateTime(_selectedTime)),
                trailing: TextButton(
                  onPressed: _pickDateTime,
                  child: const Text('Změnit'),
                ),
              ),
            ),
            const SizedBox(height: 12),
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
                child: Text(_isEdit ? 'Uložit změny' : 'Uložit'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}