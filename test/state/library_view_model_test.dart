import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:translatoo/core/constants/app_constants.dart';
import 'package:translatoo/core/services/model_manager_service.dart';
import 'package:translatoo/core/services/storage_service.dart';
import 'package:translatoo/core/services/translation_backend.dart';
import 'package:translatoo/core/services/translation_service.dart';
import 'package:translatoo/models/language.dart';
import 'package:translatoo/models/language_pair.dart';
import 'package:translatoo/models/translation_record.dart';
import 'package:translatoo/state/library_view_model.dart';
import 'package:translatoo/state/translator_view_model.dart';

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

void main() {
  late StorageService storage;
  late LibraryViewModel vm;

  setUp(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    storage = StorageService(prefs: await SharedPreferences.getInstance());
    await storage.initialize();
    vm = LibraryViewModel(storageService: storage);
  });

  tearDown(() => vm.dispose());

  var seq = 0;
  TranslationRecord record({
    required String source,
    String? translated,
    Language from = Language.pt,
    Language to = Language.en,
    bool favorite = false,
  }) => TranslationRecord(
    id: 'id-${seq++}',
    sourceText: source,
    translatedText: translated ?? '[$source]',
    sourceLang: from,
    targetLang: to,
    timestamp: DateTime.utc(2026, 9, 2).add(Duration(seconds: seq)),
    isFavorite: favorite,
  );

  group('dedupe', () {
    test('repetir a mesma origem no mesmo par ATUALIZA em vez de duplicar', () {
      vm
        ..addRecord(record(source: 'bom dia', translated: 'good day'))
        ..addRecord(record(source: 'bom dia', translated: 'good morning'));

      expect(vm.history, hasLength(1));
      expect(vm.history.single.translatedText, 'good morning');
    });

    test('mesma origem em par DIFERENTE cria entrada nova', () {
      vm
        ..addRecord(record(source: 'bom dia'))
        ..addRecord(record(source: 'bom dia', to: Language.zh));

      expect(vm.history, hasLength(2));
    });

    test('repetição não-consecutiva é entrada legítima', () {
      vm
        ..addRecord(record(source: 'bom dia'))
        ..addRecord(record(source: 'boa noite'))
        ..addRecord(record(source: 'bom dia'));

      expect(vm.history, hasLength(3));
    });
  });

  group('capacidade FIFO', () {
    test('a 201ª tradução descarta a mais antiga', () {
      for (var i = 0; i <= AppConstants.historyLimit; i++) {
        vm.addRecord(record(source: 'frase $i'));
      }

      expect(vm.history, hasLength(AppConstants.historyLimit));
      expect(vm.history.first.sourceText, 'frase 200');
      expect(
        vm.history.any((r) => r.sourceText == 'frase 0'),
        isFalse,
        reason: 'a mais antiga saiu',
      );
    });

    test('favorito NUNCA é descartado pelo limite', () {
      vm.addRecord(record(source: 'guardar'));
      vm.toggleFavorite(vm.history.first.id);

      for (var i = 0; i < AppConstants.historyLimit + 50; i++) {
        vm.addRecord(record(source: 'frase $i'));
      }

      expect(
        vm.history.any((r) => r.sourceText == 'guardar'),
        isTrue,
        reason: 'o usuário disse explicitamente que aquilo importa',
      );
      expect(vm.favorites, hasLength(1));
    });
  });

  group('exclusão e desfazer', () {
    test('undoDelete restaura na POSIÇÃO original, não no topo', () {
      vm
        ..addRecord(record(source: 'primeira'))
        ..addRecord(record(source: 'segunda'))
        ..addRecord(record(source: 'terceira'));
      // Ordem: terceira, segunda, primeira.
      final alvo = vm.history[1];

      vm.delete(alvo.id);
      expect(vm.history.map((r) => r.sourceText), <String>[
        'terceira',
        'primeira',
      ]);

      vm.undoDelete();
      expect(vm.history.map((r) => r.sourceText), <String>[
        'terceira',
        'segunda',
        'primeira',
      ]);
    });

    test('undoDelete sem exclusão pendente é no-op', () {
      vm.addRecord(record(source: 'única'));
      expect(vm.canUndo, isFalse);

      vm.undoDelete();

      expect(vm.history, hasLength(1));
    });

    test('forgetUndo descarta a pendência (SnackBar expirou)', () {
      vm.addRecord(record(source: 'x'));
      vm.delete(vm.history.first.id);
      expect(vm.canUndo, isTrue);

      vm
        ..forgetUndo()
        ..undoDelete();

      expect(vm.canUndo, isFalse);
      expect(vm.history, isEmpty);
    });

    test('excluir um favorito o remove das duas coleções', () {
      vm.addRecord(record(source: 'favorita'));
      final id = vm.history.first.id;
      vm
        ..toggleFavorite(id)
        ..delete(id);

      expect(vm.history, isEmpty);
      expect(vm.favorites, isEmpty);
    });
  });

  group('clearHistory', () {
    test('preserva TODOS os favoritos', () {
      vm
        ..addRecord(record(source: 'comum'))
        ..addRecord(record(source: 'importante'));
      vm.toggleFavorite(vm.history.first.id); // 'importante'

      vm.clearHistory();

      expect(vm.history.map((r) => r.sourceText), <String>['importante']);
      expect(vm.favorites, hasLength(1));
    });

    test('sem favoritos, esvazia tudo', () {
      vm
        ..addRecord(record(source: 'a'))
        ..addRecord(record(source: 'b'));

      vm.clearHistory();

      expect(vm.history, isEmpty);
    });
  });

  group('busca', () {
    setUp(() {
      vm
        ..addRecord(record(source: 'Bom dia', translated: 'Good morning'))
        ..addRecord(record(source: 'Boa noite', translated: 'Good evening'));
    });

    test('é case-insensitive na ORIGEM', () {
      vm.search('BOM');
      expect(vm.visibleHistory, hasLength(1));
      expect(vm.visibleHistory.single.sourceText, 'Bom dia');
    });

    test('encontra também pela TRADUÇÃO', () {
      vm.search('evening');
      expect(vm.visibleHistory.single.sourceText, 'Boa noite');
    });

    test('busca vazia devolve tudo', () {
      vm.search('   ');
      expect(vm.visibleHistory, hasLength(2));
    });

    test('não altera o histórico, só a visão', () {
      vm.search('nada que exista');
      expect(vm.visibleHistory, isEmpty);
      expect(vm.history, hasLength(2));
    });
  });

  group('filtro por par', () {
    setUp(() {
      vm
        ..addRecord(record(source: 'pt→en'))
        ..addRecord(record(source: 'en→pt', from: Language.en, to: Language.pt))
        ..addRecord(record(source: 'pt→zh', to: Language.zh));
    });

    test('o chip é BIDIRECIONAL: PT↔EN casa os dois sentidos', () {
      vm.filterBy(const LanguagePair(source: Language.pt, target: Language.en));

      expect(vm.visibleHistory.map((r) => r.sourceText), <String>[
        'en→pt',
        'pt→en',
      ]);
    });

    test('filtro nulo é "Todos"', () {
      vm
        ..filterBy(const LanguagePair(source: Language.pt, target: Language.zh))
        ..filterBy(null);

      expect(vm.visibleHistory, hasLength(3));
    });

    test('busca e filtro se combinam', () {
      vm
        ..filterBy(const LanguagePair(source: Language.pt, target: Language.en))
        ..search('en→pt');

      expect(vm.visibleHistory.single.sourceText, 'en→pt');
    });
  });

  test('grava sozinho a tradução concluída pelo tradutor', () async {
    // Regra §3.4: o histórico observa o tradutor em vez de a UI ter de lembrar
    // de chamar addRecord — o mesmo padrão do TtsViewModel.
    final models = ModelManagerService(api: _ReadyModelApi());
    await models.refreshAll();
    final translator = TranslatorViewModel(
      translationService: TranslationService(primary: _EchoBackend()),
      modelManager: models,
    );
    final library = LibraryViewModel(
      storageService: storage,
      translatorViewModel: translator,
    );
    addTearDown(() {
      library.dispose();
      translator.dispose();
      models.dispose();
    });

    translator.onTextChanged('bom dia');
    await translator.translateNow();
    await pumpEventQueue();

    expect(library.history, hasLength(1));
    expect(library.history.single.sourceText, 'bom dia');

    // Notificações repetidas do tradutor não regravam a mesma conclusão.
    translator.notifyListeners();
    await pumpEventQueue();
    expect(library.history, hasLength(1));
  });

  test('o estado sobrevive a uma nova instância (persistência)', () async {
    vm.addRecord(record(source: 'persistida'));
    vm.toggleFavorite(vm.history.first.id);

    final outra = LibraryViewModel(storageService: storage);
    addTearDown(outra.dispose);

    expect(outra.history.single.sourceText, 'persistida');
    expect(outra.favorites, hasLength(1));
  });
}
