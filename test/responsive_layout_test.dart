import 'package:bebia/core/design/bebia_theme.dart';
import 'package:bebia/core/settings/bebia_preferences.dart';
import 'package:bebia/features/feeding/feeding_form_screen.dart';
import 'package:bebia/features/settings/settings_screen.dart';
import 'package:bebia/shared/widgets/app_shell.dart';
import 'package:bebia/shared/widgets/bebia_components.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/memory_preferences_store.dart';

ThemeData _theme() =>
    BebiaTheme.light(profileSex: null, preferences: const BebiaPreferences());

void main() {
  testWidgets('main navigation preserves the state of visited sections', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: _theme(),
        home: const AppShell(
          screensOverride: <Widget>[
            Center(child: Text('Domovská sekce')),
            Center(child: Text('Časová osa')),
            Center(child: Text('Souhrn statistik')),
            Center(child: Text('Uživatelské nastavení')),
          ],
        ),
      ),
    );

    await tester.tap(find.text('Přehled'));
    await tester.pump();
    expect(find.text('Časová osa'), findsOneWidget);

    await tester.tap(find.text('Domů'));
    await tester.pump();
    expect(find.text('Domovská sekce'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('settings remain usable on a narrow viewport with large text', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final controller = BebiaSettingsController(store: MemoryPreferencesStore());
    await controller.load();
    await tester.pumpWidget(
      MaterialApp(
        theme: _theme(),
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: const TextScaler.linear(2)),
          child: child!,
        ),
        home: SettingsScreen(controller: controller),
      ),
    );
    await tester.pump();

    expect(find.text('Nastavení'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('feeding form avoids overflow with a simulated keyboard', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        theme: _theme(),
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(
            viewInsets: const EdgeInsets.only(bottom: 220),
            textScaler: const TextScaler.linear(1.8),
          ),
          child: child!,
        ),
        home: const FeedingFormScreen(),
      ),
    );
    await tester.pump();

    expect(find.byType(FeedingFormScreen), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('shared empty state remains descriptive without color', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: _theme(),
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
