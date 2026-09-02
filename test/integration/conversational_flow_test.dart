import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:translatoo/core/constants/app_constants.dart';
import 'package:translatoo/core/services/app_exception.dart';
import 'package:translatoo/core/services/mic_permission_service.dart';
import 'package:translatoo/core/services/model_manager_service.dart';
import 'package:translatoo/core/services/stt_service.dart';
import 'package:translatoo/core/services/translation_backend.dart';
import 'package:translatoo/core/services/translation_service.dart';
import 'package:translatoo/core/services/tts_service.dart';
import 'package:translatoo/core/services/whisper_model_installer.dart';
import 'package:translatoo/models/language.dart';
import 'package:translatoo/models/language_pair.dart';
import 'package:translatoo/state/speech_view_model.dart';
import 'package:translatoo/state/translator_view_model.dart';
import 'package:translatoo/state/tts_view_model.dart';

/// INTEGRAÇÃO M1 × M2 × M3 (F2.9).
///
/// Os testes de unidade provam cada ViewModel isolado. Este arquivo prova o que
/// nenhum deles vê: que o ciclo conversacional **fecha** — microfone → texto →
/// tradução → voz — com os três conversando entre si.
///
/// Só os SERVIÇOS são falsos. Os três ViewModels são os reais, ligados como no
/// `main.dart`; senão o teste provaria a fiação do teste, não a do app.

// ── Dublês de plataforma ───────────────────────────────────────────────────

class _FakeEngine implements SttEngine {
  _FakeSession? session;
  Object? startError;

  @override
  Future<SttEngineSession> startSession({
    required String modelPath,
    required String languageCode,
  }) async {
    if (startError != null) throw startError!;
    return session = _FakeSession();
  }
}

class _FakeSession implements SttEngineSession {
  final StreamController<String> _partials = StreamController<String>();
  String finalText = '';

  void emitPartial(String text) => _partials.add(text);

  @override
  Stream<String> get partials => _partials.stream;

  @override
  void feed(Uint8List pcm16Bytes) {}

  @override
  Future<String> stop() async {
    unawaited(_partials.close());
    return finalText;
  }
}

class _FakeAudio implements SttAudioSource {
  final StreamController<double> _amplitude =
      StreamController<double>.broadcast();
  StreamController<Uint8List>? _pcm;

  @override
  Stream<double> get amplitude => _amplitude.stream;

  /// Cada escuta abre um fluxo NOVO. Reaproveitar o mesmo controller de
  /// subscrição única quebraria a segunda sessão — e um microfone de verdade
  /// abre e fecha quantas vezes o usuário quiser.
  @override
  Future<Stream<Uint8List>> start() async {
    await _pcm?.close();
    return (_pcm = StreamController<Uint8List>()).stream;
  }

  @override
  Future<void> stop() async {}
}

class _FakePermissionApi implements MicPermissionApi {
  _FakePermissionApi(this.current);

  PermissionStatus current;

  @override
  Future<PermissionStatus> status() async => current;

  @override
  Future<PermissionStatus> request() async => current;

  @override
  Future<bool> openSettings() async => true;
}

class _InstalledStorage implements WhisperAssetStorage {
  static final Uint8List _bytes = Uint8List.fromList(<int>[1, 2]);

  @override
  Future<Uint8List> readAsset(String assetKey) async => _bytes;

  @override
  Future<String> modelsDirectory() async => '/data/whisper';

  @override
  Future<int?> fileSizeBytes(String path) async => _bytes.lengthInBytes;

  @override
  Future<void> writeFile(String path, Uint8List bytes) async {}
}

/// Motor de voz falso: registra o que foi falado e permite simular voz ausente.
class _FakeTtsEngine implements TtsEngine {
  final StreamController<TtsEvent> _events =
      StreamController<TtsEvent>.broadcast();
  final List<String> spoken = <String>[];
  final List<String> configuredLanguages = <String>[];

