import 'package:flutter/foundation.dart';

import '../core/constants/app_constants.dart';
import '../core/services/app_exception.dart';
import '../core/services/storage_service.dart';
import '../models/language_pair.dart';
import '../models/translation_record.dart';
import 'translator_view_model.dart';

/// Filtro de par de idiomas da tela Histórico (F3.2). `null` = Todos.
///
/// O filtro é **bidirecional**: o chip "PT↔EN" casa tanto pt→en quanto en→pt.
/// Separá-los dobraria a fileira de chips para seis e obrigaria o usuário a
/// lembrar em que direção traduziu — que é justamente o que ele não lembra.
typedef PairFilter = LanguagePair?;

/// Biblioteca de traduções: histórico e favoritos (F3.1 · M4 · PRD §3.4).
///
/// REGRAS implementadas aqui:
/// - **Dedupe** — repetir a mesma origem no mesmo par, em sequência, atualiza a
///   entrada existente em vez de criar outra. Traduzir de novo depois de
///   corrigir um acento não deve encher o histórico de quase-duplicatas.
/// - **FIFO de [AppConstants.historyLimit]** — a 201ª tradução descarta a mais
///   antiga NÃO-favorita. Favorito nunca é descartado automaticamente: o
///   usuário disse explicitamente que aquilo importa.
/// - **`clearHistory()` preserva favoritos** — pelo mesmo motivo.
/// - **`undoDelete()` restaura na POSIÇÃO original**, não no topo. Desfazer
///   devolve ao estado anterior; empurrar para o topo seria outra alteração.
/// - Falha de persistência vira `AppException(ErrorCode.storage)`.
class LibraryViewModel extends ChangeNotifier {
  LibraryViewModel({
    required StorageService storageService,
    TranslatorViewModel? translatorViewModel,
  }) : _storage = storageService,
       _translator = translatorViewModel {
    _history = List<TranslationRecord>.of(_storage.history);
    _favorites = List<TranslationRecord>.of(_storage.favorites);
    _translator?.addListener(_onTranslationCompleted);
  }

  final StorageService _storage;

  /// Fonte das traduções concluídas. Opcional para os testes de regra, que não
  /// precisam de um tradutor para exercitar dedupe, FIFO e filtros.
  final TranslatorViewModel? _translator;

  /// Última tradução gravada, para não registrar de novo a cada `notifyListeners`
  /// do tradutor — ele notifica por muitos motivos além de concluir.
  String? _lastRecordedSignature;

  List<TranslationRecord> _history = <TranslationRecord>[];
  List<TranslationRecord> _favorites = <TranslationRecord>[];

  String _query = '';
  PairFilter _pairFilter;
  ErrorCode? _errorCode;

  /// Última exclusão, guardada para o "Desfazer" da SnackBar (F3.2).
  ({TranslationRecord record, int index})? _lastDeleted;

  // ── Estado observável ────────────────────────────────────────────────────

  /// Histórico completo, do mais recente para o mais antigo.
  List<TranslationRecord> get history => List.unmodifiable(_history);

  List<TranslationRecord> get favorites => List.unmodifiable(_favorites);

  String get query => _query;
  PairFilter get pairFilter => _pairFilter;
  ErrorCode? get errorCode => _errorCode;

  /// Há exclusão desfazível pendente? A UI usa para decidir se mostra a ação.
  bool get canUndo => _lastDeleted != null;

  /// Histórico após busca e filtro — é isto que a lista renderiza.
  List<TranslationRecord> get visibleHistory {
    final normalized = _query.trim().toLowerCase();
    return List.unmodifiable(
      _history.where((record) {
        if (!_matchesPair(record)) return false;
        if (normalized.isEmpty) return true;
        // Busca em origem OU tradução: o usuário lembra de um dos dois lados,
        // e raramente sabe qual.
        return record.sourceText.toLowerCase().contains(normalized) ||
            record.translatedText.toLowerCase().contains(normalized);
      }),
    );
  }

  bool isFavorite(String id) => _favorites.any((r) => r.id == id);

  // ── Escrita ──────────────────────────────────────────────────────────────

  /// Registra uma tradução concluída.
  ///
  /// Dedupe: se a ÚLTIMA entrada tem a mesma origem e o mesmo par, ela é
  /// atualizada (timestamp e resultado) em vez de duplicar. A comparação é só
  /// com a última porque o caso real é retraduzir o que se acabou de digitar —
  /// varrer a lista inteira esconderia repetições legítimas de dias atrás.
  void addRecord(TranslationRecord record) {
    final last = _history.isEmpty ? null : _history.first;
    final isRepeat =
        last != null &&
        last.sourceText == record.sourceText &&
        last.sourceLang == record.sourceLang &&
        last.targetLang == record.targetLang;

    if (isRepeat) {
      _history[0] = last.copyWith(
        translatedText: record.translatedText,
        timestamp: record.timestamp,
      );
    } else {
      _history.insert(0, record);
      _enforceLimit();
    }
    _persistHistory();
  }

