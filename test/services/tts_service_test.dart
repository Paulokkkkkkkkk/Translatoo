import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:translatoo/core/services/app_exception.dart';
import 'package:translatoo/core/services/tts_service.dart';
import 'package:translatoo/models/language.dart';

/// Engine fake que modela o CONTRATO de sessão do [TtsEngine]: quem fala é o
/// teste (empurra `started`/`completed`/`cancelled` no [emit]), e o [stop]
/// emite `cancelled` quando uma fala chegou a começar (mesmo contrato do motor
/// real).
class _FakeEngine implements TtsEngine {
  final StreamController<TtsEvent> _events =
      StreamController<TtsEvent>.broadcast();

  bool languageAvailable = true;
  bool failConfigure = false;

  /// `true` = o `speak` falha no meio (erro no stream, como o motor real).
  bool failOnSpeak = false;

  final List<String> spoken = <String>[];
  final List<String> configuredLanguages = <String>[];
  final List<(double, double)> configuredVoice = <(double, double)>[];
  int isLanguageAvailableCalls = 0;
  int stopCalls = 0;
  bool _utteranceLive = false;

  @override
  Stream<TtsEvent> get events => _events.stream;

  @override
  Future<bool> isLanguageAvailable(String ttsCode) async {
    isLanguageAvailableCalls++;
    return languageAvailable;
  }

  @override
  Future<void> configure({
    required String languageCode,
    required double rate,
    required double pitch,
  }) async {
    if (failConfigure) throw StateError('sem engine de TTS');
    configuredLanguages.add(languageCode);
    configuredVoice.add((rate, pitch));
  }

  @override
  Future<void> speak(String text) async {
    if (failOnSpeak) {
      _events.addError(StateError('fala falhou no meio'));
      return;
    }
    spoken.add(text);
    _utteranceLive = true;
  }

  /// Interrompe a fala viva (mesmo contrato do motor real: emite cancelled).
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
  late _FakeEngine engine;
  late TtsService service;
  late StreamSubscription<TtsEvent> sub;
  final List<TtsEvent> lifecycle = <TtsEvent>[];
  final List<Object> errors = <Object>[];

  setUp(() {
    engine = _FakeEngine();
    service = TtsService(engine: engine);
    lifecycle.clear();
    errors.clear();
    sub = service.events.listen(
      lifecycle.add,
      onError: (Object e, StackTrace st) => errors.add(e),
    );
  });

  tearDown(() async {
    await sub.cancel();
    await service.dispose();
  });

  group('TtsService — voz ausente (AC-M3-2)', () {
    test(
      'sem voz, lança AppException(ttsVoiceMissing) sem tocar no motor',
      () async {
        engine.languageAvailable = false;
        expect(
          service.speak(language: Language.zh, text: '你好'),
          throwsA(
            isA<AppException>()
                .having((e) => e.code, 'code', ErrorCode.ttsVoiceMissing)
                .having(
                  (e) => e.suggestedAction,
                  'ação',
                  SuggestedAction.openSettings,
                ),
          ),
        );
        expect(engine.spoken, isEmpty);
        expect(engine.configuredLanguages, isEmpty);
      },
    );

    test(
      'isLanguageAvailable consulta o SO uma vez e guarda em cache',
      () async {
        await service.ensureVoice(Language.zh);
        await service.ensureVoice(Language.zh);
        expect(engine.isLanguageAvailableCalls, 1);

        service.refreshVoices(); // app voltou de segundo plano (F2.7)
        await service.ensureVoice(Language.zh);
        expect(engine.isLanguageAvailableCalls, 2);
      },
    );
  });

  group('TtsService — reprodução (AC-M3-1/3)', () {
    test(
      'speak configura idioma de destino e emite started/completed',
      () async {
        await service.speak(language: Language.zh, text: '你好');
        expect(engine.configuredLanguages, [Language.zh.ttsCode]);
        expect(engine.spoken, ['你好']);
        // Defaults do AppSettings: rate normalizado 0,5; pitch 1,0.
        expect(engine.configuredVoice, [(0.5, 1.0)]);
        expect(service.isSpeaking, isTrue);

        engine.emit(const TtsEvent(TtsEventKind.started));
        await pumpEventQueue();
        expect(lifecycle, [const TtsEvent(TtsEventKind.started)]);

        engine.emit(const TtsEvent(TtsEventKind.completed));
        await pumpEventQueue();
        expect(lifecycle, [
          const TtsEvent(TtsEventKind.started),
          const TtsEvent(TtsEventKind.completed),
        ]);
        expect(service.isSpeaking, isFalse);
      },
    );

    test('texto vazio é ignorado (nada vai ao motor)', () async {
      await service.speak(language: Language.en, text: '   ');
      expect(engine.spoken, isEmpty);
      expect(service.isSpeaking, isFalse);
    });

    test(
      'fala nova durante outra fala não vaza evento da sessão velha',
      () async {
        await service.speak(language: Language.zh, text: '第一');
        engine.emit(const TtsEvent(TtsEventKind.started));
        await pumpEventQueue();
        expect(lifecycle, [const TtsEvent(TtsEventKind.started)]);

        // Segunda fala com a primeira ainda no ar: o motor a interrompe sem
        // emitir `cancelled` da sessão velha para o observador.
        lifecycle.clear();
        await service.speak(language: Language.zh, text: '第二');
        await pumpEventQueue();
        expect(lifecycle, isEmpty);

        engine.emit(const TtsEvent(TtsEventKind.started));
        engine.emit(const TtsEvent(TtsEventKind.completed));
        await pumpEventQueue();
        expect(lifecycle, [
          const TtsEvent(TtsEventKind.started),
          const TtsEvent(TtsEventKind.completed),
        ]);
        expect(service.isSpeaking, isFalse);
      },
    );

    test('stop interrompe a fala e devolve ao repouso', () async {
      await service.speak(language: Language.pt, text: 'olá');
      engine.emit(const TtsEvent(TtsEventKind.started));
      await pumpEventQueue();

      lifecycle.clear();
      await service.stop();
      await pumpEventQueue();
      expect(service.isSpeaking, isFalse);
      expect(engine.stopCalls, 1);
      // O `cancelled` do motor é órfão (o serviço já encerrou a sessão): nada
      // de evento duplicado — quem parou foi a própria UI/ViewModel.
      expect(lifecycle, isEmpty);
    });
  });

  group('TtsService — parâmetros de voz', () {
    test('setRate/setPitch chegam ao motor na próxima fala', () async {
      service.setRate(0.8);
      service.setPitch(1.4);
      await service.speak(language: Language.en, text: 'hello');
      expect(engine.configuredVoice, [(0.8, 1.4)]);
    });

    test(
      'valores fora da faixa são limitados (nunca chegam crus ao plugin)',
      () {
        service.setRate(3.0);
        service.setPitch(-1.0);
        expect(service.rate, 1.0);
        expect(service.pitch, 0.5);
      },
    );
  });

  group('TtsService — erro de motor (RN-03)', () {
    test(
      'falha no meio da fala vira AppException no stream e encerra',
      () async {
        engine.failOnSpeak = true;
        await service.speak(language: Language.en, text: 'hello');
        await pumpEventQueue();
        expect(service.isSpeaking, isFalse);
        expect(errors, hasLength(1));
        expect(errors.single, isA<AppException>());
        expect((errors.single as AppException).code, ErrorCode.ttsVoiceMissing);
      },
    );
  });
}
