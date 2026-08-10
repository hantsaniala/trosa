import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:trosa/const.dart';

/// Trosa theme.
///
/// The app's identity colour is the classic Trosa yellow (`#FECE00` — the
/// same value used by the Android splash screen). Flutter's Material 3
/// defaults wash light-yellow seeds out to a pale, barely-visible primary and
/// paint the AppBar with the surface colour, which is why the old yellow
/// "disappeared" after the v2 upgrade. This theme restores it explicitly:
/// the AppBar, the FAB and the primary accents are the full-strength brand
/// yellow, paired with a dark ink so text on yellow stays readable.
abstract final class AppTheme {
  /// The classic Trosa yellow (also `splash_color` on Android).
  static const Color brand = Color(0xFFFECE00);

  /// Slightly deeper gold used for the hero card gradient.
  static const Color brandDeep = Color(0xFFF0B400);

  /// Near-black warm ink that reads well on top of the brand yellow.
  static const Color ink = Color(0xFF241D00);

  static ThemeData light() => _build(
        // kPrimaryColor (const.dart) is the app's original yellow swatch.
        ColorScheme.fromSeed(seedColor: kPrimaryColor).copyWith(
          primary: brand,
          onPrimary: ink,
          primaryContainer: const Color(0xFFFFF1B8),
          onPrimaryContainer: const Color(0xFF3B2F00),
          secondary: const Color(0xFF9A7600),
          onSecondary: Colors.white,
          secondaryContainer: const Color(0xFFFFE08A),
          onSecondaryContainer: const Color(0xFF2E2300),
          // Pure-white "white mode": clean white surfaces with near-black
          // ink, cards and input fills in light neutrals so panels stay
          // subtly separated without the warm cream tint.
          surface: const Color(0xFFFFFFFF),
          onSurface: const Color(0xFF1C1A15),
          onSurfaceVariant: const Color(0xFF4E4B43),
          surfaceContainerLow: const Color(0xFFF7F6F1),
          surfaceContainerHighest: const Color(0xFFECEAE2),
          outline: const Color(0xFF7C7668),
        ),
      );

  static ThemeData dark() => _build(
        ColorScheme.fromSeed(seedColor: kPrimaryColor, brightness: Brightness.dark)
            .copyWith(
          primary: const Color(0xFFFFDB3D),
          onPrimary: const Color(0xFF2C2300),
          primaryContainer: const Color(0xFF4A3C00),
          onPrimaryContainer: const Color(0xFFFFE9A3),
          secondary: const Color(0xFFE4BE45),
          onSecondary: const Color(0xFF3C2F00),
          secondaryContainer: const Color(0xFF5C4A00),
          onSecondaryContainer: const Color(0xFFFFE9A3),
          surface: const Color(0xFF19150C),
          onSurface: const Color(0xFFEDE6D6),
          onSurfaceVariant: const Color(0xFFCFC6B0),
          outline: const Color(0xFF978E79),
        ),
      );

  static ThemeData _build(ColorScheme scheme) {
    final bool dark = scheme.brightness == Brightness.dark;
    return ThemeData(
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.surface,
      appBarTheme: AppBarTheme(
        // Brand yellow AppBar in both modes: the app's identity colour.
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: scheme.onPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.2,
        ),
        iconTheme: IconThemeData(color: scheme.onPrimary),
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: dark ? Brightness.dark : Brightness.light,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        color: scheme.surfaceContainerLow,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surfaceContainerHighest.withValues(alpha: 0.5),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: scheme.outlineVariant, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: scheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: scheme.error, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: scheme.error, width: 2),
        ),
        labelStyle: TextStyle(color: scheme.onSurfaceVariant),
        hintStyle: TextStyle(
          color: scheme.onSurfaceVariant.withValues(alpha: 0.8),
        ),
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        side: BorderSide(color: scheme.outlineVariant),
        backgroundColor: scheme.surface,
        selectedColor: scheme.primary,
        labelStyle: TextStyle(
          color: scheme.onSurface,
          fontWeight: FontWeight.w600,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        showCheckmark: false,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
        elevation: 2,
        focusElevation: 2,
        hoverElevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: scheme.inverseSurface,
        contentTextStyle: TextStyle(color: scheme.onInverseSurface),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: scheme.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        titleTextStyle: TextStyle(
          color: scheme.onSurface,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
        contentTextStyle:
            TextStyle(color: scheme.onSurfaceVariant, fontSize: 15),
      ),
      listTileTheme: ListTileThemeData(
        iconColor: scheme.onSurfaceVariant,
        textColor: scheme.onSurface,
      ),
      dividerTheme: DividerThemeData(color: scheme.outlineVariant),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: scheme.primary,
        selectionColor: scheme.primary.withValues(alpha: 0.35),
        selectionHandleColor: scheme.primary,
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(color: scheme.primary),
      popupMenuTheme: PopupMenuThemeData(
        color: scheme.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: TextStyle(color: scheme.onSurface),
      ),
    );
  }
}
