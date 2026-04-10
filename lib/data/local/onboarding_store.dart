import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class OnboardingStore {
  static const _fileName = 'onboarding_state.json';

  Future<bool> isCompleted() async {
    final file = await _file();
    if (!await file.exists()) {
      return false;
    }

    final raw = await file.readAsString();
    if (raw.trim().isEmpty) {
      return false;
    }

    final json = jsonDecode(raw) as Map<String, dynamic>;
    return json['completed'] == true;
  }

  Future<void> setCompleted(bool completed) async {
    final file = await _file();
    await file.writeAsString(jsonEncode({'completed': completed}));
  }

  Future<File> _file() async {
    final dir = await getApplicationSupportDirectory();
    return File(p.join(dir.path, _fileName));
  }
}
