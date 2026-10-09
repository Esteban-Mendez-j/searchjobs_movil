import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const background = Color(0xFFF7F6FF);
  static const surface = Colors.white;
  static const primary = Color(0xFF1E40AF);
  static const primaryDark = Color(0xFF0A2A8F);
  static const accent = Color(0xFF2563EB);
  static const chip = Color(0xFFE0E4FF);
  static const field = Color(0xFFE8EBFF);
  static const textPrimary = Color(0xFF111827);
  static const textSecondary = Color(0xFF4B5563);
  static const textMuted = Color(0xFF9CA3AF);
  static const danger = Color(0xFFB91C1C);
  static const dangerSoft = Color(0xFFFEE2E2);
  static const grid = Color(0x1A4F46E5);

  static const series = <Color>[
    Color(0xFF0A2A8F),
    Color(0xFF2F6BFF),
    Color(0xFF0891B2),
    Color(0xFF6366F1),
    Color(0xFF64748B),
  ];

  static Color seriesColor(int i) => series[i % series.length];
}

class AppTextStyles {
  AppTextStyles._();

  static TextStyle mono(
          {double size = 12,
          Color color = AppColors.textSecondary,
          FontWeight weight = FontWeight.w500}) =>
      TextStyle(
          fontFamily: 'monospace',
          fontSize: size,
          color: color,
          fontWeight: weight);
}

class AppTheme {
  AppTheme._();

  static ThemeData get light => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
            seedColor: AppColors.primary, surface: AppColors.surface),
        scaffoldBackgroundColor: AppColors.background,
        textTheme: ThemeData.light().textTheme.apply(
              bodyColor: AppColors.textPrimary,
              displayColor: AppColors.textPrimary,
            ),
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: Colors.white,
          indicatorColor: AppColors.chip,
          labelTextStyle: WidgetStateProperty.all(
              const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
        ),
      );
}
