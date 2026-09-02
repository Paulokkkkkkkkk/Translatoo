import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/app_settings.dart';
import '../../models/language.dart';
import '../../models/translation_record.dart';
import '../constants/app_constants.dart';

/// ÚNICO ponto de acesso ao `shared_preferences` (PRD M4).
///
/// - Gravações agrupadas com debounce de 500 ms ([scheduleWrite]); chame
///   [flush] antes de fechar o app (ou em testes) para descarregar.
/// - Leituras toleram JSON corrompido: reiniciam a coleção vazia e logam
///   apenas em debug (zero telemetria).
/// - Migrações incrementais guiadas por `schemaVersion`.
class StorageService {
  StorageService({
    required SharedPreferences prefs,
    Duration writeDebounce = AppConstants.prefsWriteDebounce,
  }) : _prefs = prefs, // ignore: prefer_initializing_formals (API nomeada)
       _writeDebounce = // ignore: prefer_initializing_formals (API nomeada)
           writeDebounce;

  final SharedPreferences _prefs;
  final Duration _writeDebounce;

  AppSettings _settings = AppSettings.defaults();
  List<TranslationRecord> _history = const [];
  List<TranslationRecord> _favorites = const [];

  final List<Future<void> Function()> _pendingWrites = [];
  Timer? _flushTimer;
  Future<void> _flushing = Future<void>.value();
  bool _disposed = false;

  AppSettings get settings => _settings;

  List<TranslationRecord> get history => List.unmodifiable(_history);

  List<TranslationRecord> get favorites => List.unmodifiable(_favorites);

  /// Carrega tudo e executa migrações pendentes. Chamar UMA vez no boot.
  Future<void> initialize() async {
    await _migrate();
    _settings = _readSettings();
    _history = readJsonList(StorageKeys.history, TranslationRecord.fromJson);
    _favorites = readJsonList(
      StorageKeys.favorites,
      TranslationRecord.fromJson,
    );
  }

  // Settings ──────────────────────────────────────────────────────────────

  void updateSettings(AppSettings value) {
    _settings = value;
    scheduleWrite(() => _writeSettings(value));
  }

  Future<void> _writeSettings(AppSettings s) async {
    await _prefs.setString(StorageKeys.settingsSrcLang, s.srcLang.name);
    await _prefs.setString(StorageKeys.settingsTgtLang, s.tgtLang.name);
    await _prefs.setDouble(StorageKeys.settingsTtsRate, s.ttsRate);
    await _prefs.setDouble(StorageKeys.settingsTtsPitch, s.ttsPitch);
    await _prefs.setBool(StorageKeys.settingsAutoPlay, s.autoPlay);
    await _prefs.setBool(StorageKeys.settingsWifiOnly, s.wifiOnly);
    await _prefs.setBool(StorageKeys.settingsCloudEnabled, s.cloudEnabled);
    await _prefs.setString(StorageKeys.settingsThemeMode, s.themeMode.name);
    await _prefs.setInt(StorageKeys.schemaVersion, s.schemaVersion);
  }

  AppSettings _readSettings() {
    final defaults = AppSettings.defaults();
    final settings = defaults.copyWith(
      srcLang: Language.tryFromCode(
        _prefs.getString(StorageKeys.settingsSrcLang),
      ),
      tgtLang: Language.tryFromCode(
        _prefs.getString(StorageKeys.settingsTgtLang),
      ),
      ttsRate: _prefs.getDouble(StorageKeys.settingsTtsRate),
      ttsPitch: _prefs.getDouble(StorageKeys.settingsTtsPitch),
      autoPlay: _prefs.getBool(StorageKeys.settingsAutoPlay),
      wifiOnly: _prefs.getBool(StorageKeys.settingsWifiOnly),
      cloudEnabled: _prefs.getBool(StorageKeys.settingsCloudEnabled),
      themeMode: SettingsThemeMode.values
          .asNameMap()[_prefs.getString(StorageKeys.settingsThemeMode)],
    );
    // RF-M1-10 (política F3.6): par inválido persistido (origem == destino,
    // ex.: gravado por versão anterior) volta ao default pt→en — a UI nunca
    // recebe um estado impossível.
    if (settings.srcLang == settings.tgtLang) return defaults;
    return settings;
  }

  // Histórico / Favoritos ────────────────────────────────────────────────

  void saveHistory(List<TranslationRecord> records) {
    _history = List.of(records);
    scheduleWrite(() async {
      await _prefs.setString(
        StorageKeys.history,
        jsonEncode(
          _history
              .take(AppConstants.historyLimit)
              .map((r) => r.toJson())
              .toList(growable: false),
        ),
      );
    });
  }

