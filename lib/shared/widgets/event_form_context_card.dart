import 'package:flutter/material.dart';

import '../../core/app_services.dart';
import '../../features/auth/app_account_session.dart';
import '../../features/family/family_connection.dart';
import '../../features/profile/child_profile.dart';
import 'info_label.dart';

class EventFormContextCard extends StatelessWidget {
  const EventFormContextCard({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AppAccountSession>(
      valueListenable: AppServices.appAccountController.session,
      builder: (context, session, _) {
        return ValueListenableBuilder<FamilyConnectionState>(
          valueListenable: AppServices.familyConnectionController.state,
          builder: (context, familyState, _) {
            return ValueListenableBuilder<String?>(
              valueListenable:
                  AppServices.childProfileController.activeProfileId,
              builder: (context, _, _) {
                final activeProfile =
                    AppServices.childProfileController.activeProfile;
                return _EventFormContextContent(
                  session: session,
                  familyState: familyState,
                  activeProfile: activeProfile,
                );
              },
            );
          },
        );
      },
    );
  }
}

class _EventFormContextContent extends StatelessWidget {
  const _EventFormContextContent({
    required this.session,
    required this.familyState,
    required this.activeProfile,
  });

  final AppAccountSession session;
  final FamilyConnectionState familyState;
  final ChildProfile? activeProfile;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final hasFamily =
        familyState.familyId != null && familyState.familyId!.isNotEmpty;
    final hasActiveProfile = activeProfile != null;
    final activeProfileLinked =
        activeProfile != null &&
        activeProfile!.familyId == familyState.familyId;

    final title = !hasActiveProfile
        ? 'Zápis zatím nemá vybrané dítě'
        : activeProfileLinked
        ? 'Událost se zapíše do sdílené rodiny'
        : hasFamily
        ? 'Událost se zapíše jen lokálně k vybranému dítěti'
        : 'Událost se zapíše lokálně k vybranému dítěti';

    final subtitle = !hasActiveProfile
        ? 'Nejdřív nahoře vyber profil dítěte. Teprve potom bude jasné, ke komu záznam patří.'
        : activeProfileLinked
        ? 'Aktivní dítě už patří do stejné rodiny jako aktuální rodinné sdílení, takže tento zápis je připravený i pro budoucí synchronizaci.'
        : hasFamily
        ? 'Rodina už existuje, ale aktivní dítě do ní ještě není přiřazené. Záznam se proto uloží pouze lokálně.'
        : 'Rodinné sdílení ještě není aktivní, takže se tento zápis uloží pouze na tomto zařízení.';

    final badge = !hasActiveProfile
        ? 'Chybí dítě'
        : activeProfileLinked
        ? 'Sdílená rodina'
        : 'Lokální režim';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        color: colorScheme.surface,
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              InfoLabel(label: badge),
            ],
          ),
          const SizedBox(height: 8),
          Text(subtitle),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (hasActiveProfile)
                InfoLabel(label: 'Dítě ${activeProfile!.name}'),
              if (session.isSignedIn)
                InfoLabel(label: 'Rodič ${session.user!.displayName}'),
              if (hasFamily) InfoLabel(label: 'Rodina ${familyState.familyId}'),
              if (familyState.hasInvite)
                InfoLabel(
                  label:
                      'Pozvánka ${_inviteStatusLabel(familyState.inviteStatus)}',
                ),
            ],
          ),
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
        return 'čeká';
      case FamilyInviteStatus.accepted:
        return 'přijatá';
      case FamilyInviteStatus.connected:
        return 'aktivní';
    }
  }
}
