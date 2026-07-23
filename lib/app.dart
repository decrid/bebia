import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'core/app_services.dart';
import 'core/design/bebia_theme.dart';
import 'core/settings/bebia_preferences.dart';
import 'shared/widgets/app_shell.dart';

class BebiaApp extends StatelessWidget {
  const BebiaApp({
    super.key,
    this.homeOverride,
    this.settingsController,
    this.shellScreensOverride,
  }) : assert(
         homeOverride == null || shellScreensOverride == null,
         'homeOverride and shellScreensOverride cannot be used together.',
       );

  final Widget? homeOverride;
  final BebiaSettingsController? settingsController;
  final List<Widget>? shellScreensOverride;

  ThemeMode _themeMode(BebiaAppearance appearance) {
    return switch (appearance) {
      BebiaAppearance.system => ThemeMode.system,
      BebiaAppearance.light => ThemeMode.light,
      BebiaAppearance.dark => ThemeMode.dark,
    };
  }

  @override
  Widget build(BuildContext context) {
    final profileController = AppServices.childProfileController;
    final settings = settingsController ?? BebiaSettingsController.instance;

    return AnimatedBuilder(
      animation: Listenable.merge(<Listenable>[
        profileController.profiles,
        profileController.activeProfileId,
        settings,
      ]),
      builder: (context, child) {
        final preferences = settings.preferences;
        final profileSex = profileController.activeProfile?.sex;
        return MaterialApp(
          title: 'Bebia',
          debugShowCheckedModeBanner: false,
          theme: BebiaTheme.light(
            profileSex: profileSex,
            preferences: preferences,
          ),
          darkTheme: BebiaTheme.dark(
            profileSex: profileSex,
            preferences: preferences,
          ),
          themeMode: _themeMode(preferences.appearance),
          themeAnimationDuration: BebiaMotion.resolve(
            BebiaMotion.standard,
            reduceMotion: preferences.reduceMotion,
          ),
          themeAnimationCurve: BebiaMotion.enter,
          builder: (context, appChild) {
            final theme = Theme.of(context);
            final isDark = theme.brightness == Brightness.dark;
            return AnnotatedRegion<SystemUiOverlayStyle>(
              value: SystemUiOverlayStyle(
                statusBarColor: Colors.transparent,
                statusBarIconBrightness: isDark
                    ? Brightness.light
                    : Brightness.dark,
                statusBarBrightness: isDark
                    ? Brightness.dark
                    : Brightness.light,
                systemNavigationBarColor: theme.colorScheme.surface,
                systemNavigationBarIconBrightness: isDark
                    ? Brightness.light
                    : Brightness.dark,
                systemNavigationBarDividerColor: Colors.transparent,
              ),
              child: appChild ?? const SizedBox.shrink(),
            );
          },
          home:
              homeOverride ??
              AppShell(
                screensOverride: shellScreensOverride,
                settingsController: settings,
              ),
        );
      },
    );
  }
}
