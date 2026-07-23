import 'package:flutter/material.dart';

import '../settings/bebia_preferences.dart';

abstract final class BebiaColors {
  static const Color sage = Color(0xFF39735E);
  static const Color sageBright = Color(0xFF65A88B);
  static const Color rose = Color(0xFFB95E79);
  static const Color sky = Color(0xFF3D7F9C);
  static const Color feeding = Color(0xFFE27A62);
  static const Color sleep = Color(0xFF6670B8);
  static const Color diaper = Color(0xFF4C9475);
  static const Color crying = Color(0xFFD49A42);
  static const Color danger = Color(0xFFB94747);
  static const Color lightCanvas = Color(0xFFF5F5F0);
  static const Color darkCanvas = Color(0xFF101815);
  static const Color darkSurface = Color(0xFF18231F);
}

abstract final class BebiaSpace {
  static const double xxs = 4;
  static const double xs = 8;
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 40;
}

abstract final class BebiaRadius {
  static const double small = 12;
  static const double medium = 18;
  static const double large = 26;
  static const double hero = 34;
  static const double pill = 999;
}

abstract final class BebiaIconSize {
  static const double small = 18;
  static const double regular = 24;
  static const double large = 30;
  static const double hero = 40;
}

abstract final class BebiaBreakpoints {
  static const double compact = 600;
  static const double expanded = 900;
  static const double contentMaxWidth = 760;
}

abstract final class BebiaMotion {
  static const Duration fast = Duration(milliseconds: 140);
  static const Duration standard = Duration(milliseconds: 240);
  static const Duration slow = Duration(milliseconds: 360);
  static const Curve enter = Curves.easeOutCubic;
  static const Curve exit = Curves.easeInCubic;

  static Duration resolve(Duration duration, {required bool reduceMotion}) =>
      reduceMotion ? Duration.zero : duration;
}

abstract final class BebiaMetrics {
  static const double minimumTouchTarget = 48;
}

@immutable
class BebiaVisuals extends ThemeExtension<BebiaVisuals> {
  const BebiaVisuals({
    required this.feeding,
    required this.sleep,
    required this.diaper,
    required this.crying,
    required this.success,
    required this.warning,
    required this.danger,
    required this.mutedText,
    required this.heroGradient,
    required this.cardShadow,
    required this.reduceMotion,
  });

  final Color feeding;
  final Color sleep;
  final Color diaper;
  final Color crying;
  final Color success;
  final Color warning;
  final Color danger;
  final Color mutedText;
  final LinearGradient heroGradient;
  final List<BoxShadow> cardShadow;
  final bool reduceMotion;

  @override
  BebiaVisuals copyWith({
    Color? feeding,
    Color? sleep,
    Color? diaper,
    Color? crying,
    Color? success,
    Color? warning,
    Color? danger,
    Color? mutedText,
    LinearGradient? heroGradient,
    List<BoxShadow>? cardShadow,
    bool? reduceMotion,
  }) {
    return BebiaVisuals(
      feeding: feeding ?? this.feeding,
      sleep: sleep ?? this.sleep,
      diaper: diaper ?? this.diaper,
      crying: crying ?? this.crying,
      success: success ?? this.success,
      warning: warning ?? this.warning,
      danger: danger ?? this.danger,
      mutedText: mutedText ?? this.mutedText,
      heroGradient: heroGradient ?? this.heroGradient,
      cardShadow: cardShadow ?? this.cardShadow,
      reduceMotion: reduceMotion ?? this.reduceMotion,
    );
  }

  @override
  BebiaVisuals lerp(covariant BebiaVisuals? other, double t) {
    if (other == null) return this;
    return BebiaVisuals(
      feeding: Color.lerp(feeding, other.feeding, t)!,
      sleep: Color.lerp(sleep, other.sleep, t)!,
      diaper: Color.lerp(diaper, other.diaper, t)!,
      crying: Color.lerp(crying, other.crying, t)!,
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
      mutedText: Color.lerp(mutedText, other.mutedText, t)!,
      heroGradient: LinearGradient.lerp(heroGradient, other.heroGradient, t)!,
      cardShadow: t < 0.5 ? cardShadow : other.cardShadow,
      reduceMotion: t < 0.5 ? reduceMotion : other.reduceMotion,
    );
  }
}

extension BebiaThemeContext on BuildContext {
  BebiaVisuals get bebia => Theme.of(this).extension<BebiaVisuals>()!;
}

