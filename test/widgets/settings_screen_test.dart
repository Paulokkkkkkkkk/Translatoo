import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:translatoo/core/services/storage_service.dart';
import 'package:translatoo/core/theme/app_theme.dart';
import 'package:translatoo/models/app_settings.dart';
import 'package:translatoo/models/language.dart';
import 'package:translatoo/models/translation_record.dart';
import 'package:translatoo/state/library_view_model.dart';
import 'package:translatoo/state/settings_view_model.dart';
import 'package:translatoo/ui/screens/settings_screen.dart';

/// O `StorageService` agrupa gravações com debounce de 500 ms, e o
/// `flutter_test` reprova Timer pendente ao descartar a árvore.
Future<void> settle(WidgetTester tester) async {
  await tester.pumpAndSettle();
  await tester.pump(const Duration(milliseconds: 600));
  await tester.pumpAndSettle();
}

void main() {
  late StorageService storage;
  late SettingsViewModel settings;
  late LibraryViewModel library;

  Future<void> pump(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 3200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    SharedPreferences.setMockInitialValues(<String, Object>{});
    storage = StorageService(prefs: await SharedPreferences.getInstance());
    await storage.initialize();
    settings = SettingsViewModel(storageService: storage);
    library = LibraryViewModel(storageService: storage);

    addTearDown(() {
      settings.dispose();
      library.dispose();
      storage.dispose();
    });

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<SettingsViewModel>.value(value: settings),
          ChangeNotifierProvider<LibraryViewModel>.value(value: library),
        ],
        child: MaterialApp(
          theme: AppTheme.light(),
          home: const Scaffold(body: SettingsScreen()),
        ),
      ),
    );
    await settle(tester);
  }

  testWidgets('mostra todas as seções de preferência', (tester) async {
    await pump(tester);

    expect(find.text('Default language pair'), findsOneWidget);
    expect(find.text('Theme'), findsOneWidget);
    expect(find.textContaining('Version'), findsOneWidget);
    // Declaração de privacidade: precisa bater com a política publicada
    // (RF-REL-03), então tem de estar visível na tela.
    expect(find.textContaining('device'), findsWidgets);
  });

  testWidgets('AC-F3-6: alternar o tema persiste no storage', (tester) async {
    await pump(tester);
    expect(settings.themeMode, SettingsThemeMode.system);

    await tester.tap(find.text('Dark'));
    await settle(tester);

    expect(settings.themeMode, SettingsThemeMode.dark);
    expect(storage.settings.themeMode, SettingsThemeMode.dark);
  });

  testWidgets('autoplay e somente Wi-Fi alternam e persistem', (tester) async {
    await pump(tester);

    await tester.tap(
      find.widgetWithText(
        SwitchListTile,
        'Listen to translation automatically',
      ),
    );
    await settle(tester);
    expect(storage.settings.autoPlay, isTrue);

    await tester.tap(
      find.widgetWithText(SwitchListTile, 'Download models over Wi-Fi only'),
    );
    await settle(tester);
    expect(storage.settings.wifiOnly, isFalse);
  });

  testWidgets('slider de velocidade mostra o valor numérico', (tester) async {
    await pump(tester);

    // A issue pede o número ao lado do rótulo: "rápido"/"lento" não dizem onde
    // o usuário está na escala.
    expect(
      find.text(storage.settings.ttsRate.toStringAsFixed(1)),
      findsWidgets,
    );
    expect(find.byType(Slider), findsNWidgets(2));
  });

  testWidgets('limpar histórico pede confirmação e preserva favoritos', (
    tester,
  ) async {
    await pump(tester);
    final now = DateTime.now().toUtc();
    library
      ..addRecord(
        TranslationRecord(
          id: 'a',
          sourceText: 'comum',
          translatedText: 'common',
          sourceLang: Language.pt,
          targetLang: Language.en,
          timestamp: now,
        ),
      )
      ..addRecord(
        TranslationRecord(
          id: 'b',
          sourceText: 'guardada',
          translatedText: 'kept',
          sourceLang: Language.pt,
          targetLang: Language.en,
          timestamp: now,
        ),
      );
    library.toggleFavorite('b');
    await settle(tester);

    await tester.tap(find.text('Clear history'));
    await settle(tester);
    expect(find.text('Clear history?'), findsOneWidget);

    await tester.tap(find.widgetWithText(FilledButton, 'Clear all'));
    await settle(tester);

    expect(library.history.map((r) => r.sourceText), <String>['guardada']);
  });

  testWidgets('escolher como destino o idioma de origem TROCA os dois', (
    tester,
  ) async {
    await pump(tester);
    expect(settings.sourceLanguage, Language.pt);
    expect(settings.targetLanguage, Language.en);

    // Dropdown do destino é o segundo da tela.
    await tester.tap(find.byType(DropdownButton<Language>).last);
    await settle(tester);
    await tester.tap(find.text('Português').last);
    await settle(tester);

    expect(settings.targetLanguage, Language.pt);
    expect(
      settings.sourceLanguage,
      Language.en,
      reason: 'RN-01: trocar é mais útil que recusar em silêncio',
    );
  });
}
