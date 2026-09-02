import 'dart:async';
import 'dart:typed_data';

import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:translatoo/core/constants/app_constants.dart';
import 'package:translatoo/core/services/app_exception.dart';
import 'package:translatoo/core/services/stt_service.dart';
import 'package:translatoo/core/services/whisper_model_installer.dart';
import 'package:translatoo/models/language.dart';

/// Motor fake: o teste decide quando cada parcial sai e o que `stop()` devolve.
class _FakeEngine implements SttEngine {
  _FakeSession? session;
  String? lastModelPath;
  String? lastLanguageCode;
  Object? startError;

  @override
  Future<SttEngineSession> startSession({
    required String modelPath,
    required String languageCode,
  }) async {
    if (startError != null) throw startError!;
    lastModelPath = modelPath;
    lastLanguageCode = languageCode;
    return session = _FakeSession();
  }
}

class _FakeSession implements SttEngineSession {
  final StreamController<String> _partials = StreamController<String>();
  final List<Uint8List> fed = <Uint8List>[];

  String finalText = '';
  bool stopped = false;
  Object? stopError;

  void emitPartial(String text) => _partials.add(text);

  @override
  Stream<String> get partials => _partials.stream;

  @override
  void feed(Uint8List pcm16Bytes) => fed.add(pcm16Bytes);

  @override
  Future<String> stop() async {
    stopped = true;
    // Sem `await`: um controller sem ouvinte nunca completa o future de
    // `close()` sob FakeAsync, e o teste travaria em vez de falhar.
    unawaited(_partials.close());
    if (stopError != null) throw stopError!;
    return finalText;
  }
}

class _FakeAudio implements SttAudioSource {
  final StreamController<Uint8List> _pcm = StreamController<Uint8List>();

  int startCount = 0;
  int stopCount = 0;
  Object? startError;

  void emit(List<int> bytes) => _pcm.add(Uint8List.fromList(bytes));
  void fail(Object error) => _pcm.addError(error);
  void close() => _pcm.close();

  @override
  Future<Stream<Uint8List>> start() async {
    startCount++;
    if (startError != null) throw startError!;
    return _pcm.stream;
  }

  @override
  Future<void> stop() async => stopCount++;
}

/// Storage do instalador (F2.1) com o modelo "já instalado": estes testes são
/// sobre as regras de fim de fala, não sobre a cópia do asset.
class _InstalledStorage implements WhisperAssetStorage {
  static final Uint8List _bytes = Uint8List.fromList(<int>[1, 2, 3, 4]);

  @override
  Future<Uint8List> readAsset(String assetKey) async => _bytes;

  @override
  Future<String> modelsDirectory() async => '/data/whisper';

  @override
  Future<int?> fileSizeBytes(String path) async => _bytes.lengthInBytes;

  @override
  Future<void> writeFile(String path, Uint8List bytes) async {}
}

