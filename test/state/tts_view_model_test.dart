import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:translatoo/core/services/app_exception.dart';
import 'package:translatoo/core/services/model_manager_service.dart';
import 'package:translatoo/core/services/translation_backend.dart';
import 'package:translatoo/core/services/translation_service.dart';
import 'package:translatoo/core/services/tts_service.dart';
import 'package:translatoo/models/language.dart';
import 'package:translatoo/models/language_pair.dart';
import 'package:translatoo/state/translator_view_model.dart';
import 'package:translatoo/state/tts_view_model.dart';

/// Tradução de eco determinística — nunca toca plugin.
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

/// Todos os pacotes "instalados": o tradutor traduz sem fluxo de download.
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

/// Motor fake do TTS (mesmo contrato da sessão do motor real): o teste fala
/// pelo [emit] e o [speak] grava o texto em [spoken].
class _FakeTtsEngine implements TtsEngine {
  final StreamController<TtsEvent> _events =
      StreamController<TtsEvent>.broadcast();

  bool languageAvailable = true;
  final List<String> spoken = <String>[];
  int stopCalls = 0;
  bool _utteranceLive = false;

  @override
  Stream<TtsEvent> get events => _events.stream;

  @override
  Future<bool> isLanguageAvailable(String ttsCode) async => languageAvailable;

  @override
  Future<void> configure({
    required String languageCode,
    required double rate,
    required double pitch,
  }) async {}

  @override
  Future<void> speak(String text) async {
    if (!languageAvailable) {
      _events.addError(StateError('voz ausente'));
      return;
    }
    spoken.add(text);
    _utteranceLive = true;
  }

  @override
  Future<void> stop() async {
    stopCalls++;
    if (_utteranceLive) {
      _utteranceLive = false;
      emit(const TtsEvent(TtsEventKind.cancelled));
    }
  }

  void emit(TtsEvent event) => _events.add(event);

  @override
  Future<void> dispose() async => _events.close();
}

void main() {
  late _FakeTtsEngine engine;
  late TtsService service;
  late ModelManagerService models;
  late TranslatorViewModel translator;
  late TtsViewModel vm;

  Future<void> build({bool autoPlay = false}) async {
    engine = _FakeTtsEngine();
    service = TtsService(engine: engine);
    models = ModelManagerService(api: _ReadyApi());
    await models.refreshAll();
    translator = TranslatorViewModel(
      translationService: TranslationService(primary: _EchoBackend()),
      modelManager: models,
    );
    vm = TtsViewModel(
      ttsService: service,
      translatorViewModel: translator,
      autoPlay: autoPlay,
    );
  }

  tearDown(() async {
    vm.dispose();
    await service.dispose();
  });

  test(
    'togglePlayback fala o resultado no idioma de destino (AC-M3-1)',
    () async {
      await build();
      translator.acceptDictatedText('bom dia');
      await pumpEventQueue();

      // autoplay OFF + ditado => já falou sozinho (RF-M3-06). Estado speaking só
      // nasce do evento nativo `started`.
      expect(engine.spoken, hasLength(1));
      expect(vm.isSpeaking, isFalse);

      engine.emit(const TtsEvent(TtsEventKind.started));
      await pumpEventQueue();
      expect(vm.isSpeaking, isTrue);
      expect(vm.state, TtsState.speaking);

      engine.emit(const TtsEvent(TtsEventKind.completed));
      await pumpEventQueue();
      expect(vm.state, TtsState.idle);
    },
  );

  test(
    'tradução de ditado fala SEMPRE, autoplay desligado (RF-M3-06)',
    () async {
      await build(autoPlay: false);
      translator.acceptDictatedText('bom dia');
      await pumpEventQueue();
      expect(engine.spoken, ['[pt->en] bom dia']);
    },
  );

  test('autoplay ligado fala tradução digitada; desligado não', () async {
    await build(autoPlay: true);
    translator.onTextChanged('olá');
    await translator.translateNow();
    await pumpEventQueue();
    expect(engine.spoken, ['[pt->en] olá']);
  });

  test('autoplay desligado não fala tradução digitada', () async {
    await build(autoPlay: false);
    translator.onTextChanged('olá');
    await translator.translateNow();
    await pumpEventQueue();
    expect(engine.spoken, isEmpty);
  });

  test('toque duplo no 🔊 é idempotente (< 300 ms, mesma fala)', () async {
    await build(autoPlay: false);
    translator.onTextChanged('oi');
    await translator.translateNow();
    await pumpEventQueue();

    await vm.togglePlayback(); // ▶
    await vm.togglePlayback(); // usuário tocou de novo enquanto fala em curso
    expect(engine.spoken, hasLength(1));
  });

  test('togglePlayback com fala em curso interrompe (AC-M3-3)', () async {
    await build(autoPlay: false);
    translator.onTextChanged('oi');
    await translator.translateNow();
    await pumpEventQueue();

    await vm.togglePlayback();
    engine.emit(const TtsEvent(TtsEventKind.started));
    await pumpEventQueue();
    expect(vm.isSpeaking, isTrue);

    await vm.togglePlayback(); // ⏹
    expect(vm.state, TtsState.idle);
    expect(engine.stopCalls, 1);
  });

  test(
    'voz ausente vira erro observável com ação e idioma (AC-M3-2)',
    () async {
      await build(autoPlay: false);
      translator.onTextChanged('oi');
      await translator.translateNow();
      await pumpEventQueue();
      engine.languageAvailable = false;
      service.refreshVoices(); // sem cache, o erro aparece de novo

      await vm.togglePlayback();
      await pumpEventQueue();
      expect(vm.state, TtsState.idle);
      expect(vm.errorCode, ErrorCode.ttsVoiceMissing);
      expect(vm.errorAction, SuggestedAction.openSettings);
      expect(vm.errorLanguage, Language.en);

      vm.acknowledgeError();
      expect(vm.errorCode, isNull);
    },
  );

  test('setRate/setPitch refletem no serviço (sliders da F2.8/F3)', () async {
    await build();
    vm.setRate(0.8);
    vm.setPitch(1.3);
    expect(vm.rate, 0.8);
    expect(vm.pitch, 1.3);
    expect(service.rate, 0.8);
    expect(service.pitch, 1.3);
  });

  test('refreshVoices invalida o cache do serviço sem lançar', () async {
    await build();
    await service.ensureVoice(Language.zh);
    expect(() => vm.refreshVoices(), returnsNormally);
    await service.ensureVoice(Language.zh); // consulta de novo, sem erro
  });
}
