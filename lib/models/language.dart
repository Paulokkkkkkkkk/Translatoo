/// Enum FECHADO de idiomas suportados (RN-01) — não estender pela UI.
///
/// Reúne TODOS os códigos externos num só lugar:
/// - [displayName]: nome nativo, nunca traduzido (padrão Papago);
/// - [bcp47Code]: BCP-47 completo (`pt-BR`, `en-US`, `zh-CN`);
/// - [mlKitCode]: código do pacote `google_mlkit_translation`;
/// - [ttsCode]: locale TTS nativo do SO (M3);
/// - [voskCode]: identificador do modelo Vosk embutido (M2).
enum Language {
  pt('Português', 'pt-BR', 'pt', 'pt-BR', 'pt'),
  en('English', 'en-US', 'en', 'en-US', 'en'),
  zh('中文', 'zh-CN', 'zh', 'zh-CN', 'zh');

  const Language(
    this.displayName,
    this.bcp47Code,
    this.mlKitCode,
    this.ttsCode,
    this.voskCode,
  );

  final String displayName;
  final String bcp47Code;
  final String mlKitCode;
  final String ttsCode;
  final String voskCode;

  /// Código usado em persistência/JSON (estável, nome do enum).
  String get jsonCode => name;

  /// Conversão tolerante usada por storage/serviços. Aceita o nome do enum,
  /// o código ML Kit e variantes BCP-47 (`pt_BR`, `EN`, `zh-TW` → zh…).
  static Language? tryFromCode(String? code) {
    if (code == null || code.isEmpty) return null;
    final normalized = code.trim().toLowerCase().replaceAll('_', '-');
    for (final language in Language.values) {
      if (language.name == normalized ||
          language.mlKitCode == normalized ||
          language.bcp47Code.toLowerCase() == normalized) {
        return language;
      }
    }
    // Fallback pelo subtag primário (`pt-XX` → pt).
    final primary = normalized.split('-').first;
    for (final language in Language.values) {
      if (language.mlKitCode == primary) return language;
    }
    return null;
  }
}
