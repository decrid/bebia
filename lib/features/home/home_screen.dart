import 'package:flutter/material.dart';

import '../../core/app_services.dart';
import '../../core/design/bebia_theme.dart';
import '../../shared/widgets/bebia_brand_mark.dart';
import '../../shared/widgets/bebia_components.dart';
import '../../shared/widgets/info_label.dart';
import '../../shared/widgets/profile_switcher.dart';
import '../auth/app_account_setup_screen.dart';
import '../crying/crying_form_screen.dart';
import '../diaper/diaper_form_screen.dart';
import '../feeding/feeding_form_screen.dart';
import '../monetization/monetization_plan_screen.dart';
import '../onboarding/onboarding_flow.dart';
import '../profile/child_profile_screen.dart';
import '../sleep/sleep_form_screen.dart';
import '../timeline/timeline_item.dart';

enum _HomeMenuAction { profiles, accountSync, onboarding, plus }

class HomeScreen extends StatefulWidget {
  static const routeName = '/home';

  const HomeScreen({
    super.key,
    this.loadData = true,
    this.checkOnboarding = true,
  });

  final bool loadData;
  final bool checkOnboarding;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<TimelineItem>> _futureRecentEvents;
  bool _didCheckOnboarding = false;

  @override
  void initState() {
    super.initState();
    _reloadData();
    AppServices.childProfileController.activeProfileId.addListener(_refresh);
    AppServices.timelineController.revision.addListener(_refresh);
    if (widget.checkOnboarding) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => _maybeOpenOnboarding(),
      );
    }
  }

  @override
  void dispose() {
    AppServices.childProfileController.activeProfileId.removeListener(_refresh);
    AppServices.timelineController.revision.removeListener(_refresh);
    super.dispose();
  }

  void _reloadData() {
    _futureRecentEvents = widget.loadData
        ? _loadRecentEvents()
        : Future<List<TimelineItem>>.value(const <TimelineItem>[]);
  }

  Future<List<TimelineItem>> _loadRecentEvents() async {
    final items = await AppServices.timelineRepository.getAll(
      childId: AppServices.childProfileController.activeProfileId.value,
    );
    return items.take(3).toList();
  }

  Future<void> _refresh() async {
    if (!mounted) return;
    setState(_reloadData);
    try {
      await _futureRecentEvents;
    } catch (error, stackTrace) {
      debugPrint('Home recent events load failed: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  Future<void> _openForm(Widget screen) async {
    await Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
    if (!mounted) return;
    await _refresh();
  }

  Future<void> _openChildProfile() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ChildProfileScreen()),
    );
    if (!mounted) return;
    await _refresh();
  }

  Future<void> _openOnboarding({bool markCompleted = false}) async {
    await Navigator.push<void>(
      context,
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => OnboardingFlow(
          onCreateProfile: () {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) _openChildProfile();
            });
          },
          onConnectParent: () {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) _openAccountSetup();
            });
          },
        ),
      ),
    );

    if (markCompleted) {
      await AppServices.onboardingStore.setCompleted(true);
    }

    if (!mounted) return;
    await _refresh();
  }

  Future<void> _maybeOpenOnboarding() async {
    if (_didCheckOnboarding || !mounted) return;
    _didCheckOnboarding = true;

    final completed = await AppServices.onboardingStore.isCompleted();
    if (!mounted || completed) return;

    await _openOnboarding(markCompleted: true);
  }

  Future<void> _openPlusScreen() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const MonetizationPlanScreen()),
    );
  }

  Future<void> _openAccountSetup() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AppAccountSetupScreen()),
    );
  }

  void _handleMenuAction(_HomeMenuAction action) {
    switch (action) {
      case _HomeMenuAction.profiles:
        _openChildProfile();
        return;
      case _HomeMenuAction.accountSync:
        _openAccountSetup();
        return;
      case _HomeMenuAction.onboarding:
        _openOnboarding();
        return;
      case _HomeMenuAction.plus:
        _openPlusScreen();
        return;
    }
  }

  String _ageLabel(DateTime dateOfBirth) {
    final now = DateTime.now();
    int months =
        (now.year - dateOfBirth.year) * 12 + now.month - dateOfBirth.month;
    if (now.day < dateOfBirth.day) months -= 1;

    if (months <= 0) {
      final days = now.difference(dateOfBirth).inDays.clamp(0, 31);
      return '$days dní';
    }

    final years = months ~/ 12;
    final remainingMonths = months % 12;
    if (years == 0) return '$months měs.';
    if (remainingMonths == 0) return '$years r.';
    return '$years r. $remainingMonths měs.';
  }

  String _relativeTime(DateTime value) {
    final difference = DateTime.now().difference(value);
    if (difference.isNegative || difference.inMinutes < 1) return 'právě teď';
    if (difference.inMinutes < 60) return 'před ${difference.inMinutes} min';
    if (difference.inHours < 24) return 'před ${difference.inHours} h';
    if (difference.inDays == 1) return 'včera';
    return 'před ${difference.inDays} d';
  }

  String _eventTitle(TimelineItem item) {
    return switch (item.type) {
      EventType.feeding => 'Krmení',
      EventType.sleep => 'Spánek',
      EventType.diaper => 'Přebalení',
      EventType.crying => 'Pláč',
    };
  }

  IconData _eventIcon(TimelineItem item) {
    return switch (item.type) {
      EventType.feeding => Icons.local_drink_outlined,
      EventType.sleep => Icons.bedtime_outlined,
      EventType.diaper => Icons.baby_changing_station_outlined,
      EventType.crying => Icons.graphic_eq_rounded,
    };
  }

  Color _eventColor(BuildContext context, TimelineItem item) {
    return switch (item.type) {
      EventType.feeding => context.bebia.feeding,
      EventType.sleep => context.bebia.sleep,
      EventType.diaper => context.bebia.diaper,
      EventType.crying => context.bebia.crying,
    };
  }

  @override
  Widget build(BuildContext context) {
    final profile = AppServices.childProfileController.activeProfile;
    final profileBarHeight = MediaQuery.textScalerOf(context).scale(1) >= 1.5
        ? 116.0
        : 92.0;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        toolbarHeight: profileBarHeight,
        titleSpacing: 0,
        title: const ProfileSwitcher(
          embedded: true,
          padding: EdgeInsets.fromLTRB(16, 12, 8, 12),
        ),
        actions: <Widget>[
          PopupMenuButton<_HomeMenuAction>(
            tooltip: 'Menu obrazovky Zapsat',
            onSelected: _handleMenuAction,
            itemBuilder: (context) => const <PopupMenuEntry<_HomeMenuAction>>[
              PopupMenuItem<_HomeMenuAction>(
                value: _HomeMenuAction.profiles,
                child: ListTile(
                  leading: Icon(Icons.child_care_outlined),
                  title: Text('Profily'),
                ),
              ),
              PopupMenuItem<_HomeMenuAction>(
                value: _HomeMenuAction.accountSync,
                child: ListTile(
                  leading: Icon(Icons.cloud_sync_outlined),
                  title: Text('Účet a synchronizace'),
                ),
              ),
              PopupMenuItem<_HomeMenuAction>(
                value: _HomeMenuAction.onboarding,
                child: ListTile(
                  leading: Icon(Icons.map_outlined),
                  title: Text('Průvodce'),
                ),
              ),
              PopupMenuItem<_HomeMenuAction>(
                value: _HomeMenuAction.plus,
                child: ListTile(
                  leading: Icon(Icons.workspace_premium_outlined),
                  title: Text('Bebia Plus'),
                ),
              ),
            ],
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          children: <Widget>[
            _LogHero(
              key: const Key('log-screen-hero'),
              eyebrow: profile == null ? 'Bez vybraného dítěte' : profile.name,
              title: 'Zapsat novou událost',
              subtitle: profile == null
                  ? 'Nejdřív můžete vybrat nebo vytvořit profil dítěte.'
                  : _ageLabel(profile.dateOfBirth),
              trailing: profile == null
                  ? FilledButton.tonalIcon(
                      onPressed: _openChildProfile,
                      icon: const Icon(Icons.child_care_outlined),
                      label: const Text('Profil'),
                    )
                  : null,
            ),
            const SizedBox(height: BebiaSpace.lg),
            _LogActionGrid(
              actions: <_LogAction>[
                _LogAction(
                  key: const Key('log-action-feeding'),
                  icon: Icons.local_drink_outlined,
                  color: context.bebia.feeding,
                  title: 'Krmení',
                  subtitle: 'Kojení, lahev nebo množství',
                  semanticsLabel: 'Zapsat krmení',
                  onTap: () => _openForm(const FeedingFormScreen()),
                ),
                _LogAction(
                  key: const Key('log-action-sleep'),
                  icon: Icons.bedtime_outlined,
                  color: context.bebia.sleep,
                  title: 'Spánek',
                  subtitle: 'Začátek, konec a délka',
                  semanticsLabel: 'Zapsat spánek',
                  onTap: () => _openForm(const SleepFormScreen()),
                ),
                _LogAction(
                  key: const Key('log-action-diaper'),
                  icon: Icons.baby_changing_station_outlined,
                  color: context.bebia.diaper,
                  title: 'Přebalení',
                  subtitle: 'Mokrá plena nebo stolice',
                  semanticsLabel: 'Zapsat přebalení',
                  onTap: () => _openForm(const DiaperFormScreen()),
                ),
                _LogAction(
                  key: const Key('log-action-crying'),
                  icon: Icons.graphic_eq_rounded,
                  color: context.bebia.crying,
                  title: 'Pláč',
                  subtitle: 'Délka a volitelný zvuk',
                  semanticsLabel: 'Zapsat pláč',
                  onTap: () => _openForm(const CryingFormScreen()),
                ),
              ],
            ),
            const SizedBox(height: BebiaSpace.lg),
            FutureBuilder<List<TimelineItem>>(
              future: _futureRecentEvents,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const _RecentEventsLoading();
                }
                if (snapshot.hasError) {
                  debugPrint(
                    'Home recent events FutureBuilder error: ${snapshot.error}',
                  );
                  return _RecentEventsError(onRetry: _refresh);
                }

                final items = snapshot.data ?? const <TimelineItem>[];
                if (items.isEmpty) return const SizedBox.shrink();

                return _RecentEventsSection(
                  items: items,
                  titleFor: _eventTitle,
                  iconFor: _eventIcon,
                  colorFor: (item) => _eventColor(context, item),
                  relativeTimeFor: _relativeTime,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _LogAction {
  const _LogAction({
    required this.key,
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.semanticsLabel,
    required this.onTap,
  });

  final Key key;
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final String semanticsLabel;
  final VoidCallback onTap;
}

class _LogHero extends StatelessWidget {
  const _LogHero({
    required this.eyebrow,
    required this.title,
    required this.subtitle,
    this.trailing,
    super.key,
  });

  final String eyebrow;
  final String title;
  final String subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(BebiaSpace.lg),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(BebiaRadius.large),
        color: scheme.primaryContainer.withValues(alpha: .42),
        border: Border.all(color: scheme.primary.withValues(alpha: .16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const BebiaBrandMark(size: 48),
              const SizedBox(width: BebiaSpace.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      eyebrow,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: scheme.primary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: BebiaSpace.xxs),
                    Text(
                      title,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: BebiaSpace.xxs),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: context.bebia.mutedText,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (trailing != null) ...<Widget>[
            const SizedBox(height: BebiaSpace.sm),
            Align(alignment: Alignment.centerLeft, child: trailing!),
          ],
        ],
      ),
    );
  }
}

class _LogActionGrid extends StatelessWidget {
  const _LogActionGrid({required this.actions});

  final List<_LogAction> actions;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final textScale = MediaQuery.textScalerOf(context).scale(1);
        final singleColumn = constraints.maxWidth < 420 || textScale >= 1.45;
        const spacing = BebiaSpace.sm;
        final tileWidth = singleColumn
            ? constraints.maxWidth
            : (constraints.maxWidth - spacing) / 2;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: actions
              .map(
                (action) => SizedBox(
                  width: tileWidth,
                  child: _LogActionCard(action: action),
                ),
              )
              .toList(),
        );
      },
    );
  }
}

