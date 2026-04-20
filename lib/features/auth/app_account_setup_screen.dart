import 'package:flutter/material.dart';

import '../../core/app_services.dart';
import '../../shared/widgets/info_label.dart';
import 'app_account_provider.dart';
import 'app_account_session.dart';

class AppAccountSetupScreen extends StatelessWidget {
  const AppAccountSetupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = AppServices.appAccountController;

    return Scaffold(
      appBar: AppBar(title: const Text('Účet a synchronizace')),
      body: ValueListenableBuilder<AppAccountSession>(
        valueListenable: controller.session,
        builder: (context, session, _) {
          return ValueListenableBuilder<String?>(
            valueListenable: controller.error,
            builder: (context, error, _) {
              return ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                children: [
                  _HeroCard(session: session),
                  const SizedBox(height: 16),
                  const _WhyAccountsCard(),
                  const SizedBox(height: 16),
                  _ProviderCard(
                    session: session,
                    onTapProvider: controller.signInPreview,
                    onSignOut: controller.signOutPreview,
                  ),
                  if (error != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      error,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ],
                ],
              );
            },
          );
        },
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.session});

  final AppAccountSession session;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final title = session.isConfigured
        ? 'Cloudový základ je připravený'
        : session.isSignedIn
        ? 'Preview účtu je aktivní'
        : 'Čeká nás dopojení Firebase';

    final subtitle = session.isConfigured
        ? 'Dalším krokem je přihlášení rodičů a vytvoření skutečné sdílené rodiny.'
        : session.isSignedIn
        ? 'Rodičovský účet je teď přihlášený jen lokálně, ale Bebia už díky tomu může ukazovat finální tok sdílení.'
        : 'Architektura už je připravená, ale chybí skutečný Firebase projekt a ostré přihlášení.';

    final badge = session.isConfigured
        ? 'Připraveno'
        : session.isPreviewMode
        ? 'Lokální preview'
        : 'Zatím lokálně';

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
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                ),
              ),
              InfoLabel(label: badge),
            ],
          ),
          const SizedBox(height: 10),
          Text(subtitle),
          if (session.isSignedIn) ...[
            const SizedBox(height: 12),
            Text(
              'Aktivní rodič: ${session.user!.displayName}',
              style: TextStyle(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _WhyAccountsCard extends StatelessWidget {
  const _WhyAccountsCard();

  @override
  Widget build(BuildContext context) {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Proč vlastní účet každého rodiče',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
            ),
            SizedBox(height: 8),
            Text(
              'Bebia nebude stát na sdíleném jednom účtu. Každý rodič bude mít vlastní přihlášení, společnou rodinu a pozvánkový tok bez sdílení hesla.',
            ),
          ],
        ),
      ),
    );
  }
}

class _ProviderCard extends StatelessWidget {
  const _ProviderCard({
    required this.session,
    required this.onTapProvider,
    required this.onSignOut,
  });

  final AppAccountSession session;
  final ValueChanged<AppAccountProvider> onTapProvider;
  final VoidCallback onSignOut;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Přihlášení rodiče',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Text(
              session.isConfigured
                  ? 'Vyber poskytovatele přihlášení pro první ostrý účet.'
                  : session.isSignedIn
                  ? 'Teď používáš lokální preview účtu. Můžeš přepnout poskytovatele nebo se odhlásit.'
                  : 'Poskytovatelé jsou připravení v návrhu. Jakmile dopojíme Firebase, spustíme ostré přihlášení.',
            ),
            const SizedBox(height: 14),
            ...session.supportedProviders.map(
              (provider) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _ProviderTile(
                  provider: provider,
                  onTap: () {
                    onTapProvider(provider);
                  },
                ),
              ),
            ),
            if (session.isSignedIn) ...[
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: onSignOut,
                  icon: const Icon(Icons.logout_rounded),
                  label: const Text('Odhlásit preview účet'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ProviderTile extends StatelessWidget {
  const _ProviderTile({required this.provider, required this.onTap});

  final AppAccountProvider provider;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Ink(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Theme.of(
              context,
            ).colorScheme.outlineVariant.withValues(alpha: 0.3),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              CircleAvatar(child: Icon(_iconFor(provider))),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  provider.label,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
              const Icon(Icons.arrow_forward_ios_rounded, size: 18),
            ],
          ),
        ),
      ),
    );
  }

  IconData _iconFor(AppAccountProvider provider) {
    switch (provider) {
      case AppAccountProvider.google:
        return Icons.account_circle_outlined;
      case AppAccountProvider.apple:
        return Icons.phone_iphone_rounded;
      case AppAccountProvider.email:
        return Icons.mail_outline_rounded;
    }
  }
}