  /// Alterna favorito. Favoritar uma entrada que o FIFO já descartou do
  /// histórico ainda funciona: o favorito vive na sua própria coleção.
  void toggleFavorite(String id) {
    final index = _history.indexWhere((r) => r.id == id);
    final existing = _favorites.indexWhere((r) => r.id == id);

    if (existing >= 0) {
      _favorites.removeAt(existing);
      if (index >= 0) {
        _history[index] = _history[index].copyWith(isFavorite: false);
      }
    } else {
      final record = index >= 0
          ? _history[index].copyWith(isFavorite: true)
          : null;
      if (record == null) return; // nada a favoritar
      _history[index] = record;
      _favorites.insert(0, record);
    }
    _persistHistory();
    _persistFavorites();
  }

  /// Exclui do histórico guardando a posição para o [undoDelete].
  void delete(String id) {
    final index = _history.indexWhere((r) => r.id == id);
    if (index < 0) return;

    _lastDeleted = (record: _history[index], index: index);
    _history.removeAt(index);
    _favorites.removeWhere((r) => r.id == id);
    _persistHistory();
    _persistFavorites();
  }

  /// Restaura a última exclusão **na posição original** (AC-M4-2).
  void undoDelete() {
    final pending = _lastDeleted;
    if (pending == null) return;
    _lastDeleted = null;

    final index = pending.index.clamp(0, _history.length);
    _history.insert(index, pending.record);
    if (pending.record.isFavorite) _favorites.insert(0, pending.record);
    _persistHistory();
    _persistFavorites();
  }

  /// Descarta a exclusão pendente — chamado quando a SnackBar expira.
  void forgetUndo() {
    if (_lastDeleted == null) return;
    _lastDeleted = null;
    notifyListeners();
  }

  /// Limpa o histórico **preservando os favoritos** (AC da issue).
  void clearHistory() {
    _lastDeleted = null;
    // Favorito continua existindo como entrada de histórico: apagá-lo aqui
    // faria "limpar histórico" excluir o que o usuário marcou para guardar.
    _history = _history.where((r) => r.isFavorite).toList();
    _persistHistory();
  }

  // ── Busca e filtro ───────────────────────────────────────────────────────

  void search(String value) {
    if (_query == value) return;
    _query = value;
    notifyListeners();
  }

  void filterBy(PairFilter pair) {
    if (_pairFilter == pair) return;
    _pairFilter = pair;
    notifyListeners();
  }

  void acknowledgeError() {
    if (_errorCode == null) return;
    _errorCode = null;
    notifyListeners();
  }

  // ── Interno ──────────────────────────────────────────────────────────────

  /// Grava toda tradução concluída (§3.4). O tradutor notifica a cada tecla e
  /// a cada mudança de estado; a assinatura evita gravar a mesma conclusão
  /// várias vezes — o dedupe do [addRecord] cuida do caso do usuário, este
  /// cuida do caso do observador.
  void _onTranslationCompleted() {
    final vm = _translator!;
    if (vm.status != TranslatorStatus.done) return;
    if (vm.sourceText.trim().isEmpty || vm.translatedText.trim().isEmpty) {
      return;
    }

    final signature =
        '${vm.sourceLang.name}|${vm.targetLang.name}|'
        '${vm.sourceText}|${vm.translatedText}';
    if (signature == _lastRecordedSignature) return;
    _lastRecordedSignature = signature;

    final now = DateTime.now().toUtc();
    addRecord(
      TranslationRecord(
        id: now.microsecondsSinceEpoch.toString(),
        sourceText: vm.sourceText,
        translatedText: vm.translatedText,
        sourceLang: vm.sourceLang,
        targetLang: vm.targetLang,
        timestamp: now,
      ),
    );
  }

  bool _matchesPair(TranslationRecord record) {
    final filter = _pairFilter;
    if (filter == null) return true;
    final direct =
        record.sourceLang == filter.source &&
        record.targetLang == filter.target;
    final reverse =
        record.sourceLang == filter.target &&
        record.targetLang == filter.source;
    return direct || reverse;
  }

  /// FIFO: descarta as mais antigas NÃO-favoritas até caber no limite.
  void _enforceLimit() {
    if (_history.length <= AppConstants.historyLimit) return;
    for (var i = _history.length - 1; i >= 0; i--) {
      if (_history.length <= AppConstants.historyLimit) break;
      if (!_history[i].isFavorite) {
        _history.removeAt(i);
      }
    }
  }

  void _persistHistory() => _guard(() => _storage.saveHistory(_history));

  void _persistFavorites() => _guard(() => _storage.saveFavorites(_favorites));

  /// Fronteira RN-03: falha de persistência vira `ERR_STORAGE` observável, e
  /// nunca uma exceção crua subindo para a UI.
  void _guard(void Function() write) {
    try {
      write();
      _errorCode = null;
    } catch (e) {
      _errorCode = ErrorCode.storage;
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _translator?.removeListener(_onTranslationCompleted);
    super.dispose();
  }
}
