import 'package:isar_community/isar.dart';
import 'package:path_provider/path_provider.dart';

import '../../features/timeline/timeline_item.dart';

class IsarService {
  static Isar? _isar;

  static Future<Isar> open() async {
    if (_isar != null) return _isar!;

    final dir = await getApplicationSupportDirectory();

    _isar = await Isar.open(
      [TimelineItemSchema],
      directory: dir.path,
      inspector: true,
    );

    return _isar!;
  }

  static Isar get instance {
    final db = _isar;
    if (db == null) {
      throw StateError(
        'Isar není inicializovaný. Zavolej nejdřív IsarService.open().',
      );
    }
    return db;
  }

  static Future<void> close() async {
    final db = _isar;
    if (db != null && db.isOpen) {
      await db.close();
      _isar = null;
    }
  }
}
