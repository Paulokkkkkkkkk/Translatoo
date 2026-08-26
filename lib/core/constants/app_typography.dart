import 'package:flutter/material.dart';

/// Tipografia base (display/title/body/label — plano §3.3).
///
/// As cores NÃO são definidas aqui: os estilos herdam a cor vigente do tema
/// (RN-04 — cor existe somente em `app_colors.dart`). Fonte: padrão da
/// plataforma (inclui fallback CJK adequado para 中文).
abstract final class AppTypography {
  // ── display ────────────────────────────────────────────────────────────
  static const TextStyle displayLarge = TextStyle(
    fontSize: 32,
    height: 1.25,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
  );

  static const TextStyle displaySmall = TextStyle(
    fontSize: 28,
    height: 1.29,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.25,
  );

  // ── title ──────────────────────────────────────────────────────────────
  static const TextStyle titleLarge = TextStyle(
    fontSize: 22,
    height: 1.27,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle titleMedium = TextStyle(
    fontSize: 18,
    height: 1.33,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle titleSmall = TextStyle(
    fontSize: 16,
    height: 1.38,
    fontWeight: FontWeight.w600,
  );

  // ── body ───────────────────────────────────────────────────────────────
  static const TextStyle bodyLarge = TextStyle(fontSize: 16, height: 1.5);

  static const TextStyle bodyMedium = TextStyle(fontSize: 14, height: 1.43);

  static const TextStyle bodySmall = TextStyle(fontSize: 12, height: 1.33);

  // ── label ──────────────────────────────────────────────────────────────
  static const TextStyle labelLarge = TextStyle(
    fontSize: 14,
    height: 1.14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.1,
  );

  static const TextStyle labelMedium = TextStyle(
    fontSize: 12,
    height: 1.33,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
  );

  static const TextStyle labelSmall = TextStyle(
    fontSize: 11,
    height: 1.45,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
  );

  /// Mapeia os estilos para o [TextTheme] Material 3.
  static TextTheme textTheme() => const TextTheme(
    displayLarge: displayLarge,
    displayMedium: displaySmall,
    headlineMedium: titleLarge,
    titleLarge: titleLarge,
    titleMedium: titleMedium,
    titleSmall: titleSmall,
    bodyLarge: bodyLarge,
    bodyMedium: bodyMedium,
    bodySmall: bodySmall,
    labelLarge: labelLarge,
    labelMedium: labelMedium,
    labelSmall: labelSmall,
  );
}