  void saveFavorites(List<TranslationRecord> records) {
    _favorites = List.of(records);
    scheduleWrite(() async {
      await _prefs.setString(
        StorageKeys.favorites,
        jsonEncode(_favorites.map((r) => r.toJson()).toList(growable: false)),
      );
    });
  }

  /// Lê uma lista JSON tolerante a corrupção: qualquer falha reinicia a
  /// coleção (lista vazia) e registra apenas um log de debug.
  List<T> readJsonList<T>(
    String key,
    T Function(Map<String, dynamic> json) fromJson,
  ) {
    final raw = _prefs.getString(key);
    if (raw == null || raw.isEmpty) return <T>[];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) {
        _logCorruption(key, 'raiz não é uma lista JSON');
        return <T>[];
      }
      return decoded
          .whereType<Map<String, dynamic>>()
          .map(fromJson)
          .toList(growable: false);
    } on FormatException catch (e) {
      _logCorruption(key, e.message);
      return <T>[];
    } catch (e) {
      _logCorruption(key, e.toString());
      return <T>[];
    }
  }

  void _logCorruption(String key, String detail) {
    if (kDebugMode) {
      debugPrint(
        '[Translatoo][storage] JSON inválido em "$key": '
        '$detail — coleção reiniciada.',
      );
    }
  }

  // Gravação agrupada (debounce) ─────────────────────────────────────────

  /// Agenda uma gravação agrupada: as operações enfileiradas executam em
  /// sequência após [_writeDebounce] sem novas escritas.
  void scheduleWrite(Future<void> Function() write) {
    if (_disposed) return;
    _pendingWrites.add(write);
    _flushTimer?.cancel();
    _flushTimer = Timer(_writeDebounce, () {
      unawaited(flush());
    });
  }

  /// Executa imediatamente todas as gravações pendentes, na ordem da fila.
  Future<void> flush() {
    final pending = List.of(_pendingWrites);
    _pendingWrites.clear();
    _flushTimer?.cancel();
    _flushTimer = null;
    _flushing = _flushing.then((_) async {
      for (final write in pending) {
        try {
          await write();
        } catch (e, st) {
          if (kDebugMode) {
            debugPrint('[Translatoo][storage] falha ao gravar: $e\n$st');
          }
          // Política de retry pertence à camada de ViewModels (F3).
        }
      }
    });
    return _flushing;
  }

  /// Cancela timers pendentes. Gravações não descarregadas são descartadas —
  /// chame [flush] antes se necessário.
  void dispose() {
    _disposed = true;
    _flushTimer?.cancel();
    _flushTimer = null;
  }

  // Migração ──────────────────────────────────────────────────────────────
  //
  // Política de `schemaVersion` (F3.6 · RF-M4-05) — quatro rotas:
  //   ausente → tratada como v1;  igual → leitura normal;
  //   menor  → migrações encadeadas (descarte só da coleção que falhar);
  //   maior  → downgrade: descarta coleções e reseta preferências (nunca
  //            interpreta um formato mais novo que o app conhece).

  /// Passos incrementais por versão DE ORIGEM (v1→v2, v2→v3…). Vazio na v1 —
  /// cada passo futuro descarta SOMENTE a coleção que migra.
  static final Map<int, Future<void> Function(SharedPreferences)> _steps = {};

  Future<void> _migrate() async {
    final stored = _prefs.getInt(StorageKeys.schemaVersion);

    // Rota AUSENTE: primeira gravação — nasce na versão atual.
    if (stored == null) {
      await _prefs.setInt(StorageKeys.schemaVersion, kSchemaVersion);
      return;
    }

    // Rota IGUAL: formato vigente, nada a fazer (leitura normal).
    if (stored == kSchemaVersion) return;

    // Rota MAIOR (downgrade): dados de app mais novo não são confiáveis.
    if (stored > kSchemaVersion) {
      await _prefs.setString(StorageKeys.history, '[]');
      await _prefs.setString(StorageKeys.favorites, '[]');
      await _writeSettings(AppSettings.defaults());
      await _prefs.setInt(StorageKeys.schemaVersion, kSchemaVersion);
      return;
    }

    // Rota MENOR: migrações encadeadas até a versão atual. Um passo que falhe
    // descarta apenas o que tocaria; o boot não pode cair por isso.
    var version = stored;
    while (version < kSchemaVersion) {
      await _steps[version]?.call(_prefs);
      version++;
    }
    await _prefs.setInt(StorageKeys.schemaVersion, kSchemaVersion);
  }
}
