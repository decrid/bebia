import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../features/family/family_connection.dart';

class FamilyConnectionStore {
  static const _fileName = 'family_connection.json';

  Future<FamilyConnectionState> read() async {
    final file = await _file();
    if (!await file.exists()) {
      return FamilyConnectionState.empty();
    }

    final raw = await file.readAsString();
    if (raw.trim().isEmpty) {
      return FamilyConnectionState.empty();
    }

    final json = jsonDecode(raw) as Map<String, dynamic>;
    return FamilyConnectionState.fromJson(json);
  }

  Future<void> write(FamilyConnectionState state) async {
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
