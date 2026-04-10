import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/app_services.dart';
import '../../shared/widgets/info_label.dart';
import 'family_connection.dart';

class FamilySharingScreen extends StatefulWidget {
  const FamilySharingScreen({super.key});

  @override
  State<FamilySharingScreen> createState() => _FamilySharingScreenState();
}

class _FamilySharingScreenState extends State<FamilySharingScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _roleController = TextEditingController(
    text: 'Rodič',
  );

  @override
  void initState() {
    super.initState();
    AppServices.familyConnectionController.load();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _roleController.dispose();
    super.dispose();
  }

  Future<void> _createInvite() async {
    await AppServices.familyConnectionController.createInvite();
  }

  Future<void> _copyInviteCode(String code) async {
    await Clipboard.setData(ClipboardData(text: code));
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Pozvánkový kód zkopírován.')));
  }

  Future<void> _addCaregiver() async {
    await AppServices.familyConnectionController.addCaregiver(
      name: _nameController.text,
      role: _roleController.text,
    );

    if (!mounted) return;
    if (AppServices.familyConnectionController.error.value == null) {
      _nameController.clear();
      _roleController.text = 'Rodič';
    }
  }

  String _formatDateTime(DateTime value) {
    final day = value.day.toString().padLeft(2, '0');
    final month = value.month.toString().padLeft(2, '0');
    final hour = value.hour.toString().padLeft(2, '0');
    final minute = value.minute.toString().padLeft(2, '0');
    return '$day.$month. $hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    final controller = AppServices.familyConnectionController;
    final colorScheme = Theme.of(context).colorScheme;
    final bottomInset = MediaQuery.of(context).padding.bottom;

    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(10, 0, 10, 6 + bottomInset),
        child: Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(32),
          child: Container(
            height: MediaQuery.of(context).size.height * 0.94,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(32),
              border: Border.all(
                color: colorScheme.outlineVariant.withValues(alpha: 0.16),
              ),
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 18, 12, 10),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Sdílení s rodičem',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close_rounded),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ValueListenableBuilder<FamilyConnectionState>(
                    valueListenable: controller.state,
                    builder: (context, state, _) {
                      return ListView(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 22),
                        children: [
                          _SharingHeaderCard(state: state),
                          const SizedBox(height: 16),
                          ValueListenableBuilder<bool>(
                            valueListenable: controller.isLoading,
                            builder: (context, isLoading, _) {
                              return _InviteCard(
                                state: state,
                                isLoading: isLoading,
                                onCreateInvite: _createInvite,
                                onCopyInviteCode: _copyInviteCode,
                                onCancelInvite: controller.cancelInvite,
                                onMarkConnected: controller.markConnected,
                                formatDateTime: _formatDateTime,
                              );
                            },
                          ),
                          const SizedBox(height: 16),
                          _CaregiverForm(
                            nameController: _nameController,
                            roleController: _roleController,
                            onSubmit: _addCaregiver,
                          ),
                          const SizedBox(height: 16),
                          _CaregiverList(
                            caregivers: state.caregivers,
                            onRemove: controller.removeCaregiver,
                          ),
                          const SizedBox(height: 12),
                          ValueListenableBuilder<String?>(
                            valueListenable: controller.error,
                            builder: (context, error, _) {
                              if (error == null) return const SizedBox.shrink();
                              return Text(
                                error,
                                style: TextStyle(color: colorScheme.error),
                              );
                            },
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SharingHeaderCard extends StatelessWidget {
  const _SharingHeaderCard({required this.state});

  final FamilyConnectionState state;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          colors: [
            colorScheme.primaryContainer.withValues(alpha: 0.62),
            colorScheme.surface,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: colorScheme.primary.withValues(alpha: 0.14),
                foregroundColor: colorScheme.primary,
                child: const Icon(Icons.diversity_1_outlined),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  state.isConnected
                      ? 'Rodina je připravená'
                      : 'Připrav propojení rodiny',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                ),
              ),
              InfoLabel(label: state.isConnected ? 'Propojeno' : 'Lokálně'),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Teď připravíme rodinný prostor, pečující osoby a pozvánku. Skutečná synchronizace mezi telefony bude navazovat přes cloud účet.',
          ),
        ],
      ),
    );
  }
}

class _InviteCard extends StatelessWidget {
  const _InviteCard({
    required this.state,
    required this.isLoading,
    required this.onCreateInvite,
    required this.onCopyInviteCode,
    required this.onCancelInvite,
    required this.onMarkConnected,
    required this.formatDateTime,
  });

  final FamilyConnectionState state;
  final bool isLoading;
  final VoidCallback onCreateInvite;
  final ValueChanged<String> onCopyInviteCode;
  final VoidCallback onCancelInvite;
  final VoidCallback onMarkConnected;
  final String Function(DateTime value) formatDateTime;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Pozvánka',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Text(
              state.hasInvite
                  ? 'Kód pak pošleš druhému rodiči.'
                  : 'Vytvoř pozvánku pro druhého rodiče.',
            ),
            const SizedBox(height: 14),
            if (state.hasInvite) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(22),
                  color: colorScheme.primaryContainer.withValues(alpha: 0.46),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Kód pozvánky',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      state.inviteCode!,
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.6,
                          ),
                    ),
                    if (state.inviteCreatedAt != null) ...[
                      const SizedBox(height: 6),
                      Text(
                        'Vytvořeno ${formatDateTime(state.inviteCreatedAt!)}',
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  FilledButton.icon(
                    onPressed: isLoading
                        ? null
                        : () => onCopyInviteCode(state.inviteCode!),
                    icon: const Icon(Icons.copy_rounded),
                    label: const Text('Kopírovat'),
                  ),
                  OutlinedButton.icon(
                    onPressed: isLoading ? null : onMarkConnected,
                    icon: const Icon(Icons.check_circle_outline_rounded),
                    label: const Text('Označit propojené'),
                  ),
                  TextButton(
                    onPressed: isLoading ? null : onCancelInvite,
                    child: const Text('Zrušit pozvánku'),
                  ),
                ],
              ),
            ] else
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: isLoading ? null : onCreateInvite,
                  icon: const Icon(Icons.group_add_outlined),
                  label: const Text('Vytvořit pozvánku'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _CaregiverForm extends StatelessWidget {
  const _CaregiverForm({
    required this.nameController,
    required this.roleController,
    required this.onSubmit,
  });

  final TextEditingController nameController;
  final TextEditingController roleController;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Pečující osoba',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Jméno',
                hintText: 'Např. táta',
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: roleController,
              decoration: const InputDecoration(
                labelText: 'Role',
                hintText: 'Rodič',
              ),
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: onSubmit,
                icon: const Icon(Icons.person_add_alt_1_rounded),
                label: const Text('Přidat osobu'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CaregiverList extends StatelessWidget {
  const _CaregiverList({required this.caregivers, required this.onRemove});

  final List<CaregiverProfile> caregivers;
  final ValueChanged<String> onRemove;

  @override
  Widget build(BuildContext context) {
    if (caregivers.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(18),
          child: Text('Zatím není přidaná žádná pečující osoba.'),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Pečující osoby',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 10),
        ...caregivers.map(
          (caregiver) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Card(
              child: ListTile(
                leading: const CircleAvatar(child: Icon(Icons.person_outline)),
                title: Text(caregiver.name),
                subtitle: Text(caregiver.role),
                trailing: caregiver.isOwner
                    ? const InfoLabel(label: 'Vlastník')
                    : IconButton(
                        onPressed: () => onRemove(caregiver.id),
                        icon: const Icon(Icons.close_rounded),
                      ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
