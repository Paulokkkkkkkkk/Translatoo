import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/constants/app_constants.dart';
import 'core/constants/app_strings.dart';
import 'core/services/connectivity_service.dart';
import 'core/services/flutter_tts_engine.dart';
import 'core/services/mic_permission_service.dart';
import 'core/services/mlkit_translation_backend.dart';
import 'core/services/model_manager_service.dart';
import 'core/services/record_audio_source.dart';
import 'core/services/share_service.dart';
import 'core/services/storage_service.dart';
import 'core/services/stt_service.dart';
import 'core/services/tflite_translation_backend.dart';
import 'core/services/translation_service.dart';
import 'core/services/tts_service.dart';
import 'core/services/whisper_model_installer.dart';
import 'core/services/whisper_stt_engine.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/perf_trace.dart';
import 'models/app_settings.dart';
import 'state/connection_view_model.dart';
import 'state/library_view_model.dart';
import 'state/settings_view_model.dart';
import 'state/speech_view_model.dart';
import 'state/translator_view_model.dart';
import 'state/tts_view_model.dart';
import 'ui/screens/home_screen.dart';

Future<void> main() async {
  final binding = WidgetsFlutterBinding.ensureInitialized();

  // F4.4: cold start medido até o PRIMEIRO frame de verdade — é o instante em
  // que o usuário vê o app, não o instante em que runApp retorna.
  final coldStart = PerfTrace.start(PerfBudget.coldStart);
  binding.addPostFrameCallback((_) => coldStart.stop());

  // Bootstrap mínimo da fundação (F0): storage carregado antes do primeiro
  // frame; conectividade resolve async sem bloquear o cold start (< 2 s).
  final prefs = await SharedPreferences.getInstance();
  final storage = StorageService(prefs: prefs);
  await storage.initialize();

  final connectivity = ConnectivityService();
  unawaited(connectivity.start());

  // ── Composição do motor M1 (F1) ───────────────────────────────────────────
  // Plano A ML Kit + Plano B TFLite atrás da MESMA TranslationBackend
  // interface; fallback transparente controlado por flag (F1.4).
  // O modo híbrido (F4.3) fica DESLIGADO na v1: `cloudBackend` é nulo porque o
  // provedor de API é decisão comercial ainda não tomada. Com ele nulo, o
  // caminho é byte a byte o mesmo de antes da F4.3 — ligar a flag nos Ajustes
  // não muda nada enquanto não houver motor.
  final translationService = TranslationService(
    primary: MlKitTranslationBackend(),
    fallback: TfliteTranslationBackend(),
    isCloudEnabled: () => storage.settings.cloudEnabled,
    isOnline: () => connectivity.isOnline.value,
  );
  final modelManager = ModelManagerService(
    api: MlKitModelManagerApi(),
    online: connectivity.isOnline,
    onMobileData: connectivity.isOnMobileData,
    // F3.6: a preferência `wifiOnly` persistida passa a valer no gate de
    // download (lida na chamada — troca em Ajustes vale já no próximo toque).
    wifiOnlyPreference: () => storage.settings.wifiOnly,
  );
  unawaited(modelManager.refreshAll());

  // ── Composição do ditado M2 (F2) ─────────────────────────────────────────
  // Motor (whisper.cpp) + fonte de áudio (record), cada um atrás da sua
  // interface: trocar qualquer um dos dois é trocar esta linha.
  final sttService = SttService(
    sttEngine: WhisperSttEngine(),
    audioSource: RecordAudioSource(),
    modelInstaller: WhisperModelInstaller(assetKey: AppConstants.sttModelAsset),
  );

  // ── Composição da leitura M3 (F2.6) ──────────────────────────────────────
  // Motor nativo do SO via flutter_tts, atrás da interface TtsEngine.
  final ttsService = TtsService(engine: FlutterTtsEngine());

  runApp(
    TranslatooApp(
      storage: storage,
      connectivity: connectivity,
      translationService: translationService,
      modelManager: modelManager,
      sttService: sttService,
      ttsService: ttsService,
    ),
  );
}

