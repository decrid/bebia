import 'package:flutter/material.dart';
import 'package:isar_community/isar.dart';

import '../../core/app_services.dart';
import '../../shared/widgets/event_form_context_card.dart';
import '../../shared/widgets/profile_switcher.dart';
import '../timeline/timeline_item.dart';
import 'feeding_model.dart';

class FeedingFormScreen extends StatefulWidget {
  const FeedingFormScreen({super.key, this.existingItem});

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
                        title: _isEdit
                            ? 'Upravit záznam krmení'
                            : 'Nové krmení',
                        subtitle:
                            'Zapiš jen to podstatné. Množství i poznámka jsou volitelné.',
                      ),
                      const SizedBox(height: 14),
                      const EventFormContextCard(),
                      const SizedBox(height: 14),
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
                      const SizedBox(height: 14),
                      SegmentedButton<String>(
                        segments: const [
                          ButtonSegment(
                            value: 'breast',
                            icon: Icon(Icons.favorite_border),
                            label: Text('Kojení'),
                          ),
                          ButtonSegment(
                            value: 'bottle',
                            icon: Icon(Icons.local_drink_outlined),
                            label: Text('Lahvička'),
                          ),
                        ],
                        selected: {_type},
                        onSelectionChanged: (selection) {
                          setState(() {
                            _type = selection.first;
                          });
                        },
                      ),
                      const SizedBox(height: 14),
                      TextField(
                        controller: _amountController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Množství (ml)',
                          hintText: 'Např. 90',
                        ),
                      ),
                      const SizedBox(height: 14),
                      TextField(
                        controller: _noteController,
                        minLines: 2,
                        maxLines: 4,
                        decoration: const InputDecoration(
                          labelText: 'Poznámka',
                          hintText: 'Např. klidné krmení nebo horší pití',
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
          colors: [Color(0xFFF0F9F7), Color(0xFFFFFFFF)],
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
