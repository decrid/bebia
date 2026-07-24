import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'atomic_json_file.dart';

class OnboardingStore {
  OnboardingStore({Future<File> Function()? fileResolver, this.beforeReplace})
    : _fileResolver = fileResolver;

  static const fileName = 'onboarding_state.json';

  final Future<File> Function()? _fileResolver;
  final Future<void> Function()? beforeReplace;
  AtomicJsonFile? _jsonFile;

  Future<bool> isCompleted() async {
    final decoded = await _json.read();
    if (decoded == null) {
      return false;
    }

    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Neplatný formát onboardingu.');
    }

    return decoded['completed'] == true;
  }

  Future<void> setCompleted(bool completed) async {
    await _json.write({'completed': completed});
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
