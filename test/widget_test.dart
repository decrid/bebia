import 'package:bebia/app.dart';
import 'package:bebia/core/settings/bebia_preferences.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/memory_preferences_store.dart';

void main() {
  testWidgets('Bebia loads and applies a persistent appearance change', (
    tester,
  ) async {
    final controller = BebiaSettingsController(store: MemoryPreferencesStore());
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
  });
}
