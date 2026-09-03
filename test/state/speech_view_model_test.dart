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
import 'package:translatoo/core/services/whisper_model_installer.dart';
import 'package:translatoo/models/language.dart';
import 'package:translatoo/models/language_pair.dart';
import 'package:translatoo/state/speech_view_model.dart';
import 'package:translatoo/state/translator_view_model.dart';

// ── Dublês do STT ──────────────────────────────────────────────────────────

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
  final StreamController<Uint8List> _pcm = StreamController<Uint8List>();
  final StreamController<double> _amplitude =
      StreamController<double>.broadcast();

  void emitLevel(double level) => _amplitude.add(level);

  @override
  Stream<double> get amplitude => _amplitude.stream;

  @override
  Future<Stream<Uint8List>> start() async => _pcm.stream;

  @override
  Future<void> stop() async {}
}

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

// ── Dublês de permissão e tradução ─────────────────────────────────────────

class _FakePermissionApi implements MicPermissionApi {
  _FakePermissionApi(this.current);

  PermissionStatus current;
  PermissionStatus? afterRequest;
  int openSettingsCount = 0;

  @override
  Future<PermissionStatus> status() async => current;

  @override
  Future<PermissionStatus> request() async => current = afterRequest ?? current;

  @override
  Future<bool> openSettings() async {
    openSettingsCount++;
    return true;
  }
}

