import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:translatoo/core/constants/app_constants.dart';
import 'package:translatoo/core/services/storage_service.dart';
import 'package:translatoo/models/app_settings.dart';
import 'package:translatoo/models/language.dart';
import 'package:translatoo/models/translation_record.dart';

/// Bateria da política de `schemaVersion` (F3.6 · RF-M4-05): as QUATRO rotas
/// (ausente/igual/menor/maior) + o par inválido (RF-M1-10).
///
/// Cada cenário "reinicia o app": grava preferências reais via um primeiro
/// [StorageService] (flush), ajusta a versão bruta quando preciso, e abre um
/// SEGUNDO serviço sobre as MESMAS preferências — um kill + relaunch de fato.
void main() {
  final record = TranslationRecord(
    id: '1',
    sourceText: 'bom dia',
    translatedText: 'good morning',
    sourceLang: Language.pt,
    targetLang: Language.en,
    timestamp: DateTime.utc(2026, 9, 1),
    isFavorite: true,
  );

  /// Grava [seed] (histórico, favoritos, par, voz) e devolve as prefs.
  Future<SharedPreferences> seed({
    AppSettings settings = const AppSettings(),
    bool withHistory = true,
  }) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final prefs = await SharedPreferences.getInstance();
    final storage = StorageService(prefs: prefs);
    await storage.initialize();
    storage.updateSettings(settings);
    if (withHistory) {
      storage.saveHistory(<TranslationRecord>[record]);
      storage.saveFavorites(<TranslationRecord>[record]);
    }
    await storage.flush();
    return prefs;
  }

  /// Abre um NOVO StorageService sobre [prefs] (novo boot).
  Future<StorageService> boot(SharedPreferences prefs) async {
    final storage = StorageService(prefs: prefs);
    await storage.initialize();
    return storage;
  }

  test(
    'rota AUSENTE: primeira execução nasce na versão atual, defaults ok',
    () async {
      final prefs = await seed(withHistory: false);
      await prefs.remove(StorageKeys.schemaVersion); // nunca houve schema

      final storage = await boot(prefs);
      expect(prefs.getInt(StorageKeys.schemaVersion), kSchemaVersion);
      expect(storage.settings, AppSettings.defaults());
      expect(storage.history, isEmpty);
    },
  );

  test('rota IGUAL: leitura normal preserva dados e preferências', () async {
    final prefs = await seed(
      settings: const AppSettings(
        srcLang: Language.en,
        tgtLang: Language.zh,
        autoPlay: true,
        wifiOnly: false,
      ),
    );

    final storage = await boot(prefs);
    expect(storage.settings.srcLang, Language.en);
    expect(storage.settings.tgtLang, Language.zh);
    expect(storage.settings.autoPlay, isTrue);
    expect(storage.settings.wifiOnly, isFalse);
    expect(storage.history, hasLength(1));
    expect(storage.favorites, hasLength(1));
  });

  test(
    'rota MENOR: versão antiga migra em cadeia SEM descartar dados (v0→v1)',
    () async {
      final prefs = await seed(
        settings: const AppSettings(srcLang: Language.pt, tgtLang: Language.en),
      );
      await prefs.setInt(StorageKeys.schemaVersion, 0); // mais antigo que o app

      final storage = await boot(prefs);
      expect(prefs.getInt(StorageKeys.schemaVersion), kSchemaVersion);
      // v0→v1 não tem passo de migração: histórico e par são PRESERVADOS.
      expect(storage.history, hasLength(1));
      expect(storage.settings.srcLang, Language.pt);
      expect(storage.settings.tgtLang, Language.en);
    },
  );

  test(
    'rota MAIOR (downgrade): descarta coleções e reseta preferências',
    () async {
      final prefs = await seed(
        settings: const AppSettings(
          srcLang: Language.zh,
          tgtLang: Language.en,
          wifiOnly: false,
          themeMode: SettingsThemeMode.dark,
        ),
      );
      await prefs.setInt(
        StorageKeys.schemaVersion,
        99,
      ); // app mais novo que nós

      final storage = await boot(prefs);
      expect(prefs.getInt(StorageKeys.schemaVersion), kSchemaVersion);
      expect(storage.history, isEmpty);
      expect(storage.favorites, isEmpty);
      expect(storage.settings, AppSettings.defaults()); // reset total
    },
  );

  test(
    'par inválido persistido (origem == destino) volta a pt→en (RF-M1-10)',
    () async {
      final prefs = await seed();
      // Grava um par impossível (zh == zh), como uma versão antiga poderia.
      await prefs.setString(StorageKeys.settingsSrcLang, 'zh');
      await prefs.setString(StorageKeys.settingsTgtLang, 'zh');

      final storage = await boot(prefs);
      expect(storage.settings.srcLang, Language.pt);
      expect(storage.settings.tgtLang, Language.en);
      // Histórico NÃO é afetado pela correção do par.
      expect(storage.history, hasLength(1));
    },
  );
}
