import 'app_account_provider.dart';

class AppAccountUser {
  const AppAccountUser({
    required this.id,
    required this.displayName,
    required this.providers,
  });

  final String id;
  final String displayName;
  final List<AppAccountProvider> providers;
}

class AppAccountSession {
  const AppAccountSession({
    required this.user,
    required this.isConfigured,
    required this.supportedProviders,
  });

  final AppAccountUser? user;
  final bool isConfigured;
  final List<AppAccountProvider> supportedProviders;

  bool get isSignedIn => user != null;
  bool get isPreviewMode => isSignedIn && !isConfigured;

  AppAccountSession copyWith({
    AppAccountUser? user,
    bool clearUser = false,
    bool? isConfigured,
    List<AppAccountProvider>? supportedProviders,
  }) {
    return AppAccountSession(
      user: clearUser ? null : (user ?? this.user),
      isConfigured: isConfigured ?? this.isConfigured,
      supportedProviders: supportedProviders ?? this.supportedProviders,
    );
  }

  factory AppAccountSession.initial() {
    return const AppAccountSession(
      user: null,
      isConfigured: false,
      supportedProviders: [
        AppAccountProvider.google,
        AppAccountProvider.apple,
        AppAccountProvider.email,
      ],
    );
  }
}
