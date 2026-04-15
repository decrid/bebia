import 'package:flutter/material.dart';

import '../../core/app_services.dart';
import '../../features/crying/crying_form_screen.dart';
import '../../features/diaper/diaper_form_screen.dart';
import '../../features/feeding/feeding_form_screen.dart';
import '../../features/home/home_screen.dart';
import '../../features/sleep/sleep_form_screen.dart';
import '../../features/statistics/statistics_screen.dart';
import '../../features/timeline/timeline_screen.dart';
import 'profile_switcher.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    TimelineScreen(),
    StatisticsScreen(),
  ];

  Future<void> _openQuickAddSheet() async {
    final screen = await showModalBottomSheet<Widget>(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const _QuickAddSheet(),
    );

    if (!mounted || screen == null) return;

    await Navigator.push(context, MaterialPageRoute(builder: (_) => screen));

    if (!mounted) return;
    await AppServices.timelineController.reloadCurrent();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 220),
        child: KeyedSubtree(
          key: ValueKey(_currentIndex),
          child: _screens[_currentIndex],
        ),
      ),
      floatingActionButton: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: colorScheme.primary.withValues(alpha: 0.18),
              blurRadius: 22,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: FloatingActionButton.extended(
          onPressed: _openQuickAddSheet,
          icon: const Icon(Icons.add_rounded),
          label: const Text('Přidat událost'),
          extendedPadding: const EdgeInsets.symmetric(horizontal: 22),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          margin: const EdgeInsets.fromLTRB(12, 0, 12, 10),
          padding: const EdgeInsets.fromLTRB(10, 8, 10, 6),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(26),
            border: Border.all(
              color: colorScheme.outlineVariant.withValues(alpha: 0.2),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 18,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: NavigationBar(
              selectedIndex: _currentIndex,
              onDestinationSelected: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.home_outlined),
                  selectedIcon: Icon(Icons.home_rounded),
                  label: 'Domů',
                ),
                NavigationDestination(
                  icon: Icon(Icons.view_timeline_outlined),
                  selectedIcon: Icon(Icons.view_timeline_rounded),
                  label: 'Přehled',
                ),
                NavigationDestination(
                  icon: Icon(Icons.insights_outlined),
                  selectedIcon: Icon(Icons.insights_rounded),
                  label: 'Statistiky',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _QuickAddSheet extends StatelessWidget {
  const _QuickAddSheet();

  void _select(BuildContext context, Widget screen) {
    Navigator.pop(context, screen);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final bottomInset = MediaQuery.of(context).padding.bottom;

    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(12, 0, 12, 12 + bottomInset),
        child: Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(32),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(32),
              border: Border.all(
                color: colorScheme.outlineVariant.withValues(alpha: 0.16),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.07),
                  blurRadius: 30,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 44,
                      height: 5,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: colorScheme.outlineVariant,
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                  Text(
                    'Co chceš zapsat?',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Vyber jen jednu událost. Zbytek můžeš doplnit později.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 18),
                  const ProfileSwitcher(
                    title: 'Vybrané dítě',
                    subtitle:
                        'Než zvolíš typ události, můžeš rychle přepnout aktivní profil.',
                  ),
                  const SizedBox(height: 18),
                  _QuickAddTile(
                    icon: Icons.local_drink_outlined,
                    title: 'Krmení',
                    subtitle: 'čas, typ a případně množství',
                    onTap: () => _select(context, const FeedingFormScreen()),
                  ),
                  const SizedBox(height: 10),
                  _QuickAddTile(
                    icon: Icons.bedtime_outlined,
                    title: 'Spánek',
                    subtitle: 'začátek, konec a délka',
                    onTap: () => _select(context, const SleepFormScreen()),
                  ),
                  const SizedBox(height: 10),
                  _QuickAddTile(
                    icon: Icons.baby_changing_station_outlined,
                    title: 'Přebalení',
                    subtitle: 'rychlý záznam bez zbytečných kroků',
                    onTap: () => _select(context, const DiaperFormScreen()),
                  ),
                  const SizedBox(height: 10),
                  _QuickAddTile(
                    icon: Icons.campaign_outlined,
                    title: 'Pláč',
                    subtitle: 'včetně audio vzorku a AI analýzy',
                    onTap: () => _select(context, const CryingFormScreen()),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _QuickAddTile extends StatelessWidget {
  const _QuickAddTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: onTap,
      child: Ink(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: colorScheme.outlineVariant.withValues(alpha: 0.2),
          ),
          color: colorScheme.surface,
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: colorScheme.primaryContainer,
                foregroundColor: colorScheme.onPrimaryContainer,
                child: Icon(icon),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.arrow_forward_ios_rounded, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}
