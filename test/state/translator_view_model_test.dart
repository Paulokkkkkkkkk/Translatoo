import 'dart:async';

import 'package:fake_async/fake_async.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:translatoo/core/constants/app_constants.dart';
import 'package:translatoo/core/services/app_exception.dart';
import 'package:translatoo/core/services/model_manager_service.dart';
import 'package:translatoo/core/services/translation_backend.dart';
import 'package:translatoo/core/services/translation_service.dart';
import 'package:translatoo/models/language.dart';
import 'package:translatoo/models/language_pair.dart';
import 'package:translatoo/state/translator_view_model.dart';

/// Backend de eco com gatilho controlável: permite travar tradução em curso
/// (bloqueios), injetar erro e inspecionar o que chegou ao motor.
class _EchoBackend implements TranslationBackend {
  Completer<void>? gate;
  Object? throwOnTranslate;
  final List<String> received = <String>[];

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
  }) async {
    final waiter = gate;
    if (waiter != null && !waiter.isCompleted) await waiter.future;
    final thrown = throwOnTranslate;
    if (thrown != null) throw thrown;
    received.add(text);
    return '[${source.mlKitCode}${target.mlKitCode}]$text';
  }

  @override
  void dispose() {}
}

/// API fake p/ gerenciador: nada instalado por padrão (fluxo AC-M1-2).
class _FakeApi implements ModelManagerApi {
  _FakeApi({bool installAll = true})
    : installed = <Language>{if (installAll) ...Language.values};

  final Set<Language> installed;

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
  late _EchoBackend backend;
  late _FakeApi api;
  late ModelManagerService manager;
  late TranslatorViewModel vm;

  Future<void> build({
    bool installAll = true,
    ValueNotifier<bool>? online,
    ValueNotifier<bool>? onMobileData,
  }) async {
    backend = _EchoBackend();
    api = _FakeApi(installAll: installAll);
    manager = ModelManagerService(
      api: api,
      online: online ?? ValueNotifier<bool>(true),
      onMobileData: onMobileData ?? ValueNotifier<bool>(false),
    );
    vm = TranslatorViewModel(
      translationService: TranslationService(primary: backend),
      modelManager: manager,
    );
    // Espelha o estado REAL dos pacotes antes de qualquer interação
    // (installAll=true ⇒ todos Ready; false ⇒ todos NotDownloaded).
    await manager.refreshAll();
    // O pré-aquecimento da F4.4 traduz um caractere assim que o par fica
    // pronto. É setup, não comportamento sob teste: contá-lo faria toda
    // asserção sobre `received` medir uma chamada que o usuário não pediu.
    backend.received.clear();
  }

  tearDown(() {
    vm.dispose();
    manager.dispose();
  });

  test('debounce de 800 ms dispara tradução automática (RF-M1-03)', () {
    fakeAsync((async) {
      unawaited(build());
      async.flushMicrotasks();
      vm.onTextChanged('Bom dia');
      expect(vm.status, TranslatorStatus.typing);

      async.elapse(const Duration(milliseconds: 700));
      expect(vm.status, TranslatorStatus.typing); // ainda dentro do debounce

      async.elapse(const Duration(milliseconds: 150));
      expect(vm.status, TranslatorStatus.done);
      expect(vm.translatedText, '[pten]Bom dia');
    });
  });

  test('digitar de novo reinicia o timer do debounce', () {
    fakeAsync((async) {
      unawaited(build());
      async.flushMicrotasks();
      vm.onTextChanged('O');
      async.elapse(const Duration(milliseconds: 600));
      vm.onTextChanged('Oi'); // reinicia
      async.elapse(const Duration(milliseconds: 250));
      expect(vm.status, isNot(TranslatorStatus.done));

      async.elapse(const Duration(milliseconds: 600));
      expect(vm.status, TranslatorStatus.done);
      expect(backend.received, hasLength(1)); // UMA tradução só
    });
  });

  test('texto vazio cancela o debounce e volta a idle', () {
    fakeAsync((async) {
      unawaited(build());
      async.flushMicrotasks();
      vm.onTextChanged('x');
      async.elapse(const Duration(milliseconds: 100));
      vm.onTextChanged('');

      expect(vm.status, TranslatorStatus.idle);
      async.elapse(const Duration(seconds: 1));
      expect(vm.status, TranslatorStatus.idle);
      expect(vm.translatedText, isEmpty);
      expect(backend.received, isEmpty);
    });
  });

  test('truncamento em 5.000 chars com flag + segurança surrogate', () {
    fakeAsync((async) {
      unawaited(build());
      async.flushMicrotasks();
      vm.onTextChanged('a' * 6000);
      expect(vm.sourceText.length, 5000);
      expect(vm.isTruncated, isTrue);

      // Emoji cruzando o limite não pode ser partido ao meio.
      vm.onTextChanged('${'a' * 4999}😀');
      expect(vm.isTruncated, isTrue);
      expect(vm.sourceText, 'a' * 4999); // emoji inteiro descartado
    });
  });
  test('⇄ troca idiomas E textos e retraduz (AC-M1-3)', () {
    fakeAsync((async) {
      unawaited(build());
      async.flushMicrotasks();
      vm.onTextChanged('Bom dia');
      async.elapse(const Duration(milliseconds: 850));
      expect(vm.translatedText, '[pten]Bom dia');

      vm.swapLanguages();
      expect(vm.sourceLang, Language.en);
      expect(vm.targetLang, Language.pt);
      expect(vm.sourceText, '[pten]Bom dia'); // textos também trocam

      async.elapse(const Duration(milliseconds: 50));
      expect(vm.status, TranslatorStatus.done);
      expect(vm.translatedText, '[enpt][pten]Bom dia');
    });
  });

