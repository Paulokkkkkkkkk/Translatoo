import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:translatoo/core/constants/app_constants.dart';
import 'package:translatoo/core/services/mic_permission_service.dart';
import 'package:translatoo/core/services/model_manager_service.dart';
import 'package:translatoo/core/services/stt_service.dart';
import 'package:translatoo/core/services/translation_backend.dart';
import 'package:translatoo/core/services/translation_service.dart';
import 'package:translatoo/core/services/tts_service.dart';
import 'package:translatoo/core/services/whisper_model_installer.dart';
import 'package:translatoo/core/services/whisper_stt_engine.dart';
import 'package:translatoo/models/language.dart';
import 'package:translatoo/models/language_pair.dart';
import 'package:translatoo/state/speech_view_model.dart';
import 'package:translatoo/state/translator_view_model.dart';
import 'package:translatoo/state/tts_view_model.dart';
import 'package:translatoo/ui/screens/translate_screen.dart';
import 'package:translatoo/ui/widgets/download_progress_card.dart';
import 'package:translatoo/ui/widgets/mode_button.dart';
import 'package:translatoo/ui/widgets/voice_block.dart';

/// Backend de eco determinístico (nunca toca plugin).
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
  }) async => '[${source.mlKitCode}${target.mlKitCode}]$text';

  @override
  void dispose() {}
}

/// API com downloads RETIDOS até [complete] — torna o card de progresso
/// observável nos asserts.
class _GateApi implements ModelManagerApi {
  final Set<Language> installed = <Language>{};
  final Map<Language, Completer<void>> pending = <Language, Completer<void>>{};

  @override
  Future<bool> isModelDownloaded(Language language) async =>
      installed.contains(language);

  @override
  Future<void> downloadModel(
    Language language, {
    required bool isWifiRequired,
  }) {
    final completer = Completer<void>();
    pending[language] = completer;
    return completer.future;
  }

  void complete(Language language) {
    final completer = pending.remove(language);
    if (completer == null) return; // download não estava em curso
    installed.add(language);
    completer.complete();
  }

  @override
  Future<void> deleteModel(Language language) async =>
      installed.remove(language);
}

/// Motor de TTS mudo: a tela lê o ViewModel desde a F2.8 (botão 🔊, erros),
/// mas estes testes nunca acionam a voz — o 🔊 em si é coberto pelos testes de
/// unidade do TtsViewModel.
class _SilentTtsEngine implements TtsEngine {
  @override
  Stream<TtsEvent> get events => const Stream<TtsEvent>.empty();

  @override
  Future<bool> isLanguageAvailable(String ttsCode) async => true;

  @override
  Future<void> configure({
    required String languageCode,
    required double rate,
    required double pitch,
  }) async {}

  @override
  Future<void> speak(String text) async {}

  @override
  Future<void> stop() async {}

  @override
  Future<void> dispose() async {}
}

/// Motor que grava o que falou — para o widget test do 🔊 (F2.8).
class _RecordingTtsEngine implements TtsEngine {
  final List<String> spoken = <String>[];

  @override
  Stream<TtsEvent> get events => const Stream<TtsEvent>.empty();

  @override
  Future<bool> isLanguageAvailable(String ttsCode) async => true;

  @override
  Future<void> configure({
    required String languageCode,
    required double rate,
    required double pitch,
  }) async {}

  @override
  Future<void> speak(String text) async => spoken.add(text);

  /// Contado, não ignorado: é assim que se prova que ir para segundo plano
  /// CALA o sintetizador (F4.6).
  int stops = 0;

  @override
  Future<void> stop() async => stops++;

  @override
  Future<void> dispose() async {}
}

