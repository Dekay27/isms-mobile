import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color primaryBlue = Color(0xFF696CFF);
  static const Color secondaryBlue = Color(0xFF03C3EC);
  static const Color surfaceTint = Color(0xFFE7E7FF);

  static ThemeData materialLight() {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: primaryBlue,
        onPrimary: Colors.white,
        secondary: secondaryBlue,
        onSecondary: Colors.white,
        surface: Colors.white,
        onSurface: Color(0xFF2A2B3F),
      ),
      scaffoldBackgroundColor: const Color(0xFFF5F5F9),
      cardTheme: const CardThemeData(
        elevation: 0,
        color: Colors.white,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(14)),
          side: BorderSide(color: Color(0x1A696CFF)),
        ),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          borderSide: BorderSide(color: Color(0x33696CFF)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          borderSide: BorderSide(color: primaryBlue, width: 1.5),
        ),
      ),
    );

    final textTheme = GoogleFonts.plusJakartaSansTextTheme(base.textTheme);

    return base.copyWith(
      textTheme: textTheme,
      cupertinoOverrideTheme: cupertinoLight(),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: <TargetPlatform, PageTransitionsBuilder>{
          TargetPlatform.android: PredictiveBackPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.linux: FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.windows: FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.fuchsia: FadeUpwardsPageTransitionsBuilder(),
        },
      ),
    );
  }

  static CupertinoThemeData cupertinoLight() {
    final text = GoogleFonts.plusJakartaSansTextTheme();

    return const CupertinoThemeData(
      brightness: Brightness.light,
      primaryColor: primaryBlue,
      barBackgroundColor: Color(0xFFF5F5F9),
      scaffoldBackgroundColor: Color(0xFFF5F5F9),
    ).copyWith(
      textTheme: CupertinoTextThemeData(
        textStyle: text.bodyMedium,
        actionTextStyle: text.labelLarge?.copyWith(color: primaryBlue),
        navTitleTextStyle: text.titleLarge?.copyWith(
          fontWeight: FontWeight.w700,
        ),
        navLargeTitleTextStyle: text.headlineSmall?.copyWith(
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
