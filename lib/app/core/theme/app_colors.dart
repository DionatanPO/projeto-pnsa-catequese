import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const primary = Color(0xFF1A3A5C);
  static const primaryLight = Color(0xFF3A6A9A);
  static const secondary = Color(0xFFC8A84E);
  static const tertiary = Color(0xFF4A8C6F);
  static const error = Color(0xFFBA1A1A);
  static const surface = Color(0xFFFCFCFF);
  static const onPrimary = Color(0xFFFFFFFF);
  static const onSecondary = Color(0xFFFFFFFF);
  static const onSurface = Color(0xFF1A1C1E);
  static const onSurfaceVariant = Color(0xFF6B7280);

  static const Color primaryContainer = Color(0xFFD4E3FF);
  static const Color secondaryContainer = Color(0xFFFFEAB3);
  static const Color tertiaryContainer = Color(0xFFCEE8D5);

  static const Color onError = Color(0xFFFFFFFF);
  static const Color onErrorDark = Color(0xFF690005);

  static ColorScheme get lightColorScheme => const ColorScheme(
    brightness: Brightness.light,
    primary: primary,
    onPrimary: onPrimary,
    secondary: secondary,
    onSecondary: onSecondary,
    tertiary: tertiary,
    error: error,
    onError: onError,
    surface: surface,
    onSurface: onSurface,
    primaryContainer: primaryContainer,
    secondaryContainer: secondaryContainer,
    tertiaryContainer: tertiaryContainer,
    onPrimaryContainer: primary,
    onSecondaryContainer: Color(0xFF2D1F00),
    onTertiaryContainer: Color(0xFF002113),
  );

  static ColorScheme get darkColorScheme => const ColorScheme(
    brightness: Brightness.dark,
    primary: Color(0xFFA8C8FF),
    onPrimary: Color(0xFF00315D),
    secondary: Color(0xFFF5C542),
    onSecondary: Color(0xFF2D1F00),
    tertiary: Color(0xFFB2CCC0),
    error: Color(0xFFFFB4AB),
    onError: onErrorDark,
    surface: Color(0xFF1A1C1E),
    onSurface: Color(0xFFE2E2E6),
    primaryContainer: Color(0xFF1A3A5C),
    secondaryContainer: Color(0xFF4A3A00),
    tertiaryContainer: Color(0xFF1B3C30),
    onPrimaryContainer: Color(0xFFD4E3FF),
    onSecondaryContainer: Color(0xFFFFEAB3),
    onTertiaryContainer: Color(0xFFCEE8D5),
  );
}
