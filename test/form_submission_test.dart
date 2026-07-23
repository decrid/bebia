import 'package:bebia/core/design/bebia_theme.dart';
import 'package:bebia/core/settings/bebia_preferences.dart';
import 'package:bebia/features/crying/ai_crying_analysis_result.dart';
import 'package:bebia/features/crying/crying_form_screen.dart';
import 'package:bebia/features/diaper/diaper_form_screen.dart';
import 'package:bebia/features/feeding/feeding_form_screen.dart';
import 'package:bebia/features/sleep/sleep_form_screen.dart';
import 'package:bebia/features/timeline/timeline_form_submission.dart';
import 'package:bebia/features/timeline/timeline_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeSubmission implements TimelineFormSubmission {
  _FakeSubmission({this.hasActiveProfile = true, this.saveError});

  @override
  final bool hasActiveProfile;
  final Object? saveError;
  final List<TimelineItem> savedItems = <TimelineItem>[];
  final List<bool> editFlags = <bool>[];

  @override
  Future<void> save(TimelineItem item, {required bool isEdit}) async {
    if (saveError != null) throw saveError!;
    savedItems.add(item);
    editFlags.add(isEdit);
  }
}

const _analysisResult = AiCryingAnalysisResult(
  cryDetected: true,
  cryProbability: 0.91,
  probableCause: 'hunger',
  confidence: 0.82,
  signals: <String>['test signal'],
  modelVersion: 'test-model',
);

Widget _formFor(String name, TimelineFormSubmission submission) {
  return switch (name) {
    'feeding' => FeedingFormScreen(submission: submission),
    'sleep' => SleepFormScreen(submission: submission),
    'diaper' => DiaperFormScreen(submission: submission),
    'crying' => CryingFormScreen(
      submission: submission,
      analyzeCrying: (_) async => _analysisResult,
    ),
    _ => throw ArgumentError.value(name),
  };
}

ThemeData _formTheme() {
  return BebiaTheme.light(
    profileSex: null,
    preferences: const BebiaPreferences(),
  );
}

void main() {
  for (final name in <String>['feeding', 'sleep', 'diaper', 'crying']) {
    testWidgets('$name validates the required active child profile', (
      tester,
    ) async {
      final submission = _FakeSubmission(hasActiveProfile: false);
      await tester.pumpWidget(
        MaterialApp(theme: _formTheme(), home: _formFor(name, submission)),
      );
      if (name == 'feeding') {
        await tester.enterText(
          find.byKey(const Key('feeding-amount-field')),
          '90',
        );
      } else if (name == 'crying') {
        await tester.enterText(
          find.byKey(const Key('crying-duration-field')),
          '12',
        );
      }

      await tester.tap(find.widgetWithText(ElevatedButton, 'Uložit'));
      await tester.pump();

      expect(
        find.text(
          'Nejdřív vyber profil dítěte, ke kterému chceš událost uložit.',
        ),
        findsOneWidget,
      );
      expect(submission.savedItems, isEmpty);
      expect(tester.takeException(), isNull);
    });

    testWidgets(
      '$name submits a valid production form through the repository seam',
      (tester) async {
        final submission = _FakeSubmission();
        await tester.pumpWidget(
          MaterialApp(theme: _formTheme(), home: _formFor(name, submission)),
        );
        if (name == 'feeding') {
          await tester.enterText(
            find.byKey(const Key('feeding-amount-field')),
            '90',
          );
        } else if (name == 'crying') {
          await tester.enterText(
            find.byKey(const Key('crying-duration-field')),
            '12',
          );
        }

        await tester.tap(find.widgetWithText(ElevatedButton, 'Uložit'));
        await tester.pumpAndSettle();

        expect(submission.savedItems, hasLength(1));
        expect(submission.editFlags, <bool>[false]);
        expect(submission.savedItems.single.type.name, name);
        if (name == 'feeding') {
          expect(submission.savedItems.single.feedingAmountMl, 90);
        } else if (name == 'crying') {
          expect(submission.savedItems.single.cryingDurationMinutes, 12);
        }
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      '$name contains a repository failure and keeps the form usable',
      (tester) async {
        final submission = _FakeSubmission(
          saveError: StateError('test write failure'),
        );
        await tester.pumpWidget(
          MaterialApp(theme: _formTheme(), home: _formFor(name, submission)),
        );

        await tester.tap(find.widgetWithText(ElevatedButton, 'Uložit'));
        await tester.pumpAndSettle();

        expect(find.textContaining('test write failure'), findsOneWidget);
        expect(find.widgetWithText(ElevatedButton, 'Uložit'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets('feeding rejects a non-numeric amount', (tester) async {
    final submission = _FakeSubmission();
    await tester.pumpWidget(
      MaterialApp(
        theme: _formTheme(),
        home: FeedingFormScreen(submission: submission),
      ),
    );
    await tester.enterText(
      find.byKey(const Key('feeding-amount-field')),
      'devadesát',
    );

    await tester.tap(find.widgetWithText(ElevatedButton, 'Uložit'));
    await tester.pump();

    expect(
      find.text('Množství musí být kladné celé číslo v mililitrech.'),
      findsOneWidget,
    );
    expect(submission.savedItems, isEmpty);
    expect(tester.takeException(), isNull);
  });

  testWidgets('crying rejects an invalid duration', (tester) async {
    final submission = _FakeSubmission();
    await tester.pumpWidget(
      MaterialApp(
        theme: _formTheme(),
        home: CryingFormScreen(
          submission: submission,
          analyzeCrying: (_) async => _analysisResult,
        ),
      ),
    );
    await tester.enterText(find.byKey(const Key('crying-duration-field')), '0');

    await tester.tap(find.widgetWithText(ElevatedButton, 'Uložit'));
    await tester.pump();

    expect(
      find.text('Délka pláče musí být kladné celé číslo v minutách.'),
      findsOneWidget,
    );
    expect(submission.savedItems, isEmpty);
    expect(tester.takeException(), isNull);
  });

  testWidgets('sleep rejects an end time before its start', (tester) async {
    final submission = _FakeSubmission();
    final existing = TimelineItem()
      ..id = 404
      ..type = EventType.sleep
      ..time = DateTime(2026, 7, 22, 11)
      ..title = 'Spánek'
      ..subtitle = 'Neplatný testovací rozsah'
      ..sleepStart = DateTime(2026, 7, 22, 12)
      ..sleepEnd = DateTime(2026, 7, 22, 11);
    await tester.pumpWidget(
      MaterialApp(
        theme: _formTheme(),
        home: SleepFormScreen(existingItem: existing, submission: submission),
      ),
    );

    await tester.tap(find.widgetWithText(ElevatedButton, 'Uložit změny'));
    await tester.pump();

    expect(
      find.text('Konec spánku musí být později než začátek spánku.'),
      findsOneWidget,
    );
    expect(submission.savedItems, isEmpty);
    expect(tester.takeException(), isNull);
  });
}
