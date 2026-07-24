import 'package:bebia/core/app_version_provider.dart';
import 'package:bebia/core/design/bebia_theme.dart';
import 'package:bebia/core/settings/bebia_preferences.dart';
import 'package:bebia/features/crying/crying_form_screen.dart';
import 'package:bebia/features/diaper/diaper_form_screen.dart';
import 'package:bebia/features/family/family_sharing_screen.dart';
import 'package:bebia/features/feeding/feeding_form_screen.dart';
import 'package:bebia/features/home/home_screen.dart';
import 'package:bebia/features/settings/settings_screen.dart';
import 'package:bebia/features/sleep/sleep_form_screen.dart';
import 'package:bebia/features/statistics/statistics_screen.dart';
import 'package:bebia/features/timeline/timeline_screen.dart';
import 'package:bebia/shared/widgets/app_shell.dart';
import 'package:bebia/shared/widgets/bebia_components.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/memory_preferences_store.dart';

ThemeData _theme(Brightness brightness) {
  const preferences = BebiaPreferences();
  return brightness == Brightness.dark
      ? BebiaTheme.dark(profileSex: null, preferences: preferences)
      : BebiaTheme.light(profileSex: null, preferences: preferences);
}

class _TestVersionProvider implements BebiaAppVersionProvider {
  @override
  Future<BebiaAppVersion> load() async {
    return const BebiaAppVersion(version: '2.4.6', buildNumber: '88');
  }
}

