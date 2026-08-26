import 'dart:async';

import 'package:connectivity_plus_platform_interface/connectivity_plus_platform_interface.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:translatoo/core/constants/app_colors.dart';
import 'package:translatoo/core/constants/app_spacing.dart';
import 'package:translatoo/core/services/connectivity_service.dart';
import 'package:translatoo/core/services/storage_service.dart';
import 'package:translatoo/core/theme/app_theme.dart';
import 'package:translatoo/main.dart';

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

    // Nota: nesta versão do Flutter o MaterialApp lê o locale da instância
    // real da plataforma (host = en-US), ignorando overrides de teste. As
    // expectativas abaixo usam o idioma do ambiente de teste; a resolução
    // pt/en/zh com fallback pt-BR é verificada nos testes unitários de
    // AppStrings (AC-F0-2) e na validação manual em device.

    await tester.pumpWidget(
      TranslatooApp(storage: storage, connectivity: connectivity),
    );
    await tester.pumpAndSettle();

    // Aba inicial Translate: rótulo da NavigationBar + título do placeholder.
    expect(find.text('Translate'), findsWidgets);
    expect(find.byType(NavigationBar), findsOneWidget);

    // Badge informativo offline no AppBar (mock sem conectividade):
    expect(find.text('Offline'), findsOneWidget);

    // Navegação → History (antes da troca há um único 'History'):
    await tester.tap(find.text('History'));
    await tester.pumpAndSettle();
    expect(
      find.text('Your translations are stored only on this device.'),
      findsOneWidget,
    );

    // Navegação → Settings:
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
    // Raio padrão aplicado aos cartões (§3.3).
    final card = theme!.cardTheme;
    expect(
      card.shape,
      isA<RoundedRectangleBorder>().having(
        (shape) => shape.borderRadius,
        'borderRadius',
        BorderRadius.circular(AppSpacing.radius),
      ),
    );
  });
}
