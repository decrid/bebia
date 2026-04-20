import 'package:firebase_core/firebase_core.dart';

import 'bebia_firebase_config.dart';

class FirebaseBootstrapService {
  const FirebaseBootstrapService();

  bool get isConfigured => BebiaFirebaseConfig.isConfigured;

  Future<bool> initializeIfConfigured() async {
    if (!isConfigured) {
      return false;
    }

    if (Firebase.apps.isNotEmpty) {
      return true;
    }

    await Firebase.initializeApp(options: BebiaFirebaseConfig.currentPlatform);
    return true;
  }
}