Future<void> _pump(
  WidgetTester tester,
  TranslatorViewModel vm,
  ModelManagerService manager, {
  TtsEngine? ttsEngine,
}) async {
  // Superfície alta: garante snackbar/botões dentro dos limites do hit-test.
  tester.view.physicalSize = const Size(1080, 2400);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });

  // Espelha o estado real dos pacotes antes do primeiro frame.
  await manager.refreshAll();
  await tester.pumpWidget(
    MultiProvider(
      providers: [
        Provider<TranslationService>.value(
          value: TranslationService(primary: _EchoBackend()),
        ),
        Provider<ModelManagerService>.value(value: manager),
        ChangeNotifierProvider<TranslatorViewModel>.value(value: vm),
        // A tela lê o TtsViewModel desde a F2.8 (botão 🔊 e snackbar de voz
        // ausente). Autoplay OFF e voz muda: nenhuma fala real nos testes.
        ChangeNotifierProvider<TtsViewModel>(
          create: (_) => TtsViewModel(
            ttsService: TtsService(engine: ttsEngine ?? _SilentTtsEngine()),
            translatorViewModel: vm,
          ),
        ),
        // A tela lê o SpeechViewModel desde a F2.5 (botão 🎤 e RN-07). Estes
        // testes são da F1.6 e nunca ditam: a fonte de áudio indisponível
        // basta, e o ditado em si é coberto por mic_button_test.dart.
        ChangeNotifierProvider<SpeechViewModel>(
          create: (_) => SpeechViewModel(
            sttService: SttService(
              sttEngine: WhisperSttEngine(),
              audioSource: const _SilentAudio(),
              modelInstaller: WhisperModelInstaller(
                assetKey: AppConstants.whisperFullModelAsset,
              ),
            ),
            permissionService: MicPermissionService(),
            translatorViewModel: vm,
          ),
        ),
      ],
      child: const MaterialApp(
        // Nota (mesma da F0): neste Flutter o MaterialApp ignora `locale` em
        // testes e usa o locale do HOST (en-US). As asserts abaixo usam, por
        // isso, as strings EN de app_strings.dart; a resolução pt/en/zh é
        // coberta pelos testes unitários de AppStrings e validação manual.
        home: Scaffold(body: SafeArea(child: TranslateScreen())),
      ),
    ),
  );
  await tester.pump();
}

TranslatorViewModel _vm(ModelManagerService manager) => TranslatorViewModel(
  translationService: TranslationService(primary: _EchoBackend()),
  modelManager: manager,
);

/// Microfone que nunca abre: estes testes não ditam, e uma captura real
/// exigiria canal de plataforma.
class _SilentAudio implements SttAudioSource {
  const _SilentAudio();

  @override
  Future<Stream<Uint8List>> start() async => const Stream<Uint8List>.empty();

  @override
  Future<void> stop() async {}

  @override
  Stream<double> get amplitude => const Stream<double>.empty();
}

