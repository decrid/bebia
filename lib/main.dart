import 'package:flutter/material.dart';

import 'core/bootstrap/bebia_bootstrap.dart';
import 'core/app_services.dart';
import 'core/settings/bebia_preferences.dart';
import 'data/local/isar_service.dart';
import 'features/auth/app_account_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(BebiaBootstrap(initialize: _initializeBebia));
}

Future<void> _initializeBebia() async {
  await BebiaSettingsController.instance.load();
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
  await AppServices.widgetSnapshotService.initialize();
}
