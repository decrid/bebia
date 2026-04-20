import 'package:firebase_core/firebase_core.dart';

class BebiaFirebaseConfig {
  const BebiaFirebaseConfig._();

  static FirebaseOptions? get currentPlatform => null;

  static bool get isConfigured => currentPlatform != null;
}
