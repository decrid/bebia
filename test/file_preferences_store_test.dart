import 'dart:convert';
import 'dart:io';

import 'package:bebia/core/settings/bebia_preferences.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late Directory directory;
  late File file;

  setUp(() async {
    directory = await Directory.systemTemp.createTemp(
      'bebia-preferences-test-',
    );
    file = File(
      '${directory.path}${Platform.pathSeparator}'
      '${FileBebiaPreferencesStore.fileName}',
    );
  });

  tearDown(() async {
    if (await directory.exists()) {
      await directory.delete(recursive: true);
    }
  });

  FileBebiaPreferencesStore createStore({
    Future<void> Function()? beforeReplace,
  }) {
    return FileBebiaPreferencesStore(
      fileResolver: () async => file,
      beforeReplace: beforeReplace,
    );
  }

  test('loads the original format without a version field', () async {
    await file.writeAsString(
      jsonEncode(<String, Object>{
        'appearance': 'dark',
        'contentDensity': 'compact',
        'reduceMotion': true,
        'hapticsEnabled': false,
      }),
    );

    final preferences = await createStore().load();

    expect(preferences.appearance, BebiaAppearance.dark);
    expect(preferences.contentDensity, BebiaContentDensity.compact);
    expect(preferences.reduceMotion, isTrue);
    expect(preferences.hapticsEnabled, isFalse);
  });

  test('migrates the known legacy version on the next safe save', () async {
    await file.writeAsString(
      jsonEncode(<String, Object>{
        'version': BebiaPreferences.legacyVersion,
        'appearance': 'light',
        'unknownLegacyField': 'keep-me',
      }),
    );
    final preferencesStore = createStore();
    final preferences = await preferencesStore.load();

    await preferencesStore.save(preferences.copyWith(reduceMotion: true));

    final decoded =
        jsonDecode(await file.readAsString()) as Map<String, dynamic>;
    expect(decoded['version'], BebiaPreferences.currentVersion);
    expect(decoded['appearance'], 'light');
    expect(decoded['reduceMotion'], isTrue);
    expect(decoded['unknownLegacyField'], 'keep-me');
  });

  test('keeps an unknown newer version read-only and unchanged', () async {
    final original = jsonEncode(<String, Object>{
      'version': BebiaPreferences.currentVersion + 5,
      'appearance': 'dark',
      'futureSetting': 'future-value',
    });
    await file.writeAsString(original);
    final preferencesStore = createStore();

    final preferences = await preferencesStore.load();

    expect(preferences.appearance, BebiaAppearance.dark);
    expect(preferencesStore.unsupportedFutureVersion, 6);
    await expectLater(
      preferencesStore.save(
        preferences.copyWith(appearance: BebiaAppearance.light),
      ),
      throwsA(isA<UnsupportedPreferencesVersionException>()),
    );
    expect(await file.readAsString(), original);
  });

  test('isolates invalid fields and preserves unknown fields', () async {
    await file.writeAsString(
      jsonEncode(<String, Object>{
        'version': BebiaPreferences.currentVersion,
        'appearance': 'not-a-theme',
        'reduceMotion': 'not-a-bool',
        'customField': <String, Object>{'enabled': true},
      }),
    );
    final preferencesStore = createStore();

    final preferences = await preferencesStore.load();
    await preferencesStore.save(preferences);

    expect(preferences.appearance, BebiaAppearance.system);
    expect(preferences.reduceMotion, isFalse);
    final decoded =
        jsonDecode(await file.readAsString()) as Map<String, dynamic>;
    expect(decoded['customField'], <String, dynamic>{'enabled': true});
  });

  test('a failed replacement restores the last valid file', () async {
    final initialStore = createStore();
    const original = BebiaPreferences(appearance: BebiaAppearance.dark);
    await initialStore.save(original);

    final failingStore = createStore(
      beforeReplace: () async => throw FileSystemException('interrupted'),
    );
    await failingStore.load();
    await expectLater(
      failingStore.save(
        const BebiaPreferences(appearance: BebiaAppearance.light),
      ),
      throwsA(isA<FileSystemException>()),
    );

    expect(await createStore().load(), original);
    expect(await File('${file.path}.tmp').exists(), isFalse);
  });

  test('recovers from a backup left by an interrupted replacement', () async {
    final backup = File('${file.path}.bak');
    await backup.writeAsString(
      jsonEncode(
        const BebiaPreferences(appearance: BebiaAppearance.dark).toJson(),
      ),
    );

    final preferences = await createStore().load();

    expect(preferences.appearance, BebiaAppearance.dark);
  });

  test('falls back to a valid backup when the target is corrupted', () async {
    await file.writeAsString('{ broken-target');
    final backup = File('${file.path}.bak');
    await backup.writeAsString(
      jsonEncode(
        const BebiaPreferences(
          appearance: BebiaAppearance.dark,
          reduceMotion: true,
        ).toJson(),
      ),
    );

    final preferences = await createStore().load();

    expect(preferences.appearance, BebiaAppearance.dark);
    expect(preferences.reduceMotion, isTrue);
    expect(await file.readAsString(), '{ broken-target');
  });

  test(
    'failed save after backup recovery preserves both recovery paths',
    () async {
      const corrupted = '{ broken-target';
      await file.writeAsString(corrupted);
      final backup = File('${file.path}.bak');
      const recovered = BebiaPreferences(
        appearance: BebiaAppearance.dark,
        reduceMotion: true,
      );
      await backup.writeAsString(jsonEncode(recovered.toJson()));
      final store = createStore(
        beforeReplace: () async => throw FileSystemException('interrupted'),
      );
      expect(await store.load(), recovered);

      await expectLater(
        store.save(recovered.copyWith(hapticsEnabled: false)),
        throwsA(isA<FileSystemException>()),
      );

      expect(await file.readAsString(), corrupted);
      expect(await createStore().load(), recovered);
    },
  );

  test('reports corrupted JSON without overwriting it', () async {
    const corrupted = '{ definitely-not-json';
    await file.writeAsString(corrupted);

    await expectLater(createStore().load(), throwsA(isA<FormatException>()));

    expect(await file.readAsString(), corrupted);
  });
}
