import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/constants/app_strings.dart';
import 'core/services/connectivity_service.dart';
import 'core/services/mlkit_translation_backend.dart';
import 'core/services/model_manager_service.dart';
import 'core/services/storage_service.dart';
import 'core/services/tflite_translation_backend.dart';
import 'core/services/translation_service.dart';
import 'core/theme/app_theme.dart';
import 'state/connection_view_model.dart';
import 'state/translator_view_model.dart';
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

  runApp(
    TranslatooApp(
      storage: storage,
      connectivity: connectivity,
      translationService: translationService,
      modelManager: modelManager,
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
  });

  final StorageService storage;
  final ConnectivityService connectivity;
  final TranslationService translationService;
  final ModelManagerService modelManager;

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
        ChangeNotifierProvider<TranslatorViewModel>(
          create: (_) => TranslatorViewModel(
            translationService: translationService,
            modelManager: modelManager,
          ),
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
