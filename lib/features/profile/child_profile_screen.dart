import 'package:flutter/material.dart';

import '../../core/app_services.dart';
import '../../shared/widgets/info_label.dart';
import 'child_profile.dart';

class ChildProfileScreen extends StatefulWidget {
  const ChildProfileScreen({super.key});

  @override
  State<ChildProfileScreen> createState() => _ChildProfileScreenState();
}

class _ChildProfileScreenState extends State<ChildProfileScreen> {
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

  Future<void> _openEditor({ChildProfile? profile}) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => _ProfileEditorDialog(profile: profile),
    );

    if (result == true && mounted) {
      setState(() {});
    }
  }

  Future<void> _setActive(ChildProfile profile) async {
    await AppServices.childProfileController.setActiveProfile(profile.id);
    if (!mounted) return;
    setState(() {});
  }

  Future<void> _deleteProfile(ChildProfile profile) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Smazat profil ${profile.name}?'),
        content: const Text(
          'Smaže se profil dítěte i všechny události, které k němu patří.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Zrušit'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Smazat'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    await AppServices.childProfileController.deleteProfile(
      profile.id,
      deleteEvents: true,
    );

    if (!mounted) return;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final controller = AppServices.childProfileController;
    final profiles = controller.profiles.value;
    final activeProfileId = controller.activeProfileId.value;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Děti a profily')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: LinearGradient(
                colors: [
                  colorScheme.primaryContainer.withValues(alpha: 0.58),
                  colorScheme.surface,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Aktivní dítě',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 6),
                Text(
                  controller.activeProfile == null
                      ? 'Nové události se zatím ukládají jako nepřiřazené.'
                      : '${controller.activeProfile!.name} • ${_ageLabel(controller.activeProfile!.dateOfBirth)}',
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          if (profiles.isEmpty)
            _EmptyProfilesState(onCreate: () => _openEditor())
          else ...[
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
                  onPressed: () => _openEditor(),
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('Vytvořit profil dítěte'),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ...profiles.map(
              (profile) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _ChildProfileTile(
                  profile: profile,
                  isActive: profile.id == activeProfileId,
                  onActivate: () => _setActive(profile),
                  onEdit: () => _openEditor(profile: profile),
                  onDelete: () => _deleteProfile(profile),
                  ageLabel: _ageLabel(profile.dateOfBirth),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _EmptyProfilesState extends StatelessWidget {
  const _EmptyProfilesState({required this.onCreate});

  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          colors: [
            colorScheme.primaryContainer.withValues(alpha: 0.42),
            colorScheme.surface,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Není vytvořen profil dítěte',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 10),
          const Text(
            'Vytvoř profil dítěte, aby se záznamy i doporučení správně přiřazovaly.',
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: onCreate,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Vytvořit profil dítěte'),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileEditorDialog extends StatefulWidget {
  const _ProfileEditorDialog({this.profile});

  final ChildProfile? profile;

  @override
  State<_ProfileEditorDialog> createState() => _ProfileEditorDialogState();
}

class _ProfileEditorDialogState extends State<_ProfileEditorDialog> {
  late final TextEditingController _nameController;
  late DateTime _dateOfBirth;
  String? _sex;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.profile?.name ?? '');
    _dateOfBirth = widget.profile?.dateOfBirth ?? DateTime.now();
    _sex = widget.profile?.sex;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
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
          widget.profile?.id ??
          'child-${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      dateOfBirth: _dateOfBirth,
      sex: _sex,
    );

    await AppServices.childProfileController.saveProfile(profile);

    if (!mounted) return;
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.profile == null
                          ? 'Vytvořit profil dítěte'
                          : 'Upravit profil dítěte',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context, false),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
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
                  subtitle: Text(_formatDate(_dateOfBirth)),
                  trailing: TextButton(
                    onPressed: _pickDate,
                    child: const Text('Změnit'),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              DropdownButtonFormField<String?>(
                key: ValueKey(
                  '${widget.profile?.id ?? 'new'}-${_sex ?? 'none'}',
                ),
                initialValue: _sex,
                decoration: const InputDecoration(
                  labelText: 'Pohlaví (volitelné)',
                ),
                items: const [
                  DropdownMenuItem<String?>(
                    value: null,
                    child: Text('Nezadáno'),
                  ),
                  DropdownMenuItem<String?>(
                    value: 'girl',
                    child: Text('Dívka'),
                  ),
                  DropdownMenuItem<String?>(
                    value: 'boy',
                    child: Text('Chlapec'),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    _sex = value;
                  });
                },
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _save,
                  child: Text(
                    widget.profile == null ? 'Vytvořit profil' : 'Uložit změny',
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
                if (isActive) const InfoLabel(label: 'Aktivní'),
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
