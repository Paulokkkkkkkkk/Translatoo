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

  // ── Escala de raios (design_system.md §2) ────────────────────────────────
  // Três níveis, e é a diferença entre eles que cria profundidade. A §P2 é
  // direta sobre o custo de ter só um: "o raio 12 lê como Material genérico e
  // apaga a identidade".

  /// `--radius-sm` — chips, badges, campos pequenos, indicadores.
  static const double radiusSm = 8;

  /// `--radius-md` — botões, inputs, snackbars, diálogos.
  static const double radiusMd = 16;

  /// `--radius-lg` — painéis, cards de tradução, sheets, squircles do grid.
  ///
  /// **Regra do squircle:** botão quadrado de ícone só usa este raio com lado
  /// ≥ 96 dp. Abaixo disso o raio grande deforma o quadrado em círculo — use
  /// [radiusMd].
  static const double radiusLg = 28;

  /// `--radius-pill` — pílulas de idioma, tags. Use como `StadiumBorder()`.
  static const double radiusPill = 999;

  /// ALIAS de [radiusMd], mantido para o código da F0/F1 não precisar migrar
  /// num único commit. Em código novo, escolha o nível pela §2.
  static const double radius = radiusMd;

  /// Área mínima de toque acessível (RN-06).
  static const double minTouchTarget = 48;
}
