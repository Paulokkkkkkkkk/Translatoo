import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:translatoo/core/constants/app_colors.dart';

/// Trava de acessibilidade da paleta (WCAG 2.1 §1.4.3 / PRD §6.2).
///
/// A paleta verde original reprovava aqui: branco sobre a primária dava 3,30:1
/// no tema claro e 1,74:1 no escuro. O teste existe para que uma próxima troca
/// de identidade não reintroduza o problema em silêncio.
void main() {
  double channelLinear(int c) {
    final double v = c / 255;
    return v <= 0.04045
        ? v / 12.92
        : math.pow((v + 0.055) / 1.055, 2.4) as double;
  }

  double luminance(Color c) {
    final int argb = c.toARGB32();
    return 0.2126 * channelLinear((argb >> 16) & 0xFF) +
        0.7152 * channelLinear((argb >> 8) & 0xFF) +
        0.0722 * channelLinear(argb & 0xFF);
  }

  double contrast(Color a, Color b) {
    final double la = luminance(a);
    final double lb = luminance(b);
    final double hi = math.max(la, lb);
    final double lo = math.min(la, lb);
    return (hi + 0.05) / (lo + 0.05);
  }

  /// Pares em que o primeiro é texto e o segundo é o fundo sobre o qual ele cai.
  List<(String, Color, Color)> pairsOf({
    required Color primary,
    required Color primaryContainer,
    required Color onPrimary,
    required Color onPrimaryContainer,
    required Color secondary,
    required Color background,
    required Color surface,
    required Color textPrimary,
    required Color textSecondary,
    required Color success,
    required Color warning,
    required Color error,
  }) => <(String, Color, Color)>[
    ('onPrimary sobre primary', onPrimary, primary),
    ('onPrimary sobre secondary', onPrimary, secondary),
    (
      'onPrimaryContainer sobre primaryContainer',
      onPrimaryContainer,
      primaryContainer,
    ),
    ('textPrimary sobre surface', textPrimary, surface),
    ('textPrimary sobre background', textPrimary, background),
    ('textSecondary sobre surface', textSecondary, surface),
    ('textSecondary sobre background', textSecondary, background),
    ('primary sobre surface', primary, surface),
    ('primary sobre background', primary, background),
    ('success sobre surface', success, surface),
    ('warning sobre surface', warning, surface),
    ('error sobre surface', error, surface),
  ];

  const double aaNormalText = 4.5;

  final Map<String, List<(String, Color, Color)>> palettes = {
    'light': pairsOf(
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
    ),
    'dark': pairsOf(
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
    ),
  };

  // OBJETOS GRÁFICOS têm outro limiar: a WCAG 2.1 SC 1.4.11 pede 3:1 para
  // elementos não-textuais, não os 4,5:1 de texto. Manter os dois no mesmo
  // balde reprovaria desenho correto — ou, pior, empurraria alguém a baixar o
  // limiar de TEXTO para caber um ponto de 8 dp.
  const double aaNonText = 3.0;

  final Map<String, List<(String, Color, Color)>> graphicalPalettes = {
    'light': <(String, Color, Color)>[
      // Ponto do ConnectionBadge, no chip sobre o bloco de marca (§5.6 · §8).
      (
        'ponto success sobre primaryContainer',
        AppColorsLight.colorSuccess,
        AppColorsLight.colorPrimaryContainer,
      ),
    ],
    'dark': <(String, Color, Color)>[
      (
        'ponto success sobre primaryContainer',
        AppColorsDark.colorSuccess,
        AppColorsDark.colorPrimaryContainer,
      ),
    ],
  };

  graphicalPalettes.forEach((String name, List<(String, Color, Color)> pairs) {
    group('paleta $name — objetos gráficos', () {
      for (final (String label, Color fg, Color bg) in pairs) {
        test('$label atinge AA para não-texto', () {
          expect(
            contrast(fg, bg),
            greaterThanOrEqualTo(aaNonText),
            reason:
                '$label ficou em ${contrast(fg, bg).toStringAsFixed(2)}:1 '
                '(mínimo $aaNonText:1 — WCAG 2.1 SC 1.4.11)',
          );
        });
      }
    });
  });

  palettes.forEach((String name, List<(String, Color, Color)> pairs) {
    group('paleta $name', () {
      for (final (String label, Color fg, Color bg) in pairs) {
        test('$label atinge AA para texto normal', () {
          expect(
            contrast(fg, bg),
            greaterThanOrEqualTo(aaNormalText),
            reason:
                '$label ficou em ${contrast(fg, bg).toStringAsFixed(2)}:1 '
                '(mínimo $aaNormalText:1 — WCAG 2.1 AA)',
          );
        });
      }
    });
  });
}
