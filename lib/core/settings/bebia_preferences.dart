import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

enum BebiaAppearance { system, light, dark }

enum BebiaContentDensity { comfortable, compact }

@immutable
class BebiaPreferences {
  const BebiaPreferences({
    this.appearance = BebiaAppearance.system,
    this.contentDensity = BebiaContentDensity.comfortable,
    this.reduceMotion = false,
    this.hapticsEnabled = true,
  });

  static const int legacyVersion = 0;
  static const int currentVersion = 1;

  final BebiaAppearance appearance;
  final BebiaContentDensity contentDensity;
  final bool reduceMotion;
  final bool hapticsEnabled;

  BebiaPreferences copyWith({
    BebiaAppearance? appearance,
    BebiaContentDensity? contentDensity,
    bool? reduceMotion,
    bool? hapticsEnabled,
  }) {
    return BebiaPreferences(
      appearance: appearance ?? this.appearance,
      contentDensity: contentDensity ?? this.contentDensity,
      reduceMotion: reduceMotion ?? this.reduceMotion,
      hapticsEnabled: hapticsEnabled ?? this.hapticsEnabled,
    );
  }

  Map<String, Object> toJson() => <String, Object>{
    'version': currentVersion,
    'appearance': appearance.name,
    'contentDensity': contentDensity.name,
    'reduceMotion': reduceMotion,
    'hapticsEnabled': hapticsEnabled,
  };

  factory BebiaPreferences.fromJson(Map<String, Object?> json) {
    return BebiaPreferences(
      appearance: _enumValue(
        BebiaAppearance.values,
        json['appearance'],
        BebiaAppearance.system,
      ),
      contentDensity: _enumValue(
        BebiaContentDensity.values,
        json['contentDensity'],
        BebiaContentDensity.comfortable,
      ),
      reduceMotion: json['reduceMotion'] is bool
          ? json['reduceMotion']! as bool
          : false,
      hapticsEnabled: json['hapticsEnabled'] is bool
          ? json['hapticsEnabled']! as bool
          : true,
    );
  }

  static T _enumValue<T extends Enum>(
    List<T> values,
    Object? rawValue,
    T fallback,
  ) {
    for (final value in values) {
      if (value.name == rawValue) return value;
    }
    return fallback;
  }

  @override
  bool operator ==(Object other) {
    return other is BebiaPreferences &&
        other.appearance == appearance &&
        other.contentDensity == contentDensity &&
        other.reduceMotion == reduceMotion &&
        other.hapticsEnabled == hapticsEnabled;
  }

  @override
  int get hashCode =>
      Object.hash(appearance, contentDensity, reduceMotion, hapticsEnabled);
}

class UnsupportedPreferencesVersionException implements Exception {
  const UnsupportedPreferencesVersionException(this.version);

  final int version;

  @override
  String toString() =>
      'Nastavení používá novější nepodporovanou verzi $version.';
}

abstract interface class BebiaPreferencesStore {
  Future<BebiaPreferences> load();

  Future<void> save(BebiaPreferences preferences);
}

class FileBebiaPreferencesStore implements BebiaPreferencesStore {
  FileBebiaPreferencesStore({this.fileResolver, this.beforeReplace});

  static const String fileName = 'bebia_preferences.json';

  final Future<File> Function()? fileResolver;

  /// Test seam invoked after the last valid file is backed up and before the
  /// temporary file replaces it.
  final Future<void> Function()? beforeReplace;

  Map<String, Object?> _preservedUnknownFields = <String, Object?>{};
  int? _unsupportedFutureVersion;
  bool _loadedFromBackup = false;

  int? get unsupportedFutureVersion => _unsupportedFutureVersion;

  Future<File> _resolveFile() async {
    if (fileResolver != null) return fileResolver!();
    final directory = await getApplicationSupportDirectory();
    return File('${directory.path}${Platform.pathSeparator}$fileName');
  }

  File _temporaryFile(File target) => File('${target.path}.tmp');

  File _backupFile(File target) => File('${target.path}.bak');

  @override
  Future<BebiaPreferences> load() async {
    final file = await _resolveFile();
    final backup = _backupFile(file);
    if (await file.exists()) {
      try {
        final preferences = await _loadFromFile(file);
        _loadedFromBackup = false;
        return preferences;
      } on FormatException {
        if (await backup.exists()) {
          final preferences = await _loadFromFile(backup);
          _loadedFromBackup = true;
          return preferences;
        }
        rethrow;
      } on FileSystemException {
        if (await backup.exists()) {
          final preferences = await _loadFromFile(backup);
          _loadedFromBackup = true;
          return preferences;
        }
        rethrow;
      }
    }
    if (await backup.exists()) {
      final preferences = await _loadFromFile(backup);
      _loadedFromBackup = true;
      return preferences;
    }

    _preservedUnknownFields = <String, Object?>{};
    _unsupportedFutureVersion = null;
    _loadedFromBackup = false;
    return const BebiaPreferences();
  }

  Future<BebiaPreferences> _loadFromFile(File source) async {
    final decoded = jsonDecode(await source.readAsString());
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Neplatný formát nastavení Bebia.');
    }

    final values = Map<String, Object?>.from(decoded);
    final version = _readVersion(values['version']);
    _unsupportedFutureVersion = version > BebiaPreferences.currentVersion
        ? version
        : null;

