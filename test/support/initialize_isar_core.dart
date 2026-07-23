import 'dart:convert';
import 'dart:ffi';
import 'dart:io';

import 'package:isar_community/isar.dart';

Future<void> initializeIsarCoreForTests() async {
  if (Platform.isAndroid || Platform.isIOS) return;

  final packageConfig = File(
    '${Directory.current.path}${Platform.pathSeparator}.dart_tool'
    '${Platform.pathSeparator}package_config.json',
  );
  final decoded =
      jsonDecode(await packageConfig.readAsString()) as Map<String, dynamic>;
  final packages = (decoded['packages'] as List<dynamic>)
      .cast<Map<String, dynamic>>();
  final flutterLibraries = packages.firstWhere(
    (package) => package['name'] == 'isar_community_flutter_libs',
  );
  final rawRootUri = flutterLibraries['rootUri'] as String;
  final resolvedRoot = Uri.parse(rawRootUri).hasScheme
      ? Uri.parse(rawRootUri)
      : packageConfig.parent.uri.resolve(rawRootUri);
  final packageRoot = Uri.parse(
    resolvedRoot.toString().endsWith('/')
        ? resolvedRoot.toString()
        : '${resolvedRoot.toString()}/',
  );
  final libraryPath = switch (Platform.operatingSystem) {
    'windows' => 'windows/libisar.dll',
    'linux' => 'linux/libisar.so',
    'macos' => 'macos/libisar.dylib',
    _ => throw UnsupportedError(
      'Isar test runtime nepodporuje ${Platform.operatingSystem}.',
    ),
  };
  final library = File.fromUri(packageRoot.resolve(libraryPath));
  if (!await library.exists()) {
    throw StateError(
      'Nativní Isar knihovna z isar_community_flutter_libs nebyla nalezena.',
    );
  }

  await Isar.initializeIsarCore(
    libraries: <Abi, String>{Abi.current(): library.path},
  );
}
