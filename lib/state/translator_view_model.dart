import 'dart:async';

import 'package:flutter/foundation.dart';

import '../core/constants/app_constants.dart';
import '../core/services/app_exception.dart';
import '../core/services/model_manager_service.dart';
import '../core/services/storage_service.dart';
import '../core/services/translation_service.dart';
import '../core/utils/perf_trace.dart';
import '../models/language.dart';
import '../models/language_pair.dart';
import '../models/model_state.dart';

/// Ciclo de vida observável da tela Traduzir (F1.5 / PRD §3.1).
enum TranslatorStatus { idle, typing, translating, done, error }

/// ViewModel do tradutor (F1.5): estado único e observável entre os cartões.
///
/// REGRAS DO PLANO implementadas aqui:
/// - debounce de 800 ms em `onTextChanged`; `translateNow()` ignora o debounce;
/// - `swapLanguages` troca idiomas E textos e retraduz (AC-M1-3);
/// - bloqueios durante `translating` (swap/seleção ignorados, não enfileirados);
/// - ausência de pacote NÃO é erro: dispara download e arma
///   `_pendingAutoTranslate` — quando o par fica `ready`, a tradução pendente
///   executa sozinha (AC-M1-2);
/// - `acceptDictatedText` é o gancho estável para o STT da Fase 2;
/// - nenhuma exceção crua escapa: tudo vira [AppException] em [error].
/// - F3.6 (RF-M4-05): com [settings] injetado, o par de idiomas nasce do
///   persistido e toda troca (⇄/seleção) é gravada na hora — o "último par"
///   sobrevive ao restart (AC-M4-3).
class TranslatorViewModel extends ChangeNotifier {
  TranslatorViewModel({
    required TranslationService translationService,
    required ModelManagerService modelManager,
    StorageService? settings,
  }) : _translation = translationService,
       _models = modelManager,
       _settings = settings {
    if (settings != null) {
      // `_readSettings` do StorageService já garante origem ≠ destino (o par
      // inválido persistido cai no default pt→en) — sem revalidar aqui.
      _sourceLang = settings.settings.srcLang;
      _targetLang = settings.settings.tgtLang;
    }
    _models.states.addListener(_onModelStatesChanged);
  }

  final TranslationService _translation;
  final ModelManagerService _models;

  /// Persistência do último par (opcional: os testes de tradução não usam).
  final StorageService? _settings;

  Language _sourceLang = Language.pt;
  Language _targetLang = Language.en;
  String _sourceText = '';
  String _translatedText = '';
  TranslatorStatus _status = TranslatorStatus.idle;
  AppException? _error;
  String? _blockedLanguageLabel;
  bool _isTruncated = false;
  bool _pendingAutoTranslate = false;

  /// A próxima conclusão de tradução nasceu de um ditado (F2.7 / RF-M3-06)?
  ///
  /// Traduções vindas do microfone SEMPRE são lidas em voz alta, mesmo com o
  /// autoplay desligado. O sinal é de consumo único: o `TtsViewModel` o lê
  /// quando a tradução conclui e o limpa imediatamente.
  bool _fromDictation = false;
  Timer? _debounce;

  // ── Estado observável ────────────────────────────────────────────────────
  Language get sourceLang => _sourceLang;
  Language get targetLang => _targetLang;
  String get sourceText => _sourceText;
  String get translatedText => _translatedText;
  TranslatorStatus get status => _status;
  AppException? get error => _error;

  /// Rótulo nativo do idioma sem pacote (para `errModelNotDownloaded`).
  String? get blockedLanguageLabel => _blockedLanguageLabel;

  /// Entrada foi cortada no limite de 5.000 chars (aviso na UI).
  bool get isTruncated => _isTruncated;

  bool get isTranslating => _status == TranslatorStatus.translating;

  /// Flag interna do Plano B (F1.4) — UI exibe apenas badge discreto.
  bool get usesAlternativeEngine => _translation.usesAlternativeEngine;

