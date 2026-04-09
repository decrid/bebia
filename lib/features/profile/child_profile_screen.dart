import 'package:flutter/material.dart';

import '../../core/app_services.dart';
import 'child_profile.dart';

class ChildProfileScreen extends StatefulWidget {
  const ChildProfileScreen({super.key});

  @override
  State<ChildProfileScreen> createState() => _ChildProfileScreenState();
}

class _ChildProfileScreenState extends State<ChildProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  DateTime _dateOfBirth = DateTime.now();
  String? _sex;
  ChildProfile? _editingProfile;

  @override
  void initState() {
    super.initState();
    final active = AppServices.childProfileController.activeProfile;
    if (active != null) {
      _loadIntoForm(active);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _loadIntoForm(ChildProfile profile) {
    setState(() {
      _editingProfile = profile;
      _nameController.text = profile.name;
      _dateOfBirth = profile.dateOfBirth;
      _sex = profile.sex;
    });
  }

  void _resetForm() {
    setState(() {
      _editingProfile = null;
      _nameController.clear();
      _dateOfBirth = DateTime.now();
      _sex = null;
    });
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dateOfBirth,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (picked == null) return;

    setState(() {
      _dateOfBirth = picked;
    });
  }

  String _formatDate(DateTime value) {
    final day = value.day.toString().padLeft(2, '0');
    final month = value.month.toString().padLeft(2, '0');
    final year = value.year.toString();
    return '$day.$month.$year';
  }

  String _ageLabel(DateTime dateOfBirth) {
    final now = DateTime.now();
    int months =
        (now.year - dateOfBirth.year) * 12 + now.month - dateOfBirth.month;
    if (now.day < dateOfBirth.day) {
      months -= 1;
    }

    if (months <= 0) {
      final days = now.difference(dateOfBirth).inDays.clamp(0, 31);
      return '$days dní';
    }

    final years = months ~/ 12;
    final remainingMonths = months % 12;

    if (years == 0) {
      return '$months měs.';
    }

    if (remainingMonths == 0) {
      return '$years r.';
    }

    return '$years r. $remainingMonths měs.';
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Zadej jméno dítěte.')));
      return;
    }

    final profile = ChildProfile(
      id:
          _editingProfile?.id ??
          'child-${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      dateOfBirth: _dateOfBirth,
      sex: _sex,
    );

    await AppServices.childProfileController.saveProfile(profile);

    if (!mounted) return;
    _loadIntoForm(profile);
  }

  Future<void> _setActive(ChildProfile profile) async {
    await AppServices.childProfileController.setActiveProfile(profile.id);
    if (!mounted) return;
    setState(() {});
  }

  Future<void> _deleteProfile(ChildProfile profile) async {
    final action = await showDialog<_DeleteProfileAction>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Smazat profil ${profile.name}?'),
        content: const Text(
          'Můžeš smazat i jeho události, nebo je ponechat jako nepřiřazené.',
        ),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.pop(context, _DeleteProfileAction.cancel),
            child: const Text('Zrušit'),
          ),
          TextButton(
            onPressed: () =>
                Navigator.pop(context, _DeleteProfileAction.keepEvents),
            child: const Text('Ponechat události'),
          ),
          TextButton(
            onPressed: () =>
                Navigator.pop(context, _DeleteProfileAction.deleteEvents),
            child: const Text('Smazat i události'),
          ),
        ],
      ),
    );

    if (action == null || action == _DeleteProfileAction.cancel) return;

    await AppServices.childProfileController.deleteProfile(
      profile.id,
      deleteEvents: action == _DeleteProfileAction.deleteEvents,
    );

    if (!mounted) return;

    final active = AppServices.childProfileController.activeProfile;
    if (active != null) {
      _loadIntoForm(active);
    } else {
      _resetForm();
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = AppServices.childProfileController;
    final profiles = controller.profiles.value;
    final activeProfileId = controller.activeProfileId.value;

    return Scaffold(
      appBar: AppBar(title: const Text('Děti a profily')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: const LinearGradient(
                  colors: [Color(0xFFE2F5F1), Color(0xFFFFFFFF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Aktivní dítě',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    controller.activeProfile == null
                        ? 'Zatím není vybraný žádný profil. Nové události se budou ukládat jako nepřiřazené.'
                        : '${controller.activeProfile!.name} • ${_ageLabel(controller.activeProfile!.dateOfBirth)}',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Profily dětí',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                ),
                TextButton.icon(
                  onPressed: _resetForm,
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('Nové dítě'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (profiles.isEmpty)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(18),
                  child: Text('Zatím není vytvořený žádný profil dítěte.'),
                ),
              )
            else
              ...profiles.map(
                (profile) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _ChildProfileTile(
                    profile: profile,
                    isActive: profile.id == activeProfileId,
                    onActivate: () => _setActive(profile),
                    onEdit: () => _loadIntoForm(profile),
                    onDelete: () => _deleteProfile(profile),
                    ageLabel: _ageLabel(profile.dateOfBirth),
                  ),
                ),
              ),
            const SizedBox(height: 18),
            Text(
              _editingProfile == null ? 'Nový profil dítěte' : 'Upravit profil',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Jméno dítěte',
                hintText: 'Např. Ema',
              ),
            ),
            const SizedBox(height: 14),
            Card(
              child: ListTile(
                title: const Text('Datum narození'),
                subtitle: Text(
                  '${_formatDate(_dateOfBirth)} • ${_ageLabel(_dateOfBirth)}',
                ),
                trailing: TextButton(
                  onPressed: _pickDate,
                  child: const Text('Změnit'),
                ),
              ),
            ),
            const SizedBox(height: 14),
            DropdownButtonFormField<String?>(
              key: ValueKey(
                "${_editingProfile?.id ?? 'new'}-${_sex ?? 'none'}",
              ),
              initialValue: _sex,
              decoration: const InputDecoration(
                labelText: 'Pohlaví (volitelné)',
              ),
              items: const [
                DropdownMenuItem<String?>(value: null, child: Text('Nezadáno')),
                DropdownMenuItem<String?>(value: 'girl', child: Text('Dívka')),
                DropdownMenuItem<String?>(value: 'boy', child: Text('Chlapec')),
              ],
              onChanged: (value) {
                setState(() {
                  _sex = value;
                });
              },
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _save,
                child: Text(
                  _editingProfile == null ? 'Vytvořit profil' : 'Uložit změny',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChildProfileTile extends StatelessWidget {
  const _ChildProfileTile({
    required this.profile,
    required this.isActive,
    required this.onActivate,
    required this.onEdit,
    required this.onDelete,
    required this.ageLabel,
  });

  final ChildProfile profile;
  final bool isActive;
  final VoidCallback onActivate;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final String ageLabel;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        profile.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(ageLabel),
                    ],
                  ),
                ),
                if (isActive)
                  const Chip(
                    label: Text('Aktivní'),
                    visualDensity: VisualDensity.compact,
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                OutlinedButton(
                  onPressed: onActivate,
                  child: Text(isActive ? 'Vybráno' : 'Nastavit aktivní'),
                ),
                OutlinedButton(onPressed: onEdit, child: const Text('Upravit')),
                OutlinedButton(
                  onPressed: onDelete,
                  child: const Text('Smazat'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

enum _DeleteProfileAction { cancel, keepEvents, deleteEvents }
