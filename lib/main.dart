import 'package:flutter/material.dart';
import 'app.dart';
import 'core/app_services.dart';
import 'data/local/isar_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await IsarService.open();
  await AppServices.childProfileController.load();
  await AppServices.familyConnectionController.load();
  runApp(const BebiaApp());
}
