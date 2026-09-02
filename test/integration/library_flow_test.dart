import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:translatoo/core/services/app_exception.dart';
import 'package:translatoo/core/services/model_manager_service.dart';
import 'package:translatoo/core/services/storage_service.dart';
import 'package:translatoo/core/services/translation_backend.dart';
import 'package:translatoo/core/services/translation_service.dart';
import 'package:translatoo/models/app_settings.dart';
import 'package:translatoo/models/language.dart';
import 'package:translatoo/models/language_pair.dart';
import 'package:translatoo/models/translation_record.dart';
import 'package:translatoo/state/library_view_model.dart';
import 'package:translatoo/state/settings_view_model.dart';
import 'package:translatoo/state/translator_view_model.dart';

/// QUALIDADE DA FASE 3 (F3.7) — os critérios da US-4 que só existem na junção
/// de ViewModel + storage + conectividade.
///
/// Os ACs de tela (F3-1, F3-2) vivem em `history_screen_test.dart`; o F3-6, em
/// `settings_screen_test.dart`. Aqui ficam os três que atravessam camadas.

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
  }) async => '[${source.name}${target.name}]$text';

  @override
  void dispose() {}
}

class _StubApi implements ModelManagerApi {
  final Set<Language> installed = <Language>{};
  int downloadCalls = 0;

  @override
  Future<bool> isModelDownloaded(Language language) async =>
      installed.contains(language);

  @override
  Future<void> downloadModel(
    Language language, {
    required bool isWifiRequired,
  }) async {
    downloadCalls++;
    installed.add(language);
  }

  @override
  Future<void> deleteModel(Language language) async =>
      installed.remove(language);
}

TranslationRecord _record(String source, DateTime at) => TranslationRecord(
  id: at.microsecondsSinceEpoch.toString(),
  sourceText: source,
  translatedText: '[eco]$source',
  sourceLang: Language.pt,
  targetLang: Language.en,
  timestamp: at,
);

void main() {
  late StorageService storage;

  Future<StorageService> openStorage() async {
    final service = StorageService(
      prefs: await SharedPreferences.getInstance(),
    );
    await service.initialize();
    addTearDown(service.dispose);
    return service;
  }

  setUp(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    storage = await openStorage();
  });

  test(
    'AC-F3-3: o "kill" do app preserva histórico, favoritos e ajustes',
    () async {
      final library = LibraryViewModel(storageService: storage);
      final settings = SettingsViewModel(storageService: storage);
      addTearDown(() {
        library.dispose();
        settings.dispose();
      });

      library.addRecord(_record('bom dia', DateTime.now().toUtc()));
      library.toggleFavorite(library.history.first.id);
      settings
        ..setThemeMode(SettingsThemeMode.dark)
        ..setTtsRate(0.9)
        ..setTargetLanguage(Language.zh);

      // Deixa o debounce de 500 ms gravar, depois reabre tudo do zero — é o que
      // acontece quando o usuário mata o app pela bandeja.
      await Future<void>.delayed(const Duration(milliseconds: 600));
      final reopened = await openStorage();
      final library2 = LibraryViewModel(storageService: reopened);
      final settings2 = SettingsViewModel(storageService: reopened);
      addTearDown(() {
        library2.dispose();
        settings2.dispose();
      });

      expect(library2.history.single.sourceText, 'bom dia');
      expect(library2.favorites, hasLength(1));
      expect(settings2.themeMode, SettingsThemeMode.dark);
      expect(settings2.ttsRate, 0.9);
      expect(settings2.targetLanguage, Language.zh);
    },
  );

  group('AC-F3-4: wifiOnly em dados móveis', () {
    late _StubApi api;
    late ModelManagerService models;
    late SettingsViewModel settings;

    ModelManagerService build({required bool online, required bool mobile}) {
      api = _StubApi();
      settings = SettingsViewModel(storageService: storage);
      addTearDown(settings.dispose);
      return models = ModelManagerService(
        api: api,
        online: ValueNotifier<bool>(online),
        onMobileData: ValueNotifier<bool>(mobile),
        wifiOnlyPreference: () => storage.settings.wifiOnly,
      );
    }

    tearDown(() => models.dispose());

    test('com a preferência LIGADA, avisa e não baixa', () async {
      build(online: true, mobile: true);
      expect(storage.settings.wifiOnly, isTrue, reason: 'default do PRD');

      await expectLater(
        models.downloadModel(Language.pt),
        throwsA(
          isA<AppException>()
              .having((e) => e.code, 'code', ErrorCode.wifiOnly)
              .having(
                (e) => e.suggestedAction,
                'ação',
                SuggestedAction.downloadAnyway,
              ),
        ),
      );
      expect(api.downloadCalls, 0);
    });

    test('"baixar mesmo assim" força SEM alterar a preferência', () async {
      build(online: true, mobile: true);

      await models.downloadModel(Language.pt, force: true);

      expect(api.downloadCalls, 1);
      expect(
        storage.settings.wifiOnly,
        isTrue,
        reason: 'a decisão pontual da UI não vira preferência persistida',
      );
    });

    test('desligar a preferência nos Ajustes libera o download', () async {
      build(online: true, mobile: true);
      settings.setWifiOnly(false);

      await models.downloadModel(Language.pt);

      expect(api.downloadCalls, 1);
    });

    test('em Wi-Fi a preferência não atrapalha', () async {
      build(online: true, mobile: false);

      await models.downloadModel(Language.pt);

      expect(api.downloadCalls, 1);
    });
  });

  test('AC-F3-5: offline não bloqueia tradução nem histórico', () async {
    final models = ModelManagerService(
      api: _StubApi()..installed.addAll(Language.values),
      online: ValueNotifier<bool>(false),
      onMobileData: ValueNotifier<bool>(false),
    );
    await models.refreshAll();
    final translator = TranslatorViewModel(
      translationService: TranslationService(primary: _EchoBackend()),
      modelManager: models,
    );
    final library = LibraryViewModel(
      storageService: storage,
      translatorViewModel: translator,
    );
    addTearDown(() {
      library.dispose();
      translator.dispose();
      models.dispose();
    });

    translator.onTextChanged('modo avião');
    await translator.translateNow();
    await pumpEventQueue();

    // RN-02: nada é bloqueado por falta de rede — só o download de pacotes.
    expect(translator.translatedText, '[pten]modo avião');
    expect(library.history, hasLength(1));
  });
}
