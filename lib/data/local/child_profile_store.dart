import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../features/profile/child_profile.dart';

class ChildProfileStore {
  static const _fileName = 'child_profiles.json';

  Future<ChildProfilesState> read() async {
    final file = await _file();
    if (!await file.exists()) {
      return ChildProfilesState.empty();
    }

    final raw = await file.readAsString();
    if (raw.trim().isEmpty) {
      return ChildProfilesState.empty();
    }

    final json = jsonDecode(raw) as Map<String, dynamic>;

    if (json.containsKey('profiles') || json.containsKey('activeProfileId')) {
      return ChildProfilesState.fromJson(json);
    }

    // Backward compatibility for the original single-profile file shape.
    final legacyProfile = ChildProfile.fromJson(
      json,
    ).copyWith(id: 'child-${DateTime.now().millisecondsSinceEpoch}');

    return ChildProfilesState(
      profiles: [legacyProfile],
      activeProfileId: legacyProfile.id,
    );
  }

  Future<void> write(ChildProfilesState state) async {
    final file = await _file();
    await file.writeAsString(jsonEncode(state.toJson()));
  }

  Future<void> clear() async {
    final file = await _file();
    if (await file.exists()) {
      await file.delete();
    }
  }

  Future<File> _file() async {
    final dir = await getApplicationSupportDirectory();
    return File(p.join(dir.path, _fileName));
  }
}
