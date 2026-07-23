import 'dart:async';

import 'package:bebia/core/app_services.dart';
import 'package:bebia/core/design/bebia_theme.dart';
import 'package:bebia/core/settings/bebia_preferences.dart';
import 'package:bebia/features/statistics/statistics_screen.dart';
import 'package:bebia/features/timeline/timeline_item.dart';
import 'package:bebia/features/timeline/timeline_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

ThemeData _stateTheme(Brightness brightness) {
  const preferences = BebiaPreferences();
  return brightness == Brightness.dark
      ? BebiaTheme.dark(profileSex: null, preferences: preferences)
      : BebiaTheme.light(profileSex: null, preferences: preferences);
}

Widget _stateApp(Widget home, {Brightness brightness = Brightness.light}) {
  return MaterialApp(
    theme: _stateTheme(brightness),
    builder: (context, child) => MediaQuery(
      data: MediaQuery.of(
        context,
      ).copyWith(textScaler: const TextScaler.linear(2)),
      child: child!,
    ),
    home: home,
  );
}

void _narrowView(WidgetTester tester) {
  tester.view.physicalSize = const Size(320, 568);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
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

const _emptyStatistics = StatisticsSnapshot(
  feedingCount: 0,
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

const _longStatistics = StatisticsSnapshot(
  feedingCount: 123456,
  sleepCount: 234567,
  diaperCount: 345678,
  cryingCount: 456789,
  totalMl: 123456789,
  totalSleepMinutes: 987654321,
  averageCryingDurationMinutes: 7654321,
  cryingResolvedCount: 345678,
  cryingUnresolvedCount: 111111,
  cryingResolvedRate: 100,
  soothingFeedingCount: 1234,
  soothingRockingCount: 2345,
  soothingCarryingCount: 3456,
  soothingPacifierCount: 4567,
  soothingOtherCount: 5678,
);

void main() {
  testWidgets('timeline renders the real empty state at 320 px and 2x text', (
    tester,
  ) async {
    _narrowView(tester);
    final controller = AppServices.timelineController;
    final oldItems = controller.items.value;
    final oldLoading = controller.isLoading.value;
    final oldError = controller.error.value;
    final oldFilter = controller.selectedFilter.value;
    addTearDown(() {
      controller.items.value = oldItems;
      controller.isLoading.value = oldLoading;
      controller.error.value = oldError;
      controller.selectedFilter.value = oldFilter;
    });
    controller.items.value = <TimelineItem>[];
    controller.isLoading.value = false;
    controller.error.value = null;
    controller.selectedFilter.value = null;

    await tester.pumpWidget(_stateApp(const TimelineScreen(loadOnInit: false)));
    await tester.pump();
    await _scrollTo(
      tester,
      find.text('Zatím nejsou k dispozici žádné záznamy.'),
    );

    expect(
      find.text('Zatím nejsou k dispozici žádné záznamy.'),
      findsOneWidget,
    );
    expect(find.byType(CustomScrollView), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('timeline lazily renders real items in dark mode', (
    tester,
  ) async {
    _narrowView(tester);
    final controller = AppServices.timelineController;
    final oldItems = controller.items.value;
    final oldLoading = controller.isLoading.value;
    final oldError = controller.error.value;
    final oldFilter = controller.selectedFilter.value;
    addTearDown(() {
      controller.items.value = oldItems;
      controller.isLoading.value = oldLoading;
      controller.error.value = oldError;
      controller.selectedFilter.value = oldFilter;
    });
    controller.items.value = <TimelineItem>[
      TimelineItem()
        ..id = 701
        ..type = EventType.feeding
        ..time = DateTime.now()
        ..title = 'Lahvička'
        ..subtitle =
            '123456789 ml • velmi dlouhý český popis skutečného záznamu'
        ..feedingType = 'bottle'
        ..feedingAmountMl = 123456789,
    ];
    controller.isLoading.value = false;
    controller.error.value = null;
    controller.selectedFilter.value = null;

    await tester.pumpWidget(
      _stateApp(
        const TimelineScreen(loadOnInit: false),
        brightness: Brightness.dark,
      ),
    );
    await tester.pump();
    final timelineItem = find.byKey(const ValueKey<int>(701));
    await _scrollTo(tester, timelineItem);

    expect(timelineItem, findsOneWidget);
    expect(
      find.descendant(of: timelineItem, matching: find.text('Krmení')),
      findsOneWidget,
    );
    expect(find.byType(CustomScrollView), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('timeline exposes real loading and error states', (tester) async {
    final controller = AppServices.timelineController;
    final oldItems = controller.items.value;
    final oldLoading = controller.isLoading.value;
    final oldError = controller.error.value;
    final oldFilter = controller.selectedFilter.value;
    addTearDown(() {
      controller.items.value = oldItems;
      controller.isLoading.value = oldLoading;
      controller.error.value = oldError;
      controller.selectedFilter.value = oldFilter;
    });
    controller.items.value = <TimelineItem>[];
    controller.isLoading.value = true;
    controller.error.value = null;
    controller.selectedFilter.value = null;

    await tester.pumpWidget(_stateApp(const TimelineScreen(loadOnInit: false)));
    await tester.pump();
    await _scrollTo(tester, find.byType(CircularProgressIndicator));
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    controller.isLoading.value = false;
    controller.error.value = 'Testovací chyba timeline';
    await tester.pump();
    await _scrollTo(tester, find.text('Testovací chyba timeline'));
    expect(find.text('Testovací chyba timeline'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('statistics render the real empty state without overflow', (
    tester,
  ) async {
    _narrowView(tester);
    await tester.pumpWidget(
      _stateApp(StatisticsScreen(loadStats: () async => _emptyStatistics)),
    );
    await tester.pumpAndSettle();
    await _scrollTo(tester, find.text('Dnes ještě není nic zapsané'));

    expect(find.text('Dnes ještě není nic zapsané'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('statistics handle extreme values at 320 px in dark mode', (
    tester,
  ) async {
    _narrowView(tester);
    await tester.pumpWidget(
      _stateApp(
        StatisticsScreen(loadStats: () async => _longStatistics),
        brightness: Brightness.dark,
      ),
    );
    await tester.pumpAndSettle();
    await _scrollTo(tester, find.byKey(const Key('statistics-metric-grid')));

    expect(find.byKey(const Key('statistics-metric-grid')), findsOneWidget);
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is RichText &&
            widget.text.toPlainText().contains('123456789'),
      ),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('statistics expose real loading and error states', (
    tester,
  ) async {
    final completer = Completer<StatisticsSnapshot>();
    await tester.pumpWidget(
      _stateApp(StatisticsScreen(loadStats: () => completer.future)),
    );
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    completer.completeError(StateError('test statistics failure'));
    await tester.pumpAndSettle();
    expect(find.text('Statistiky se nepodařilo načíst.'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
