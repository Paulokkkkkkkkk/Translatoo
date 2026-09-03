import 'dart:async';

import 'package:flutter/foundation.dart';

import '../core/services/app_exception.dart';
import '../core/services/tts_service.dart';
import '../models/language.dart';
import 'translator_view_model.dart';

/// Ciclo de vida observável da leitura em voz alta (F2.7 / PRD §3.3).
enum TtsState { idle, speaking }

/// ViewModel da leitura em voz alta (F2.7 / M3).
///
/// REGRAS implementadas aqui:
/// - Fala o RESULTADO da tradução no idioma de DESTINO (`TranslatorViewModel`);
/// - **RF-M3-06** — autoplay (default OFF) fala cada tradução concluída; uma
///   tradução ORIGINADA DE DITADO fala SEMPRE, autoplay ou não (o sinal vem de
///   `TranslatorViewModel.consumeDictatedFlag`);
/// - **Anti duplo-toque** — refalar o MESMO texto com uma fala em curso e
///   < 300 ms é idempotente (toque duplo no 🔊 não reinicia a voz);
/// - **RN-07** — TTS segue até concluir mesmo em segundo plano (nada a fazer
///   aqui: o motor nativo cuida); ao VOLTAR de segundo plano o cache de voz é
///   invalidado ([refreshVoices]) — a voz pode ter sido instalada lá fora;
/// - Erros (voz ausente / falha de motor) viram [AppException] exposta como
///   [errorCode]+[errorAction], e a UI resolve a mensagem em `app_strings.dart`.
class TtsViewModel extends ChangeNotifier {
  TtsViewModel({
    required TtsService ttsService,
    required TranslatorViewModel translatorViewModel,
    bool autoPlay = false,
    double rate = 0.5,
    double pitch = 1.0,
  }) : _tts = ttsService,
       _translator = translatorViewModel,
       // Público × privado (autoPlay × _autoPlay): sem formal possível.
       _autoPlay = // ignore: prefer_initializing_formals
           autoPlay {
    _tts
      ..setRate(rate)
      ..setPitch(pitch);
    _eventsSub = _tts.events.listen(
      _onTtsEvent,
      onError: (Object e, StackTrace st) => _onTtsError(e),
    );
    _translator.addListener(_onTranslatorChanged);
  }

  /// Mesmo texto refalado dentro desta janela é toque duplo (F2.7).
  static const Duration _doubleTapWindow = Duration(milliseconds: 300);

  final TtsService _tts;
  final TranslatorViewModel _translator;

  bool _autoPlay;
  TtsState _state = TtsState.idle;
  ErrorCode? _errorCode;
  SuggestedAction _errorAction = SuggestedAction.none;

  /// Idioma da fala que falhou — para a mensagem `errTtsVoiceMissing(idioma)`.
  Language? _errorLanguage;
  String? _lastSpokenText;
  DateTime? _lastSpokenAt;

  /// Trecho em reprodução (para o mini-player da F2.8) — `null` quando parado.
  String? _speakingText;
  StreamSubscription<TtsEvent>? _eventsSub;

  TtsState get state => _state;
  bool get isSpeaking => _state == TtsState.speaking;
  bool get autoPlay => _autoPlay;

  ErrorCode? get errorCode => _errorCode;
  SuggestedAction get errorAction => _errorAction;

  /// Rótulo nativo do idioma cuja voz faltou (mensagem parametrizada).
  Language? get errorLanguage => _errorLanguage;

  /// Velocidade/tom vigentes (lidos do serviço; os sliders da F2.8/F3 usam).
  double get rate => _tts.rate;
  double get pitch => _tts.pitch;

  /// Trecho falado em curso (mini-player). Vale mesmo se o resultado da
  /// tradução mudou enquanto a voz antiga ainda terminava.
  String? get speakingText => _speakingText;

  /// Autoplay (default OFF — vira item de Ajustes na F3).
  void setAutoPlay(bool value) {
    if (_autoPlay == value) return;
    _autoPlay = value;
    notifyListeners();
  }

  /// 🔊 — alterna fala/parada do resultado corrente. Sem resultado (ou com a
  /// tradução ainda em curso) é no-op.
  Future<void> togglePlayback() async {
    if (_state == TtsState.speaking) {
      await stop();
      return;
    }
    await speakTranslation();
  }

