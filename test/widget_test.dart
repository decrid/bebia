import 'package:bebia/app.dart';
import 'package:bebia/core/app_version_provider.dart';
import 'package:bebia/core/design/bebia_theme.dart';
import 'package:bebia/core/settings/bebia_preferences.dart';
import 'package:bebia/features/crying/crying_form_screen.dart';
import 'package:bebia/features/diaper/diaper_form_screen.dart';
import 'package:bebia/features/feeding/feeding_form_screen.dart';
import 'package:bebia/features/home/home_screen.dart';
import 'package:bebia/features/settings/settings_screen.dart';
import 'package:bebia/features/sleep/sleep_form_screen.dart';
import 'package:bebia/features/statistics/statistics_screen.dart';
import 'package:bebia/features/timeline/timeline_screen.dart';
import 'package:bebia/shared/widgets/app_shell.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/memory_preferences_store.dart';

class _WidgetTestVersionProvider implements BebiaAppVersionProvider {
  @override
  Future<BebiaAppVersion> load() async {
    return const BebiaAppVersion(version: '1.2.3', buildNumber: '45');
  }
}

const _widgetTestStats = StatisticsSnapshot(
  feedingCount: 1,
  sleepCount: 0,
  diaperCount: 0,
  cryingCount: 0,
  totalMl: 90,
  totalSleepMinutes: 0,
  averageCryingDurationMinutes: null,
  cryingResolvedCount: 0,
  cryingUnresolvedCount: 0,
  cryingResolvedRate: null,
  soothingFeedingCount: 0,
  soothingRockingCount: 0,
  soothingCarryingCount: 0,
  soothingPacifierCount: 0,
  soothingOtherCount: 0,
);

void main() {
  testWidgets('Bebia starts with the real app shell and production screens', (
    tester,
  ) async {
    final semanticsHandle = tester.ensureSemantics();
    try {
      final controller = BebiaSettingsController(
        store: MemoryPreferencesStore(),
      );
      await controller.load();

      await tester.pumpWidget(
        BebiaApp(
          settingsController: controller,
          shellScreensOverride: <Widget>[
            const HomeScreen(loadData: false, checkOnboarding: false),
            const TimelineScreen(loadOnInit: false),
            StatisticsScreen(loadStats: () async => _widgetTestStats),
            SettingsScreen(
              controller: controller,
              appVersionProvider: _WidgetTestVersionProvider(),
            ),
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(controller.initialized, isTrue);
      expect(find.byType(AppShell), findsOneWidget);
      expect(find.byType(HomeScreen), findsOneWidget);
      expect(find.text('Zapsat'), findsOneWidget);
      expect(find.text('Přehled'), findsOneWidget);
      expect(find.text('Statistiky'), findsOneWidget);
      expect(find.text('Nastavení'), findsOneWidget);
      expect(find.text('Domů'), findsNothing);
      expect(find.text('Pulse dne'), findsNothing);
      expect(find.text('Rodinné sdílení'), findsNothing);
      expect(find.text('Krmení'), findsOneWidget);
      expect(find.text('Spánek'), findsOneWidget);
      expect(find.text('Přebalení'), findsOneWidget);
      expect(find.text('Pláč'), findsOneWidget);
      expect(find.byKey(const Key('quick-add-button')), findsNothing);
      expect(find.byKey(const Key('quick-add-button-compact')), findsNothing);

      await tester.tap(find.text('Přehled'));
      await tester.pumpAndSettle();

      final quickAdd = find.byKey(const Key('quick-add-button-compact'));
      expect(quickAdd, findsOneWidget);
      final quickAddButton = find.descendant(
        of: quickAdd,
        matching: find.byType(FloatingActionButton),
      );
      expect(quickAddButton.hitTestable(), findsOneWidget);
      final quickAddSize = tester.getSize(quickAddButton);
      expect(quickAddSize.width, greaterThanOrEqualTo(48));
      expect(quickAddSize.height, greaterThanOrEqualTo(48));
      expect(tester.getSemantics(quickAdd).label, contains('Zapsat událost'));
      expect(tester.takeException(), isNull);
    } finally {
      semanticsHandle.dispose();
    }
  });

  testWidgets('Zapsat actions open existing event forms', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: BebiaTheme.light(
          profileSex: null,
          preferences: const BebiaPreferences(),
        ),
        home: const HomeScreen(loadData: false, checkOnboarding: false),
      ),
    );
    await tester.pumpAndSettle();

    final actions = <Key, Type>{
      const Key('log-action-feeding'): FeedingFormScreen,
      const Key('log-action-sleep'): SleepFormScreen,
      const Key('log-action-diaper'): DiaperFormScreen,
      const Key('log-action-crying'): CryingFormScreen,
    };

    for (final entry in actions.entries) {
      await tester.tap(find.byKey(entry.key));
      await tester.pumpAndSettle();
      expect(find.byType(entry.value), findsOneWidget);
      Navigator.of(tester.element(find.byType(entry.value))).pop();
      await tester.pumpAndSettle();
    }

    expect(tester.takeException(), isNull);
  });

  testWidgets('Bebia loads and applies a persistent appearance change', (
    tester,
  ) async {
    final store = MemoryPreferencesStore();
    final controller = BebiaSettingsController(store: store);
    await controller.load();

    await tester.pumpWidget(
      BebiaApp(
        settingsController: controller,
        homeOverride: Builder(
          builder: (context) => Scaffold(
            body: Text(
              Theme.of(context).brightness.name,
              key: const Key('active-brightness'),
            ),
          ),
        ),
      ),
    );
    expect(find.text('light'), findsOneWidget);

    await controller.setAppearance(BebiaAppearance.dark);
    await tester.pumpAndSettle();

    expect(find.text('dark'), findsOneWidget);
    expect(tester.takeException(), isNull);

    final reloaded = BebiaSettingsController(store: store);
    await reloaded.load();
    await tester.pumpWidget(
      BebiaApp(
        settingsController: reloaded,
        homeOverride: Builder(
          builder: (context) => Scaffold(
            body: Text(
              Theme.of(context).brightness.name,
              key: const Key('reloaded-brightness'),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(reloaded.preferences.appearance, BebiaAppearance.dark);
    expect(find.text('dark'), findsOneWidget);
  });
}
