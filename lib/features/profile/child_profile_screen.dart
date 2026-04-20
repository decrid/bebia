import 'package:flutter/material.dart';

import '../../core/app_services.dart';
import '../../shared/widgets/info_label.dart';
import '../auth/app_account_session.dart';
import '../auth/app_account_setup_screen.dart';
import '../family/family_connection.dart';
import '../family/family_sharing_screen.dart';
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

  String _formatDateTime(DateTime? value) {
    if (value == null) {
      return 'neuvedeno';
    }
    final day = value.day.toString().padLeft(2, '0');
    final month = value.month.toString().padLeft(2, '0');
    final year = value.year.toString();
    final hour = value.hour.toString().padLeft(2, '0');
    final minute = value.minute.toString().padLeft(2, '0');
    return '$day.$month.$year v $hour:$minute';
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

  Future<void> _openAccountSetup() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AppAccountSetupScreen()),
    );

    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _openFamilySharing() async {
    await showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const FamilySharingScreen(),
    );

    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _setActive(ChildProfile profile) async {
    await AppServices.childProfileController.setActiveProfile(profile.id);
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _assignToCurrentFamily(ChildProfile profile) async {
    final familyId =
        AppServices.familyConnectionController.state.value.familyId;
    if (familyId == null || familyId.isEmpty) {
      return;
    }

    await AppServices.childProfileController.assignProfileToFamily(
      profileId: profile.id,
      familyId: familyId,
    );

    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _removeFromFamily(ChildProfile profile) async {
    await AppServices.childProfileController.removeProfileFromFamily(
      profile.id,
    );
    if (mounted) {
      setState(() {});
    }
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

    if (confirmed != true) {
      return;
    }

    await AppServices.childProfileController.deleteProfile(
      profile.id,
      deleteEvents: true,
    );

    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = AppServices.childProfileController;
    final profiles = controller.profiles.value;
    final activeProfileId = controller.activeProfileId.value;
    final activeProfile = controller.activeProfile;
    final accountSession = AppServices.appAccountController.session.value;
    final familyState = AppServices.familyConnectionController.state.value;
    final colorScheme = Theme.of(context).colorScheme;
    final activeProfileReady =
        activeProfile != null &&
        familyState.familyId != null &&
        activeProfile.familyId == familyState.familyId;

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
                  activeProfile == null
                      ? 'Nové události se zatím ukládají jako nepřiřazené.'
                      : '${activeProfile.name} • ${_ageLabel(activeProfile.dateOfBirth)}',
                ),
                if (activeProfile != null) ...[
                  const SizedBox(height: 10),
                  InfoLabel(
                    label: activeProfileReady
                        ? 'Aktivní dítě už je přidané do rodiny'
                        : 'Aktivní dítě ještě není navázané na sdílenou rodinu',
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),
          _ProfileSharingBanner(
            session: accountSession,
            familyState: familyState,
            hasProfiles: profiles.isNotEmpty,
            activeProfileReady: activeProfileReady,
            onOpenAccountSetup: _openAccountSetup,
            onOpenFamilySharing: _openFamilySharing,
            onCreateProfile: () => _openEditor(),
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
                  currentFamilyId: familyState.familyId,
                  ageLabel: _ageLabel(profile.dateOfBirth),
                  linkedAtLabel: _formatDateTime(profile.linkedToFamilyAt),
                  onActivate: () => _setActive(profile),
                  onEdit: () => _openEditor(profile: profile),
                  onDelete: () => _deleteProfile(profile),
                  onAssignToFamily: () => _assignToCurrentFamily(profile),
                  onRemoveFromFamily: () => _removeFromFamily(profile),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ProfileSharingBanner extends StatelessWidget {
  const _ProfileSharingBanner({
    required this.session,
    required this.familyState,
    required this.hasProfiles,
    required this.activeProfileReady,
    required this.onOpenAccountSetup,
    required this.onOpenFamilySharing,
    required this.onCreateProfile,
  });

  final AppAccountSession session;
  final FamilyConnectionState familyState;
  final bool hasProfiles;
  final bool activeProfileReady;
  final Future<void> Function() onOpenAccountSetup;
  final Future<void> Function() onOpenFamilySharing;
  final Future<void> Function() onCreateProfile;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final title = switch ((
      hasProfiles,
      session.isSignedIn,
      familyState.inviteStatus,
      activeProfileReady,
    )) {
      (false, _, _, _) => 'Nejdřív vytvoř profil dítěte',
      (true, false, _, _) => 'Profil čeká na rodičovský účet',
      (true, true, FamilyInviteStatus.none, _) =>
        'Profil čeká na založení rodiny',
      (true, true, FamilyInviteStatus.draft, _) =>
        'Profil čeká na odeslání pozvánky',
      (true, true, FamilyInviteStatus.waitingForAcceptance, _) =>
        'Profil čeká na přijetí pozvánky',
      (true, true, FamilyInviteStatus.accepted, false) =>
        'Dítě ještě není přidané do aktivované rodiny',
      (true, true, FamilyInviteStatus.accepted, true) =>
        'Profil čeká na finální aktivaci rodiny',
      (true, true, FamilyInviteStatus.connected, false) =>
        'Dítě ještě není přidané do rodiny',
      (true, true, FamilyInviteStatus.connected, true) =>
        'Profil je připravený pro sdílenou rodinu',
    };

    final subtitle = switch ((
      hasProfiles,
      session.isSignedIn,
      familyState.inviteStatus,
      activeProfileReady,
    )) {
      (false, _, _, _) =>
        'Dokud neexistuje dítě, nemá Bebia co sdílet. Začni vytvořením prvního profilu.',
      (true, false, _, _) =>
        'Profil dítěte už existuje, ale pro bezpečné sdílení mezi rodiči ještě chybí účet.',
      (true, true, FamilyInviteStatus.none, _) =>
        'Účet už je připravený. Další krok je vytvořit rodinu a první pozvánku.',
      (true, true, FamilyInviteStatus.draft, _) =>
        'Rodina i kód pozvánky už existují, ale ještě zbývá pozvánku opravdu odeslat.',
      (true, true, FamilyInviteStatus.waitingForAcceptance, _) =>
        'Pozvánka už čeká na přijetí. Jakmile ji druhý rodič potvrdí, Bebia se posune do dalšího kroku.',
      (true, true, FamilyInviteStatus.accepted, false) =>
        'Pozvánka už byla přijatá, ale konkrétní dítě ještě není navázané na rodinný prostor.',
      (true, true, FamilyInviteStatus.accepted, true) =>
        'Dítě už je připravené, zbývá jen finálně aktivovat společnou rodinu.',
      (true, true, FamilyInviteStatus.connected, false) =>
        'Rodina už je aktivní, ale konkrétní dítě je ještě potřeba do ní výslovně přidat.',
      (true, true, FamilyInviteStatus.connected, true) =>
        'Aktivní dítě už je navázané na stejný rodinný prostor, který bude později synchronizovaný mezi zařízeními.',
    };

    final label = switch ((
      hasProfiles,
      session.isSignedIn,
      familyState.inviteStatus,
      activeProfileReady,
    )) {
      (false, _, _, _) => 'Krok 1',
      (true, false, _, _) => 'Krok 2',
      (true, true, FamilyInviteStatus.none, _) => 'Krok 3',
      (true, true, FamilyInviteStatus.draft, _) => 'Návrh',
      (true, true, FamilyInviteStatus.waitingForAcceptance, _) => 'Čeká',
      (true, true, FamilyInviteStatus.accepted, false) => 'Krok 4',
      (true, true, FamilyInviteStatus.accepted, true) => 'Přijato',
      (true, true, FamilyInviteStatus.connected, false) => 'Krok 4',
      (true, true, FamilyInviteStatus.connected, true) => 'Připraveno',
    };

    final Widget action = !hasProfiles
        ? FilledButton.tonalIcon(
            onPressed: () {
              onCreateProfile();
            },
            icon: const Icon(Icons.add_rounded),
            label: const Text('Vytvořit profil dítěte'),
          )
        : !session.isSignedIn
        ? FilledButton.tonalIcon(
            onPressed: () {
              onOpenAccountSetup();
            },
            icon: const Icon(Icons.manage_accounts_outlined),
            label: const Text('Otevřít účet'),
          )
        : FilledButton.tonalIcon(
            onPressed: () {
              onOpenFamilySharing();
            },
            icon: const Icon(Icons.family_restroom_outlined),
            label: Text(
              familyState.isConnected ? 'Spravovat rodinu' : 'Dokončit sdílení',
            ),
          );

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        color: colorScheme.surface,
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: colorScheme.secondaryContainer,
                foregroundColor: colorScheme.primary,
                child: const Icon(Icons.child_care_outlined),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              InfoLabel(label: label),
            ],
          ),
          const SizedBox(height: 10),
          Text(subtitle),
          if (session.isSignedIn) ...[
            const SizedBox(height: 10),
            Text(
              'Aktivní rodič: ${session.user!.displayName}',
              style: TextStyle(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
          if (familyState.familyId != null &&
              familyState.familyId!.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              'Rodina: ${familyState.familyId}',
              style: TextStyle(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (familyState.hasInvite) ...[
              const SizedBox(height: 4),
              Text(
                'Pozvánka: ${_inviteStatusLabel(familyState.inviteStatus)}',
                style: TextStyle(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
          const SizedBox(height: 14),
          action,
        ],
      ),
    );
  }

  String _inviteStatusLabel(FamilyInviteStatus status) {
    switch (status) {
      case FamilyInviteStatus.none:
        return 'bez pozvánky';
      case FamilyInviteStatus.draft:
        return 'návrh';
      case FamilyInviteStatus.waitingForAcceptance:
        return 'čeká na přijetí';
      case FamilyInviteStatus.accepted:
        return 'přijatá';
      case FamilyInviteStatus.connected:
        return 'aktivní';
    }
  }
}

class _EmptyProfilesState extends StatelessWidget {
  const _EmptyProfilesState({required this.onCreate});

  final Future<void> Function() onCreate;

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
              onPressed: () {
                onCreate();
              },
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

    if (picked == null) {
      return;
    }
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

    final existingProfile = widget.profile;
    final profile = ChildProfile(
      id:
          existingProfile?.id ??
          'child-${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      dateOfBirth: _dateOfBirth,
      sex: _sex,
      familyId: existingProfile?.familyId,
      linkedToFamilyAt: existingProfile?.linkedToFamilyAt,
    );

    await AppServices.childProfileController.saveProfile(profile);

    if (!mounted) {
      return;
    }
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
    required this.currentFamilyId,
    required this.ageLabel,
    required this.linkedAtLabel,
    required this.onActivate,
    required this.onEdit,
    required this.onDelete,
    required this.onAssignToFamily,
    required this.onRemoveFromFamily,
  });

  final ChildProfile profile;
  final bool isActive;
  final String? currentFamilyId;
  final String ageLabel;
  final String linkedAtLabel;
  final VoidCallback onActivate;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final Future<void> Function() onAssignToFamily;
  final Future<void> Function() onRemoveFromFamily;

  bool get isLinkedToCurrentFamily =>
      currentFamilyId != null && profile.familyId == currentFamilyId;

  @override
  Widget build(BuildContext context) {
    final hasCurrentFamily =
        currentFamilyId != null && currentFamilyId!.isNotEmpty;

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
            const SizedBox(height: 10),
            InfoLabel(
              label: !profile.isLinkedToFamily
                  ? 'Zatím není přiřazené do žádné rodiny'
                  : isLinkedToCurrentFamily
                  ? 'Patří do aktuální sdílené rodiny'
                  : 'Patří do jiné rodiny než je aktuálně otevřená',
            ),
            if (profile.isLinkedToFamily) ...[
              const SizedBox(height: 6),
              Text('Napojeno: $linkedAtLabel'),
            ],
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                OutlinedButton(
                  onPressed: onActivate,
                  child: Text(isActive ? 'Vybráno' : 'Nastavit aktivní'),
                ),
                if (hasCurrentFamily && !isLinkedToCurrentFamily)
                  OutlinedButton.icon(
                    onPressed: () {
                      onAssignToFamily();
                    },
                    icon: const Icon(Icons.family_restroom_outlined),
                    label: const Text('Přidat do rodiny'),
                  ),
                if (isLinkedToCurrentFamily)
                  OutlinedButton.icon(
                    onPressed: () {
                      onRemoveFromFamily();
                    },
                    icon: const Icon(Icons.link_off_rounded),
                    label: const Text('Odebrat z rodiny'),
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
