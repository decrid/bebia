import 'package:flutter/material.dart';
import 'package:isar_community/isar.dart';

import '../../core/design/bebia_theme.dart';
import '../../shared/widgets/bebia_components.dart';
import '../../shared/widgets/event_form_context_card.dart';
import '../../shared/widgets/profile_switcher.dart';
import '../timeline/timeline_item.dart';
import '../timeline/timeline_form_submission.dart';
import 'feeding_model.dart';

class FeedingFormScreen extends StatefulWidget {
  const FeedingFormScreen({super.key, this.existingItem, this.submission});

  final TimelineItem? existingItem;
  final TimelineFormSubmission? submission;

  @override
  State<FeedingFormScreen> createState() => _FeedingFormScreenState();
}

class _FeedingFormScreenState extends State<FeedingFormScreen> {
  String _type = 'breast';
  DateTime _selectedTime = DateTime.now();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  bool _isSaving = false;

  bool get _isEdit => widget.existingItem != null;
  TimelineFormSubmission get _submission =>
      widget.submission ?? const AppTimelineFormSubmission();

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

    if (pickedTime == null || !mounted) return;

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
    if (_isSaving) return;
    if (!_submission.hasActiveProfile) {
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
    if (amountText.isNotEmpty && (parsedAmount == null || parsedAmount <= 0)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Množství musí být kladné celé číslo v mililitrech.'),
        ),
      );
      return;
    }
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

    setState(() => _isSaving = true);
    try {
      await _submission.save(item, isEdit: _isEdit);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Krmení se nepodařilo uložit: $error')),
      );
      return;
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }

    if (!mounted) return;
    if (Navigator.of(context).canPop()) {
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profileSwitcherHeight =
        MediaQuery.textScalerOf(context).scale(1) >= 1.5 ? 84.0 : 56.0;
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Text(_isEdit ? 'Upravit krmení' : 'Krmení'),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(profileSwitcherHeight),
          child: const ProfileSwitcher(
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
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final stackOptions =
                              constraints.maxWidth < 340 ||
                              MediaQuery.textScalerOf(context).scale(1) >= 1.5;
                          const options = [
                            (
                              value: 'breast',
                              label: 'Kojení',
                              icon: Icons.favorite_border,
                            ),
                            (
                              value: 'bottle',
                              label: 'Lahvička',
                              icon: Icons.local_drink_outlined,
                            ),
                          ];

                          return Semantics(
                            label: 'Typ krmení',
                            child: Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: options.map((option) {
                                return SizedBox(
                                  width: stackOptions
                                      ? constraints.maxWidth
                                      : null,
                                  child: ChoiceChip(
                                    avatar: Icon(option.icon),
                                    label: Text(option.label),
                                    selected: _type == option.value,
                                    onSelected: (_) {
                                      setState(() {
                                        _type = option.value;
                                      });
                                    },
                                  ),
                                );
                              }).toList(),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 14),
                      TextField(
                        key: const Key('feeding-amount-field'),
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
                    onPressed: _isSaving ? null : _save,
                    child: Text(
                      _isSaving
                          ? 'Ukládám…'
                          : _isEdit
                          ? 'Uložit změny'
                          : 'Uložit',
                    ),
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
    return BebiaFormIntroCard(
      accent: context.bebia.feeding,
      title: title,
      subtitle: subtitle,
    );
  }
}