class _LogActionCard extends StatelessWidget {
  const _LogActionCard({required this.action});

  final _LogAction action;

  @override
  Widget build(BuildContext context) {
    return BebiaCard(
      key: action.key,
      onTap: action.onTap,
      semanticsLabel: action.semanticsLabel,
      color: action.color.withValues(alpha: .08),
      borderColor: action.color.withValues(alpha: .22),
      padding: const EdgeInsets.all(BebiaSpace.md),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 124),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              width: BebiaMetrics.minimumTouchTarget,
              height: BebiaMetrics.minimumTouchTarget,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: action.color.withValues(alpha: .16),
                borderRadius: BorderRadius.circular(BebiaRadius.medium),
              ),
              child: Icon(
                action.icon,
                color: action.color,
                size: BebiaIconSize.large,
              ),
            ),
            const SizedBox(height: BebiaSpace.sm),
            Text(
              action.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: BebiaSpace.xxs),
            Text(
              action.subtitle,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: context.bebia.mutedText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecentEventsLoading extends StatelessWidget {
  const _RecentEventsLoading();

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Načítání posledních záznamů',
      child: const LinearProgressIndicator(),
    );
  }
}

class _RecentEventsError extends StatelessWidget {
  const _RecentEventsError({required this.onRetry});

  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return BebiaCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text(
            'Poslední záznamy se nepodařilo načíst.',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: BebiaSpace.sm),
          FilledButton.tonalIcon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Zkusit znovu'),
          ),
        ],
      ),
    );
  }
}

