import 'dart:ui';

/// ─────────────────────────────────────────────────────────────────────────
/// TRANSLATOO — Tokens de cor (RN-04) — paleta Azul & Branco
///
/// ÚNICA fonte de cores do projeto. É proibido usar `Color(0x…)` fora deste
/// arquivo. Cada token documenta a variável CSS equivalente do design system
/// web (PRD §4.3), p.ex. `--color-primary`.
///
/// `AppColorsLight` e `AppColorsDark` expõem EXATAMENTE os mesmos nomes
/// estáticos (UX-05 / plano §3.3): trocar de paleta é trocar de classe —
/// nenhum widget precisa ser tocado.
/// ─────────────────────────────────────────────────────────────────────────
abstract final class AppColorsLight {
  /// `--color-primary` — botões primários, pills ativas, foco, marca.
  static const Color colorPrimary = Color(0xFF3954FD);

  /// `--color-primary-container` — fundo de pills/seletores inativos, badges suaves.
  static const Color colorPrimaryContainer = Color(0xFFE9ECFF);

  /// `--color-on-primary` — texto/ícone sobre primária.
  static const Color colorOnPrimary = Color(0xFFFFFFFF);

  /// `--color-on-primary-container` — texto sobre container verde claro.
  static const Color colorOnPrimaryContainer = Color(0xFF101C6B);

  /// `--color-secondary` — acentos secundários, waveform, destaques.
  static const Color colorSecondary = Color(0xFF2438D9);

  /// `--color-background` — fundo geral (branco gelo).
  static const Color colorBackground = Color(0xFFF5F6FF);

  /// `--color-surface` — cartões origem/destino, sheets (branco puro).
  static const Color colorSurface = Color(0xFFFFFFFF);

  /// `--color-text-primary` — textos principais.
  static const Color colorTextPrimary = Color(0xFF131C42);

  /// `--color-text-secondary` — textos de apoio, contador n/5000, timestamps.
  static const Color colorTextSecondary = Color(0xFF5F678F);

  /// `--color-success` — badge online 🟢, download concluído.
  static const Color colorSuccess = Color(0xFF15803D);

  /// `--color-warning` — avisos (Wi-Fi restrito, voz ausente).
  static const Color colorWarning = Color(0xFFB45309);

  /// `--color-error` — botão mic gravando, erros.
  static const Color colorError = Color(0xFFDC2626);

  /// `--color-border` — bordas de cartões e inputs.
  static const Color colorBorder = Color(0xFFCED5EC);

  /// `--color-overlay` — scrim do overlay de escuta.
  static const Color colorOverlay = Color(0x66000000);
}

/// Modo DARK — mesmos nomes, valores próprios (plano §3.2).
abstract final class AppColorsDark {
  /// `--color-primary` — primária clara p/ contraste em fundo escuro.
  static const Color colorPrimary = Color(0xFF93A4FF);

  /// `--color-primary-container` — containers/pills em dark.
  static const Color colorPrimaryContainer = Color(0xFF232E76);

  /// `--color-on-primary` — texto escuro sobre verde claro.
  static const Color colorOnPrimary = Color(0xFF080F33);

  /// `--color-on-primary-container` — texto sobre container.
  static const Color colorOnPrimaryContainer = Color(0xFFD9E0FF);

  /// `--color-secondary` — acentos.
  static const Color colorSecondary = Color(0xFF6478FF);

  /// `--color-background` — fundo geral.
  static const Color colorBackground = Color(0xFF0C1030);

  /// `--color-surface` — cartões/sheets.
  static const Color colorSurface = Color(0xFF171C42);

  /// `--color-text-primary` — textos principais.
  static const Color colorTextPrimary = Color(0xFFEDEFFA);

  /// `--color-text-secondary` — textos de apoio.
  static const Color colorTextSecondary = Color(0xFFA3ABD0);

  /// `--color-success` — badge online 🟢.
  static const Color colorSuccess = Color(0xFF4ADE80);

  /// `--color-warning` — avisos.
  static const Color colorWarning = Color(0xFFFBBF24);

  /// `--color-error` — erros / mic gravando.
  static const Color colorError = Color(0xFFF87171);

  /// `--color-border` — bordas.
  static const Color colorBorder = Color(0xFF2F3768);

  /// `--color-overlay` — scrim.
  static const Color colorOverlay = Color(0x99000000);
}
