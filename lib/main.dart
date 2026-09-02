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
import 'core/services/storage_service.dart';
import 'core/services/stt_service.dart';
import 'core/services/tflite_translation_backend.dart';
import 'core/services/translation_service.dart';
import 'core/services/tts_service.dart';
import 'core/services/whisper_model_installer.dart';
import 'core/services/whisper_stt_engine.dart';
import 'core/theme/app_theme.dart';
import 'state/connection_view_model.dart';
import 'state/speech_view_model.dart';
import 'state/translator_view_model.dart';
import 'state/tts_view_model.dart';
import 'ui/screens/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

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
  final translationService = TranslationService(
    primary: MlKitTranslationBackend(),
    fallback: TfliteTranslationBackend(),
  );
  final modelManager = ModelManagerService(
    api: MlKitModelManagerApi(),
    online: connectivity.isOnline,
    onMobileData: connectivity.isOnMobileData,
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
        ChangeNotifierProvider<ConnectionViewModel>(
          create: (_) => ConnectionViewModel(connectivity),
        ),
        Provider<SttService>.value(value: sttService),
        Provider<TtsService>.value(value: ttsService),
        ChangeNotifierProvider<TranslatorViewModel>(
          create: (_) => TranslatorViewModel(
            translationService: translationService,
            modelManager: modelManager,
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
      child: MaterialApp(
        onGenerateTitle: (context) => AppStrings.of(context).appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
        // v1 segue o sistema; override manual chega na F3 (Ajustes).
        themeMode: ThemeMode.system,
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
    );
  }
}
