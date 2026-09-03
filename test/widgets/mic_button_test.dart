import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:translatoo/core/constants/app_constants.dart';
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
import 'package:translatoo/ui/widgets/mic_button.dart';
import 'package:translatoo/ui/widgets/voice_block.dart';
import 'package:translatoo/ui/widgets/waveform.dart';

class _FakeEngine implements SttEngine {
  _FakeSession? session;

  @override
  Future<SttEngineSession> startSession({
    required String modelPath,
    required String languageCode,
  }) async => session = _FakeSession();
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

class _GrantedPermissionApi implements MicPermissionApi {
  @override
  Future<PermissionStatus> status() async => PermissionStatus.granted;

  @override
  Future<PermissionStatus> request() async => PermissionStatus.granted;

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
  }) async => '[eco]$text';

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

/// `pumpAndSettle` é PROIBIDO enquanto a escuta está ativa: o anel pulsante
/// (§5.8) agenda frames para sempre, e o settle avançaria o relógio até estourar
/// o teto de 60 s do `SttService`, encerrando a sessão sozinho. Avança-se o
/// tempo da transição do modo na mão.
Future<void> _settleMode(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 400));
}

/// Encerra a sessão antes do fim do teste: o teto de 60 s do `SttService` é um
/// `Timer` real, e o `flutter_test` reprova qualquer timer pendente na hora em
/// que a árvore é descartada.
Future<void> _endSession(WidgetTester tester, SpeechViewModel speech) async {
  await speech.cancel();
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 400));
}

void main() {
  late _FakeEngine engine;
  late SpeechViewModel speech;
  late TranslatorViewModel translator;
  late ModelManagerService models;
  late SttService stt;
  late _FakeAudio audio;
  late bool voiceMode;

  /// Monta apenas o botão dentro de um Scaffold — a integração com a tela
  /// inteira já é coberta por translate_screen_test.dart.
  Future<void> pumpButton(
    WidgetTester tester, {
    bool dictationAvailable = true,
  }) async {
    voiceMode = false;
    engine = _FakeEngine();
    models = ModelManagerService(api: _ReadyModelApi());
    await models.refreshAll();
    translator = TranslatorViewModel(
      translationService: TranslationService(primary: _EchoBackend()),
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
    speech = SpeechViewModel(
      sttService: stt,
      permissionService: MicPermissionService(api: _GrantedPermissionApi()),
      translatorViewModel: translator,
      dictationAvailable: dictationAvailable,
    );

    addTearDown(() async {
      speech.dispose();
      await stt.dispose();
      translator.dispose();
      models.dispose();
    });

    // Réplica mínima da tela: o 🎤 leva ao MODO VOZ (§4), que é onde a escuta
    // acontece desde a #58 — a folha sobreposta da F2.5 não existe mais.
    await tester.pumpWidget(
      ChangeNotifierProvider<SpeechViewModel>.value(
        value: speech,
        child: MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) => Column(
                children: <Widget>[
                  if (voiceMode) const VoiceBlock(height: 200),
                  Row(
                    children: <Widget>[
                      ?MicButton.maybe(
                        context,
                        onPressed: () {
                          setState(() => voiceMode = true);
                          unawaited(speech.start());
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  testWidgets('build sem modelo de STT OMITE o botão da árvore (F2.1b)', (
    tester,
  ) async {
    await pumpButton(tester, dictationAvailable: false);

    expect(find.byType(MicButton), findsNothing);
    // Ausente, não desabilitado: nenhum controle inerte na tela.
    expect(find.byType(IconButton), findsNothing);
  });

  testWidgets('ocioso usa contorno na cor de ação', (tester) async {
    await pumpButton(tester);

    final icon = tester.widget<Icon>(find.byType(Icon));
    expect(icon.icon, Icons.mic_none_outlined);
    expect(
      icon.color,
      Theme.of(tester.element(find.byType(MicButton))).colorScheme.primary,
    );
  });

  testWidgets(
    'escutando: ícone preenchido em colorError e bloco de voz aberto',
    (tester) async {
      await pumpButton(tester);

      await tester.tap(find.byType(IconButton).first);
      await _settleMode(tester);

      expect(speech.state, SpeechState.listening);
      expect(find.byType(VoiceBlock), findsOneWidget);

      final icon = tester.widget<Icon>(find.byIcon(Icons.mic));
      expect(
        icon.color,
        Theme.of(tester.element(find.byType(MicButton))).colorScheme.error,
      );

      await _endSession(tester, speech);
    },
  );

  testWidgets('parcial aparece no bloco de voz e é SUBSTITUÍDO a cada emissão', (
    tester,
  ) async {
    await pumpButton(tester);
    await tester.tap(find.byType(IconButton).first);
    await _settleMode(tester);

    // O parcial é renderizado no PAINEL DE ORIGEM (§5.1), que não faz parte
    // desta réplica mínima — aqui basta provar que o ViewModel substitui, e
    // nunca concatena. A renderização é coberta em translate_screen_test.dart.
    engine.session!.emitPartial('bom');
    await tester.pump();
    expect(speech.partialText, 'bom');

    engine.session!.emitPartial('bom dia');
    await tester.pump();
    expect(speech.partialText, 'bom dia');

    await _endSession(tester, speech);
  });

  testWidgets('fim da escuta sai do modo voz sozinho (AC-M2-1 / AC-M2-3)', (
    tester,
  ) async {
    await pumpButton(tester);
    await tester.tap(find.byType(IconButton).first);
    await _settleMode(tester);
    expect(find.byType(VoiceBlock), findsOneWidget);

    // A pausa de 1,5 s do SttService encerra a sessão; a folha some sem que
    // ninguém a feche explicitamente.
    engine.session!
      ..emitPartial('bom dia')
      ..finalText = 'Bom dia.';
    await tester.pump();
    await tester.pump(sttSentencePause);
    await _settleMode(tester);
    await tester.pump(const Duration(milliseconds: 400));

    // O MODO permanece — quem sai dele é o botão de modo. O que termina é a
    // ESCUTA: diferente da folha da F2.5, que se fechava sozinha, o bloco de
    // voz é uma tela, não um overlay transitório.
    expect(find.byType(VoiceBlock), findsOneWidget);
    expect(speech.state, SpeechState.idle);
    expect(translator.sourceText, 'Bom dia.');
  });

  testWidgets('onda aparece só quando há nível real de microfone (§5.7)', (
    tester,
  ) async {
    await pumpButton(tester);
    await tester.tap(find.byType(IconButton).first);
    await _settleMode(tester);

    // Sem nível: instrução, nenhuma barra inventada (§5.7).
    expect(find.byType(Waveform), findsNothing);
    expect(find.textContaining('Speak'), findsWidgets);

    audio.emitLevel(0.6);
    await tester.pump();

    expect(find.byType(Waveform), findsOneWidget);

    await _endSession(tester, speech);
  });

  testWidgets('a pílula encerra a escuta e dispara a tradução (§5.7)', (
    tester,
  ) async {
    await pumpButton(tester);
    await tester.tap(find.byType(IconButton).first);
    await _settleMode(tester);

    engine.session!
      ..emitPartial('bom dia')
      ..finalText = 'Bom dia.';
    await tester.pump();

    // A pílula troca de rótulo durante a escuta e é o controle de parada.
    await tester.tap(find.text('Listening…'));
    await _settleMode(tester);

    expect(speech.state, SpeechState.idle);
    expect(translator.sourceText, 'Bom dia.');
  });
}
