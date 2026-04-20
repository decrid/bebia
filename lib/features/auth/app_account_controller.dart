import 'package:flutter/foundation.dart';

import 'app_account_provider.dart';
import 'app_account_session.dart';

class AppAccountController {
  final ValueNotifier<AppAccountSession> session =
      ValueNotifier<AppAccountSession>(AppAccountSession.initial());
  final ValueNotifier<bool> isLoading = ValueNotifier<bool>(false);
  final ValueNotifier<String?> error = ValueNotifier<String?>(null);

  bool get isConfigured => session.value.isConfigured;

  Future<void> markBackendConfigured({
    required List<AppAccountProvider> supportedProviders,
  }) async {
    session.value = session.value.copyWith(
      isConfigured: true,
      supportedProviders: supportedProviders,
    );
  }

  Future<void> signInPreview(AppAccountProvider provider) async {
    isLoading.value = true;
    error.value = null;

    try {
      final displayName = switch (provider) {
        AppAccountProvider.google => 'Rodič přes Google',
        AppAccountProvider.apple => 'Rodič přes Apple',
        AppAccountProvider.email => 'Rodič přes e-mail',
      };

      session.value = session.value.copyWith(
        user: AppAccountUser(
          id: 'preview-${provider.name}',
          displayName: displayName,
          providers: [provider],
        ),
      );

      if (!session.value.isConfigured) {
        error.value =
            'Ukázkový účet byl vytvořen jen lokálně. Ostré přihlášení se zapne po dopojení Firebase.';
      }
    } finally {
      isLoading.value = false;
    }
  }

  void signOutPreview() {
    error.value = null;
    session.value = session.value.copyWith(clearUser: true);
  }

  void dispose() {
    session.dispose();
    isLoading.dispose();
    error.dispose();
  }
}
