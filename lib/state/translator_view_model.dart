import 'dart:async';

import 'package:flutter/foundation.dart';

import '../core/constants/app_constants.dart';
import '../core/services/app_exception.dart';
import '../core/services/model_manager_service.dart';
import '../core/services/translation_service.dart';
import '../models/language.dart';
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
class TranslatorViewModel extends ChangeNotifier {
  TranslatorViewModel({
    required TranslationService translationService,
    required ModelManagerService modelManager,
  }) : _translation = translationService,
       _models = modelManager {
    _models.states.addListener(_onModelStatesChanged);
  }

  final TranslationService _translation;
  final ModelManagerService _models;

  Language _sourceLang = Language.pt;
  Language _targetLang = Language.en;
  String _sourceText = '';
  String _translatedText = '';
  TranslatorStatus _status = TranslatorStatus.idle;
  AppException? _error;
  String? _blockedLanguageLabel;
  bool _isTruncated = false;
  bool _pendingAutoTranslate = false;
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
    try {
      final result = await _translation.translate(
        source: _sourceLang,
        target: _targetLang,
        text: _sourceText,
      );
      _translatedText = result;
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

  /// Retomada automática pós-download (AC-M1-2): notificação do gerenciador.
  void _onModelStatesChanged() {
    if (_pendingAutoTranslate && isPairReady()) {
      _pendingAutoTranslate = false;
      unawaited(_translate());
    }
    notifyListeners();
  }

  // ── Idiomas ──────────────────────────────────────────────────────────────

  /// ⇄ troca idiomas E textos e retraduz (AC-M1-3); bloqueado durante tradução.
  void swapLanguages() {
    if (_status == TranslatorStatus.translating) return;
    _cancelDebounce();
    final language = _sourceLang;
    _sourceLang = _targetLang;
    _targetLang = language;
    final text = _sourceText;
    _sourceText = _translatedText;
    _translatedText = text;
    _isTruncated = false;
    _error = null;
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
    notifyListeners();
    if (_sourceText.trim().isNotEmpty) unawaited(_translate());
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
    notifyListeners();
    if (_sourceText.trim().isNotEmpty) unawaited(_translate());
  }

  // ── Ações auxiliares / ciclo de vida ─────────────────────────────────────

  /// Limpa origem e destino.
  void clearSource() {
    _cancelDebounce();
    _sourceText = '';
    _translatedText = '';
    _isTruncated = false;
    _error = null;
    _status = TranslatorStatus.idle;
    notifyListeners();
  }

  /// GANCHO DA FASE 2 (F2/M2): texto ditado chega pronto e dispara tradução
  /// imediata — nenhum ajuste na UI quando o STT entrar.
  void acceptDictatedText(String text) {
    onTextChanged(text);
    unawaited(translateNow());
  }

  @override
  void dispose() {
    _cancelDebounce();
    _models.states.removeListener(_onModelStatesChanged);
    super.dispose();
  }
}
