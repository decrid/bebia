import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../features/family/family_connection.dart';
import 'atomic_json_file.dart';

class FamilyConnectionStore {
  FamilyConnectionStore({
    Future<File> Function()? fileResolver,
    this.beforeReplace,
  }) : _fileResolver = fileResolver;

  static const fileName = 'family_connection.json';

  final Future<File> Function()? _fileResolver;
  final Future<void> Function()? beforeReplace;
  AtomicJsonFile? _jsonFile;

  Future<FamilyConnectionState> read() async {
    final decoded = await _json.read();
    if (decoded == null) {
      return FamilyConnectionState.empty();
    }

    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Neplatný formát rodinného sdílení.');
    }

    return FamilyConnectionState.fromJson(decoded);
  }

  Future<void> write(FamilyConnectionState state) async {
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
}
