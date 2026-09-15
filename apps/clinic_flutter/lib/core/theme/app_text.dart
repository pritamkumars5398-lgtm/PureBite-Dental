import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Type scale from docs/02-design-tokens.md. Uses the platform UI font
/// (no runtime Google Fonts download — that is blocked by the macOS sandbox).
abstract final class AppText {
  static TextTheme light() => _scale(AppColors.text, AppColors.textMuted);

  static TextTheme dark() => _scale(AppColors.textDark, AppColors.textMutedDark);

  static TextTheme _scale(Color body, Color muted) {
    TextStyle style({
      required double size,
      required double height,
      required FontWeight weight,
      double letterSpacing = 0,
      Color? color,
    }) {
      return TextStyle(
        fontSize: size,
        height: height,
        fontWeight: weight,
        letterSpacing: letterSpacing,
        color: color ?? body,
      );
    }

    return TextTheme(
      displayLarge: style(
        size: 28,
        height: 1.15,
        weight: FontWeight.w700,
        letterSpacing: -0.4,
      ),
      headlineLarge: style(
        size: 22,
        height: 1.25,
        weight: FontWeight.w700,
        letterSpacing: -0.25,
      ),
      headlineMedium: style(
        size: 18,
        height: 1.30,
        weight: FontWeight.w600,
        letterSpacing: -0.15,
      ),
      headlineSmall: style(size: 15, height: 1.35, weight: FontWeight.w600),
      bodyLarge: style(size: 15, height: 1.55, weight: FontWeight.w400),
      bodyMedium: style(size: 14, height: 1.50, weight: FontWeight.w400),
      labelLarge: style(size: 14, height: 1.20, weight: FontWeight.w600),
      labelMedium: style(size: 14, height: 1.30, weight: FontWeight.w500),
      labelSmall: style(
        size: 12,
        height: 1.40,
        weight: FontWeight.w500,
        letterSpacing: 0.1,
        color: muted,
      ),
      bodySmall: style(
        size: 11,
        height: 1.30,
        weight: FontWeight.w600,
        letterSpacing: 0.2,
        color: muted,
      ),
    );
  }
}
