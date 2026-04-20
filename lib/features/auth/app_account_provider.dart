enum AppAccountProvider { google, apple, email }

extension AppAccountProviderLabel on AppAccountProvider {
  String get label {
    switch (this) {
      case AppAccountProvider.google:
        return 'Google';
      case AppAccountProvider.apple:
        return 'Apple';
      case AppAccountProvider.email:
        return 'E-mail';
    }
  }
}
