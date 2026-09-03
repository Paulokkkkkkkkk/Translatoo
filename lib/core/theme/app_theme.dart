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

/// Cores semânticas que o `ColorScheme` do Material não tem slot próprio para
/// guardar.
///
/// A §6 do design system nomeia TRÊS exceções cromáticas: favorito
/// (`colorWarning`), gravação (`colorError`) e sucesso (`colorSuccess`). Só o
/// erro existe no `ColorScheme`; as outras duas ficavam presas dentro do
/// builder do tema, inalcançáveis pelos widgets — e a saída fácil seria um
/// widget importar `app_colors.dart`, que a RN-04 proíbe.
class AppSemanticColors extends ThemeExtension<AppSemanticColors> {
  const AppSemanticColors({required this.success, required this.warning});

  final Color success;
  final Color warning;

  static Color success_(BuildContext context) =>
      Theme.of(context).extension<AppSemanticColors>()!.success;

  static Color warning_(BuildContext context) =>
      Theme.of(context).extension<AppSemanticColors>()!.warning;

  @override
  AppSemanticColors copyWith({Color? success, Color? warning}) =>
      AppSemanticColors(
        success: success ?? this.success,
        warning: warning ?? this.warning,
      );

  @override
  AppSemanticColors lerp(AppSemanticColors? other, double t) {
    if (other == null) return this;
    return AppSemanticColors(
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
    );
  }
}

/// Dois `ThemeData` Material 3 construídos EXCLUSIVAMENTE a partir dos
/// tokens de `app_colors.dart` (plano §3.3 / RN-04).
///
/// Seleção: `ThemeMode.system` é o default; override manual chega na F3 via
/// Ajustes. Alternar o tema escuro do sistema muda o app inteiro sem tocar
/// em nenhum widget.
abstract final class AppTheme {
  /// Cadeia de fallback tipográfico (F1.9 / RF-CJK-01..04, risco R8).
  ///
  /// Único lugar do app que nomeia uma família de fonte. PT e EN continuam na
  /// tipografia nativa da plataforma: o subset de Noto Sans SC só é consultado
  /// para os pontos de código que a fonte nativa não cobre — na prática, os
  /// glifos Han, que sem isto renderizam como tofu (□□□) em Androids sem
  /// pacote de idioma chinês. Aplicar fonte widget a widget é PROIBIDO (mesma
  /// regra dos tokens de cor, RN-04): tudo nasce do [TextTheme] abaixo.
  static const List<String> cjkFallback = <String>['NotoSansSC'];

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
    // Fallback CJK injetado uma única vez; os temas de componente abaixo
    // derivam DESTE TextTheme, e não de AppTypography, para herdá-lo.
    final text = AppTypography.textTheme().apply(
      fontFamilyFallback: cjkFallback,
    );

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
      // Expõe `colorBackground` pelo ColorScheme: é a superfície do painel de
      // ORIGEM (§3), e widget nenhum pode alcançar app_colors.dart direto.
      surfaceContainerLow: c.background,
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
      extensions: <ThemeExtension<dynamic>>[
        AppSemanticColors(success: c.success, warning: c.warning),
      ],
      scaffoldBackgroundColor: c.background,
      textTheme: text,
      // BLOCO DE MARCA (§3 plano 1 · §4 primeira faixa): a barra superior é a
      // superfície de marca do app, não um cabeçalho neutro. O painel de
      // conteúdo sobe por cima dela (§P1).
      appBarTheme: AppBarTheme(
        backgroundColor: c.primary,
        foregroundColor: c.onPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        // §8 regra 1: NADA de texto de superfície sobre o bloco de marca. O
        // título herdava `textPrimary` de quando a barra era neutra, o que
        // virou texto quase invisível assim que o fundo ficou azul.
        titleTextStyle: text.titleLarge!.copyWith(color: c.onPrimary),
        iconTheme: IconThemeData(color: c.onPrimary),
        actionsIconTheme: IconThemeData(color: c.onPrimary),
        // A OUTRA METADE DA CURVA. Traçando a silhueta de `home.webp`, o bloco
        // de marca recua da borda direita ~28 px ANTES de a faixa do painel
        // começar: o canto inferior DIREITO do bloco é arredondado, e o canto
        // superior ESQUERDO do painel também. As duas curvas se encaixam em
        // diagonal — é esse encaixe que faz o painel parecer deslizar por
        // baixo da marca. Só uma das duas não produz o efeito.
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomRight: Radius.circular(AppSpacing.radiusLg),
          ),
        ),
      ),
      cardTheme: CardThemeData(
        color: c.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          // Card é painel (§2 · §3, plano 2). SEM borda: hierarquia vem da
          // superfície e da sombra, nunca de contorno (§P3).
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: c.primary,
          foregroundColor: c.onPrimary,
          minimumSize: const Size(64, AppSpacing.minTouchTarget),
          textStyle: text.labelLarge,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: c.primary,
          foregroundColor: c.onPrimary,
          minimumSize: const Size(64, AppSpacing.minTouchTarget),
          textStyle: text.labelLarge,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: c.surface,
        hintStyle: text.bodyLarge!.copyWith(color: c.textSecondary),
        counterStyle: text.labelMedium!.copyWith(color: c.textSecondary),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          borderSide: BorderSide(color: c.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          borderSide: BorderSide(color: c.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          borderSide: BorderSide(color: c.primary, width: 2),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: c.textPrimary,
        contentTextStyle: text.bodyMedium!.copyWith(color: c.background),
        actionTextColor: c.primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: c.surface,
        indicatorColor: c.primaryContainer,
        height: 64,
        labelTextStyle: WidgetStatePropertyAll(
          text.labelMedium!.copyWith(color: c.textPrimary),
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
      // Sheet é painel (§2): o topo arredondado grande é o que faz a folha
      // "subir por cima" do conteúdo (§P1).
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: c.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppSpacing.radiusLg),
          ),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: c.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        ),
      ),
    );
  }
}
