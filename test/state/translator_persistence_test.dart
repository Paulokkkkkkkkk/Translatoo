import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:translatoo/core/services/model_manager_service.dart';
import 'package:translatoo/core/services/storage_service.dart';
import 'package:translatoo/core/services/translation_backend.dart';
import 'package:translatoo/core/services/translation_service.dart';
import 'package:translatoo/models/app_settings.dart';
import 'package:translatoo/models/language.dart';
import 'package:translatoo/models/language_pair.dart';
import 'package:translatoo/state/translator_view_model.dart';

class _EchoBackend implements TranslationBackend {
  @override
  String get id => 'echo';

  @override
  Future<bool> isModelDownloaded(Language language) async => true;

  @override
  Future<bool> isReady(LanguagePair pair) async => true;

  @override
  Future<String> translate({
    required Language source,
    required Language target,
    required String text,
  }) async => '[${source.mlKitCode}->${target.mlKitCode}] $text';

  @override
  void dispose() {}
}

class _ReadyApi implements ModelManagerApi {
  @override
  Future<bool> isModelDownloaded(Language language) async => true;

  @override
  Future<void> downloadModel(
    Language language, {
    required bool isWifiRequired,
  }) async {}

  @override
  Future<void> deleteModel(Language language) async {}
}

void main() {
  test('nasce com o ÚLTIMO par persistido (AC-M4-3)', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final prefs = await SharedPreferences.getInstance();
    final storage = StorageService(prefs: prefs);
    await storage.initialize();
    storage.updateSettings(
      const AppSettings(srcLang: Language.en, tgtLang: Language.zh),
    );

    final models = ModelManagerService(api: _ReadyApi());
    await models.refreshAll();
    final vm = TranslatorViewModel(
      translationService: TranslationService(primary: _EchoBackend()),
      modelManager: models,
      settings: storage,
    );

    expect(vm.sourceLang, Language.en);
    expect(vm.targetLang, Language.zh);

    vm.dispose();
    models.dispose();
  });

  test(
    'troca de idioma grava o par na hora (persistência do último par)',
    () async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      final prefs = await SharedPreferences.getInstance();
      final storage = StorageService(prefs: prefs);
      await storage.initialize();

      final models = ModelManagerService(api: _ReadyApi());
      await models.refreshAll();
      final vm = TranslatorViewModel(
        translationService: TranslationService(primary: _EchoBackend()),
        modelManager: models,
        settings: storage,
      );

      vm.selectTarget(Language.zh);
      expect(storage.settings.srcLang, Language.pt);
      expect(storage.settings.tgtLang, Language.zh);

      vm.swapLanguages();
      expect(storage.settings.srcLang, Language.zh);
      expect(storage.settings.tgtLang, Language.pt);

      vm.dispose();
      models.dispose();
    },
  );
}
