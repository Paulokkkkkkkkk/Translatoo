/// Escala de espaçamento do design system (plano §3.3):
/// 4 / 8 / 16 / 24 / 32 — raio padrão 12.
abstract final class AppSpacing {
  /// `--space-xs` — apertos finos (ícone↔rótulo).
  static const double xs = 4;

  /// `--space-sm` — respiro interno compacto.
  static const double sm = 8;

  /// `--space-md` — padding padrão de cartões e inputs.
  static const double md = 16;

  /// `--space-lg` — separação entre blocos/seções.
  static const double lg = 24;

  /// `--space-xl` — margens de tela.
  static const double xl = 32;

  /// `--radius-md` — raio padrão de cartões, inputs, sheets e snacks.
  static const double radius = 12;

  /// Área mínima de toque acessível (RN-06).
  static const double minTouchTarget = 48;
}