    final migrated = _migrateKnownVersion(values, version);
    _preservedUnknownFields = Map<String, Object?>.from(values)
      ..remove('version')
      ..remove('appearance')
      ..remove('contentDensity')
      ..remove('reduceMotion')
      ..remove('hapticsEnabled');
    return BebiaPreferences.fromJson(migrated);
  }

  int _readVersion(Object? rawVersion) {
    if (rawVersion == null) return BebiaPreferences.legacyVersion;
    if (rawVersion is int && rawVersion >= 0) return rawVersion;
    throw const FormatException('Neplatná verze nastavení Bebia.');
  }

  Map<String, Object?> _migrateKnownVersion(
    Map<String, Object?> values,
    int version,
  ) {
    switch (version) {
      case BebiaPreferences.legacyVersion:
      case BebiaPreferences.currentVersion:
        return values;
      default:
        // A future file remains untouched and read-only. Known fields can still
        // be displayed safely, while save() prevents a destructive downgrade.
        return values;
    }
  }

  @override
  Future<void> save(BebiaPreferences preferences) async {
    final futureVersion = _unsupportedFutureVersion;
    if (futureVersion != null) {
      throw UnsupportedPreferencesVersionException(futureVersion);
    }

    final file = await _resolveFile();
    final temporary = _temporaryFile(file);
    final backup = _backupFile(file);
    final invalid = File('${file.path}.invalid');
    await file.parent.create(recursive: true);

    if (await temporary.exists()) {
      await temporary.delete();
    }
    await temporary.writeAsString(
      jsonEncode(<String, Object?>{
        ..._preservedUnknownFields,
        ...preferences.toJson(),
      }),
      flush: true,
    );

    var originalWasBackedUp = false;
    var invalidTargetWasMoved = false;
    final preserveRecoveryBackup = _loadedFromBackup && await backup.exists();
    try {
      if (preserveRecoveryBackup) {
        if (await invalid.exists()) {
          await invalid.delete();
        }
        if (await file.exists()) {
          await file.rename(invalid.path);
          invalidTargetWasMoved = true;
        }
      } else {
        if (await backup.exists()) {
          await backup.delete();
        }
        if (await file.exists()) {
          await file.rename(backup.path);
          originalWasBackedUp = true;
        }
      }

      if (beforeReplace != null) {
        await beforeReplace!();
      }
      await temporary.rename(file.path);
      _loadedFromBackup = false;
    } on Object {
      if (!await file.exists()) {
        if (invalidTargetWasMoved && await invalid.exists()) {
          await invalid.rename(file.path);
        } else if (originalWasBackedUp && await backup.exists()) {
          await backup.rename(file.path);
        }
      }
      rethrow;
    } finally {
      if (await temporary.exists()) {
        await temporary.delete();
      }
    }

    // The new target is already durable. A stale backup is harmless and will
    // also be ignored by load(), so cleanup failure must not report save loss.
    if (await backup.exists()) {
      try {
        await backup.delete();
      } on FileSystemException {
        // Keep the recovery copy; the current target remains authoritative.
      }
    }
    if (await invalid.exists()) {
      try {
        await invalid.delete();
      } on FileSystemException {
        // Nový target je validní; starý poškozený soubor už není autoritativní.
      }
    }
  }
}

class BebiaSettingsController extends ChangeNotifier {
  BebiaSettingsController({required BebiaPreferencesStore store})
    : _store = store;

  static final BebiaSettingsController instance = BebiaSettingsController(
    store: FileBebiaPreferencesStore(),
  );

  final BebiaPreferencesStore _store;
  Future<void> _writeQueue = Future<void>.value();

  BebiaPreferences _preferences = const BebiaPreferences();
  BebiaPreferences get preferences => _preferences;

  BebiaPreferences _lastPersisted = const BebiaPreferences();
  int _revision = 0;
  bool _disposed = false;

  bool _initialized = false;
  bool get initialized => _initialized;

  String? _lastError;
  String? get lastError => _lastError;

  Future<void> load() async {
    try {
      _preferences = await _store.load();
      _lastPersisted = _preferences;
      final futureVersion = _store is FileBebiaPreferencesStore
          ? _store.unsupportedFutureVersion
          : null;
      _lastError = futureVersion == null
          ? null
          : 'Nastavení vytvořila novější verze aplikace. Zůstává zachované '
                'a v této verzi je jen pro čtení.';
    } on Object {
      _preferences = const BebiaPreferences();
      _lastPersisted = _preferences;
      _lastError =
          'Nastavení se nepodařilo načíst. Původní soubor zůstal zachovaný.';
    } finally {
      _initialized = true;
      _notifySafely();
    }
  }

  Future<bool> setAppearance(BebiaAppearance value) =>
      _persist(_preferences.copyWith(appearance: value));

  Future<bool> setContentDensity(BebiaContentDensity value) =>
      _persist(_preferences.copyWith(contentDensity: value));

  Future<bool> setReduceMotion(bool value) =>
      _persist(_preferences.copyWith(reduceMotion: value));

  Future<bool> setHapticsEnabled(bool value) =>
      _persist(_preferences.copyWith(hapticsEnabled: value));

  Future<bool> reset() => _persist(const BebiaPreferences());

  Future<bool> _persist(BebiaPreferences updated) {
    if (_disposed) return Future<bool>.value(false);
    if (updated == _preferences) return Future<bool>.value(true);

    final operationRevision = ++_revision;
    final completer = Completer<bool>();
    _preferences = updated;
    _lastError = null;
    _notifySafely();

    _writeQueue = _writeQueue.then((_) async {
      try {
        await _store.save(updated);
        _lastPersisted = updated;
        if (operationRevision == _revision) {
          _lastError = null;
          _notifySafely();
        }
        completer.complete(true);
      } on Object {
        if (operationRevision == _revision) {
          _preferences = _lastPersisted;
          _lastError =
              'Změnu se nepodařilo bezpečně uložit. Poslední potvrzené '
              'nastavení zůstalo zachované.';
          _notifySafely();
        }
        completer.complete(false);
      }
    });

    return completer.future;
  }

  void _notifySafely() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