  /// Modo híbrido (F4.3): a última tradução saiu do aparelho porque a nuvem
  /// não respondeu. Só vira badge quando o modo está LIGADO — com ele
  /// desligado, "local" é o normal e informar seria ruído.
  bool get resultWasLocalFallback =>
      _translation.cloudActive && _translation.lastResultWasLocal;

  /// Este build tem ditado? (F2.1b) A `ui/` pergunta ao ViewModel, nunca ao
  /// flavor. Quando `false`, o 🎤 é OMITIDO da árvore de widgets na F2.5 —
  /// não renderizado desabilitado: um controle permanentemente inerte é pior
  /// que sua ausência.
  bool get canDictate => AppConstants.hasEmbeddedSttModels;

  ModelState stateFor(Language language) => _models.stateFor(language);

  bool isPairReady() =>
      _models.stateFor(_sourceLang) is ModelReady &&
      _models.stateFor(_targetLang) is ModelReady;

  // ── Entrada de texto ─────────────────────────────────────────────────────

  /// Chamado a cada tecla. Aplica truncamento (RF-M1-04) e agenda tradução
  /// automática com debounce de 800 ms (RF-M1-03).
  void onTextChanged(String raw) {
    // Digitação é gesto manual: apaga o sinal de ditado pendente (o
    // `acceptDictatedText` o religa DEPOIS deste método, se for o caso).
    _fromDictation = false;
    var value = raw;
    if (value.length > AppConstants.maxInputChars) {
      value = _truncateToLimit(value);
      _isTruncated = true;
    } else {
      _isTruncated = false;
    }
    _sourceText = value;
    _cancelDebounce();

    if (value.trim().isEmpty) {
      _status = TranslatorStatus.idle;
      notifyListeners();
      return;
    }
    _status = TranslatorStatus.typing;
    _debounce = Timer(AppConstants.translateDebounce, () {
      unawaited(_translate());
    });
    notifyListeners();
  }

  /// Truncamento seguro de UTF-16: nunca divide um par surrogate ao meio.
  String _truncateToLimit(String value) {
    var end = AppConstants.maxInputChars;
    if (end > 0 &&
        end < value.length &&
        _isHighSurrogate(value.codeUnitAt(end - 1)) &&
        _isLowSurrogate(value.codeUnitAt(end))) {
      end--;
    }
    return value.substring(0, end);
  }

  static bool _isHighSurrogate(int unit) => unit >= 0xD800 && unit <= 0xDBFF;
  static bool _isLowSurrogate(int unit) => unit >= 0xDC00 && unit <= 0xDFFF;

  void _cancelDebounce() {
    _debounce?.cancel();
    _debounce = null;
  }

  // ── Tradução ─────────────────────────────────────────────────────────────

  /// Tradução imediata (botão Traduzir / gancho STT) — ignora o debounce.
  Future<void> translateNow() => _translate();

