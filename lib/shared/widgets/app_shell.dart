import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/app_services.dart';
import '../../core/design/bebia_theme.dart';
import '../../core/platform/bebia_platform_bridge.dart';
import '../../core/settings/bebia_preferences.dart';
import '../../features/crying/crying_form_screen.dart';
import '../../features/diaper/diaper_form_screen.dart';
import '../../features/feeding/feeding_form_screen.dart';
import '../../features/home/home_screen.dart';
import '../../features/settings/settings_screen.dart';
import '../../features/sleep/sleep_form_screen.dart';
import '../../features/statistics/statistics_screen.dart';
import '../../features/timeline/timeline_item.dart';
import '../../features/timeline/timeline_screen.dart';
import 'bebia_brand_mark.dart';
import 'bebia_components.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key, this.screensOverride, this.settingsController});

  final List<Widget>? screensOverride;
  final BebiaSettingsController? settingsController;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _currentIndex = 0;
  final Set<int> _visitedSections = <int>{0};

  static const List<NavigationDestination> _destinations =
      <NavigationDestination>[
        NavigationDestination(
          icon: Icon(Icons.note_add_outlined),
          selectedIcon: Icon(Icons.note_add_rounded),
          label: 'Zapsat',
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
        NavigationDestination(
          icon: Icon(Icons.tune_outlined),
          selectedIcon: Icon(Icons.tune_rounded),
          label: 'Nastavení',
        ),
      ];

  BebiaSettingsController get _settingsController =>
      widget.settingsController ?? BebiaSettingsController.instance;
  List<Widget> get _activeScreens =>
      widget.screensOverride ??
      <Widget>[
        const HomeScreen(),
        const TimelineScreen(),
        const StatisticsScreen(),
        SettingsScreen(controller: _settingsController),
      ];

  @override
  void initState() {
    super.initState();
    AppServices.platformBridge.launchTarget.addListener(_handleLaunchTarget);
    WidgetsBinding.instance.addPostFrameCallback((_) => _handleLaunchTarget());
  }

  @override
  void dispose() {
    AppServices.platformBridge.launchTarget.removeListener(_handleLaunchTarget);
    super.dispose();
  }

  Future<void> _feedback() async {
    if (_settingsController.preferences.hapticsEnabled) {
      await HapticFeedback.selectionClick();
    }
  }

  void _selectDestination(int index) {
    if (index == _currentIndex || index >= _activeScreens.length) return;
    _feedback();
    setState(() {
      _visitedSections.add(index);
      _currentIndex = index;
    });
  }

  Future<void> _openQuickAddSheet() async {
    await _feedback();
    if (!mounted) return;
    final screen = await showModalBottomSheet<Widget>(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const BebiaModalSurface(
        title: 'Co chcete zaznamenat?',
        child: _QuickAddSheet(),
      ),
    );

    if (!mounted || screen == null) return;
    await _openScreen(screen);
  }

  Future<void> _openScreen(Widget screen) async {
    final reduceMotion = context.bebia.reduceMotion;
    await Navigator.of(context).push<void>(
      PageRouteBuilder<void>(
        transitionDuration: BebiaMotion.resolve(
          BebiaMotion.standard,
          reduceMotion: reduceMotion,
        ),
        reverseTransitionDuration: BebiaMotion.resolve(
          BebiaMotion.fast,
          reduceMotion: reduceMotion,
        ),
        pageBuilder: (_, animation, secondaryAnimation) => screen,
        transitionsBuilder: (_, animation, secondaryAnimation, child) {
          if (reduceMotion) return child;
          return FadeTransition(
            opacity: CurvedAnimation(
              parent: animation,
              curve: BebiaMotion.enter,
            ),
            child: SlideTransition(
              position:
                  Tween<Offset>(
                    begin: const Offset(0, .025),
                    end: Offset.zero,
                  ).animate(
                    CurvedAnimation(
                      parent: animation,
                      curve: BebiaMotion.enter,
                    ),
                  ),
              child: child,
            ),
          );
        },
      ),
    );

    if (!mounted) return;
    await AppServices.timelineController.reloadCurrent();
    if (mounted) setState(() {});
  }

  void _handleLaunchTarget() {
    if (!mounted) return;
    final target = AppServices.platformBridge.consumeLaunchTarget();
    if (target == null) return;
    Navigator.of(context).popUntil((route) => route.isFirst);

    switch (target.section) {
      case BebiaLaunchSection.home:
        setState(() {
          _visitedSections.add(0);
          _currentIndex = 0;
        });
        return;
      case BebiaLaunchSection.timeline:
        final type = _eventType(target.eventType);
        setState(() {
          _visitedSections.add(1);
          _currentIndex = 1;
        });
        unawaited(AppServices.timelineController.load(type));
        return;
      case BebiaLaunchSection.add:
        final screen = _formFor(target.eventType);
        if (screen != null) unawaited(_openScreen(screen));
        return;
    }
  }

  EventType? _eventType(String? value) {
    return switch (value) {
      'feeding' => EventType.feeding,
      'sleep' => EventType.sleep,
      'diaper' => EventType.diaper,
      'crying' => EventType.crying,
      _ => null,
    };
  }

  Widget? _formFor(String? value) {
    return switch (value) {
      'feeding' => const FeedingFormScreen(),
      'sleep' => const SleepFormScreen(),
      'diaper' => const DiaperFormScreen(),
      'crying' => const CryingFormScreen(),
      _ => null,
    };
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final screens = _activeScreens;
    if (_currentIndex >= screens.length) _currentIndex = 0;

    final content = Stack(
      key: const ValueKey<String>('bebia-main-sections'),
      children: List<Widget>.generate(screens.length, (index) {
        if (!_visitedSections.contains(index)) {
          return const SizedBox.shrink();
        }
        final selected = index == _currentIndex;
        return Positioned.fill(
          child: Offstage(
            offstage: !selected,
            child: TickerMode(
              enabled: selected,
              child: SafeArea(bottom: false, child: screens[index]),
            ),
          ),
        );
      }),
    );

    return PopScope(
      canPop: _currentIndex == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && _currentIndex != 0) {
          setState(() => _currentIndex = 0);
        }
      },
      child: LayoutBuilder(
        builder: (context, constraints) {
          final useRail = constraints.maxWidth >= BebiaBreakpoints.compact;
          return Scaffold(
            resizeToAvoidBottomInset: true,
            body: useRail
                ? Row(
                    children: <Widget>[
                      SafeArea(
                        right: false,
                        child: NavigationRail(
                          selectedIndex: _currentIndex,
                          onDestinationSelected: _selectDestination,
                          labelType:
                              constraints.maxWidth >= BebiaBreakpoints.expanded
                              ? NavigationRailLabelType.none
                              : NavigationRailLabelType.all,
                          extended:
                              constraints.maxWidth >= BebiaBreakpoints.expanded,
                          leading: Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: BebiaSpace.md,
                            ),
                            child: const BebiaBrandMark(),
                          ),
                          destinations: _destinations
                              .map(
                                (destination) => NavigationRailDestination(
                                  icon: destination.icon,
                                  selectedIcon: destination.selectedIcon,
                                  label: Text(destination.label),
                                ),
                              )
                              .toList(),
                        ),
                      ),
                      VerticalDivider(color: scheme.outlineVariant, width: 1),
                      Expanded(child: content),
                    ],
                  )
                : content,
            floatingActionButton: _currentIndex > 0 && _currentIndex < 3
                ? Semantics(
                    key: const Key('quick-add-button-compact'),
                    container: true,
                    button: true,
                    label: 'Zapsat událost',
                    child: FloatingActionButton(
                      onPressed: _openQuickAddSheet,
                      tooltip: 'Zapsat událost',
                      child: const Icon(Icons.add_rounded),
                    ),
                  )
                : null,
            floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
            bottomNavigationBar: useRail
                ? null
                : SafeArea(
                    top: false,
                    minimum: const EdgeInsets.fromLTRB(
                      BebiaSpace.sm,
                      0,
                      BebiaSpace.sm,
                      BebiaSpace.xs,
                    ),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: scheme.surface,
                        borderRadius: BorderRadius.circular(BebiaRadius.large),
                        border: Border.all(color: scheme.outlineVariant),
                        boxShadow: context.bebia.cardShadow,
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(BebiaRadius.large),
                        child: MediaQuery.withClampedTextScaling(
                          maxScaleFactor: 1.35,
                          child: NavigationBar(
                            selectedIndex: _currentIndex,
                            onDestinationSelected: _selectDestination,
                            destinations: _destinations,
                          ),
                        ),
                      ),
                    ),
                  ),
          );
        },
      ),
    );
  }
}

