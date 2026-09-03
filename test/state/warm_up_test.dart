import 'package:flutter_test/flutter_test.dart';
import 'package:translatoo/core/services/model_manager_service.dart';
import 'package:translatoo/core/services/translation_backend.dart';
import 'package:translatoo/core/services/translation_service.dart';
import 'package:translatoo/models/language.dart';
import 'package:translatoo/models/language_pair.dart';
import 'package:translatoo/state/translator_view_model.dart';

/// Pré-aquecimento do motor (F4.4).
///
/// O ML Kit carrega o modelo na PRIMEIRA tradução. Sem aquecer, esse custo cai
/// justamente onde o usuário está olhando o resultado.

class _CountingBackend implements TranslationBackend {
  final List<String> translated = <String>[];
  bool ready = true;
  Object? error;

  @override
  String get id => 'counting';

  @override
  Future<bool> isModelDownloaded(Language language) async => ready;

  @override
  Future<bool> isReady(LanguagePair pair) async => ready;

  @override
  Future<String> translate({
    required Language source,
    required Language target,
    required String text,
  }) async {
    if (error != null) throw error!;
    translated.add(text);
    return '[eco]$text';
  }

  @override
  void dispose() {}
}

class _StubApi implements ModelManagerApi {
  final Set<Language> installed = <Language>{};

  @override
  Future<bool> isModelDownloaded(Language language) async =>
      installed.contains(language);

  @override
  Future<void> downloadModel(
    Language language, {
    required bool isWifiRequired,
  }) async => installed.add(language);

  @override
  Future<void> deleteModel(Language language) async =>
      installed.remove(language);
}

void main() {
  late _CountingBackend backend;

  setUp(() => backend = _CountingBackend());

  test('warmUp traduz um caractere para forçar a carga do modelo', () async {
    final service = TranslationService(primary: backend);

    await service.warmUp(
      const LanguagePair(source: Language.pt, target: Language.en),
    );

    expect(backend.translated, <String>['a']);
  });

  test('warmUp com o par NÃO pronto não chama o motor', () async {
    backend.ready = false;
    final service = TranslationService(primary: backend);

    await service.warmUp(
      const LanguagePair(source: Language.pt, target: Language.en),
    );

    expect(backend.translated, isEmpty);
  });

  test(
    'falha no aquecimento é silenciosa — é otimização, não função',
    () async {
      backend.error = StateError('modelo corrompido');
      final service = TranslationService(primary: backend);

      // Não pode lançar: a tradução real ainda funciona, só mais lenta na
      // primeira vez.
      await expectLater(
        service.warmUp(
          const LanguagePair(source: Language.pt, target: Language.en),
        ),
        completes,
      );
    },
  );

  test('o ViewModel aquece quando o par fica pronto, e uma vez só', () async {
    final api = _StubApi();
    final models = ModelManagerService(api: api);
    final vm = TranslatorViewModel(
      translationService: TranslationService(primary: backend),
      modelManager: models,
    );
    addTearDown(() {
      vm.dispose();
      models.dispose();
    });

    // Par ausente: nada a aquecer.
    await models.refreshAll();
    await pumpEventQueue();
    expect(backend.translated, isEmpty);

    // Pacotes chegam → aquece.
    api.installed.addAll(Language.values);
    await models.refreshAll();
    await pumpEventQueue();
    expect(backend.translated, <String>['a']);

    // Notificações repetidas do gerenciador não reaquecem o mesmo par.
    await models.refreshAll();
    await pumpEventQueue();
    expect(backend.translated, hasLength(1));
  });

  test('trocar de idioma aquece o par NOVO', () async {
    final api = _StubApi()..installed.addAll(Language.values);
    final models = ModelManagerService(api: api);
    await models.refreshAll();
    final vm = TranslatorViewModel(
      translationService: TranslationService(primary: backend),
      modelManager: models,
    );
    addTearDown(() {
      vm.dispose();
      models.dispose();
    });
    await pumpEventQueue();
    final antes = backend.translated.length;

    // pt→en vira pt→zh: outro modelo, outra carga.
    vm.selectTarget(Language.zh);
    await pumpEventQueue();

    expect(backend.translated.length, antes + 1);
  });
}
