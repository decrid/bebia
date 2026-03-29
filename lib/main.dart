import 'package:flutter/material.dart';
import 'app.dart';
import 'data/local/isar_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await IsarService.open();
  runApp(const BebiaApp());
}