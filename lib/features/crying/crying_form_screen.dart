import 'package:flutter/material.dart';
import 'package:isar_community/isar.dart';
import '../../core/app_services.dart';
import '../timeline/timeline_item.dart';

class CryingFormScreen extends StatefulWidget {
  const CryingFormScreen({
    super.key,
    this.existingItem,
  });

  final TimelineItem? existingItem;

  @override
  State<CryingFormScreen> createState() => _CryingFormScreenState();
}

class _CryingFormScreenState extends State<CryingFormScreen> {
  double _intensity = 3;
  DateTime _selectedTime = DateTime.now();

  bool get _isEdit => widget.existingItem != null;

  @override
  void initState() {
    super.initState();

    final existingItem = widget.existingItem;
    if (existingItem != null) {
      _selectedTime = existingItem.time;

      if (existingItem.cryingIntensity != null) {
        _intensity = existingItem.cryingIntensity!.toDouble();
      } else {
        final prefix = 'Intenzita: ';
        if (existingItem.subtitle.startsWith(prefix)) {
          final value = int.tryParse(
            existingItem.subtitle.replaceFirst(prefix, '').trim(),
          );
          if (value != null && value >= 1 && value <= 5) {
            _intensity = value.toDouble();
          }
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
    final item = TimelineItem()
      ..id = widget.existingItem?.id ?? Isar.autoIncrement
      ..type = EventType.crying
      ..time = _selectedTime
      ..title = 'Pláč'
      ..subtitle = 'Intenzita: ${_intensity.toInt()}'
      ..cryingIntensity = _intensity.toInt();

    if (_isEdit) {
      await AppServices.timelineController.update(item);
    } else {
      await AppServices.timelineController.add(item);
    }

    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? 'Upravit pláč' : 'Pláč'),
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
                      const Text('Intenzita pláče'),
                      Slider(
                        value: _intensity,
                        min: 1,
                        max: 5,
                        divisions: 4,
                        label: _intensity.toInt().toString(),
                        onChanged: (value) {
                          setState(() {
                            _intensity = value;
                          });
                        },
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