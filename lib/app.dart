import 'package:flutter/material.dart';

import 'core/app_services.dart';
import 'shared/widgets/app_shell.dart';

class BebiaApp extends StatelessWidget {
  const BebiaApp({super.key, this.homeOverride});

  final Widget? homeOverride;

  @override
  Widget build(BuildContext context) {
    final profileController = AppServices.childProfileController;

    return AnimatedBuilder(
      animation: Listenable.merge([
        profileController.profiles,
        profileController.activeProfileId,
      ]),
      builder: (context, child) {
        final palette = _BebiaPalette.fromSex(
          profileController.activeProfile?.sex,
        );
        final colorScheme = ColorScheme.fromSeed(
          seedColor: palette.seed,
          brightness: Brightness.light,
          surface: palette.surface,
        );

        return MaterialApp(
          title: 'Bebia',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: colorScheme,
            scaffoldBackgroundColor: palette.scaffold,
            appBarTheme: AppBarTheme(
              backgroundColor: Colors.transparent,
              foregroundColor: colorScheme.onSurface,
              elevation: 0,
              centerTitle: false,
              titleTextStyle: TextStyle(
                color: colorScheme.onSurface,
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
            cardTheme: CardThemeData(
              elevation: 0,
              color: Colors.white,
              surfaceTintColor: Colors.transparent,
              margin: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
                side: BorderSide(
                  color: colorScheme.outlineVariant.withValues(alpha: 0.22),
                ),
              ),
            ),
            navigationBarTheme: NavigationBarThemeData(
              backgroundColor: Colors.white,
              indicatorColor: colorScheme.primaryContainer.withValues(
                alpha: 0.9,
              ),
              height: 68,
              surfaceTintColor: Colors.transparent,
              labelTextStyle: WidgetStateProperty.resolveWith((states) {
                final selected = states.contains(WidgetState.selected);
                return TextStyle(
                  fontSize: 12,
                  fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                );
              }),
            ),
            chipTheme: ChipThemeData(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(999),
              ),
              side: BorderSide(
                color: colorScheme.outlineVariant.withValues(alpha: 0.22),
              ),
              backgroundColor: Colors.white,
              surfaceTintColor: Colors.transparent,
              labelStyle: TextStyle(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
            inputDecorationTheme: InputDecorationTheme(
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: BorderSide(
                  color: colorScheme.outlineVariant.withValues(alpha: 0.35),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: BorderSide(
                  color: colorScheme.outlineVariant.withValues(alpha: 0.35),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: BorderSide(color: colorScheme.primary, width: 1.4),
              ),
            ),
            floatingActionButtonTheme: FloatingActionButtonThemeData(
              elevation: 0,
              highlightElevation: 0,
              backgroundColor: palette.fab,
              foregroundColor: palette.onFab,
              extendedTextStyle: const TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 16,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
            bottomSheetTheme: const BottomSheetThemeData(
              backgroundColor: Colors.transparent,
              surfaceTintColor: Colors.transparent,
            ),
          ),
          home: child,
        );
      },
      child: homeOverride ?? const AppShell(),
    );
  }
}

class _BebiaPalette {
  const _BebiaPalette({
    required this.seed,
    required this.surface,
    required this.scaffold,
    required this.fab,
    required this.onFab,
  });

  final Color seed;
  final Color surface;
  final Color scaffold;
  final Color fab;
  final Color onFab;

  factory _BebiaPalette.fromSex(String? sex) {
    switch (sex) {
      case 'boy':
        return const _BebiaPalette(
          seed: Color(0xFF257C9F),
          surface: Color(0xFFFCFCFA),
          scaffold: Color(0xFFF3F7FA),
          fab: Color(0xFFA9DFF2),
          onFab: Color(0xFF103747),
        );
      case 'girl':
        return const _BebiaPalette(
          seed: Color(0xFFC76B8A),
          surface: Color(0xFFFFFCFC),
          scaffold: Color(0xFFFAF4F6),
          fab: Color(0xFFF5B8C9),
          onFab: Color(0xFF4B1F2C),
        );
      default:
        return const _BebiaPalette(
          seed: Color(0xFF7A8F78),
          surface: Color(0xFFFCFCFA),
          scaffold: Color(0xFFF7F6F2),
          fab: Color(0xFFD5E7D1),
          onFab: Color(0xFF243522),
        );
    }
  }
}
