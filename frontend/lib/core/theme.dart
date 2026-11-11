import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Paleta do EcoScan v2 (mesmos tokens do Figma).
class AppColors {
  static const bg = Color(0xFFF7F8F4);
  static const surface = Color(0xFFFFFFFF);
  static const ink = Color(0xFF13241A);
  static const muted = Color(0xFF6E7A72);
  static const line = Color(0xFFE9ECE4);
  static const primary = Color(0xFF0F3D2A);
  static const primarySoft = Color(0xFFE8F0E2);
  static const accent = Color(0xFFB9D46E);
  static const accentSoft = Color(0xFFF1F6E1);
  static const danger = Color(0xFFB4432A);
  static const dangerSoft = Color(0xFFFBEEE9);
  static const warn = Color(0xFF946512);
  static const warnSoft = Color(0xFFFAF2DF);
  static const subtle = Color(0xFFF0F2EC);
  static const leaf = Color(0xFF7A9A48);
  static const leafDark = Color(0xFF557A34);
  static const dark = Color(0xFF0E1A13);
  static const white70 = Color(0xB3FFFFFF);
  static const white15 = Color(0x26FFFFFF);
  static const white10 = Color(0x1AFFFFFF);
}

class AppShadows {
  static const soft = [
    BoxShadow(color: Color(0x0F0F3D2A), blurRadius: 20, offset: Offset(0, 4)),
  ];
  static const top = [
    BoxShadow(color: Color(0x0D0F3D2A), blurRadius: 16, offset: Offset(0, -4)),
  ];
}

class AppText {
  static TextStyle t(double size, FontWeight weight, Color color,
          {double ls = 0, double? height}) =>
      GoogleFonts.plusJakartaSans(
        fontSize: size,
        fontWeight: weight,
        color: color,
        letterSpacing: ls,
        height: height,
      );

  static TextStyle get display => t(30, FontWeight.w700, AppColors.ink, ls: -0.8, height: 1.15);
  static TextStyle get title => t(20, FontWeight.w700, AppColors.ink, ls: -0.4);
  static TextStyle get section => t(17, FontWeight.w700, AppColors.ink);
  static TextStyle get body => t(15, FontWeight.w400, AppColors.ink, height: 1.4);
  static TextStyle get bodyStrong => t(15, FontWeight.w600, AppColors.ink);
  static TextStyle get caption => t(13, FontWeight.w400, AppColors.muted, height: 1.35);
  static TextStyle get label => t(13, FontWeight.w600, AppColors.muted);
}

ThemeData buildTheme() {
  final base = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      primary: AppColors.primary,
      surface: AppColors.surface,
    ),
    scaffoldBackgroundColor: AppColors.bg,
  );
  return base.copyWith(
    textTheme: GoogleFonts.plusJakartaSansTextTheme(base.textTheme)
        .apply(bodyColor: AppColors.ink, displayColor: AppColors.ink),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: AppColors.primary,
      contentTextStyle: AppText.t(14, FontWeight.w500, Colors.white),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: AppColors.surface,
      showDragHandle: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
    ),
  );
}
