import 'package:connectivity_plus_platform_interface/connectivity_plus_platform_interface.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:translatoo/core/constants/app_constants.dart';
import 'package:translatoo/core/services/connectivity_service.dart';
import 'package:translatoo/core/services/model_manager_service.dart';
import 'package:translatoo/core/services/storage_service.dart';
import 'package:translatoo/core/services/stt_service.dart';
import 'package:translatoo/core/services/translation_service.dart';
import 'package:translatoo/core/services/tts_service.dart';
import 'package:translatoo/core/services/whisper_model_installer.dart';
import 'package:translatoo/core/services/whisper_stt_engine.dart';
import 'package:translatoo/main.dart';
import 'package:translatoo/ui/screens/translate_screen.dart';

import 'responsive_doubles.dart';

/// Os TRÊS breakpoints do PRD §4.1 (F4.2).
///
/// O teste monta o app inteiro (`TranslatooApp`), e não uma tela isolada: o
/// breakpoint de 1024 dp muda a shell — troca gaveta por rail —, e isso só
/// aparece com o `Scaffold` real.
void main() {
  late StorageService storage;
  late ConnectivityService connectivity;
  late ModelManagerService models;

  Future<void> pumpAt(WidgetTester tester, Size size) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    SharedPreferences.setMockInitialValues(<String, Object>{});
    storage = StorageService(prefs: await SharedPreferences.getInstance());
    await storage.initialize();

    ConnectivityPlatform.instance = FakeConnectivity();
    connectivity = ConnectivityService();
    models = ModelManagerService(api: ReadyModelApi());
    await models.refreshAll();

    addTearDown(() {
      connectivity.dispose();
      models.dispose();
      storage.dispose();
    });

    await tester.pumpWidget(
      TranslatooApp(
        storage: storage,
        connectivity: connectivity,
        translationService: TranslationService(primary: EchoBackend()),
        modelManager: models,
        sttService: SttService(
          sttEngine: WhisperSttEngine(),
          audioSource: const SilentAudio(),
          modelInstaller: WhisperModelInstaller(
            assetKey: AppConstants.whisperFullModelAsset,
          ),
        ),
        ttsService: TtsService(engine: SilentTtsEngine()),
      ),
    );
    await tester.pumpAndSettle();
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pumpAndSettle();
  }

  testWidgets('320 dp: coluna única, sem overflow (uma mão)', (tester) async {
    await pumpAt(tester, const Size(320, 720));

    expect(find.byType(NavigationRail), findsNothing);
    expect(find.byType(TranslateScreen), findsOneWidget);
    // Overflow em Flutter vira exceção de layout capturada pelo framework.
    expect(tester.takeException(), isNull);
  });

  testWidgets('600 dp: painéis lado a lado, navegação ainda na gaveta', (
    tester,
  ) async {
    await pumpAt(tester, const Size(700, 900));

    expect(find.byType(NavigationRail), findsNothing);
    expect(find.byType(Drawer), findsNothing); // fechada, mas disponível
    expect(tester.takeException(), isNull);
  });

  testWidgets('1024 dp: NavigationRail substitui a gaveta', (tester) async {
    await pumpAt(tester, const Size(1200, 900));

    expect(find.byType(NavigationRail), findsOneWidget);

    // A gaveta some: manter as duas seria duas navegações para o mesmo lugar.
    final scaffold = tester.widget<Scaffold>(find.byType(Scaffold).first);
    expect(scaffold.drawer, isNull);
    expect(tester.takeException(), isNull);
  });

  testWidgets('o rail navega entre os três destinos', (tester) async {
    await pumpAt(tester, const Size(1200, 900));

    await tester.tap(find.text('History').last);
    await tester.pumpAndSettle();
    expect(find.text('No translations yet.'), findsOneWidget);

    await tester.tap(find.text('Settings').last);
    await tester.pumpAndSettle();
    expect(find.text('Theme'), findsOneWidget);
  });
}