  /// Fala o resultado corrente no idioma de destino. Voz ausente/falha vira
  /// erro observável — nunca exceção crua na UI (RN-03).
  Future<void> speakTranslation() async {
    final text = _translator.translatedText;
    if (text.trim().isEmpty) return;
    _clearError();

    // Anti duplo-toque: refalar o MESMO texto dentro de 300 ms é toque
    // repetido (o `started` nativo ainda não chegou quando o 2º toque cai —
    // o estado não pode ser a âncora dessa decisão).
    final now = DateTime.now();
    final last = _lastSpokenAt;
    if (text == _lastSpokenText &&
        last != null &&
        now.difference(last) < _doubleTapWindow) {
      return;
    }
    _lastSpokenText = text;
    _lastSpokenAt = now;
    _speakingText = text;

    try {
      await _tts.speak(language: _translator.targetLang, text: text);
      // O estado `speaking` nasce do evento nativo `started` (fala de verdade
      // começou); até lá a UI continua com o botão ▶ — nenhum estado otimista.
    } on AppException catch (e) {
      _speakingText = null;
      _fail(e, _translator.targetLang);
    }
  }

  /// ⏹ — interrompe a fala em curso.
  Future<void> stop() async {
    await _tts.stop();
    _speakingText = null;
    // O serviço descarta o `cancelled` do motor (sessão já encerrada); quem
    // encerra o estado aqui é o próprio comando de parada.
    _setState(TtsState.idle);
  }

  /// Invalida o cache de vozes do serviço (abertura do app / volta de segundo
  /// plano): a voz pode ter sido instalada no sistema enquanto o app esteve
  /// fora (F2.7).
  void refreshVoices() => _tts.refreshVoices();

  /// Sliders da F2.8 (debug) e F3 (Ajustes): valem para a próxima reprodução.
  void setRate(double value) {
    _tts.setRate(value);
    notifyListeners();
  }

  void setPitch(double value) {
    _tts.setPitch(value);
    notifyListeners();
  }

  /// Limpa o erro depois que a UI o exibiu.
  void acknowledgeError() {
    if (_errorCode == null) return;
    _clearError();
    notifyListeners();
  }

  // ── Interno ──────────────────────────────────────────────────────────────

  /// Autoplay + ditado: toda conclusão de tradução que nasceu do microfone
  /// fala sozinha; com autoplay ligado, toda conclusão fala.
  void _onTranslatorChanged() {
    if (_translator.status != TranslatorStatus.done) return;
    final dictated = _translator.consumeDictatedFlag();
    if (dictated || _autoPlay) {
      unawaited(speakTranslation());
    }
  }

  void _onTtsEvent(TtsEvent event) {
    switch (event.kind) {
      case TtsEventKind.started:
        if (_state != TtsState.speaking) _setState(TtsState.speaking);
      case TtsEventKind.completed || TtsEventKind.cancelled:
        _speakingText = null;
        _setState(TtsState.idle);
    }
  }

  void _onTtsError(Object error) {
    final exception = error is AppException
        ? error
        : AppException(ErrorCode.ttsVoiceMissing, cause: error);
    _speakingText = null;
    _fail(exception, _translator.targetLang);
  }

  void _fail(AppException error, Language language) {
    _setState(TtsState.idle);
    _errorCode = error.code;
    _errorAction = error.suggestedAction;
    _errorLanguage = language;
    notifyListeners();
  }

  void _clearError() {
    _errorCode = null;
    _errorAction = SuggestedAction.none;
    _errorLanguage = null;
  }

  void _setState(TtsState next) {
    if (_state == next) return;
    _state = next;
    notifyListeners();
  }

  @override
  void dispose() {
    _translator.removeListener(_onTranslatorChanged);
    // A sessão de voz em curso é do serviço injetado; ao morrer o ViewModel
    // manda parar — deixar o áudio falando sem dono violaria o ciclo de vida.
    unawaited(_tts.stop());
    unawaited(_eventsSub?.cancel() ?? Future<void>.value());
    _eventsSub = null;
    super.dispose();
  }
}