class _QuickAddSheet extends StatelessWidget {
  const _QuickAddSheet();

  void _select(BuildContext context, Widget screen) {
    if (BebiaSettingsController.instance.preferences.hapticsEnabled) {
      HapticFeedback.selectionClick();
    }
    Navigator.pop(context, screen);
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      shrinkWrap: true,
      padding: const EdgeInsets.fromLTRB(
        BebiaSpace.md,
        BebiaSpace.xs,
        BebiaSpace.md,
        BebiaSpace.lg,
      ),
      children: <Widget>[
        _QuickAddTile(
          icon: Icons.local_drink_outlined,
          color: context.bebia.feeding,
          title: 'Krmení',
          subtitle: 'Čas, způsob, množství',
          onTap: () => _select(context, const FeedingFormScreen()),
        ),
        const SizedBox(height: BebiaSpace.xs),
        _QuickAddTile(
          icon: Icons.bedtime_outlined,
          color: context.bebia.sleep,
          title: 'Spánek',
          subtitle: 'Začátek a konec',
          onTap: () => _select(context, const SleepFormScreen()),
        ),
        const SizedBox(height: BebiaSpace.xs),
        _QuickAddTile(
          icon: Icons.baby_changing_station_outlined,
          color: context.bebia.diaper,
          title: 'Přebalení',
          subtitle: 'Typ pleny',
          onTap: () => _select(context, const DiaperFormScreen()),
        ),
        const SizedBox(height: BebiaSpace.xs),
        _QuickAddTile(
          icon: Icons.graphic_eq_rounded,
          color: context.bebia.crying,
          title: 'Pláč',
          subtitle: 'Délka a volitelný zvuk',
          onTap: () => _select(context, const CryingFormScreen()),
        ),
      ],
    );
  }
}

class _QuickAddTile extends StatelessWidget {
  const _QuickAddTile({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return BebiaEventActionTile(
      icon: icon,
      color: color,
      title: title,
      subtitle: subtitle,
      onTap: onTap,
    );
  }
}
