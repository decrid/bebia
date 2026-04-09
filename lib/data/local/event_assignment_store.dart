import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class EventAssignmentStore {
  static const _fileName = 'event_assignments.json';

  Future<Map<int, String>> read() async {
    final file = await _file();
    if (!await file.exists()) {
      return {};
    }

    final raw = await file.readAsString();
    if (raw.trim().isEmpty) {
      return {};
    }

    final json = jsonDecode(raw) as Map<String, dynamic>;
    return json.map(
      (key, value) => MapEntry(int.tryParse(key) ?? -1, value as String),
    )..remove(-1);
  }

  Future<void> write(Map<int, String> assignments) async {
    final file = await _file();
    final json = assignments.map(
      (key, value) => MapEntry(key.toString(), value),
    );
    await file.writeAsString(jsonEncode(json));
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