void main() {
  late _FakeEngine engine;
  late _FakeAudio audio;
  late SttService service;
  late List<SttResult> results;
  late List<Object> errors;

  setUp(() {
    engine = _FakeEngine();
    audio = _FakeAudio();
    service = SttService(
      sttEngine: engine,
      audioSource: audio,
      modelInstaller: WhisperModelInstaller(
        assetKey: AppConstants.whisperFullModelAsset,
        storage: _InstalledStorage(),
      ),
    );
    results = <SttResult>[];
    errors = <Object>[];
    service.results.listen(results.add, onError: errors.add);
  });

  /// `start` é assíncrono (instala o modelo, abre motor e microfone); sob
  /// [FakeAsync] é preciso deixar a fila de microtasks drenar.
  void startListening(FakeAsync async, [Language language = Language.pt]) {
    unawaited(service.start(language));
    async.flushMicrotasks();
  }

  test('start carrega o modelo e passa o idioma de ORIGEM ao motor', () {
    fakeAsync((async) {
      startListening(async, Language.zh);

      expect(service.phase, SttPhase.listening);
      expect(engine.lastModelPath, '/data/whisper/ggml-base-q5_1.bin');
      expect(engine.lastLanguageCode, Language.zh.sttCode);
      expect(audio.startCount, 1);
    });
  });

  test(
    'start com sessão ativa é no-op (dois toques não abrem dois micros)',
    () {
      fakeAsync((async) {
        startListening(async);
        startListening(async);

        expect(audio.startCount, 1);
      });
    },
  );

  test('áudio flui para o motor e parciais chegam como não-finais', () {
    fakeAsync((async) {
      startListening(async);

      audio.emit(<int>[1, 2, 3]);
      async.flushMicrotasks();
      engine.session!.emitPartial('bom');
      engine.session!.emitPartial('bom dia');
      async.flushMicrotasks();

      expect(engine.session!.fed, hasLength(1));
      expect(results, <SttResult>[
        const SttResult('bom', isFinal: false),
        const SttResult('bom dia', isFinal: false),
      ]);
    });
  });

  test('pausa de 1,5 s encerra a frase (RF-M2-05)', () {
    fakeAsync((async) {
      startListening(async);

      engine.session!.emitPartial('bom dia');
      async.flushMicrotasks();
      engine.session!.finalText = 'Bom dia.';

      // Ainda dentro da pausa: nada finaliza.
      async.elapse(sttSentencePause - const Duration(milliseconds: 1));
      expect(results.where((r) => r.isFinal), isEmpty);

      async.elapse(const Duration(milliseconds: 1));
      async.flushMicrotasks();

      expect(results.last, const SttResult('Bom dia.', isFinal: true));
      expect(service.phase, SttPhase.idle);
      expect(audio.stopCount, 1);
    });
  });

  test('cada parcial novo REARMA a pausa — falar sem parar não corta', () {
    fakeAsync((async) {
      startListening(async);

      for (var i = 0; i < 5; i++) {
        engine.session!.emitPartial('palavra $i');
        async.flushMicrotasks();
        async.elapse(const Duration(milliseconds: 1200)); // < 1,5 s
      }

      expect(results.where((r) => r.isFinal), isEmpty);
      expect(service.phase, SttPhase.listening);
    });
  });

  test('silêncio inicial NÃO encerra a sessão antes da primeira fala', () {
    fakeAsync((async) {
      startListening(async);

      async.elapse(const Duration(seconds: 10));

      expect(service.phase, SttPhase.listening);
      expect(results, isEmpty);
    });
  });

  test('auto-stop aos 60 s preserva o último resultado (RF-M2-06)', () {
    fakeAsync((async) {
      startListening(async);

      // Fala contínua: cada segundo rearma a pausa de 1,5 s, que assim nunca
      // dispara. Aos 59 s ainda está escutando — só o teto duro encerra.
      for (var i = 0; i < 59; i++) {
        engine.session!.emitPartial('palavra $i');
        async.flushMicrotasks();
        async.elapse(const Duration(seconds: 1));
      }
      expect(service.phase, SttPhase.listening);

      // A pausa do último parcial venceria em 60,5 s; o teto vence em 60,0 s.
      async.elapse(const Duration(seconds: 2));
      async.flushMicrotasks();

      expect(service.phase, SttPhase.idle);
      final finals = results.where((r) => r.isFinal).toList();
      expect(finals, hasLength(1));
      expect(finals.single.text, 'palavra 58');
    });
  });

  test('final vazio do motor recai no último parcial', () {
    fakeAsync((async) {
      startListening(async);

      engine.session!.emitPartial('quase certo');
      async.flushMicrotasks();
      engine.session!.finalText = ''; // motor não refinou nada

      async.elapse(sttSentencePause);
      async.flushMicrotasks();

      expect(results.last, const SttResult('quase certo', isFinal: true));
    });
  });

  test('stop() manual emite o final uma única vez', () {
    fakeAsync((async) {
      startListening(async);

      engine.session!.emitPartial('oi');
      async.flushMicrotasks();
      engine.session!.finalText = 'Oi.';

      unawaited(service.stop());
      async.flushMicrotasks();
      // A pausa que já estava armada não pode emitir um segundo final.
      async.elapse(sttSentencePause * 2);
      async.flushMicrotasks();

      expect(results.where((r) => r.isFinal), hasLength(1));
      expect(service.phase, SttPhase.idle);
    });
  });

  test('cancel() descarta a sessão sem emitir final e fecha o motor', () {
    fakeAsync((async) {
      startListening(async);

      engine.session!.emitPartial('descartar');
      async.flushMicrotasks();

      unawaited(service.cancel());
      async.flushMicrotasks();
      async.elapse(sttMaxDuration);

      expect(results.where((r) => r.isFinal), isEmpty);
      expect(service.phase, SttPhase.idle);
      expect(engine.session!.stopped, isTrue); // contexto nativo liberado
      expect(audio.stopCount, 1);
    });
  });

  test('falha ao abrir o motor vira AppException(sttEngine)', () {
    fakeAsync((async) {
      engine.startError = StateError('contexto nativo indisponível');

      Object? thrown;
      unawaited(
        service.start(Language.pt).catchError((Object e) => thrown = e),
      );
      async.flushMicrotasks();

      expect(thrown, isA<AppException>());
      expect((thrown! as AppException).code, ErrorCode.sttEngine);
      expect(service.phase, SttPhase.idle);
    });
  });

  test('erro no fluxo de áudio vira AppException no stream de resultados', () {
    fakeAsync((async) {
      startListening(async);

      audio.fail(StateError('microfone tomado por outro app'));
      async.flushMicrotasks();

      expect(errors, hasLength(1));
      expect((errors.single as AppException).code, ErrorCode.sttEngine);
      expect(service.phase, SttPhase.idle);
    });
  });

  test('fim do fluxo de áudio finaliza como uma parada normal', () {
    fakeAsync((async) {
      startListening(async);

      engine.session!.emitPartial('tchau');
      async.flushMicrotasks();
      engine.session!.finalText = 'Tchau.';

      audio.close();
      async.flushMicrotasks();

      expect(results.last, const SttResult('Tchau.', isFinal: true));
      expect(service.phase, SttPhase.idle);
    });
  });

  test('falha ao fechar a sessão vira AppException, não exceção crua', () {
    fakeAsync((async) {
      startListening(async);

      engine.session!.emitPartial('oi');
      async.flushMicrotasks();
      engine.session!.stopError = StateError('isolate morto');

      async.elapse(sttSentencePause);
      async.flushMicrotasks();

      expect(errors, hasLength(1));
      expect((errors.single as AppException).code, ErrorCode.sttEngine);
    });
  });
}
