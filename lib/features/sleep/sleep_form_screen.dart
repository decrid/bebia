import 'package:flutter/material.dart';
import 'package:isar_community/isar.dart';

import '../../core/app_services.dart';
import '../../shared/widgets/event_form_context_card.dart';
import '../../shared/widgets/profile_switcher.dart';
import '../timeline/timeline_item.dart';
import 'sleep_model.dart';

class SleepFormScreen extends StatefulWidget {
  const SleepFormScreen({super.key, this.existingItem});

  final TimelineItem? existingItem;

  @override
  State<SleepFormScreen> createState() => _SleepFormScreenState();
}

class _SleepFormScreenState extends State<SleepFormScreen> {
  DateTime _startTime = DateTime.now().subtract(const Duration(hours: 1));
  DateTime _endTime = DateTime.now();
  final TextEditingController _noteController = TextEditingController();

  bool get _isEdit => widget.existingItem != null;

  @override
  void initState() {
    super.initState();

    final existingItem = widget.existingItem;
    if (existingItem != null) {
      _startTime =
          existingItem.sleepStart ??
          (existingItem.sleepEnd ?? existingItem.time).subtract(
            const Duration(hours: 1),
          );
      _endTime = existingItem.sleepEnd ?? existingItem.time;
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

  String _formatDuration(int minutes) {
    final hours = minutes ~/ 60;
    final remainingMinutes = minutes % 60;

    if (hours > 0 && remainingMinutes > 0) {
      return '$hours h $remainingMinutes min';
    }
    if (hours > 0) {
      return '$hours h';
    }
    return '$remainingMinutes min';
  }

  int get _durationMinutes => _endTime.difference(_startTime).inMinutes;

  Future<void> _pickStartTime() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _startTime,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (pickedDate == null || !mounted) return;

    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_startTime),
    );

    if (pickedTime == null) return;

    final newStartTime = DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      pickedTime.hour,
      pickedTime.minute,
    );

    if (!newStartTime.isBefore(_endTime)) {
      _showInvalidRangeMessage();
      return;
    }

    setState(() {
      _startTime = newStartTime;
    });
  }

  Future<void> _pickEndTime() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _endTime,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (pickedDate == null || !mounted) return;

    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_endTime),
    );

    if (pickedTime == null) return;

    final newEndTime = DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      pickedTime.hour,
      pickedTime.minute,
    );

    if (!newEndTime.isAfter(_startTime)) {
      _showInvalidRangeMessage();
      return;
    }

    setState(() {
      _endTime = newEndTime;
    });
  }

  void _showInvalidRangeMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Konec spánku musí být později než začátek spánku.'),
      ),
    );
  }

  Future<void> _save() async {
    if (AppServices.childProfileController.activeProfile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Nejdřív vyber profil dítěte, ke kterému chceš událost uložit.',
          ),
        ),
      );
      return;
    }

    if (!_endTime.isAfter(_startTime)) {
      _showInvalidRangeMessage();
      return;
    }

    final note = _noteController.text.trim().isEmpty
        ? null
        : _noteController.text.trim();

    final record = SleepRecord(
      id: _endTime.millisecondsSinceEpoch.toString(),
      startTime: _startTime,
      endTime: _endTime,
      note: note,
    );

    final durationMinutes = record.endTime
        .difference(record.startTime)
        .inMinutes;

    final item = TimelineItem()
      ..id = widget.existingItem?.id ?? Isar.autoIncrement
      ..type = EventType.sleep
      ..time = record.endTime
      ..title = 'Spánek'
      ..subtitle = _formatDuration(durationMinutes)
      ..note = note
      ..sleepStart = record.startTime
      ..sleepEnd = record.endTime
      ..sleepDurationMinutes = durationMinutes;

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
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(56),
          child: ProfileSwitcher(
            embedded: true,
            padding: EdgeInsets.fromLTRB(16, 0, 16, 12),
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _FormIntroCard(
                        title: _isEdit ? 'Upravit spánek' : 'Nový spánek',
                        subtitle:
                            'Stačí zapsat začátek a konec. Délka se dopočítá automaticky.',
                      ),
                      const SizedBox(height: 14),
                      const EventFormContextCard(),
                      const SizedBox(height: 14),
                      Card(
                        child: ListTile(
                          title: const Text('Začátek spánku'),
                          subtitle: Text(_formatDateTime(_startTime)),
                          trailing: TextButton(
                            onPressed: _pickStartTime,
                            child: const Text('Změnit'),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Card(
                        child: ListTile(
                          title: const Text('Konec spánku'),
                          subtitle: Text(_formatDateTime(_endTime)),
                          trailing: TextButton(
                            onPressed: _pickEndTime,
                            child: const Text('Změnit'),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Card(
                        child: ListTile(
                          title: const Text('Délka spánku'),
                          subtitle: Text(_formatDuration(_durationMinutes)),
                        ),
                      ),
                      const SizedBox(height: 14),
                      TextField(
                        controller: _noteController,
                        minLines: 2,
                        maxLines: 4,
                        decoration: const InputDecoration(
                          labelText: 'Poznámka',
                          hintText: 'Např. usnul rychle nebo se budil',
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

class _FormIntroCard extends StatelessWidget {
  const _FormIntroCard({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: [Color(0xFFF3F7FF), Color(0xFFFFFFFF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Text(subtitle),
        ],
      ),
    );
  }
}
