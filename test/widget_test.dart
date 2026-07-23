import 'package:bebia/app.dart';
import 'package:bebia/core/app_version_provider.dart';
import 'package:bebia/core/settings/bebia_preferences.dart';
import 'package:bebia/features/home/home_screen.dart';
import 'package:bebia/features/settings/settings_screen.dart';
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
      expect(find.text('Domů'), findsOneWidget);
      expect(find.text('Přehled'), findsOneWidget);
      expect(find.text('Statistiky'), findsOneWidget);
      expect(find.text('Nastavení'), findsOneWidget);
      final quickAdd = find.byKey(const Key('quick-add-button'));
      final quickAddSize = tester.getSize(quickAdd);
      expect(quickAddSize.width, greaterThanOrEqualTo(48));
      expect(quickAddSize.height, greaterThanOrEqualTo(48));
      expect(tester.getSemantics(quickAdd).label, contains('Zapsat událost'));
      expect(tester.takeException(), isNull);
    } finally {
      semanticsHandle.dispose();
    }
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