void main() {
  testWidgets('digita → debounce → tradução; contador, ⇄ e limpar', (
    tester,
  ) async {
    final api = _GateApi()..installed.addAll(Language.values);
    final manager = ModelManagerService(api: api);
    final vm = _vm(manager);
    await _pump(tester, vm, manager);

    expect(find.text('0/5000'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'Bom dia');
    await tester.pump(); // typing + contador
    expect(find.text('7/5000'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 850)); // debounce
    await tester.pump();
    await tester.pump();
    expect(find.text('[pten]Bom dia'), findsOneWidget);

    // ⇄ com Semantics própria (RN-06). Strings EN: locale do host nos testes.
    expect(find.bySemanticsLabel('Swap languages'), findsOneWidget);

    await tester.tap(find.byTooltip('Clear'));
    await tester.pump();
    expect(find.text('0/5000'), findsOneWidget);
    expect(find.text('[pten]Bom dia'), findsNothing);

    vm.dispose();
    manager.dispose();
  });

  testWidgets('AC-M1-2 na UI: card de download → pacotes prontos → retomada', (
    tester,
  ) async {
    final api = _GateApi();
    final manager = ModelManagerService(api: api);
    final vm = _vm(manager);
    await _pump(tester, vm, manager);

    await tester.enterText(find.byType(TextField), 'Oi');
    await tester.pump(const Duration(milliseconds: 850));
    await tester.pump();

    // Card sobreposto: nome nativo + progresso inicial.
    expect(find.byType(DownloadProgressCard), findsOneWidget);
    expect(find.text('Português'), findsWidgets);
    // O aviso ficou compacto (uma linha): o progresso divide o texto com o
    // tamanho estimado, em vez de ter linha própria.
    expect(find.textContaining('0%'), findsOneWidget);

    api.complete(Language.pt);
    api.complete(Language.en);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    await tester.pump();

    // Camada de estado retomou sozinha antes da UI refletir.
    expect(vm.status, TranslatorStatus.done);
    expect(find.textContaining('[pten]Oi'), findsOneWidget);
    expect(find.byType(DownloadProgressCard), findsNothing);

    vm.dispose();
    manager.dispose();
  });

  testWidgets('ERR_WIFI_ONLY vira snackbar com "Baixar mesmo assim"', (
    tester,
  ) async {
    final api = _GateApi();
    final manager = ModelManagerService(
      api: api,
      online: ValueNotifier<bool>(true),
      onMobileData: ValueNotifier<bool>(true), // rede medida
    );
    final vm = _vm(manager);
    await _pump(tester, vm, manager);

    await tester.enterText(find.byType(TextField), 'Oi');
    await tester.pump(const Duration(milliseconds: 850));
    await tester.pump();

    // Mensagem da tabela §4.8 com ação sugerida — nunca stacktrace.
    expect(find.text('Download restricted to Wi-Fi'), findsOneWidget);

    // Decisão "Baixar mesmo assim": exercitada no ViewModel (o tap geométrico
    // sobre a snackbar varia conforme o tamanho da superfície de teste).
    await vm.confirmDownloadAnyway();

    // O re-download forçado cria NOVOS pendings na API gateada: concluímos.
    api.complete(Language.pt);
    api.complete(Language.en);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    await tester.pump(const Duration(milliseconds: 50));

    expect(vm.error, isNull);
    expect(vm.status, TranslatorStatus.done);
    expect(find.textContaining('[pten]Oi'), findsOneWidget);
    expect(api.installed, containsAll([Language.pt, Language.en]));

    vm.dispose();
    manager.dispose();
  });

  testWidgets('botão de modo alterna Texto ↔ Voz sem overlay (§5.3 · §9.2)', (
    tester,
  ) async {
    final api = _GateApi()..installed.addAll(Language.values);
    final manager = ModelManagerService(api: api);
    final vm = _vm(manager);
    await _pump(tester, vm, manager);

    // Modo texto: o bloco de voz não existe.
    expect(find.byType(VoiceBlock), findsNothing);
    expect(find.byType(ModeButton), findsOneWidget);

    await tester.tap(find.byType(ModeButton));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    // Um toque bastou — nenhum overlay de escolha entre dois modos (§9.2).
    expect(find.byType(VoiceBlock), findsOneWidget);

    await tester.tap(find.byType(ModeButton));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.byType(VoiceBlock), findsNothing);

    vm.dispose();
    manager.dispose();
  });

  testWidgets('botão TRADUZIR executa imediatamente (ignora debounce)', (
    tester,
  ) async {
    final api = _GateApi()..installed.addAll(Language.values);
    final manager = ModelManagerService(api: api);
    final vm = _vm(manager);
    await _pump(tester, vm, manager);

    await tester.enterText(find.byType(TextField), 'Olá');
    await tester.pump();
    // Único botão primário da tela (sem card de download neste cenário).
    final traduzir = find.byType(FilledButton);
    expect(traduzir, findsOneWidget);
    await tester.tap(traduzir);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 30));

    expect(find.text('[pten]Olá'), findsOneWidget);

    vm.dispose();
    manager.dispose();
  });

  testWidgets(
    '🔊 desabilitado sem resultado; fala a tradução ao tocar (F2.8)',
    (tester) async {
      final api = _GateApi()..installed.addAll(Language.values);
      final manager = ModelManagerService(api: api);
      final vm = _vm(manager);
      final engine = _RecordingTtsEngine();
      await _pump(tester, vm, manager, ttsEngine: engine);

      // Sem resultado: o botão existe, mas está inerte (nenhuma ação).
      IconButton speaker() => tester.widget<IconButton>(
        find.ancestor(
          of: find.byIcon(Icons.volume_up_outlined),
          matching: find.byType(IconButton),
        ),
      );
      expect(speaker().onPressed, isNull);

      await tester.enterText(find.byType(TextField), 'Olá');
      await tester.pump(const Duration(milliseconds: 850));
      await tester.pump();
      expect(find.text('[pten]Olá'), findsOneWidget);

      await tester.tap(find.byTooltip('Listen to translation'));
      await tester.pump();
      expect(engine.spoken, ['[pten]Olá']);

      vm.dispose();
      manager.dispose();
    },
  );

  testWidgets('F4.5: a ordem de foco segue a ordem VISUAL, não a da árvore', (
    tester,
  ) async {
    // O botão de modo é o último filho do `Stack` (precisa desenhar POR CIMA),
    // mas fica visualmente no alto, cavalgando a fronteira entre bloco e
    // painel. Se o foco seguisse a árvore, o leitor de tela o anunciaria por
    // último — depois de tudo o que está abaixo dele na tela. O que salva é a
    // `ReadingOrderTraversalPolicy` padrão, que ordena por geometria; este
    // teste trava isso, porque uma política customizada em algum ancestral
    // futuro quebraria a ordem sem nenhum sintoma visível.
    final api = _GateApi()..installed.addAll(Language.values);
    final manager = ModelManagerService(api: api);
    final vm = _vm(manager);
    await _pump(tester, vm, manager);

    final modeRect = tester.getRect(find.byType(ModeButton));
    final fieldRect = tester.getRect(find.byType(TextField).first);
    expect(
      modeRect.top,
      lessThan(fieldRect.top),
      reason: 'o botão de modo está acima do campo na TELA',
    );

    final policy = FocusTraversalGroup.of(
      tester.element(find.byType(ModeButton)),
    );
    expect(
      policy,
      isA<ReadingOrderTraversalPolicy>(),
      reason:
          'com política de ordem-da-árvore o botão de modo seria anunciado '
          'por último, apesar de estar no alto da tela',
    );

    vm.dispose();
    manager.dispose();
  });

  testWidgets('RN-07: segundo plano encerra a escuta mas NÃO cala a leitura', (
    tester,
  ) async {
    // Parece inconsistente e é deliberado: quem troca de app no meio de uma
    // frase quer terminar de OUVI-LA; microfone aberto fora de vista é outra
    // história. A RN-07 escolheu esse lado, e o teste impede que alguém
    // "conserte" a inconsistência sem passar pelo PRD.
    final api = _GateApi()..installed.addAll(Language.values);
    final manager = ModelManagerService(api: api);
    final vm = _vm(manager);
    final engine = _RecordingTtsEngine();
    await _pump(tester, vm, manager, ttsEngine: engine);

    await tester.enterText(find.byType(TextField), 'Olá');
    await tester.pump(const Duration(milliseconds: 850));
    await tester.pump();
    await tester.tap(find.byTooltip('Listen to translation'));
    await tester.pump();
    expect(engine.spoken, ['[pten]Olá']);

    final antes = engine.stops;
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    await tester.pump();

    expect(
      engine.stops,
      antes,
      reason: 'a RN-07 manda o TTS seguir até concluir ou o SO interromper',
    );

    vm.dispose();
    manager.dispose();
  });

  testWidgets('o botão de modo NÃO pode cobrir a ação do card de download', (
    tester,
  ) async {
    // Este foi o bug que fazia "a tradução não funcionar": o card avisava que
    // faltava o pacote, mas o botão de modo flutuava exatamente sobre o
    // "Baixar". O usuário via o aviso e não conseguia agir sobre ele — e sem
    // pacote, nada traduz. O sintoma não parecia de layout, parecia de motor.
    final api = _GateApi(); // nenhum idioma instalado: o card aparece
    final manager = ModelManagerService(api: api);
    final vm = _vm(manager);
    await _pump(tester, vm, manager);
    await tester.pump();

    expect(find.byType(DownloadProgressCard), findsOneWidget);

    final card = tester.getRect(find.byType(DownloadProgressCard));
    final modeButton = tester.getRect(find.byType(ModeButton));

    expect(
      card.overlaps(modeButton),
      isFalse,
      reason:
          'o card de download precisa ficar ACIMA da pilha, fora do alcance '
          'do botão flutuante — senão sua ação fica inalcançável',
    );

    vm.dispose();
    manager.dispose();
  });
}
