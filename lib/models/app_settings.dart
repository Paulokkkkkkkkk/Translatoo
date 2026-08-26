import 'language.dart';

/// Modo de tema escolhido pelo usuário. Espelha `ThemeMode` sem importar o
/// Flutter na camada de modelos (a conversão acontece na borda da UI).
enum SettingsThemeMode { system, light, dark }

/// Configurações do usuário (M4) — imutável, com [copyWith].
///
/// Defaults conforme PRD §M4: par inicial pt→en, `wifiOnly = true`,
/// `cloudEnabled = false` na v1, tema segue o sistema.
class AppSettings {
  const AppSettings({
    this.srcLang = Language.pt,
    this.tgtLang = Language.en,
    this.ttsRate = 0.5,
    this.ttsPitch = 1.0,
    this.autoPlay = false,
    this.wifiOnly = true,
    this.cloudEnabled = false,
    this.themeMode = SettingsThemeMode.system,
    this.schemaVersion = kCurrentSchemaVersion,
  });

  factory AppSettings.defaults() => const AppSettings();

  /// Versão do schema com que esta instância foi escrita.
  static const int kCurrentSchemaVersion = 1;

  final Language srcLang;
  final Language tgtLang;

  /// Velocidade TTS normalizada 0.0–1.0 (mapeada por plataforma na F2).
  final double ttsRate;

  /// Tom TTS (0.5–2.0, padrão 1.0).
  final double ttsPitch;
  final bool autoPlay;

  /// Download de modelos somente via Wi-Fi (default `true` — PRD M4).
  final bool wifiOnly;

  /// Modo híbrido nuvem (P2). Sempre `false` na v1.
  final bool cloudEnabled;
  final SettingsThemeMode themeMode;
  final int schemaVersion;

  AppSettings copyWith({
    Language? srcLang,
    Language? tgtLang,
    double? ttsRate,
    double? ttsPitch,
    bool? autoPlay,
    bool? wifiOnly,
    bool? cloudEnabled,
    SettingsThemeMode? themeMode,
    int? schemaVersion,
  }) {
    return AppSettings(
      srcLang: srcLang ?? this.srcLang,
      tgtLang: tgtLang ?? this.tgtLang,
      ttsRate: ttsRate ?? this.ttsRate,
      ttsPitch: ttsPitch ?? this.ttsPitch,
      autoPlay: autoPlay ?? this.autoPlay,
      wifiOnly: wifiOnly ?? this.wifiOnly,
      cloudEnabled: cloudEnabled ?? this.cloudEnabled,
      themeMode: themeMode ?? this.themeMode,
      schemaVersion: schemaVersion ?? this.schemaVersion,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'schemaVersion': schemaVersion,
    'srcLang': srcLang.jsonCode,
    'tgtLang': tgtLang.jsonCode,
    'ttsRate': ttsRate,
    'ttsPitch': ttsPitch,
    'autoPlay': autoPlay,
    'wifiOnly': wifiOnly,
    'cloudEnabled': cloudEnabled,
    'themeMode': themeMode.name,
  };

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    final defaults = AppSettings.defaults();
    return defaults.copyWith(
      srcLang: Language.tryFromCode(json['srcLang'] as String?),
      tgtLang: Language.tryFromCode(json['tgtLang'] as String?),
      ttsRate: (json['ttsRate'] as num?)?.toDouble(),
      ttsPitch: (json['ttsPitch'] as num?)?.toDouble(),
      autoPlay: json['autoPlay'] as bool?,
      wifiOnly: json['wifiOnly'] as bool?,
      cloudEnabled: json['cloudEnabled'] as bool?,
      themeMode: SettingsThemeMode.values.asNameMap()[json['themeMode']],
      schemaVersion: (json['schemaVersion'] as num?)?.toInt(),
    );
  }

  @override
  bool operator ==(Object other) =>
      other is AppSettings &&
      other.srcLang == srcLang &&
      other.tgtLang == tgtLang &&
      other.ttsRate == ttsRate &&
      other.ttsPitch == ttsPitch &&
      other.autoPlay == autoPlay &&
      other.wifiOnly == wifiOnly &&
      other.cloudEnabled == cloudEnabled &&
      other.themeMode == themeMode &&
      other.schemaVersion == schemaVersion;

  @override
  int get hashCode => Object.hash(
    srcLang,
    tgtLang,
    ttsRate,
    ttsPitch,
    autoPlay,
    wifiOnly,
    cloudEnabled,
    themeMode,
    schemaVersion,
  );

  @override
  String toString() => 'AppSettings(${toJson()})';
}
