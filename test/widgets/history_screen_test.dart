import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:translatoo/core/services/model_manager_service.dart';
import 'package:translatoo/core/services/storage_service.dart';
import 'package:translatoo/core/services/translation_backend.dart';
import 'package:translatoo/core/services/translation_service.dart';
import 'package:translatoo/core/theme/app_theme.dart';
import 'package:translatoo/models/language.dart';
import 'package:translatoo/models/language_pair.dart';
import 'package:translatoo/models/translation_record.dart';
import 'package:translatoo/state/library_view_model.dart';
import 'package:translatoo/state/translator_view_model.dart';
import 'package:translatoo/ui/screens/history_screen.dart';
import 'package:translatoo/ui/widgets/history_card.dart';

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

/// O `StorageService` agrupa gravações com debounce de 500 ms, e o
/// `flutter_test` reprova qualquer Timer pendente quando a árvore é
/// descartada. `pumpAndSettle` sozinho não resolve: um Timer que não agenda
/// frame nenhum não é avançado por ele.
Future<void> settle(WidgetTester tester) async {
  await tester.pumpAndSettle();
  await tester.pump(const Duration(milliseconds: 600));
  await tester.pumpAndSettle();
}

void main() {
  late StorageService storage;
  late LibraryViewModel library;
  late TranslatorViewModel translator;
  late ModelManagerService models;

  var seq = 0;
  TranslationRecord record(
    String source, {
    Language from = Language.pt,
    Language to = Language.en,
  }) {
    seq++;
    return TranslationRecord(
      id: 'id-$seq',
      sourceText: source,
      translatedText: 'traduzido $source',
      sourceLang: from,
      targetLang: to,
      // Mais recente = timestamp maior; a lista já vem ordenada pelo VM.
      timestamp: DateTime.now().toUtc().subtract(Duration(minutes: seq)),
    );
  }

  Future<void> pump(
    WidgetTester tester, {
    List<TranslationRecord> seed = const <TranslationRecord>[],
  }) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    SharedPreferences.setMockInitialValues(<String, Object>{});
    storage = StorageService(prefs: await SharedPreferences.getInstance());
    await storage.initialize();

    models = ModelManagerService(api: _ReadyModelApi());
    await models.refreshAll();
    translator = TranslatorViewModel(
      translationService: TranslationService(primary: _EchoBackend()),
      modelManager: models,
    );
    library = LibraryViewModel(storageService: storage);
    // Semeia do mais antigo para o mais novo: addRecord insere no topo.
    for (final r in seed.reversed) {
      library.addRecord(r);
    }

    addTearDown(() {
      library.dispose();
      translator.dispose();
      models.dispose();
    });

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<LibraryViewModel>.value(value: library),
          ChangeNotifierProvider<TranslatorViewModel>.value(value: translator),
        ],
        // Tema REAL do app: o ★ de favorito lê `AppSemanticColors`, que só
        // existe no ThemeData do projeto. Um MaterialApp padrão faria o card
        // estourar — e é melhor descobrir isso aqui do que no aparelho.
        child: MaterialApp(
          theme: AppTheme.light(),
          home: const Scaffold(body: HistoryScreen()),
        ),
      ),
    );
    await settle(tester);
  }

  testWidgets('estado vazio quando não há traduções', (tester) async {
    await pump(tester);

    expect(find.text('No translations yet.'), findsOneWidget);
    expect(find.byType(HistoryCard), findsNothing);
  });

  testWidgets('AC-M4-1: 3 traduções, da mais recente para a mais antiga', (
    tester,
  ) async {
    await pump(
      tester,
      seed: <TranslationRecord>[
        record('mais recente'),
        record('do meio'),
        record('mais antiga'),
      ],
    );

    expect(find.byType(HistoryCard), findsNWidgets(3));

    final cards = tester
        .widgetList<HistoryCard>(find.byType(HistoryCard))
        .toList();
    expect(cards.map((c) => c.record.sourceText), <String>[
      'mais recente',
      'do meio',
      'mais antiga',
    ]);
  });

  testWidgets('AC-M4-2: swipe exclui e "Desfazer" restaura na posição', (
    tester,
  ) async {
    await pump(
      tester,
      seed: <TranslationRecord>[
        record('primeira'),
        record('segunda'),
        record('terceira'),
      ],
    );

    await tester.drag(find.text('segunda'), const Offset(-600, 0));
    await settle(tester);

    expect(library.history.map((r) => r.sourceText), <String>[
      'primeira',
      'terceira',
    ]);

    await tester.tap(find.text('Undo'));
    await settle(tester);

    // Volta ao MEIO, não ao topo.
    expect(library.history.map((r) => r.sourceText), <String>[
      'primeira',
      'segunda',
      'terceira',
    ]);
  });

  testWidgets('busca filtra a lista sem apagar o histórico', (tester) async {
    await pump(
      tester,
      seed: <TranslationRecord>[record('bom dia'), record('boa noite')],
    );

    await tester.enterText(find.byType(TextField), 'noite');
    await settle(tester);

    expect(find.byType(HistoryCard), findsOneWidget);
    expect(library.history, hasLength(2));
  });

  testWidgets('chip de par filtra nos DOIS sentidos', (tester) async {
    await pump(
      tester,
      seed: <TranslationRecord>[
        record('pt para en'),
        record('en para pt', from: Language.en, to: Language.pt),
        record('pt para zh', to: Language.zh),
      ],
    );

    await tester.tap(find.text('Português ↔ English'));
    await settle(tester);

    expect(find.byType(HistoryCard), findsNWidgets(2));
  });

  testWidgets('"Limpar tudo" pede confirmação e preserva favoritos', (
    tester,
  ) async {
    await pump(
      tester,
      seed: <TranslationRecord>[record('comum'), record('guardada')],
    );
    library.toggleFavorite(library.history.last.id); // 'guardada'
    await settle(tester);

    await tester.tap(find.widgetWithText(TextButton, 'Clear all'));
    await settle(tester);
    expect(find.text('Clear history?'), findsOneWidget);

    await tester.tap(find.widgetWithText(FilledButton, 'Clear all'));
    await settle(tester);

    expect(library.history.map((r) => r.sourceText), <String>['guardada']);
  });

  testWidgets('tocar no card devolve texto E par de idiomas ao Tradutor', (
    tester,
  ) async {
    await pump(
      tester,
      seed: <TranslationRecord>[
        record('reabrir', from: Language.en, to: Language.zh),
      ],
    );

    await tester.tap(find.text('reabrir'));
    await settle(tester);

    expect(translator.sourceText, 'reabrir');
    expect(translator.sourceLang, Language.en);
    expect(translator.targetLang, Language.zh);
  });
}
