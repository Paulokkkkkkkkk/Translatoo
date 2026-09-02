import 'package:flutter/foundation.dart';

import '../core/services/storage_service.dart';
import '../models/app_settings.dart';
import '../models/language.dart';
import 'tts_view_model.dart';

/// Preferências do usuário (F3.3 · M4 · PRD §3.5).
///
/// É a ÚNICA porta de escrita das configurações: a tela chama este ViewModel,
/// que persiste no [StorageService] e propaga o que outros ViewModels precisam
/// saber. Deixar a tela escrever direto no storage espalharia a regra de
/// persistência por widgets.
///
/// **AC-M3-4** — velocidade e tom sobrevivem ao restart: toda mudança grava na
/// hora (o debounce de 500 ms do storage agrupa as gravações do slider) e o
/// `TtsViewModel` nasce no `main` já lendo os valores persistidos.
class SettingsViewModel extends ChangeNotifier {
  SettingsViewModel({
    required StorageService storageService,
    TtsViewModel? ttsViewModel,
  }) : _storage = storageService,
       _tts = ttsViewModel;

  final StorageService _storage;

  /// Espelha rate/pitch/autoplay para a reprodução em curso. Opcional para os
  /// testes de persistência, que não precisam de motor de voz.
  final TtsViewModel? _tts;

  AppSettings get settings => _storage.settings;

  Language get sourceLanguage => settings.srcLang;
  Language get targetLanguage => settings.tgtLang;
  double get ttsRate => settings.ttsRate;
  double get ttsPitch => settings.ttsPitch;
  bool get autoPlay => settings.autoPlay;
  bool get wifiOnly => settings.wifiOnly;
  SettingsThemeMode get themeMode => settings.themeMode;

  /// Par padrão. RN-01 exige origem ≠ destino: escolher um idioma que já é o
  /// outro lado TROCA os dois, em vez de recusar em silêncio.
  void setSourceLanguage(Language value) {
    if (value == settings.srcLang) return;
    _write(
      value == settings.tgtLang
          ? settings.copyWith(srcLang: value, tgtLang: settings.srcLang)
          : settings.copyWith(srcLang: value),
    );
  }

  void setTargetLanguage(Language value) {
    if (value == settings.tgtLang) return;
    _write(
      value == settings.srcLang
          ? settings.copyWith(tgtLang: value, srcLang: settings.tgtLang)
          : settings.copyWith(tgtLang: value),
    );
  }

  void setAutoPlay(bool value) {
    if (value == settings.autoPlay) return;
    _tts?.setAutoPlay(value);
    _write(settings.copyWith(autoPlay: value));
  }

  /// Velocidade normalizada 0..1 (0,5 ≈ normal no SO).
  void setTtsRate(double value) {
    final clamped = value.clamp(0.0, 1.0);
    if (clamped == settings.ttsRate) return;
    _tts?.setRate(clamped);
    _write(settings.copyWith(ttsRate: clamped));
  }

  /// Tom na escala nativa 0,5..2,0 (1,0 = normal).
  void setTtsPitch(double value) {
    final clamped = value.clamp(0.5, 2.0);
    if (clamped == settings.ttsPitch) return;
    _tts?.setPitch(clamped);
    _write(settings.copyWith(ttsPitch: clamped));
  }

  void setWifiOnly(bool value) {
    if (value == settings.wifiOnly) return;
    _write(settings.copyWith(wifiOnly: value));
  }

  /// Override manual do tema sobre o `ThemeMode.system` default da F0
  /// (AC-F3-6). A conversão para `ThemeMode` acontece na borda da UI — a
  /// camada de modelos não importa Flutter.
  void setThemeMode(SettingsThemeMode value) {
    if (value == settings.themeMode) return;
    _write(settings.copyWith(themeMode: value));
  }

  void _write(AppSettings value) {
    _storage.updateSettings(value);
    notifyListeners();
  }
}
