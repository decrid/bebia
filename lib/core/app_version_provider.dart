import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';

@immutable
class BebiaAppVersion {
  const BebiaAppVersion({required this.version, required this.buildNumber});

  const BebiaAppVersion.unavailable() : version = '', buildNumber = '';

  final String version;
  final String buildNumber;

  bool get isAvailable => version.isNotEmpty;

  String get displayLabel {
    if (!isAvailable) return 'Verze není dostupná';
    if (buildNumber.isEmpty) return 'Verze $version';
    return 'Verze $version ($buildNumber)';
  }
}

abstract interface class BebiaAppVersionProvider {
  Future<BebiaAppVersion> load();
}

class PackageInfoAppVersionProvider implements BebiaAppVersionProvider {
  const PackageInfoAppVersionProvider();

  @override
  Future<BebiaAppVersion> load() async {
    final info = await PackageInfo.fromPlatform();
    return BebiaAppVersion(
      version: info.version.trim(),
      buildNumber: info.buildNumber.trim(),
    );
  }
}
