import 'dart:convert';

import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:translatoo/core/constants/app_constants.dart';
import 'package:translatoo/core/services/storage_service.dart';
import 'package:translatoo/models/app_settings.dart';
import 'package:translatoo/models/language.dart';
import 'package:translatoo/models/translation_record.dart';

Future<SharedPreferences> _mockPrefs([
  Map<String, Object> initial = const <String, Object>{},
]) async {
  SharedPreferences.setMockInitialValues(initial);
  return SharedPreferences.getInstance();
}

TranslationRecord _rec(String id) => TranslationRecord(
  id: id,
  sourceText: 'olá $id',
  translatedText: 'hello $id',
  sourceLang: Language.pt,
  targetLang: Language.en,
  timestamp: DateTime.utc(2026, 1, 1),
);

void main() {
  group('StorageService (F0.7)', () {
    test('settings sobrevivem a um restart simulado (AC-F0-3)', () async {
      final prefs = await _mockPrefs();
      final storage = StorageService(prefs: prefs);
      await storage.initialize();

      storage.updateSettings(
        const AppSettings(tgtLang: Language.zh, wifiOnly: false),
      );
      await storage.flush(); // descarrega gravações agrupadas

      // Novo serviço lendo os mesmos dados persistidos = novo boot.
      final reborn = StorageService(prefs: prefs);
      await reborn.initialize();

      expect(reborn.settings.tgtLang, Language.zh);
      expect(reborn.settings.wifiOnly, isFalse);
      expect(reborn.settings.srcLang, Language.pt); // default preservado
      expect(reborn.settings.themeMode, SettingsThemeMode.system);
      storage.dispose();
      reborn.dispose();
    });

    test('histórico só grava após o debounce de 500 ms', () {
      fakeAsync((async) async {
        final prefs = await _mockPrefs();
        final storage = StorageService(prefs: prefs);
        await storage.initialize();

        storage.saveHistory([_rec('a'), _rec('b')]);
        expect(
          prefs.getString(StorageKeys.history),
          isNull,
          reason: 'antes do debounce nada deve ser gravado',
        );

        async.elapse(AppConstants.prefsWriteDebounce);
        expect(prefs.getString(StorageKeys.history), isNotNull);

        final decoded =
            jsonDecode(prefs.getString(StorageKeys.history)!) as List;
        expect(decoded, hasLength(2));
        storage.dispose();
      });
    });

    test('JSON corrompido reinicia a coleção sem lançar', () async {
      final prefs = await _mockPrefs(<String, Object>{
        StorageKeys.history: '{não sou json',
        StorageKeys.favorites: '"texto solto"',
      });
      final storage = StorageService(prefs: prefs);

      await storage.initialize();

      expect(storage.history, isEmpty);
      expect(storage.favorites, isEmpty);
      storage.dispose();
    });

    test('itens não-mapa são descartados na leitura', () async {
      final raw = jsonEncode(<Object>[_rec('ok').toJson(), 42, 'inválido']);
      final prefs = await _mockPrefs({StorageKeys.history: raw});
      final storage = StorageService(prefs: prefs);

      await storage.initialize();

      expect(storage.history, hasLength(1));
      expect(storage.history.first.id, 'ok');
      storage.dispose();
    });

    test('FIFO limita o histórico em 200 entradas', () async {
      final prefs = await _mockPrefs();
      final storage = StorageService(prefs: prefs);
      await storage.initialize();

      storage.saveHistory(List.generate(250, (i) => _rec('r$i')));
      await storage.flush();

      final decoded = jsonDecode(prefs.getString(StorageKeys.history)!) as List;
      expect(decoded, hasLength(AppConstants.historyLimit));
      storage.dispose();
    });

    test('migração escreve schemaVersion atual', () async {
      final prefs = await _mockPrefs();
      final storage = StorageService(prefs: prefs);

      expect(prefs.getInt(StorageKeys.schemaVersion), isNull);
      await storage.initialize();
      expect(prefs.getInt(StorageKeys.schemaVersion), kSchemaVersion);
      storage.dispose();
    });

    // Política F3.6 (RF-M4-05): app mais novo que o gravado = downgrade —
    // nunca interpreta formato desconhecido. O detalhamento das 4 rotas vive
    // em storage_migration_test.dart.
    test(
      'migração em downgrade volta ao schema atual e reseta dados',
      () async {
        final prefs = await _mockPrefs({StorageKeys.schemaVersion: 99});
        final storage = StorageService(prefs: prefs);

        await storage.initialize();
        expect(prefs.getInt(StorageKeys.schemaVersion), kSchemaVersion);
        expect(storage.settings, AppSettings.defaults());
        expect(storage.history, isEmpty);
        storage.dispose();
      },
    );
  });
}
