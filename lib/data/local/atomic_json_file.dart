import 'dart:async';
import 'dart:convert';
import 'dart:io';

class AtomicJsonFile {
  AtomicJsonFile({required this.resolveFile, this.beforeReplace});

  final Future<File> Function() resolveFile;
  final Future<void> Function()? beforeReplace;

  Future<void> _writeQueue = Future<void>.value();
  bool _loadedFromBackup = false;

  Future<Object?> read() async {
    final file = await resolveFile();
    final backup = _backupFile(file);

    if (await file.exists()) {
      try {
        final value = await _readFromFile(file);
        _loadedFromBackup = false;
        return value;
      } on FormatException {
        if (await backup.exists()) {
          final value = await _readFromFile(backup);
          _loadedFromBackup = true;
          return value;
        }
        rethrow;
      } on FileSystemException {
        if (await backup.exists()) {
          final value = await _readFromFile(backup);
          _loadedFromBackup = true;
          return value;
        }
        rethrow;
      }
    }

    if (await backup.exists()) {
      final value = await _readFromFile(backup);
      _loadedFromBackup = true;
      return value;
    }

    _loadedFromBackup = false;
    return null;
  }

  Future<void> write(Object? value) {
    final operation = _writeQueue.then((_) => _write(value));
    _writeQueue = operation.catchError((_) {});
    return operation;
  }

  Future<Object?> _readFromFile(File file) async {
    final raw = await file.readAsString();
    if (raw.trim().isEmpty) return null;
    return jsonDecode(raw);
  }

  Future<void> _write(Object? value) async {
    final file = await resolveFile();
    final temporary = _temporaryFile(file);
    final backup = _backupFile(file);
    final invalid = File('${file.path}.invalid');
    await file.parent.create(recursive: true);

    if (await temporary.exists()) {
      await temporary.delete();
    }

    await temporary.writeAsString(jsonEncode(value), flush: true);

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

    await _deleteBestEffort(backup);
    await _deleteBestEffort(invalid);
  }

  File _temporaryFile(File target) => File('${target.path}.tmp');

  File _backupFile(File target) => File('${target.path}.bak');

  Future<void> _deleteBestEffort(File file) async {
    if (!await file.exists()) return;
    try {
      await file.delete();
    } on FileSystemException {
      // A stale recovery file is safer than reporting loss of a valid target.
    }
  }
}
