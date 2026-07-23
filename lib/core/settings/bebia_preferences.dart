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

abstract interface class BebiaPreferencesStore {
  Future<BebiaPreferences> load();

  Future<void> save(BebiaPreferences preferences);
}

class FileBebiaPreferencesStore implements BebiaPreferencesStore {
  FileBebiaPreferencesStore({this.fileResolver});

  static const String fileName = 'bebia_preferences.json';

  final Future<File> Function()? fileResolver;

  Future<File> _resolveFile() async {
    if (fileResolver != null) return fileResolver!();
    final directory = await getApplicationSupportDirectory();
    return File('${directory.path}${Platform.pathSeparator}$fileName');
  }

  @override
  Future<BebiaPreferences> load() async {
    final file = await _resolveFile();
    if (!await file.exists()) return const BebiaPreferences();

    final decoded = jsonDecode(await file.readAsString());
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Neplatný formát nastavení Bebia.');
    }
    return BebiaPreferences.fromJson(decoded);
  }

  @override
  Future<void> save(BebiaPreferences preferences) async {
    final file = await _resolveFile();
    await file.parent.create(recursive: true);
    await file.writeAsString(jsonEncode(preferences.toJson()), flush: true);
  }
}

class BebiaSettingsController extends ChangeNotifier {
  BebiaSettingsController({required BebiaPreferencesStore store})
    : _store = store;

  static final BebiaSettingsController instance = BebiaSettingsController(
    store: FileBebiaPreferencesStore(),
  );

  final BebiaPreferencesStore _store;

  BebiaPreferences _preferences = const BebiaPreferences();
  BebiaPreferences get preferences => _preferences;

  bool _initialized = false;
  bool get initialized => _initialized;

  String? _lastError;
  String? get lastError => _lastError;

  Future<void> load() async {
    try {
      _preferences = await _store.load();
      _lastError = null;
    } on Object {
      _preferences = const BebiaPreferences();
      _lastError =
          'Nastavení se nepodařilo načíst. Používají se bezpečné výchozí hodnoty.';
    } finally {
      _initialized = true;
      notifyListeners();
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

  Future<bool> _persist(BebiaPreferences updated) async {
    if (updated == _preferences) return true;
    final previous = _preferences;
    _preferences = updated;
    _lastError = null;
    notifyListeners();
    try {
      await _store.save(updated);
      return true;
    } on Object {
      _preferences = previous;
      _lastError = 'Změnu se nepodařilo uložit. Zkuste to prosím znovu.';
      notifyListeners();
      return false;
    }
  }
}
