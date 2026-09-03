/// Constantes técnicas do produto (plano F0.4). Serviços e ViewModels não
/// usam magic numbers — tudo nasce aqui.
///
/// Nota de projeto: os códigos BCP-47 (`pt-BR`, `en-US`, `zh-CN`) vivem no
/// enum FECHADO `Language` (models/language.dart, RN-01), junto dos códigos
/// ML Kit / TTS / STT, mantendo o domínio coeso.
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

  /// Alvo de latência por tradução (M1) — medido e logado só em debug.
  static const int translationLatencyTargetMs = 300;

  /// Tamanho ESTIMADO de um pacote de idiomas (exibição na UI de download).
  /// O valor real varia por idioma/plataforma (~30 MB segundo o PRD §3.1).
  static const int estimatedModelSizeMb = 30;

  /// Diretório, dentro dos dados do app, onde o modelo ggml é materializado
  /// como arquivo real (M2 — o whisper.cpp abre por caminho, não por asset).
  static const String whisperModelsDirName = 'whisper';

  /// Modelo ggml embutido no flavor `full` (56,9 MB) — spike F2.0.
  static const String whisperFullModelAsset =
      'assets/models/whisper/ggml-base-q5_1.bin';

  /// Modelo ggml embutido no flavor `lite` (30,7 MB) — spike F2.0.
  static const String whisperLiteModelAsset =
      'assets/models/whisper/ggml-tiny-q5_1.bin';

  /// Modelo ggml REALMENTE presente neste binário (F2.1b).
  ///
  /// Ponto ÚNICO em que o flavor entra no código Dart: os `flavors:` do
  /// pubspec decidem qual `.bin` é empacotado, e este `--dart-define` diz ao
  /// app qual deles procurar. Vazio = build sem modelo embutido, e então o
  /// ditado inteiro é omitido da UI (ver [hasEmbeddedSttModels]).
  ///
  /// Os comandos de build que definem cada valor estão no README.
  static const String sttModelAsset = String.fromEnvironment(
    'STT_MODEL_ASSET',
    defaultValue: whisperFullModelAsset,
  );

  /// Este binário tem modelo de ditado? Lido uma única vez, em tempo de
  /// compilação — a `ui/` NUNCA consulta flavor, só o ViewModel que expõe
  /// esta capacidade (regra de camadas §4).
  static const bool hasEmbeddedSttModels = sttModelAsset != '';

  /// Plano B (F1.4): motor alternativo TFLite p/ devices sem GMS. Enquanto a
  /// spike não embutir um modelo viável (docs/tflite_spike.md), permanece OFF.
  static const bool enableAlternativeEngine = false;

  /// Intervalo de sondagem do estado do modelo durante o download.
  static const Duration modelDownloadPollInterval = Duration(milliseconds: 400);
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
