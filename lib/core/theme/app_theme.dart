import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';
import '../constants/app_typography.dart';

/// Conjunto tipado dos 14 tokens — alimenta o construtor único de tema.
/// Os valores vêm SEMPRE das classes estáticas de `app_colors.dart`.
typedef _Tokens = ({
  Color primary,
  Color primaryContainer,
  Color onPrimary,
  Color onPrimaryContainer,
  Color secondary,
  Color background,
  Color surface,
  Color textPrimary,
  Color textSecondary,
  Color success,
  Color warning,
  Color error,
  Color border,
  Color overlay,
});

/// Dois `ThemeData` Material 3 construídos EXCLUSIVAMENTE a partir dos
/// tokens de `app_colors.dart` (plano §3.3 / RN-04).
///
/// Seleção: `ThemeMode.system` é o default; override manual chega na F3 via
/// Ajustes. Alternar o tema escuro do sistema muda o app inteiro sem tocar
/// em nenhum widget.
abstract final class AppTheme {
  static ThemeData light() => _build(Brightness.light, (
    primary: AppColorsLight.colorPrimary,
    primaryContainer: AppColorsLight.colorPrimaryContainer,
    onPrimary: AppColorsLight.colorOnPrimary,
    onPrimaryContainer: AppColorsLight.colorOnPrimaryContainer,
    secondary: AppColorsLight.colorSecondary,
    background: AppColorsLight.colorBackground,
    surface: AppColorsLight.colorSurface,
    textPrimary: AppColorsLight.colorTextPrimary,
    textSecondary: AppColorsLight.colorTextSecondary,
    success: AppColorsLight.colorSuccess,
    warning: AppColorsLight.colorWarning,
    error: AppColorsLight.colorError,
    border: AppColorsLight.colorBorder,
    overlay: AppColorsLight.colorOverlay,
  ));

  static ThemeData dark() => _build(Brightness.dark, (
    primary: AppColorsDark.colorPrimary,
    primaryContainer: AppColorsDark.colorPrimaryContainer,
    onPrimary: AppColorsDark.colorOnPrimary,
    onPrimaryContainer: AppColorsDark.colorOnPrimaryContainer,
    secondary: AppColorsDark.colorSecondary,
    background: AppColorsDark.colorBackground,
    surface: AppColorsDark.colorSurface,
    textPrimary: AppColorsDark.colorTextPrimary,
    textSecondary: AppColorsDark.colorTextSecondary,
    success: AppColorsDark.colorSuccess,
    warning: AppColorsDark.colorWarning,
    error: AppColorsDark.colorError,
    border: AppColorsDark.colorBorder,
    overlay: AppColorsDark.colorOverlay,
  ));

  static ThemeData _build(Brightness brightness, _Tokens c) {
    final scheme = ColorScheme(
      brightness: brightness,
      primary: c.primary,
      onPrimary: c.onPrimary,
      primaryContainer: c.primaryContainer,
      onPrimaryContainer: c.onPrimaryContainer,
      secondary: c.secondary,
      onSecondary: c.onPrimary,
      secondaryContainer: c.primaryContainer,
      onSecondaryContainer: c.onPrimaryContainer,
      error: c.error,
      onError: c.onPrimary,
      surface: c.surface,
      onSurface: c.textPrimary,
      surfaceContainerHighest: c.border,
      onSurfaceVariant: c.textSecondary,
      outline: c.border,
      outlineVariant: c.border,
      shadow: c.overlay,
      scrim: c.overlay,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: c.background,
      textTheme: AppTypography.textTheme(),
      appBarTheme: AppBarTheme(
        backgroundColor: c.background,
        foregroundColor: c.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: AppTypography.titleLarge.copyWith(color: c.textPrimary),
      ),
      cardTheme: CardThemeData(
        color: c.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radius),
          side: BorderSide(color: c.border),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: c.primary,
          foregroundColor: c.onPrimary,
          minimumSize: const Size(64, AppSpacing.minTouchTarget),
          textStyle: AppTypography.labelLarge,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radius),
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: c.primary,
          foregroundColor: c.onPrimary,
          minimumSize: const Size(64, AppSpacing.minTouchTarget),
          textStyle: AppTypography.labelLarge,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radius),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: c.surface,
        hintStyle: AppTypography.bodyLarge.copyWith(color: c.textSecondary),
        counterStyle: AppTypography.labelMedium.copyWith(
          color: c.textSecondary,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radius),
          borderSide: BorderSide(color: c.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radius),
          borderSide: BorderSide(color: c.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radius),
          borderSide: BorderSide(color: c.primary, width: 2),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: c.textPrimary,
        contentTextStyle: AppTypography.bodyMedium.copyWith(
          color: c.background,
        ),
        actionTextColor: c.primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radius),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: c.surface,
        indicatorColor: c.primaryContainer,
        height: 64,
        labelTextStyle: WidgetStatePropertyAll(
          AppTypography.labelMedium.copyWith(color: c.textPrimary),
        ),
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            color: states.contains(WidgetState.selected)
                ? c.onPrimaryContainer
                : c.textSecondary,
          ),
        ),
      ),
      dividerTheme: DividerThemeData(color: c.border),
      dialogTheme: DialogThemeData(
        backgroundColor: c.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radius),
        ),
      ),
    );
  }
}
