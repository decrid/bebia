import 'package:bebia/core/app_version_provider.dart';
import 'package:bebia/core/design/bebia_theme.dart';
import 'package:bebia/core/settings/bebia_preferences.dart';
import 'package:bebia/features/settings/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/memory_preferences_store.dart';

class _FakeVersionProvider implements BebiaAppVersionProvider {
  const _FakeVersionProvider(this.value);

  final BebiaAppVersion value;

  @override
  Future<BebiaAppVersion> load() async => value;
}

Future<void> _scrollToVersion(WidgetTester tester) async {
  final settingsList = find.byKey(
    const PageStorageKey<String>('settings-list'),
  );
  await tester.dragUntilVisible(
    find.text('O APLIKACI'),
    settingsList,
    const Offset(0, -200),
    maxIteration: 30,
  );
  await tester.pumpAndSettle();
}

void main() {
  test('unavailable package metadata has a safe user-facing fallback', () {
    expect(
      const BebiaAppVersion.unavailable().displayLabel,
      'Verze není dostupná',
    );
  });

  testWidgets('settings display the version supplied by the app package', (
    tester,
  ) async {
    final controller = BebiaSettingsController(store: MemoryPreferencesStore());
    await controller.load();
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      MaterialApp(
        theme: BebiaTheme.light(
          profileSex: null,
          preferences: const BebiaPreferences(),
        ),
        home: SettingsScreen(
          controller: controller,
          appVersionProvider: const _FakeVersionProvider(
            BebiaAppVersion(version: '9.8.7', buildNumber: '654'),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await _scrollToVersion(tester);

    expect(find.text('Verze 9.8.7 (654)'), findsOneWidget);
    expect(find.text('Verze 1.0.0 (1)'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
