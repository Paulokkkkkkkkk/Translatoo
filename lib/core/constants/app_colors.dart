import 'dart:ui';

/// ─────────────────────────────────────────────────────────────────────────
/// TRANSLATOO — Tokens de cor (RN-04)
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
  static const Color colorPrimary = Color(0xFF16A34A);

  /// `--color-primary-container` — fundo de pills/seletores inativos, badges suaves.
  static const Color colorPrimaryContainer = Color(0xFFDCFCE7);

  /// `--color-on-primary` — texto/ícone sobre primária.
  static const Color colorOnPrimary = Color(0xFFFFFFFF);

  /// `--color-on-primary-container` — texto sobre container verde claro.
  static const Color colorOnPrimaryContainer = Color(0xFF14532A);

  /// `--color-secondary` — acentos secundários, waveform, destaques.
  static const Color colorSecondary = Color(0xFF22C55E);

  /// `--color-background` — fundo geral (branco gelo).
  static const Color colorBackground = Color(0xFFF8FAFC);

  /// `--color-surface` — cartões origem/destino, sheets (branco puro).
  static const Color colorSurface = Color(0xFFFFFFFF);

  /// `--color-text-primary` — textos principais.
  static const Color colorTextPrimary = Color(0xFF0F172A);

  /// `--color-text-secondary` — textos de apoio, contador n/5000, timestamps.
  static const Color colorTextSecondary = Color(0xFF64748B);

  /// `--color-success` — badge online 🟢, download concluído.
  static const Color colorSuccess = Color(0xFF16A34A);

  /// `--color-warning` — avisos (Wi-Fi restrito, voz ausente).
  static const Color colorWarning = Color(0xFFF59E0B);

  /// `--color-error` — botão mic gravando, erros.
  static const Color colorError = Color(0xFFEF4444);

  /// `--color-border` — bordas de cartões e inputs.
  static const Color colorBorder = Color(0xFFE2E8F0);

  /// `--color-overlay` — scrim do overlay de escuta.
  static const Color colorOverlay = Color(0x66000000);
}

/// Modo DARK — mesmos nomes, valores próprios (plano §3.2).
abstract final class AppColorsDark {
  /// `--color-primary` — primária clara p/ contraste em fundo escuro.
  static const Color colorPrimary = Color(0xFF4ADE80);

  /// `--color-primary-container` — containers/pills em dark.
  static const Color colorPrimaryContainer = Color(0xFF14532A);

  /// `--color-on-primary` — texto escuro sobre verde claro.
  static const Color colorOnPrimary = Color(0xFF052E16);

  /// `--color-on-primary-container` — texto sobre container.
  static const Color colorOnPrimaryContainer = Color(0xFFBBF7D0);

  /// `--color-secondary` — acentos.
  static const Color colorSecondary = Color(0xFF22C55E);

  /// `--color-background` — fundo geral.
  static const Color colorBackground = Color(0xFF0F172A);

  /// `--color-surface` — cartões/sheets.
  static const Color colorSurface = Color(0xFF1E293B);

  /// `--color-text-primary` — textos principais.
  static const Color colorTextPrimary = Color(0xFFF1F5F9);

  /// `--color-text-secondary` — textos de apoio.
  static const Color colorTextSecondary = Color(0xFF94A3B8);

  /// `--color-success` — badge online 🟢.
  static const Color colorSuccess = Color(0xFF4ADE80);

  /// `--color-warning` — avisos.
  static const Color colorWarning = Color(0xFFFBBF24);

  /// `--color-error` — erros / mic gravando.
  static const Color colorError = Color(0xFFF87171);

  /// `--color-border` — bordas.
  static const Color colorBorder = Color(0xFF334155);

  /// `--color-overlay` — scrim.
  static const Color colorOverlay = Color(0x99000000);
}
