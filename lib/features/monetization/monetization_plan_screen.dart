import 'package:flutter/material.dart';

import '../../core/app_services.dart';
import 'monetization_feature.dart';

class MonetizationPlanScreen extends StatelessWidget {
  const MonetizationPlanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final service = AppServices.monetizationService;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Bebia Plus')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              gradient: LinearGradient(
                colors: [
                  colorScheme.primaryContainer.withValues(alpha: 0.6),
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
                  service.plusName,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  service.plusTagline,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  service.positioningSummary,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 14),
                ...service.plusValueProps.map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.check_circle_outline_rounded, size: 18),
                        const SizedBox(width: 8),
                        Expanded(child: Text(item)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          const _SectionHeader(
            title: 'Konkrétní výbava Bebia Plus',
            subtitle: 'Toto je navržený balík placené hodnoty, do kterého by měla Bebia dorůst.',
          ),
          const SizedBox(height: 10),
          ...service.premiumFeatures.map(
            (feature) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _FeatureCard(
                feature: feature,
                tint: const Color(0xFFFFF3E7),
                badge: feature.launchPhase,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Nejlepší moment pro nabídku upgradu',
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
                  ),
                  const SizedBox(height: 8),
                  ...service.premiumFeatures.map(
                    (feature) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text('${feature.title}: ${feature.upgradeMoment}'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          const _SectionHeader(
            title: 'Co má zůstat zdarma',
            subtitle: 'Tyto části musí zůstat otevřené, aby mohl růst návyk i důvěra.',
          ),
          const SizedBox(height: 10),
          ...service.freeFeatures.map(
            (feature) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _FeatureCard(
                feature: feature,
                tint: const Color(0xFFEAF8F7),
                badge: 'Zdarma',
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Plán nasazení',
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
                  ),
                  const SizedBox(height: 8),
                  ...service.rolloutPlan.map(
                    (item) => Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Text(item),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 4),
        Text(subtitle),
      ],
    );
  }
}

class _FeatureCard extends StatelessWidget {
  const _FeatureCard({
    required this.feature,
    required this.tint,
    required this.badge,
  });

  final MonetizationFeature feature;
  final Color tint;
  final String badge;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundColor: tint,
              foregroundColor: colorScheme.primary,
              child: Icon(
                feature.includedInFree
                    ? Icons.lock_open_rounded
                    : Icons.auto_awesome_outlined,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    feature.title,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 4),
                  Text(feature.description),
                  const SizedBox(height: 8),
                  Text(
                    '${feature.plusPillar} • ${feature.launchPhase}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    feature.businessReason,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Chip(label: Text(badge)),
          ],
        ),
      ),
    );
  }
}
