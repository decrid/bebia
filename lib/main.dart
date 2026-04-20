import 'package:flutter/material.dart';

import 'app.dart';
import 'core/app_services.dart';
import 'data/local/isar_service.dart';
import 'features/auth/app_account_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await IsarService.open();
  final firebaseReady = await AppServices.firebaseBootstrapService
      .initializeIfConfigured();
  if (firebaseReady) {
    await AppServices.appAccountController.markBackendConfigured(
      supportedProviders: const [
        AppAccountProvider.google,
        AppAccountProvider.apple,
        AppAccountProvider.email,
      ],
    );
  }
  await AppServices.childProfileController.load();
  await AppServices.familyConnectionController.load();
  runApp(const BebiaApp());
}
