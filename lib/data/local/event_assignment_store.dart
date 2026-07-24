import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'atomic_json_file.dart';

class EventAssignmentStore {
  EventAssignmentStore({
    Future<File> Function()? fileResolver,
    this.beforeReplace,
  }) : _fileResolver = fileResolver;

  static const fileName = 'event_assignments.json';

  final Future<File> Function()? _fileResolver;
  final Future<void> Function()? beforeReplace;
  AtomicJsonFile? _jsonFile;

  Future<Map<int, String>> read() async {
    final decoded = await _json.read();
    if (decoded == null) {
      return {};
    }

    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Neplatný formát přiřazení událostí.');
    }

    final assignments = <int, String>{};
    for (final entry in decoded.entries) {
      final id = int.tryParse(entry.key);
      final childId = entry.value;
      if (id != null && childId is String && childId.isNotEmpty) {
        assignments[id] = childId;
      }
    }
    return assignments;
  }

  Future<void> write(Map<int, String> assignments) async {
    final json = assignments.map(
      (key, value) => MapEntry(key.toString(), value),
    );
    await _json.write(json);
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
}