  Future<void> _translate() async {
    _cancelDebounce();
    if (_sourceText.trim().isEmpty) {
      if (_status != TranslatorStatus.idle) {
        _status = TranslatorStatus.idle;
        notifyListeners();
      }
      return;
    }
    // Bloqueio durante tradução em curso (regra F1.5).
    if (_status == TranslatorStatus.translating) return;

    // Pacotes ausentes não são erro: viram fluxo de download (AC-M1-2).
    final missing = <Language>[
      if (_models.stateFor(_sourceLang) is! ModelReady) _sourceLang,
      if (_models.stateFor(_targetLang) is! ModelReady) _targetLang,
    ];
    if (missing.isNotEmpty) {
      _pendingAutoTranslate = true;
      _blockedLanguageLabel = missing.first.displayName;
      _status = TranslatorStatus.idle;
      for (final language in missing) {
        if (_models.stateFor(language) is ModelNotDownloaded) {
          unawaited(_startDownload(language));
        }
      }
      notifyListeners();
      return;
    }

    _pendingAutoTranslate = false;
    _error = null;
    _status = TranslatorStatus.translating;
    notifyListeners();
    final trace = PerfTrace.start(PerfBudget.translation);
    try {
      final result = await _translation.translate(
        source: _sourceLang,
        target: _targetLang,
        text: _sourceText,
      );
      trace.stop(
        detail:
            '${_sourceLang.bcp47Code}->${_targetLang.bcp47Code} '
            '${_sourceText.length} chars '
            '${_translation.lastResultWasLocal ? 'local' : 'nuvem'}',
      );
      _translatedText = result;
      // O pacote que faltava chegou: o rótulo guardado para a mensagem de erro
      // não vale mais. Deixá-lo aqui faria um erro FUTURO e sem relação nomear
      // o idioma errado.
      _blockedLanguageLabel = null;
      _status = TranslatorStatus.done;
    } on AppException catch (e) {
      _error = e;
      _blockedLanguageLabel ??= _targetLang.displayName;
      _status = TranslatorStatus.error;
    } catch (e, st) {
      _error = AppException(
        ErrorCode.translationFailed,
        cause: e,
        stackTrace: st,
      );
      _status = TranslatorStatus.error;
    }
    notifyListeners();
  }

  Future<void> _startDownload(Language language, {bool force = false}) async {
    try {
      await _models.downloadModel(language, force: force);
    } on AppException catch (e) {
      _error = e;
      _blockedLanguageLabel = language.displayName;
      _status = TranslatorStatus.error;
      notifyListeners();
    }
  }

  /// Ação "Baixar mesmo assim" (ERR_WIFI_ONLY): força SEM alterar preferência.
  Future<void> confirmDownloadAnyway() async {
    _error = null;
    final missing = <Language>[
      if (_models.stateFor(_sourceLang) is ModelNotDownloaded) _sourceLang,
      if (_models.stateFor(_targetLang) is ModelNotDownloaded) _targetLang,
    ];
    if (missing.isEmpty) {
      await _translate();
      return;
    }
    for (final language in missing) {
      unawaited(_startDownload(language, force: true));
    }
    notifyListeners();
  }

  /// Ação "Tentar novamente" da tabela §4.8.
  void retryLastAction() {
    _error = null;
    unawaited(_translate());
    notifyListeners();
  }

  /// Par já pré-aquecido — não repetir a cada notificação do gerenciador.
  LanguagePair? _warmedPair;

  /// Retomada automática pós-download (AC-M1-2): notificação do gerenciador.
  void _onModelStatesChanged() {
    if (_pendingAutoTranslate && isPairReady()) {
      _pendingAutoTranslate = false;
      unawaited(_translate());
    } else if (isPairReady()) {
      // F4.4: assim que o par fica pronto, paga a carga do modelo fora do
      // caminho crítico. Sem isto, o custo aparece na PRIMEIRA tradução —
      // justamente quando o usuário está olhando o resultado.
      _warmUpCurrentPair();
    }
    notifyListeners();
  }

  void _warmUpCurrentPair() {
    final pair = LanguagePair(source: _sourceLang, target: _targetLang);
    if (_warmedPair == pair) return;
    _warmedPair = pair;
    unawaited(_translation.warmUp(pair));
  }

  // ── Idiomas ──────────────────────────────────────────────────────────────

  /// Pré-aquece o par corrente se ele já estiver pronto. Chamado na troca de
  /// idioma: o par novo tem outro modelo, e a carga dele é outra espera.
  void warmUpIfReady() {
    if (isPairReady()) _warmUpCurrentPair();
  }

  /// ⇄ troca idiomas E textos e retraduz (AC-M1-3); bloqueado durante tradução.
  void swapLanguages() {
    if (_status == TranslatorStatus.translating) return;
    _cancelDebounce();
    _fromDictation = false;
    final language = _sourceLang;
    _sourceLang = _targetLang;
    _targetLang = language;
    final text = _sourceText;
    _sourceText = _translatedText;
    _translatedText = text;
    _isTruncated = false;
    _error = null;
    _persistPair();
    if (_sourceText.trim().isEmpty) {
      _status = TranslatorStatus.idle;
      notifyListeners();
      return;
    }
    unawaited(_translate());
  }