/// Backend que traduz prefixando o par — o mesmo truque do teste da F1.5.
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
  late _FakePermissionApi permissionApi;
  late _EchoBackend backend;
  late TranslatorViewModel translator;
  late ModelManagerService models;
  late SttService stt;
  late SpeechViewModel vm;
  late _FakeAudio audio;

  Future<void> build({
    PermissionStatus permission = PermissionStatus.granted,
  }) async {
    engine = _FakeEngine();
    permissionApi = _FakePermissionApi(permission);
    backend = _EchoBackend();
    models = ModelManagerService(api: _ReadyModelApi());
    await models.refreshAll();

    translator = TranslatorViewModel(
      translationService: TranslationService(primary: backend),
      modelManager: models,
    );
    audio = _FakeAudio();
    stt = SttService(
      sttEngine: engine,
      audioSource: audio,
      modelInstaller: WhisperModelInstaller(
        assetKey: AppConstants.whisperFullModelAsset,
        storage: _InstalledStorage(),
      ),
    );
    vm = SpeechViewModel(
      sttService: stt,
      permissionService: MicPermissionService(api: permissionApi),
      translatorViewModel: translator,
    );
  }

  tearDown(() {
    vm.dispose();
    translator.dispose();
    models.dispose();
  });

  group('onda do ditado (F2.2b · §5.7)', () {
    test('sem nível de microfone a UI não desenha onda', () async {
      await build();
      await vm.start();

      expect(vm.hasAudioLevel, isFalse);
      expect(vm.waveformLevels.every((level) => level == 0), isTrue);
    });

    test(
      'nível real alimenta as barras, do mais antigo ao mais recente',
      () async {
        await build();
        await vm.start();

        audio
          ..emitLevel(0.2)
          ..emitLevel(0.9);
        await pumpEventQueue();

        expect(vm.hasAudioLevel, isTrue);
        expect(vm.waveformLevels.last, 0.9);
        expect(vm.waveformLevels[vm.waveformLevels.length - 2], 0.2);
      },
    );

    test(
      'o histórico tem tamanho fixo — 60 s de escuta não vazam memória',
      () async {
        await build();
        await vm.start();
        final size = vm.waveformLevels.length;

        for (var i = 0; i < size * 3; i++) {
          audio.emitLevel(0.5);
        }
        await pumpEventQueue();

        expect(vm.waveformLevels, hasLength(size));
      },
    );

    test('encerrar a escuta zera a onda', () async {
      await build();
      await vm.start();
      audio.emitLevel(0.8);
      await pumpEventQueue();
      expect(vm.hasAudioLevel, isTrue);

      engine.session!.finalText = 'pronto';
      await vm.stop();
      await pumpEventQueue();

      expect(vm.hasAudioLevel, isFalse);
    });

    test('nível fora da escuta é ignorado', () async {
      await build();

      audio.emitLevel(0.7);
      await pumpEventQueue();

      expect(vm.hasAudioLevel, isFalse);
    });
  });

  test('start leva a listening quando a permissão já está concedida', () async {
    await build();

    await vm.start();

    expect(vm.state, SpeechState.listening);
    expect(vm.isDictating, isTrue);
    expect(vm.errorCode, isNull);
  });

  test('parciais atualizam partialText SUBSTITUINDO o anterior', () async {
    await build();
    await vm.start();

    engine.session!.emitPartial('bom');
    await pumpEventQueue();
    expect(vm.partialText, 'bom');

    engine.session!.emitPartial('bom dia');
    await pumpEventQueue();
    expect(vm.partialText, 'bom dia'); // substituído, não concatenado
  });

  test('resultado final dispara a tradução imediata', () async {
    await build();
    await vm.start();

    engine.session!
      ..emitPartial('bom dia')
      ..finalText = 'Bom dia.';
    await pumpEventQueue();

    await vm.stop();
    await pumpEventQueue();

    expect(vm.state, SpeechState.idle);
    expect(vm.finalText, 'Bom dia.');
    expect(vm.partialText, isEmpty);
    expect(backend.translated, <String>['Bom dia.']);
    expect(translator.translatedText, '[pten]Bom dia.');
  });

  test('final vazio não traduz nem apaga o campo', () async {
    await build();
    translator.onTextChanged('texto que estava lá');
    await vm.start();

    engine.session!.finalText = '   ';
    await vm.stop();
    await pumpEventQueue();

    expect(backend.translated, isEmpty);
    expect(translator.sourceText, 'texto que estava lá');
  });

  test('cancelar restaura o texto anterior e não traduz (AC-M2-4)', () async {
    await build();
    translator.onTextChanged('rascunho anterior');
    await vm.start();

    engine.session!.emitPartial('fala descartada');
    await pumpEventQueue();

    await vm.cancel();
    await pumpEventQueue();

    expect(vm.state, SpeechState.idle);
    expect(vm.partialText, isEmpty);
    expect(translator.sourceText, 'rascunho anterior');
    expect(backend.translated, isEmpty);
  });

  test('background durante a escuta FINALIZA com o parcial (RN-07)', () async {
    await build();
    await vm.start();

    engine.session!
      ..emitPartial('metade da frase')
      ..finalText = 'metade da frase';
    await pumpEventQueue();

    vm.onAppBackgrounded();
    await pumpEventQueue();

    expect(vm.state, SpeechState.idle);
    expect(vm.finalText, 'metade da frase');
    expect(backend.translated, <String>['metade da frase']);
  });

  group('transições inválidas são ignoradas, nunca lançam', () {
    test('stop() em idle', () async {
      await build();
      await expectLater(vm.stop(), completes);
      expect(vm.state, SpeechState.idle);
    });

    test('cancel() em idle', () async {
      await build();
      await expectLater(vm.cancel(), completes);
      expect(vm.state, SpeechState.idle);
    });

    test('background fora da escuta', () async {
      await build();
      vm.onAppBackgrounded();
      expect(vm.state, SpeechState.idle);
    });

    test('start() duplo não abre duas sessões', () async {
      await build();
      await vm.start();
      final first = engine.session;

      await vm.start();

      expect(identical(engine.session, first), isTrue);
      expect(vm.state, SpeechState.listening);
    });
  });

  group('permissão', () {
    test('negada vira erro com ação de nova tentativa', () async {
      await build(permission: PermissionStatus.denied);
      permissionApi.afterRequest = PermissionStatus.denied;

      await vm.start();

      expect(vm.state, SpeechState.error);
      expect(vm.errorCode, ErrorCode.micPermission);
      expect(vm.errorAction, SuggestedAction.retry);
    });

    test('negada para sempre oferece abrir configurações (AC-M2-2)', () async {
      await build(permission: PermissionStatus.permanentlyDenied);

      await vm.start();

      expect(vm.state, SpeechState.error);
      expect(vm.errorAction, SuggestedAction.openSettings);

      await vm.openAppSettings();
      expect(permissionApi.openSettingsCount, 1);
    });

    test('recusar o diálogo explicativo volta a idle, sem erro', () async {
      await build(permission: PermissionStatus.denied);

      await vm.start(onPermissionNeeded: () async => false);

      expect(vm.state, SpeechState.idle);
      expect(vm.errorCode, isNull);
    });

    test('o diálogo explicativo vem ANTES do pedido ao sistema', () async {
      await build(permission: PermissionStatus.denied);
      permissionApi.afterRequest = PermissionStatus.granted;
      var askedBeforeRequest = false;

      await vm.start(
        onPermissionNeeded: () async {
          askedBeforeRequest = permissionApi.current == PermissionStatus.denied;
          return true;
        },
      );

      expect(askedBeforeRequest, isTrue);
      expect(vm.state, SpeechState.listening);
    });
  });

  test('falha do motor vira estado de erro, não exceção', () async {
    await build();
    engine.startError = StateError('contexto nativo indisponível');

    await expectLater(vm.start(), completes);

    expect(vm.state, SpeechState.error);
    expect(vm.errorCode, ErrorCode.sttEngine);
  });

  test('acknowledgeError devolve o botão ao normal', () async {
    await build(permission: PermissionStatus.permanentlyDenied);
    await vm.start();
    expect(vm.state, SpeechState.error);

    vm.acknowledgeError();

    expect(vm.state, SpeechState.idle);
    expect(vm.errorCode, isNull);
  });
}
