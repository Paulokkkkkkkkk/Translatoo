import 'dart:async';
import 'dart:typed_data';

import 'package:connectivity_plus_platform_interface/connectivity_plus_platform_interface.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:translatoo/core/constants/app_colors.dart';
import 'package:translatoo/core/constants/app_constants.dart';
import 'package:translatoo/core/constants/app_spacing.dart';
import 'package:translatoo/core/services/connectivity_service.dart';
import 'package:translatoo/core/services/model_manager_service.dart';
import 'package:translatoo/core/services/storage_service.dart';
import 'package:translatoo/core/services/stt_service.dart';
import 'package:translatoo/core/services/translation_backend.dart';
import 'package:translatoo/core/services/translation_service.dart';
import 'package:translatoo/core/services/tts_service.dart';
import 'package:translatoo/core/services/whisper_model_installer.dart';
import 'package:translatoo/core/services/whisper_stt_engine.dart';
import 'package:translatoo/core/theme/app_theme.dart';
import 'package:translatoo/main.dart';
import 'package:translatoo/models/language.dart';
import 'package:translatoo/models/language_pair.dart';

class _FakePlatform extends ConnectivityPlatform {
  _FakePlatform(this.initialResults);

  final List<ConnectivityResult> initialResults;
  final StreamController<List<ConnectivityResult>> events =
      StreamController<List<ConnectivityResult>>.broadcast();

  @override
  Future<List<ConnectivityResult>> checkConnectivity() async => initialResults;

  @override
  Stream<List<ConnectivityResult>> get onConnectivityChanged => events.stream;
}

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

/// Voz que nunca fala: estes testes não acionam o 🔊, e o flutter_tts real
/// exigiria canal de plataforma.
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

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('shell navega pelas 3 abas e exibe badge offline (AC-F0-1)', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final prefs = await SharedPreferences.getInstance();
    final storage = StorageService(prefs: prefs);
    await storage.initialize();

    final platform = _FakePlatform([ConnectivityResult.none]);
    final originalPlatform = ConnectivityPlatform.instance;
    ConnectivityPlatform.instance = platform;
    addTearDown(() => ConnectivityPlatform.instance = originalPlatform);

    final connectivity = ConnectivityService();
    await connectivity.start();

    // Motor M1 stubado (F1): pacotes "instalados" para não exibir o card de
    // download (evitaria pumpAndSettle com progresso indeterminado).
    final translationService = TranslationService(primary: _StubBackend());
    final manager = ModelManagerService(api: _StubApi());
    await manager.refreshAll();

    // Nota: nesta versão do Flutter o MaterialApp lê o locale da instância
    // real da plataforma (host = en-US), ignorando overrides de teste. As
    // expectativas abaixo usam o idioma do ambiente de teste; a resolução
    // pt/en/zh com fallback pt-BR é verificada nos testes unitários de
    // AppStrings (AC-F0-2) e na validação manual em device.

    await tester.pumpWidget(
      TranslatooApp(
        storage: storage,
        connectivity: connectivity,
        translationService: translationService,
        modelManager: manager,
        // Composição do M2 (F2.5): a shell só precisa que exista; o ditado em
        // si é coberto por mic_button_test.dart.
        sttService: SttService(
          sttEngine: WhisperSttEngine(),
          audioSource: const _SilentAudio(),
          modelInstaller: WhisperModelInstaller(
            assetKey: AppConstants.whisperFullModelAsset,
          ),
        ),
        // Composição do M3 (F2.6): idem — existe para a shell não quebrar; a
        // reprodução em si é coberta por tts_view_model_test.dart.
        ttsService: TtsService(engine: _SilentTtsEngine()),
      ),
    );
    await tester.pumpAndSettle();

    // Badge informativo offline no AppBar (mock sem conectividade):
    expect(find.text('Offline'), findsOneWidget);

    // A navegação vive na GAVETA desde a decisão da §10 (opção A): os destinos
    // só existem depois de abrir o ☰. Enquanto ela está fechada, o rodapé fica
    // livre para a LanguageBar de largura total (§5.2).
    expect(find.byType(NavigationBar), findsNothing);
    expect(find.text('History'), findsNothing);

    final scaffold = tester.firstState<ScaffoldState>(find.byType(Scaffold));
    scaffold.openDrawer();
    await tester.pumpAndSettle();
    expect(find.byType(NavigationDrawer), findsOneWidget);

    // Navegação → History:
    await tester.tap(find.text('History'));
    await tester.pumpAndSettle();
    expect(
      find.text('Your translations are stored only on this device.'),
      findsOneWidget,
    );

    // Navegação → Settings:
    scaffold.openDrawer();
    await tester.pumpAndSettle();
    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();
    expect(find.text('App preferences will appear here.'), findsOneWidget);
  });

  testWidgets('tema dark nasce exclusivamente dos tokens', (tester) async {
    ColorScheme? scheme;
    ThemeData? theme;

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark(),
        home: Builder(
          builder: (context) {
            theme = Theme.of(context);
            scheme = theme!.colorScheme;
            return const Scaffold(body: SizedBox.shrink());
          },
        ),
      ),
    );

    expect(scheme!.primary, AppColorsDark.colorPrimary);
    expect(theme!.scaffoldBackgroundColor, AppColorsDark.colorBackground);
    expect(scheme!.error, AppColorsDark.colorError);
    // Card é PAINEL, e painel usa radiusLg (design_system §2, issue #53).
    final card = theme!.cardTheme;
    expect(
      card.shape,
      isA<RoundedRectangleBorder>().having(
        (shape) => shape.borderRadius,
        'borderRadius',
        BorderRadius.circular(AppSpacing.radiusLg),
      ),
    );
  });
}

/// Backend stub p/ o shell (nenhuma chamada real ao plugin nos testes).
class _StubBackend implements TranslationBackend {
  @override
  String get id => 'stub';

  @override
  Future<bool> isModelDownloaded(Language language) async => true;

  @override
  Future<bool> isReady(LanguagePair pair) async => true;

  @override
  Future<String> translate({
    required Language source,
    required Language target,
    required String text,
  }) async => text;

  @override
  void dispose() {}
}

/// API stub: todos os pacotes sempre instalados.
class _StubApi implements ModelManagerApi {
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