  void selectSource(Language language) {
    if (language == _sourceLang || _status == TranslatorStatus.translating) {
      return;
    }
    if (language == _targetLang) {
      swapLanguages();
      return;
    }
    _sourceLang = language;
    _error = null;
    _fromDictation = false;
    _clearStaleResult();
    _persistPair();
    notifyListeners();
    if (_sourceText.trim().isNotEmpty) unawaited(_translate());
    warmUpIfReady();
  }

  void selectTarget(Language language) {
    if (language == _targetLang || _status == TranslatorStatus.translating) {
      return;
    }
    if (language == _sourceLang) {
      swapLanguages();
      return;
    }
    _targetLang = language;
    _error = null;
    _fromDictation = false;
    _clearStaleResult();
    _persistPair();
    notifyListeners();
    if (_sourceText.trim().isNotEmpty) unawaited(_translate());
    warmUpIfReady();
  }

  /// Apaga o resultado ao trocar de idioma.
  ///
  /// O texto que está no painel foi traduzido para OUTRO idioma; mantê-lo sob
  /// o rótulo novo afirma uma coisa falsa — o painel dizia "中文" exibindo
  /// inglês. Normalmente a retradução cobre isso em milissegundos, mas quando
  /// o pacote do idioma novo ainda não existe ela não acontece, e a mentira
  /// fica na tela durante todo o download.
  void _clearStaleResult() {
    if (_translatedText.isEmpty) return;
    _translatedText = '';
    _isTruncated = false;
  }

  /// Grava o par corrente (F3.6) — o debounce de 500 ms do storage agrupa
  /// trocas rápidas; sem [settings] injetado é no-op.
  void _persistPair() {
    final storage = _settings;
    if (storage == null) return;
    storage.updateSettings(
      storage.settings.copyWith(srcLang: _sourceLang, tgtLang: _targetLang),
    );
  }

  // ── Ações auxiliares / ciclo de vida ─────────────────────────────────────

  /// Limpa origem e destino.
  void clearSource() {
    _cancelDebounce();
    _sourceText = '';
    _translatedText = '';
    _isTruncated = false;
    _error = null;
    _fromDictation = false;
    _status = TranslatorStatus.idle;
    notifyListeners();
  }

  /// GANCHO DA FASE 2 (F2/M2): texto ditado chega pronto e dispara tradução
  /// imediata — nenhum ajuste na UI quando o STT entrar.
  void acceptDictatedText(String text) {
    onTextChanged(text);
    // Sinal p/ o TTS (F2.7): o sinal é limpo por quem o consome (a conclusão
    // da tradução), não aqui — um `onTextChanged` em seguida não pode apagá-lo.
    _fromDictation = true;
    unawaited(translateNow());
  }

  /// Lê e LIMPA o sinal "esta tradução veio de um ditado" (consulta única).
  ///
  /// O consumo acontece na conclusão (`status == done`): se a tradução falhou,
  /// o sinal morre no próximo gesto manual (digitar troca o texto e limpa em
  /// [onTextChanged]), sem nunca virar fala fantasma de uma ação do usuário.
  bool consumeDictatedFlag() {
    final dictated = _fromDictation;
    _fromDictation = false;
    return dictated;
  }

  /// Devolve o campo de origem ao estado anterior a um ditado cancelado
  /// (AC-M2-4, F2.4). Ao contrário de [onTextChanged], NÃO agenda tradução:
  /// desistir de falar não pode disparar trabalho nenhum.
  void restoreSourceText(String text) {
    _cancelDebounce();
    _sourceText = text;
    _isTruncated = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _cancelDebounce();
    _models.states.removeListener(_onModelStatesChanged);
    super.dispose();
  }
}