  test('trocar de idioma APAGA o resultado anterior', () {
    fakeAsync((async) {
      unawaited(build());
      async.flushMicrotasks();
      vm.onTextChanged('Bom dia');
      async.elapse(const Duration(milliseconds: 850));
      expect(vm.translatedText, '[pten]Bom dia');

      // O texto no painel foi traduzido para INGLÊS; sob o rótulo "中文" ele
      // afirma uma coisa falsa.
      vm.selectTarget(Language.zh);
      expect(vm.translatedText, isEmpty);

      async.elapse(const Duration(milliseconds: 50));
      expect(vm.translatedText, '[ptzh]Bom dia');
    });
  });

  test('sem o pacote do idioma novo, o painel esvazia ANTES da retradução', () {
    fakeAsync((async) {
      unawaited(build());
      async.flushMicrotasks();
      vm.onTextChanged('Bom dia');
      async.elapse(const Duration(milliseconds: 850));
      expect(vm.translatedText, '[pten]Bom dia');

      // Pacote de zh some do aparelho: a retradução não sai na hora.
      api.installed.remove(Language.zh);
      unawaited(manager.refreshAll());
      async.flushMicrotasks();

      vm.selectTarget(Language.zh);
      // Sem a limpeza, o inglês ficaria sob o rótulo 中文 durante todo o
      // download — que no aparelho leva minutos, não milissegundos.
      expect(vm.translatedText, isEmpty);
      expect(vm.status, isNot(TranslatorStatus.done));

      // E o AC-M1-2 continua valendo: baixado o pacote, a tradução retoma.
      async.elapse(const Duration(milliseconds: 900));
      expect(vm.translatedText, '[ptzh]Bom dia');
    });
  });

  test('bloqueios durante `translating`: swap/seleção são ignorados', () {
    fakeAsync((async) {
      unawaited(build());
      async.flushMicrotasks();
      backend.gate = Completer<void>(); // segura a tradução
      vm.onTextChanged('Oi');
      async.elapse(const Duration(milliseconds: 850));
      expect(vm.isTranslating, isTrue);

      vm.swapLanguages(); // deve ser ignorado
      expect(vm.sourceLang, Language.pt);
      vm.selectTarget(Language.zh); // idem
      expect(vm.targetLang, Language.en);

      backend.gate!.complete();
      async.elapse(const Duration(milliseconds: 50));
      expect(vm.status, TranslatorStatus.done);

      vm.swapLanguages(); // agora funciona
      expect(vm.sourceLang, Language.en);
    });
  });

  test('erro do motor vira AppException — nunca exceção crua (RN-03)', () {
    fakeAsync((async) {
      unawaited(build());
      async.flushMicrotasks();
      backend.throwOnTranslate = const AppException(
        ErrorCode.translationFailed,
      );

      vm.onTextChanged('Oi');
      async.elapse(const Duration(milliseconds: 850));

      expect(vm.status, TranslatorStatus.error);
      expect(vm.error?.code, ErrorCode.translationFailed);
    });
  });

  test('canDictate reflete o modelo embutido no flavor (F2.1b)', () {
    fakeAsync((async) {
      unawaited(build());
      async.flushMicrotasks();
      // O default de compilação é o flavor `full`; um build sem
      // --dart-define=STT_MODEL_ASSET= mantém o ditado disponível.
      expect(vm.canDictate, AppConstants.hasEmbeddedSttModels);
      expect(vm.canDictate, isTrue);
    });
  });

  test('acceptDictatedText traduz imediatamente (gancho F2)', () {
    fakeAsync((async) {
      unawaited(build());
      async.flushMicrotasks();
      vm.acceptDictatedText('Oi'); // sem esperar debounce nenhum
      async.elapse(Duration.zero);

      expect(vm.status, TranslatorStatus.done);
      expect(vm.translatedText, '[pten]Oi');
    });
  });

  test(
    'AC-M1-2: pacote ausente → download → tradução pendente executa sozinha',
    () {
      fakeAsync((async) {
        unawaited(build(installAll: false));
        async.flushMicrotasks();
        vm.onTextChanged('Oi');
        async.elapse(const Duration(milliseconds: 850));
        async.elapse(Duration.zero);

        // Ausência NÃO é erro: dispara downloads e, com o par pronto,
        // retoma a tradução pendente sozinha (a API fake os conclui).
        expect(vm.error, isNull);
        expect(vm.blockedLanguageLabel, isNull);
        expect(vm.status, TranslatorStatus.done);
        expect(vm.translatedText, '[pten]Oi');
        expect(api.installed, containsAll([Language.pt, Language.en]));
      });
    },
  );

  test(
    'ERR_WIFI_ONLY expõe erro + "baixar mesmo assim" força sem mudar prefs',
    () {
      fakeAsync((async) {
        unawaited(
          build(
            installAll: false,
            online: ValueNotifier<bool>(true),
            onMobileData: ValueNotifier<bool>(true),
          ),
        );
        async.flushMicrotasks();

        vm.onTextChanged('Oi');
        async.elapse(const Duration(milliseconds: 850));
        async.elapse(Duration.zero);

        expect(vm.status, TranslatorStatus.error);
        expect(vm.error?.code, ErrorCode.wifiOnly);
        expect(api.installed, isEmpty); // nada baixado sem a decisão do usuário

        // Decisão da UI ("Baixar mesmo assim"): força SEM alterar preferência.
        unawaited(vm.confirmDownloadAnyway());
        async.elapse(Duration.zero);

        expect(vm.error, isNull);
        expect(vm.status, TranslatorStatus.done); // pendência retomada sozinha
        expect(vm.translatedText, '[pten]Oi');
        expect(api.installed, containsAll([Language.pt, Language.en]));
      });
    },
  );
}