  /// Locales SEM voz instalada no "sistema".
  final Set<String> missingVoices = <String>{};

  int stopCount = 0;

  @override
  Future<bool> isLanguageAvailable(String ttsCode) async =>
      !missingVoices.contains(ttsCode);

  @override
  Future<void> configure({
    required String languageCode,
    required double rate,
    required double pitch,
  }) async => configuredLanguages.add(languageCode);

  @override
  Future<void> speak(String text) async {
    spoken.add(text);
    _events.add(const TtsEvent(TtsEventKind.started));
  }

  /// O motor nativo avisa quando terminou de falar.
  void finishSpeaking() => _events.add(const TtsEvent(TtsEventKind.completed));

  @override
  Future<void> stop() async {
    stopCount++;
    _events.add(const TtsEvent(TtsEventKind.cancelled));
  }

  @override
  Stream<TtsEvent> get events => _events.stream;

  @override
  Future<void> dispose() async => _events.close();
}

class _EchoBackend implements TranslationBackend {
  final List<String> translated = <String>[];

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
    translated.add(text);
    return '[${source.name}${target.name}]$text';
  }

  @override
  void dispose() {}
}

class _ReadyModelApi implements ModelManagerApi {
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
  late _FakeEngine engine;
  late _FakeTtsEngine ttsEngine;
  late _EchoBackend backend;
  late ModelManagerService models;
  late SttService stt;
  late TtsService tts;
  late TranslatorViewModel translator;
  late SpeechViewModel speech;
  late TtsViewModel voice;

  Future<void> build({
    PermissionStatus permission = PermissionStatus.granted,
    bool autoPlay = false,
    Set<String> missingVoices = const <String>{},
  }) async {
    engine = _FakeEngine();
    ttsEngine = _FakeTtsEngine()..missingVoices.addAll(missingVoices);
    backend = _EchoBackend();
    models = ModelManagerService(api: _ReadyModelApi());
    await models.refreshAll();

    translator = TranslatorViewModel(
      translationService: TranslationService(primary: backend),
      modelManager: models,
    );
    stt = SttService(
      sttEngine: engine,
      audioSource: _FakeAudio(),
      modelInstaller: WhisperModelInstaller(
        assetKey: AppConstants.whisperFullModelAsset,
        storage: _InstalledStorage(),
      ),
    );
    tts = TtsService(engine: ttsEngine);
    speech = SpeechViewModel(
      sttService: stt,
      permissionService: MicPermissionService(
        api: _FakePermissionApi(permission),
      ),
      translatorViewModel: translator,
    );
    voice = TtsViewModel(
      ttsService: tts,
      translatorViewModel: translator,
      autoPlay: autoPlay,
    );

    addTearDown(() async {
      voice.dispose();
      speech.dispose();
      await stt.dispose();
      await tts.dispose();
      translator.dispose();
      models.dispose();
    });
  }

  /// Fala uma frase inteira: abre o microfone, emite parciais e deixa a pausa
  /// de 1,5 s encerrar — o caminho que o usuário percorre de verdade.
  Future<void> dictate(String partial, String finalText) async {
    await speech.start();
    // Captura a sessão DESTA rodada: `engine.session` aponta para a mais
    // recente, e ditar duas vezes seguidas é justamente o que o AC-M3-3 exige.
    final session = engine.session!
      ..emitPartial(partial)
      ..finalText = finalText;
    expect(session, same(engine.session));
    await pumpEventQueue();
    await speech.stop();
    await pumpEventQueue();
  }

  test('AC-F2-1: ciclo completo microfone → texto → tradução → voz', () async {
    await build();

    await dictate('bom dia', 'Bom dia.');

    // M2 entregou o texto…
    expect(speech.state, SpeechState.idle);
    expect(speech.finalText, 'Bom dia.');
    // …M1 traduziu sem esperar o debounce…
    expect(backend.translated, <String>['Bom dia.']);
    expect(translator.translatedText, '[pten]Bom dia.');
    // …e M3 falou sozinho, mesmo com autoplay DESLIGADO (RF-M3-06).
    expect(voice.autoPlay, isFalse);
    expect(ttsEngine.spoken, <String>['[pten]Bom dia.']);
    // A voz é a do idioma de DESTINO, não a da origem.
    expect(ttsEngine.configuredLanguages.last, Language.en.ttsCode);
  });