class _RecentEventsSection extends StatelessWidget {
  const _RecentEventsSection({
    required this.items,
    required this.titleFor,
    required this.iconFor,
    required this.colorFor,
    required this.relativeTimeFor,
  });

  final List<TimelineItem> items;
  final String Function(TimelineItem item) titleFor;
  final IconData Function(TimelineItem item) iconFor;
  final Color Function(TimelineItem item) colorFor;
  final String Function(DateTime time) relativeTimeFor;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const BebiaSectionHeader(title: 'Nedávno zapsáno'),
        BebiaCard(
          padding: const EdgeInsets.all(BebiaSpace.sm),
          child: Column(
            children: <Widget>[
              for (var index = 0; index < items.length; index++) ...<Widget>[
                _RecentEventTile(
                  item: items[index],
                  title: titleFor(items[index]),
                  icon: iconFor(items[index]),
                  color: colorFor(items[index]),
                  relativeTime: relativeTimeFor(items[index].time),
                ),
                if (index != items.length - 1)
                  Divider(
                    height: BebiaSpace.sm,
                    color: Theme.of(context).colorScheme.outlineVariant,
                  ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _RecentEventTile extends StatelessWidget {
  const _RecentEventTile({
    required this.item,
    required this.title,
    required this.icon,
    required this.color,
    required this.relativeTime,
  });

  final TimelineItem item;
  final String title;
  final IconData icon;
  final Color color;
  final String relativeTime;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '$title, $relativeTime',
      child: Padding(
        padding: const EdgeInsets.all(BebiaSpace.xs),
        child: Row(
          children: <Widget>[
            Container(
              width: 40,
              height: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: color.withValues(alpha: .14),
                borderRadius: BorderRadius.circular(BebiaRadius.medium),
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: BebiaSpace.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(title, style: Theme.of(context).textTheme.titleSmall),
                  const SizedBox(height: BebiaSpace.xxs),
                  Text(
                    _eventMeta(item),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: context.bebia.mutedText,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: BebiaSpace.xs),
            InfoLabel(label: relativeTime),
          ],
        ),
      ),
    );
  }

  String _eventMeta(TimelineItem item) {
    return switch (item.type) {
      EventType.feeding => item.feedingAmountMl == null
          ? 'Zapsáno'
          : '${item.feedingAmountMl} ml',
      EventType.sleep => item.sleepDurationMinutes == null
          ? 'Zapsáno'
          : '${item.sleepDurationMinutes} min',
      EventType.diaper => switch (item.diaperType) {
        'wet' => 'Mokrá plena',
        'poop' => 'Stolice',
        'both' => 'Mokrá i stolice',
        _ => 'Zapsáno',
      },
      EventType.crying => item.cryingDurationMinutes == null
          ? 'Zapsáno'
          : '${item.cryingDurationMinutes} min',
    };
  }
}
