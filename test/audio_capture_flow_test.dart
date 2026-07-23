import 'package:bebia/core/audio_capture_service.dart';
import 'package:bebia/core/design/bebia_theme.dart';
import 'package:bebia/core/settings/bebia_preferences.dart';
import 'package:bebia/features/crying/crying_form_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

enum _StartBehavior { success, permissionDenied, failure }

class _FakeAudioCapture implements AudioCapture {
  _FakeAudioCapture({this.startBehavior = _StartBehavior.success});

  final _StartBehavior startBehavior;
  bool recording = false;
  int startCalls = 0;
  int stopCalls = 0;
  int cancelCalls = 0;
  int deleteCalls = 0;

  @override
  Future<void> cancelRecording() async {
    cancelCalls++;
    recording = false;
  }

  @override
  Future<bool> hasPermission({bool request = true}) async {
    return startBehavior != _StartBehavior.permissionDenied;
  }

  @override
  Future<void> deleteRecording(String path) async {
    deleteCalls++;
  }

  @override
  Future<bool> isRecording() async => recording;

  @override
  Future<String> startRecording() async {
    startCalls++;
    switch (startBehavior) {
      case _StartBehavior.success:
        recording = true;
        return '/tmp/crying-test.wav';
      case _StartBehavior.permissionDenied:
        throw const AudioPermissionDeniedException();
      case _StartBehavior.failure:
        throw const AudioCaptureStartException(
          'Testovací mikrofon se nepodařilo spustit.',
        );
    }
  }

  @override
  Future<String?> stopRecording() async {
    stopCalls++;
    recording = false;
    return '/tmp/crying-test.wav';
  }
}

ThemeData _testTheme() {
  return BebiaTheme.light(
    profileSex: null,
    preferences: const BebiaPreferences(),
  );
}

Future<void> _pumpAudioForm(
  WidgetTester tester,
  _FakeAudioCapture audioCapture,
) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: _testTheme(),
      home: CryingFormScreen(audioCapture: audioCapture),
    ),
  );
  final startButton = find.byKey(const Key('crying-start-recording'));
  await tester.ensureVisible(startButton);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('permission denial leaves recording off and explains recovery', (
    tester,
  ) async {
    final audioCapture = _FakeAudioCapture(
      startBehavior: _StartBehavior.permissionDenied,
    );
    await _pumpAudioForm(tester, audioCapture);

    await tester.tap(find.byKey(const Key('crying-start-recording')));
    await tester.pumpAndSettle();

    expect(audioCapture.recording, isFalse);
    expect(
      find.text(
        'Přístup k mikrofonu nebyl udělen. Povol ho v nastavení aplikace.',
      ),
      findsOneWidget,
    );
    expect(
      tester
          .widget<ElevatedButton>(
            find.byKey(const Key('crying-start-recording')),
          )
          .onPressed,
      isNotNull,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('start failure is visible and does not enable stop', (
    tester,
  ) async {
    final audioCapture = _FakeAudioCapture(
      startBehavior: _StartBehavior.failure,
    );
    await _pumpAudioForm(tester, audioCapture);

    await tester.tap(find.byKey(const Key('crying-start-recording')));
    await tester.pumpAndSettle();

    expect(
      find.text('Testovací mikrofon se nepodařilo spustit.'),
      findsOneWidget,
    );
    expect(
      tester
          .widget<ElevatedButton>(
            find.byKey(const Key('crying-stop-recording')),
          )
          .onPressed,
      isNull,
    );
    expect(audioCapture.recording, isFalse);
    expect(tester.takeException(), isNull);
  });

  testWidgets('successful start and stop expose consistent UI states', (
    tester,
  ) async {
    final audioCapture = _FakeAudioCapture();
    await _pumpAudioForm(tester, audioCapture);

    await tester.tap(find.byKey(const Key('crying-start-recording')));
    await tester.pumpAndSettle();
    expect(find.text('Nahrávání běží'), findsOneWidget);
    expect(audioCapture.recording, isTrue);

    await tester.tap(find.byKey(const Key('crying-stop-recording')));
    await tester.pumpAndSettle();
    expect(find.text('Audio vzorek je uložen'), findsOneWidget);
    expect(audioCapture.recording, isFalse);
    expect(audioCapture.stopCalls, 1);

    await tester.tap(find.byKey(const Key('crying-clear-recording')));
    await tester.pumpAndSettle();
    expect(find.text('Audio vzorek byl odebrán'), findsOneWidget);
    expect(audioCapture.deleteCalls, 1);
    expect(tester.takeException(), isNull);
  });

  testWidgets('leaving the form cancels an active recording', (tester) async {
    final audioCapture = _FakeAudioCapture();
    await _pumpAudioForm(tester, audioCapture);

    await tester.tap(find.byKey(const Key('crying-start-recording')));
    await tester.pumpAndSettle();
    expect(audioCapture.recording, isTrue);

    await tester.pumpWidget(const MaterialApp(home: SizedBox.shrink()));
    await tester.pump();

    expect(audioCapture.cancelCalls, 1);
    expect(audioCapture.recording, isFalse);
    expect(tester.takeException(), isNull);
  });

  testWidgets('leaving without save deletes a stopped temporary recording', (
    tester,
  ) async {
    final audioCapture = _FakeAudioCapture();
    await _pumpAudioForm(tester, audioCapture);
    await tester.tap(find.byKey(const Key('crying-start-recording')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('crying-stop-recording')));
    await tester.pumpAndSettle();

    await tester.pumpWidget(const MaterialApp(home: SizedBox.shrink()));
    await tester.pump();

    expect(audioCapture.deleteCalls, 1);
    expect(tester.takeException(), isNull);
  });
}
