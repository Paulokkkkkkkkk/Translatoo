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
import 'package:translatoo/ui/widgets/listening_sheet.dart';
import 'package:translatoo/ui/widgets/mic_button.dart';

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
/// tempo da transição da folha na mão.
Future<void> _settleSheet(WidgetTester tester) async {
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

  /// Monta apenas o botão dentro de um Scaffold — a integração com a tela
  /// inteira já é coberta por translate_screen_test.dart.
  Future<void> pumpButton(
    WidgetTester tester, {
    bool dictationAvailable = true,
  }) async {
    engine = _FakeEngine();
    models = ModelManagerService(api: _ReadyModelApi());
    await models.refreshAll();
    translator = TranslatorViewModel(
      translationService: TranslationService(primary: _EchoBackend()),
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

    await tester.pumpWidget(
      ChangeNotifierProvider<SpeechViewModel>.value(
        value: speech,
        child: MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => Row(
                children: <Widget>[
                  ?MicButton.maybe(
                    context,
                    onPressed: () => unawaited(
                      speech.start().then((_) {
                        if (speech.state == SpeechState.listening) {
                          unawaited(ListeningSheet.show(context));
                        }
                      }),
                    ),
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

  testWidgets('escutando: ícone preenchido em colorError e folha aberta', (
    tester,
  ) async {
    await pumpButton(tester);

    await tester.tap(find.byType(IconButton).first);
    await _settleSheet(tester);

    expect(speech.state, SpeechState.listening);
    expect(find.byType(ListeningSheet), findsOneWidget);

    final icon = tester.widget<Icon>(find.byIcon(Icons.mic));
    expect(
      icon.color,
      Theme.of(tester.element(find.byType(MicButton))).colorScheme.error,
    );

    await _endSession(tester, speech);
  });

  testWidgets('parcial aparece na folha e é SUBSTITUÍDO a cada emissão', (
    tester,
  ) async {
    await pumpButton(tester);
    await tester.tap(find.byType(IconButton).first);
    await _settleSheet(tester);

    engine.session!.emitPartial('bom');
    await tester.pump();
    expect(find.text('bom'), findsOneWidget);

    engine.session!.emitPartial('bom dia');
    await tester.pump();
    expect(find.text('bom dia'), findsOneWidget);
    expect(find.text('bom'), findsNothing); // substituído, não concatenado

    await _endSession(tester, speech);
  });

  testWidgets('fim da escuta fecha a folha sozinho (AC-M2-1 / AC-M2-3)', (
    tester,
  ) async {
    await pumpButton(tester);
    await tester.tap(find.byType(IconButton).first);
    await _settleSheet(tester);
    expect(find.byType(ListeningSheet), findsOneWidget);

    // A pausa de 1,5 s do SttService encerra a sessão; a folha some sem que
    // ninguém a feche explicitamente.
    engine.session!
      ..emitPartial('bom dia')
      ..finalText = 'Bom dia.';
    await tester.pump();
    await tester.pump(sttSentencePause);
    await _settleSheet(tester);
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.byType(ListeningSheet), findsNothing);
    expect(speech.state, SpeechState.idle);
    expect(translator.sourceText, 'Bom dia.');
  });

  testWidgets('cancelar na folha restaura o texto anterior (AC-M2-4)', (
    tester,
  ) async {
    await pumpButton(tester);
    translator.onTextChanged('rascunho');
    await tester.tap(find.byType(IconButton).first);
    await _settleSheet(tester);

    engine.session!.emitPartial('fala descartada');
    await tester.pump();

    await tester.tap(find.text('Cancel'));
    await _settleSheet(tester);
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.byType(ListeningSheet), findsNothing);
    expect(translator.sourceText, 'rascunho');
  });
}