  test('digitar NÃO dispara voz com autoplay desligado', () async {
    await build();

    translator.onTextChanged('Oi');
    await translator.translateNow();
    await pumpEventQueue();

    expect(translator.translatedText, isNotEmpty);
    expect(
      ttsEngine.spoken,
      isEmpty,
      reason: 'só ditado fala sozinho; texto digitado espera o 🔊',
    );
  });

  test('com autoplay ligado, tradução digitada também fala', () async {
    await build(autoPlay: true);

    translator.onTextChanged('Oi');
    await translator.translateNow();
    await pumpEventQueue();

    expect(ttsEngine.spoken, <String>['[pten]Oi']);
  });

  test('AC-F2-2: permissão negada para sempre não derruba o app', () async {
    await build(permission: PermissionStatus.permanentlyDenied);

    await expectLater(speech.start(), completes);

    expect(speech.state, SpeechState.error);
    expect(speech.errorAction, SuggestedAction.openSettings);
    // O app segue utilizável: digitar e traduzir continuam funcionando.
    translator.onTextChanged('Oi');
    await translator.translateNow();
    expect(translator.translatedText, '[pten]Oi');
  });

  test('AC-F2-4: cancelar restaura o texto e NÃO traduz nem fala', () async {
    await build();
    translator.onTextChanged('rascunho anterior');

    await speech.start();
    engine.session!.emitPartial('fala descartada');
    await pumpEventQueue();
    await speech.cancel();
    await pumpEventQueue();

    expect(translator.sourceText, 'rascunho anterior');
    expect(backend.translated, isEmpty);
    expect(ttsEngine.spoken, isEmpty);
  });

  test('AC-F2-6 (RN-07): background encerra com o parcial e traduz', () async {
    await build();

    await speech.start();
    engine.session!
      ..emitPartial('metade da frase')
      ..finalText = 'metade da frase';
    await pumpEventQueue();

    speech.onAppBackgrounded();
    await pumpEventQueue();

    expect(speech.state, SpeechState.idle);
    expect(backend.translated, <String>['metade da frase']);
    expect(ttsEngine.spoken, isNotEmpty);
  });

  test('AC-F2-5: voz ausente vira erro acionável sem travar o ciclo', () async {
    await build(missingVoices: <String>{Language.en.ttsCode});

    await dictate('bom dia', 'Bom dia.');

    // A tradução aconteceu; só a fala falhou.
    expect(translator.translatedText, '[pten]Bom dia.');
    expect(ttsEngine.spoken, isEmpty);
    expect(voice.errorCode, ErrorCode.ttsVoiceMissing);
    expect(voice.state, TtsState.idle);
  });

  test('AC-M3-3: ditar de novo durante a fala não sobrepõe áudios', () async {
    await build();

    await dictate('bom dia', 'Bom dia.');
    expect(voice.state, TtsState.speaking);

    // Segunda fala enquanto a primeira ainda toca.
    await dictate('boa noite', 'Boa noite.');

    expect(ttsEngine.spoken, <String>['[pten]Bom dia.', '[pten]Boa noite.']);
    expect(
      ttsEngine.stopCount,
      greaterThanOrEqualTo(1),
      reason: 'fila única: a emissão anterior é interrompida antes da próxima',
    );
  });

  test('trocar o idioma de destino muda a voz da próxima fala', () async {
    await build();

    translator.selectTarget(Language.zh);
    await dictate('bom dia', 'Bom dia.');

    expect(ttsEngine.configuredLanguages.last, Language.zh.ttsCode);
  });
}
