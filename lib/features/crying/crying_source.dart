class CryingSource {
  static const String manual = 'manual';
  static const String aiDetected = 'ai_detected';
  static const String aiConfirmed = 'ai_confirmed';

  static String label(String? source) {
    switch (source) {
      case manual:
        return 'Ruční záznam';
      case aiDetected:
        return 'AI detekce';
      case aiConfirmed:
        return 'AI potvrzeno';
      default:
        return 'Neznámý zdroj';
    }
  }
}