/// Raiz de composição: injeta os serviços via `provider` e monta o
/// MaterialApp com os dois temas de tokens (§3) e resolução pt/en/zh com
/// fallback pt-BR (F0.5).
class TranslatooApp extends StatelessWidget {
  const TranslatooApp({
    super.key,
    required this.storage,
    required this.connectivity,
    required this.translationService,
    required this.modelManager,
    required this.sttService,
    required this.ttsService,
  });

  final StorageService storage;
  final ConnectivityService connectivity;
  final TranslationService translationService;
  final ModelManagerService modelManager;
  final SttService sttService;
  final TtsService ttsService;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<StorageService>.value(value: storage),
        Provider<ConnectivityService>.value(value: connectivity),
        Provider<TranslationService>.value(value: translationService),
        Provider<ModelManagerService>.value(value: modelManager),
        // Compartilhamento (F4.1): sem estado, sem rede — const basta.
        Provider<ShareService>.value(value: const ShareService()),
        ChangeNotifierProvider<ConnectionViewModel>(
          create: (_) => ConnectionViewModel(connectivity),
        ),
        Provider<SttService>.value(value: sttService),
        Provider<TtsService>.value(value: ttsService),
        ChangeNotifierProvider<TranslatorViewModel>(
          create: (_) => TranslatorViewModel(
            translationService: translationService,
            modelManager: modelManager,
            // F3.6: nasce com o último par persistido (AC-M4-3) e grava trocas.
            settings: storage,
          ),
        ),
        // Depende do TranslatorViewModel (autoplay/ditado) e do StorageService
        // (preferências iniciais de voz): só existe depois de ambos na lista.
        ChangeNotifierProxyProvider<TranslatorViewModel, TtsViewModel>(
          create: (context) => TtsViewModel(
            ttsService: context.read<TtsService>(),
            translatorViewModel: context.read<TranslatorViewModel>(),
            autoPlay: context.read<StorageService>().settings.autoPlay,
            rate: context.read<StorageService>().settings.ttsRate,
            pitch: context.read<StorageService>().settings.ttsPitch,
          ),
          update: (_, _, tts) => tts!,
        ),
        // Preferências: depende do TtsViewModel para espelhar rate/pitch na
        // reprodução em curso, e não só na próxima.
        ChangeNotifierProxyProvider<TtsViewModel, SettingsViewModel>(
          create: (context) => SettingsViewModel(
            storageService: storage,
            ttsViewModel: context.read<TtsViewModel>(),
          ),
          update: (_, _, settings) => settings!,
        ),
        // Grava toda tradução concluída no histórico (M4). Como o TtsViewModel,
        // observa o tradutor em vez de a UI ter de lembrar de chamar.
        ChangeNotifierProxyProvider<TranslatorViewModel, LibraryViewModel>(
          create: (context) => LibraryViewModel(
            storageService: storage,
            translatorViewModel: context.read<TranslatorViewModel>(),
          ),
          update: (_, _, library) => library!,
        ),
        // Depende do TranslatorViewModel para entregar o texto ditado: só
        // existe depois dele na lista de providers.
        ChangeNotifierProxyProvider<TranslatorViewModel, SpeechViewModel>(
          create: (context) => SpeechViewModel(
            sttService: sttService,
            permissionService: MicPermissionService(),
            translatorViewModel: context.read<TranslatorViewModel>(),
          ),
          update: (_, _, speech) => speech!,
        ),
      ],
      child: Consumer<SettingsViewModel>(
        builder: (context, settings, _) => MaterialApp(
          onGenerateTitle: (context) => AppStrings.of(context).appName,
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          // Override manual da F3.3 sobre o default `system` da F0 (AC-F3-6).
          themeMode: switch (settings.themeMode) {
            SettingsThemeMode.system => ThemeMode.system,
            SettingsThemeMode.light => ThemeMode.light,
            SettingsThemeMode.dark => ThemeMode.dark,
          },
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('pt', 'BR'),
            Locale('en', 'US'),
            Locale('zh', 'CN'),
          ],
          localeResolutionCallback: (locale, supportedLocales) {
            for (final supported in supportedLocales) {
              if (supported.languageCode.toLowerCase() ==
                  locale?.languageCode.toLowerCase()) {
                return supported;
              }
            }
            return const Locale('pt', 'BR');
          },
          home: const HomeScreen(),
        ),
      ),
    );
  }
}