const _sampleStats = StatisticsSnapshot(
  feedingCount: 1,
  sleepCount: 0,
  diaperCount: 0,
  cryingCount: 0,
  totalMl: 0,
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

void _useNarrowKeyboardViewport(WidgetTester tester) {
  tester.view.physicalSize = const Size(320, 568);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

Widget _largeTextApp({
  required ThemeData theme,
  required Widget home,
  double keyboardInset = 220,
}) {
  return MaterialApp(
    theme: theme,
    builder: (context, child) => MediaQuery(
      data: MediaQuery.of(context).copyWith(
        viewInsets: EdgeInsets.only(bottom: keyboardInset),
        viewPadding: const EdgeInsets.only(top: 24, bottom: 34),
        padding: EdgeInsets.only(top: 24, bottom: keyboardInset > 0 ? 0 : 34),
        textScaler: const TextScaler.linear(2),
      ),
      child: child!,
    ),
    home: home,
  );
}

Future<void> _scrollTo(WidgetTester tester, Finder target) async {
  final verticalScrollable = find.byWidgetPredicate(
    (widget) =>
        widget is Scrollable && widget.axisDirection == AxisDirection.down,
  );
  await tester.scrollUntilVisible(
    target,
    180,
    scrollable: verticalScrollable.last,
    maxScrolls: 40,
  );
  await tester.pump();
}

void main() {
  testWidgets('main navigation preserves state in real production forms', (
    tester,
  ) async {
    final controller = BebiaSettingsController(store: MemoryPreferencesStore());
    await controller.load();
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      MaterialApp(
        theme: _theme(Brightness.light),
        home: AppShell(
          screensOverride: <Widget>[
            const FeedingFormScreen(),
            const SleepFormScreen(),
            const DiaperFormScreen(),
            SettingsScreen(
              controller: controller,
              appVersionProvider: _TestVersionProvider(),
            ),
          ],
        ),
      ),
    );

    final firstField = find.byType(TextField).first;
    await tester.enterText(firstField, '42');

    await tester.tap(find.text('Přehled'));
    await tester.pump();
    expect(find.byType(SleepFormScreen), findsOneWidget);

    await tester.tap(find.text('Statistiky'));
    await tester.pump();
    expect(find.byType(DiaperFormScreen), findsOneWidget);

    await tester.tap(find.text('Nastavení'));
    await tester.pump();
    expect(find.byType(SettingsScreen), findsOneWidget);

    await tester.binding.handlePopRoute();
    await tester.pump();
    expect(find.byType(FeedingFormScreen), findsOneWidget);
    expect(find.text('42'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  for (final brightness in Brightness.values) {
    final mode = brightness.name;

    testWidgets('settings support 320 px, keyboard and 2x text in $mode mode', (
      tester,
    ) async {
      _useNarrowKeyboardViewport(tester);
      final controller = BebiaSettingsController(
        store: MemoryPreferencesStore(),
      );
      await controller.load();
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        _largeTextApp(
          theme: _theme(brightness),
          home: SettingsScreen(
            controller: controller,
            appVersionProvider: _TestVersionProvider(),
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(SettingsScreen), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    final forms = <String, Widget Function()>{
      'feeding': () => const FeedingFormScreen(),
      'sleep': () => const SleepFormScreen(),
      'diaper': () => const DiaperFormScreen(),
      'crying': () => const CryingFormScreen(),
    };

    for (final entry in forms.entries) {
      testWidgets(
        '${entry.key} form supports 320 px, keyboard and 2x text in $mode mode',
        (tester) async {
          _useNarrowKeyboardViewport(tester);
          await tester.pumpWidget(
            _largeTextApp(theme: _theme(brightness), home: entry.value()),
          );
          await tester.pump();

          final expectedType = entry.value().runtimeType;
          expect(
            find.byWidgetPredicate(
              (widget) => widget.runtimeType == expectedType,
            ),
            findsOneWidget,
          );
          expect(tester.takeException(), isNull);
        },
      );
    }

    testWidgets('timeline uses one safe scroll surface in $mode mode', (
      tester,
    ) async {
      _useNarrowKeyboardViewport(tester);
      await tester.pumpWidget(
        _largeTextApp(
          theme: _theme(brightness),
          home: const TimelineScreen(loadOnInit: false),
          keyboardInset: 0,
        ),
      );
      await tester.pump();

      expect(find.byType(CustomScrollView), findsOneWidget);
      expect(find.byType(TimelineScreen), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('Zapsat remains action-driven in $mode mode', (tester) async {
      _useNarrowKeyboardViewport(tester);
      await tester.pumpWidget(
        _largeTextApp(
          theme: _theme(brightness),
          home: const HomeScreen(loadData: false, checkOnboarding: false),
          keyboardInset: 0,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(HomeScreen), findsOneWidget);
      expect(find.byKey(const Key('log-screen-hero')), findsOneWidget);
      expect(find.text('Zapsat novou událost'), findsOneWidget);
      for (final key in <Key>[
        const Key('log-action-feeding'),
        const Key('log-action-sleep'),
        const Key('log-action-diaper'),
        const Key('log-action-crying'),
      ]) {
        await _scrollTo(tester, find.byKey(key));
        expect(find.byKey(key).hitTestable(), findsOneWidget);
      }
      expect(find.text('Pulse dne'), findsNothing);
      expect(find.text('Rodinné sdílení'), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('statistics grid is content-driven in $mode mode', (
      tester,
    ) async {
      _useNarrowKeyboardViewport(tester);
      await tester.pumpWidget(
        _largeTextApp(
          theme: _theme(brightness),
          home: StatisticsScreen(loadStats: () async => _sampleStats),
          keyboardInset: 0,
        ),
      );
      await tester.pumpAndSettle();
      await _scrollTo(tester, find.byKey(const Key('statistics-metric-grid')));

      expect(find.byType(StatisticsScreen), findsOneWidget);
      expect(find.byKey(const Key('statistics-metric-grid')), findsOneWidget);
      expect(find.byType(GridView), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('family sharing remains keyboard-safe in $mode mode', (
      tester,
    ) async {
      _useNarrowKeyboardViewport(tester);
      await tester.pumpWidget(
        _largeTextApp(
          theme: _theme(brightness),
          home: const FamilySharingScreen(loadOnInit: false),
        ),
      );
      await tester.pump();

      expect(find.byType(FamilySharingScreen), findsOneWidget);
      expect(find.text('Rodinné sdílení'), findsOneWidget);
      final primaryAction = find.text('Otevřít účet a synchronizaci');
      await _scrollTo(tester, primaryAction);
      expect(primaryAction.hitTestable(), findsOneWidget);
      expect(find.textContaining('Bez rodičovského účtu'), findsWidgets);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('home log actions open the existing production forms', (
    tester,
  ) async {
    await tester.pumpWidget(
      _largeTextApp(
        theme: _theme(Brightness.light),
        home: const HomeScreen(loadData: false, checkOnboarding: false),
        keyboardInset: 0,
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
      final action = find.byKey(entry.key);
      await _scrollTo(tester, action);
      expect(action.hitTestable(), findsOneWidget);
      await tester.tap(action);
      await tester.pumpAndSettle();
      expect(find.byType(entry.value), findsOneWidget);
      await tester.pageBack();
      await tester.pumpAndSettle();
    }

    expect(tester.takeException(), isNull);
  });

  testWidgets('shared empty state remains descriptive without color', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: _theme(Brightness.light),
        home: const Scaffold(
          body: BebiaStatePanel(
            icon: Icons.event_note_outlined,
            title: 'Zatím bez záznamů',
            message: 'První událost můžete přidat hlavním tlačítkem.',
          ),
        ),
      ),
    );

    expect(find.text('Zatím bez záznamů'), findsOneWidget);
    expect(find.byIcon(Icons.event_note_outlined), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