abstract final class BebiaTheme {
  static ThemeData light({
    required String? profileSex,
    required BebiaPreferences preferences,
  }) {
    return _build(
      brightness: Brightness.light,
      profileSex: profileSex,
      preferences: preferences,
    );
  }

  static ThemeData dark({
    required String? profileSex,
    required BebiaPreferences preferences,
  }) {
    return _build(
      brightness: Brightness.dark,
      profileSex: profileSex,
      preferences: preferences,
    );
  }

  static ThemeData _build({
    required Brightness brightness,
    required String? profileSex,
    required BebiaPreferences preferences,
  }) {
    final isDark = brightness == Brightness.dark;
    final seed = switch (profileSex) {
      'boy' => BebiaColors.sky,
      'girl' => BebiaColors.rose,
      _ => BebiaColors.sage,
    };
    final scheme = ColorScheme.fromSeed(
      seedColor: seed,
      brightness: brightness,
      surface: isDark ? BebiaColors.darkSurface : const Color(0xFFFFFEFA),
    );
    final typography = brightness == Brightness.dark
        ? Typography.material2021().white
        : Typography.material2021().black;
    final textTheme = typography.copyWith(
      displaySmall: typography.displaySmall?.copyWith(
        fontWeight: FontWeight.w800,
        height: 1.08,
        letterSpacing: -0.8,
      ),
      headlineMedium: typography.headlineMedium?.copyWith(
        fontWeight: FontWeight.w800,
        height: 1.12,
        letterSpacing: -0.45,
      ),
      headlineSmall: typography.headlineSmall?.copyWith(
        fontWeight: FontWeight.w800,
        height: 1.16,
        letterSpacing: -0.25,
      ),
      titleLarge: typography.titleLarge?.copyWith(
        fontWeight: FontWeight.w800,
        height: 1.2,
      ),
      titleMedium: typography.titleMedium?.copyWith(
        fontWeight: FontWeight.w700,
        height: 1.25,
      ),
      bodyLarge: typography.bodyLarge?.copyWith(height: 1.45),
      bodyMedium: typography.bodyMedium?.copyWith(height: 1.45),
      labelLarge: typography.labelLarge?.copyWith(
        fontWeight: FontWeight.w800,
        letterSpacing: 0.1,
      ),
    );
    final visuals = BebiaVisuals(
      feeding: isDark ? const Color(0xFFFFA18B) : BebiaColors.feeding,
      sleep: isDark ? const Color(0xFFAEB6FF) : BebiaColors.sleep,
      diaper: isDark ? const Color(0xFF7FC7A7) : BebiaColors.diaper,
      crying: isDark ? const Color(0xFFF0BE6D) : BebiaColors.crying,
      success: isDark ? const Color(0xFF72C79D) : const Color(0xFF287A56),
      warning: isDark ? const Color(0xFFF0BE6D) : const Color(0xFF9A6418),
      danger: isDark ? const Color(0xFFFF8C8C) : BebiaColors.danger,
      mutedText: isDark ? const Color(0xFFB4C2BB) : const Color(0xFF5D6C65),
      heroGradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: isDark
            ? <Color>[seed.withValues(alpha: 0.5), BebiaColors.darkSurface]
            : <Color>[seed.withValues(alpha: 0.24), const Color(0xFFFFF8EC)],
      ),
      cardShadow: <BoxShadow>[
        BoxShadow(
          color: Colors.black.withValues(alpha: isDark ? 0.22 : 0.055),
          blurRadius: isDark ? 22 : 26,
          offset: const Offset(0, 10),
        ),
      ],
      reduceMotion: preferences.reduceMotion,
    );
    final compact = preferences.contentDensity == BebiaContentDensity.compact;

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: isDark
          ? BebiaColors.darkCanvas
          : BebiaColors.lightCanvas,
      canvasColor: isDark ? BebiaColors.darkCanvas : BebiaColors.lightCanvas,
      textTheme: textTheme,
      visualDensity: compact
          ? const VisualDensity(horizontal: -1, vertical: -1)
          : VisualDensity.standard,
      materialTapTargetSize: MaterialTapTargetSize.padded,
      extensions: <ThemeExtension<dynamic>>[visuals],
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        backgroundColor: Colors.transparent,
        foregroundColor: scheme.onSurface,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: textTheme.titleLarge?.copyWith(color: scheme.onSurface),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: scheme.surface,
        surfaceTintColor: Colors.transparent,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(BebiaRadius.large),
          side: BorderSide(color: scheme.outlineVariant.withValues(alpha: .5)),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: compact ? 64 : 70,
        elevation: 0,
        backgroundColor: scheme.surface,
        surfaceTintColor: Colors.transparent,
        indicatorColor: scheme.primaryContainer,
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            color: states.contains(WidgetState.selected)
                ? scheme.onPrimaryContainer
                : scheme.onSurfaceVariant,
          ),
        ),
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => TextStyle(
            color: states.contains(WidgetState.selected)
                ? scheme.onSurface
                : scheme.onSurfaceVariant,
            fontSize: 12,
            fontWeight: states.contains(WidgetState.selected)
                ? FontWeight.w800
                : FontWeight.w600,
          ),
        ),
      ),
      navigationRailTheme: NavigationRailThemeData(
        elevation: 0,
        backgroundColor: scheme.surface,
        indicatorColor: scheme.primaryContainer,
        useIndicator: true,
        selectedIconTheme: IconThemeData(color: scheme.onPrimaryContainer),
        unselectedIconTheme: IconThemeData(color: scheme.onSurfaceVariant),
        selectedLabelTextStyle: textTheme.labelMedium?.copyWith(
          color: scheme.onSurface,
          fontWeight: FontWeight.w800,
        ),
        unselectedLabelTextStyle: textTheme.labelMedium?.copyWith(
          color: scheme.onSurfaceVariant,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surface,
        contentPadding: EdgeInsets.symmetric(
          horizontal: BebiaSpace.md,
          vertical: compact ? BebiaSpace.sm : BebiaSpace.md,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(BebiaRadius.medium),
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(BebiaRadius.medium),
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(BebiaRadius.medium),
          borderSide: BorderSide(color: scheme.primary, width: 1.6),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(BebiaRadius.medium),
          borderSide: BorderSide(color: scheme.error),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          minimumSize: const Size(
            BebiaMetrics.minimumTouchTarget,
            BebiaMetrics.minimumTouchTarget,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: BebiaSpace.lg,
            vertical: BebiaSpace.md,
          ),
          textStyle: textTheme.labelLarge,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(BebiaRadius.medium),
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(
            BebiaMetrics.minimumTouchTarget,
            BebiaMetrics.minimumTouchTarget,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: BebiaSpace.lg,
            vertical: BebiaSpace.md,
          ),
          textStyle: textTheme.labelLarge,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(BebiaRadius.medium),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(
            BebiaMetrics.minimumTouchTarget,
            BebiaMetrics.minimumTouchTarget,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: BebiaSpace.lg,
            vertical: BebiaSpace.md,
          ),
          textStyle: textTheme.labelLarge,
          side: BorderSide(color: scheme.outlineVariant),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(BebiaRadius.medium),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          minimumSize: const Size(
            BebiaMetrics.minimumTouchTarget,
            BebiaMetrics.minimumTouchTarget,
          ),
          textStyle: textTheme.labelLarge,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(BebiaRadius.small),
          ),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        elevation: 0,
        highlightElevation: 1,
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
        extendedTextStyle: textTheme.labelLarge,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(BebiaRadius.medium),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: scheme.surface,
        selectedColor: scheme.primaryContainer,
        surfaceTintColor: Colors.transparent,
        side: BorderSide(color: scheme.outlineVariant),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(BebiaRadius.pill),
        ),
        labelStyle: textTheme.labelMedium,
        padding: const EdgeInsets.symmetric(
          horizontal: BebiaSpace.xs,
          vertical: BebiaSpace.xxs,
        ),
      ),
      dialogTheme: DialogThemeData(
        elevation: 0,
        backgroundColor: scheme.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(BebiaRadius.large),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        elevation: 0,
        modalElevation: 0,
        backgroundColor: scheme.surface,
        modalBackgroundColor: scheme.surface,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(BebiaRadius.hero),
          ),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        elevation: 0,
        backgroundColor: isDark
            ? scheme.surfaceContainerHighest
            : const Color(0xFF22352E),
        contentTextStyle: textTheme.bodyMedium?.copyWith(
          color: isDark ? scheme.onSurface : scheme.onInverseSurface,
          fontWeight: FontWeight.w600,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(BebiaRadius.medium),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: scheme.outlineVariant.withValues(alpha: .65),
        space: 1,
      ),
    );
  }
}
