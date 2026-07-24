import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../features/profile/child_profile.dart';
import 'atomic_json_file.dart';

class ChildProfileStore {
  ChildProfileStore({Future<File> Function()? fileResolver, this.beforeReplace})
    : _fileResolver = fileResolver;

  static const fileName = 'child_profiles.json';

  final Future<File> Function()? _fileResolver;
  final Future<void> Function()? beforeReplace;
  AtomicJsonFile? _jsonFile;

  Future<ChildProfilesState> read() async {
    final decoded = await _json.read();
    if (decoded == null) {
      return ChildProfilesState.empty();
    }

    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Neplatný formát profilů dětí.');
    }

    if (decoded.containsKey('profiles') ||
        decoded.containsKey('activeProfileId')) {
      return ChildProfilesState.fromJson(decoded);
    }

    // Backward compatibility for the original single-profile file shape.
    final legacyProfile = ChildProfile.fromJson(
      decoded,
    ).copyWith(id: _stableLegacyId(decoded));

    final migrated = ChildProfilesState(
      profiles: [legacyProfile],
      activeProfileId: legacyProfile.id,
      legacyUnassignedEventsMigrationChildId: legacyProfile.id,
    );
    await write(migrated);
    return migrated;
  }

  Future<void> write(ChildProfilesState state) async {
    await _json.write(state.toJson());
  }

  Future<void> clear() async {
    final file = await _file();
    if (await file.exists()) {
      await file.delete();
    }
  }

  Future<File> _file() async {
    final resolver = _fileResolver;
    if (resolver != null) return resolver();
    final dir = await getApplicationSupportDirectory();
    return File(p.join(dir.path, fileName));
  }

  AtomicJsonFile get _json => _jsonFile ??= AtomicJsonFile(
    resolveFile: _file,
    beforeReplace: beforeReplace,
  );

  String _stableLegacyId(Map<String, dynamic> json) {
    final canonical = jsonEncode(<String, Object?>{
      'name': json['name'],
      'dateOfBirth': json['dateOfBirth'],
      'sex': json['sex'],
    });
    var hash = 0x811c9dc5;
    for (final codeUnit in canonical.codeUnits) {
      hash ^= codeUnit;
      hash = (hash * 0x01000193) & 0xffffffff;
    }
    return 'child-legacy-${hash.toRadixString(16).padLeft(8, '0')}';
  }
}
