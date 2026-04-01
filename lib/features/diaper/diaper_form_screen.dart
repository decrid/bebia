import 'package:flutter/material.dart';
import 'package:isar_community/isar.dart';
import '../../core/app_services.dart';
import '../timeline/timeline_item.dart';
import 'diaper_model.dart';

class DiaperFormScreen extends StatefulWidget {
  const DiaperFormScreen({
    super.key,
    this.existingItem,
  });

  final TimelineItem? existingItem;

  @override
  State<DiaperFormScreen> createState() => _DiaperFormScreenState();
}

class _DiaperFormScreenState extends State<DiaperFormScreen> {
  String _type = 'wet';
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

      if (existingItem.diaperType != null) {
        _type = existingItem.diaperType!;
      } else {
        switch (existingItem.subtitle) {
          case 'Stolice':
            _type = 'poop';
            break;
          case 'Oboje':
            _type = 'both';
            break;
          default:
            _type = 'wet';
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
    final note = _noteController.text.trim().isEmpty
        ? null
        : _noteController.text.trim();

    final record = DiaperRecord(
      id: _selectedTime.millisecondsSinceEpoch.toString(),
      time: _selectedTime,
      type: _type,
      note: note,
    );

    final diaperLabel = _type == 'wet'
        ? 'Mokrá'
        : _type == 'poop'
            ? 'Stolice'
            : 'Oboje';

    final item = TimelineItem()
      ..id = widget.existingItem?.id ?? Isar.autoIncrement
      ..type = EventType.diaper
      ..time = record.time
      ..title = 'Přebalení'
      ..subtitle = diaperLabel
      ..note = note
      ..diaperType = record.type;

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
        title: Text(_isEdit ? 'Upravit přebalení' : 'Přebalení'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
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
                          DropdownMenuItem(value: 'wet', child: Text('Mokrá')),
                          DropdownMenuItem(
                            value: 'poop',
                            child: Text('Stolice'),
                          ),
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
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SafeArea(
                top: false,
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _save,
                    child: Text(_isEdit ? 'Uložit změny' : 'Uložit'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}