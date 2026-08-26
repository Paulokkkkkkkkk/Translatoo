/// Constantes técnicas do produto (plano F0.4). Serviços e ViewModels não
/// usam magic numbers — tudo nasce aqui.
///
/// Nota de projeto: os códigos BCP-47 (`pt-BR`, `en-US`, `zh-CN`) vivem no
/// enum FECHADO `Language` (models/language.dart, RN-01), junto dos códigos
/// ML Kit / TTS / Vosk, mantendo o domínio coeso.
///
/// Timings de fases futuras já contratados pelo PRD e definidos como
/// constantes de nível superior:
///
/// ```dart
/// const sttSentencePause = Duration(milliseconds: 1500); // M2 (F2)
/// const sttMaxDuration   = Duration(seconds: 60);        // M2 (F2)
/// ```
library;

/// Pausa que encerra uma frase no ditado (M2 — implementado na Fase 2).
const Duration sttSentencePause = Duration(milliseconds: 1500);

/// Duração máxima contínua de escuta (M2 — implementado na Fase 2).
const Duration sttMaxDuration = Duration(seconds: 60);

abstract final class AppConstants {
  /// Limite máximo de caracteres no campo de origem (M1).
  static const int maxInputChars = 5000;

  /// Tamanho do bloco ao fatiar textos longos (≤ 4.500 por chamada).
  static const int chunkBlockChars = 4500;

  /// Debounce da tradução automática ao digitar (M1).
  static const Duration translateDebounce = Duration(milliseconds: 800);

  /// Agrupamento das gravações no storage (M4).
  static const Duration prefsWriteDebounce = Duration(milliseconds: 500);

  /// Limite FIFO do histórico (M4).
  static const int historyLimit = 200;

  /// Timeout do modo híbrido nuvem (P2 — flag `cloudEnabled`).
  static const Duration cloudTimeout = Duration(milliseconds: 2000);
}

/// Chaves de persistência (PRD §M4). Único lugar onde as strings existem.
abstract final class StorageKeys {
  static const String history = 'translatoo.history';
  static const String favorites = 'translatoo.favorites';
  static const String settingsSrcLang = 'translatoo.settings.srcLang';
  static const String settingsTgtLang = 'translatoo.settings.tgtLang';
  static const String settingsTtsRate = 'translatoo.settings.ttsRate';
  static const String settingsTtsPitch = 'translatoo.settings.ttsPitch';
  static const String settingsAutoPlay = 'translatoo.settings.autoPlay';
  static const String settingsWifiOnly = 'translatoo.settings.wifiOnly';
  static const String settingsCloudEnabled = 'translatoo.settings.cloudEnabled';
  static const String settingsThemeMode = 'translatoo.settings.themeMode';
  static const String schemaVersion = 'translatoo.settings.schemaVersion';
}

/// Versão atual do schema de persistência (migrações incrementais).
const int kSchemaVersion = 1;
