import 'dart:async';

import 'package:flutter/foundation.dart';

import '../core/constants/app_constants.dart';
import '../core/services/app_exception.dart';
import '../core/services/mic_permission_service.dart';
import '../core/services/stt_service.dart';
import 'translator_view_model.dart';

/// Máquina de estados do microfone (F2.4 / PRD §3.2).
///
/// Hierarquia FECHADA: a UI faz switch exaustivo, e um estado novo quebra a
/// compilação em vez de cair num `default` silencioso.
enum SpeechState {
  /// Sem escuta. Único estado a partir do qual `start` é aceito.
  idle,

  /// Pedindo permissão, instalando o modelo, abrindo o contexto nativo.
  initializing,

  /// Microfone aberto; parciais chegando.
  listening,

  /// Escuta encerrada, aguardando o texto final do motor.
  processing,

  /// Falhou. `errorCode` diz o quê; a UI resolve a mensagem via app_strings.
  error,
}

/// ViewModel do ditado (F2.4).
///
/// REGRAS implementadas aqui:
/// - **Transições inválidas são IGNORADAS**, nunca lançam — `stop()` em `idle`
///   é um toque duplo do usuário, não um bug do programa (AC da issue #24).
/// - Resultado final → [TranslatorViewModel.acceptDictatedText], que traduz
///   ignorando o debounce de 800 ms.
/// - **RF-M2-07**: durante a escuta o campo de digitação fica desabilitado e o
///   TTS, silenciado — quem lê [isDictating] é a UI (F2.5) e o TTS (F2.8).
/// - **RN-07**: app em background durante a escuta **finaliza** com o último
///   parcial. Perder a fala inteira porque uma notificação roubou o foco é o
///   pior desfecho possível; encerrar preserva o que já foi dito.
/// - **AC-M2-4**: cancelar restaura EXATAMENTE o texto anterior à escuta e não
///   dispara tradução.
class SpeechViewModel extends ChangeNotifier {
  SpeechViewModel({
    required SttService sttService,
    required MicPermissionService permissionService,
    required TranslatorViewModel translatorViewModel,
    bool? dictationAvailable,
  }) : _canDictate = dictationAvailable ?? AppConstants.hasEmbeddedSttModels,
       _stt = sttService,
       _permissions = permissionService,
       _translator = translatorViewModel {
    _resultsSub = _stt.results.listen(_onResult, onError: _onEngineError);
    _amplitudeSub = _stt.amplitude.listen(_onAmplitude);
  }

  /// Costura de teste: o valor de produção vem do flavor (F2.1b), mas o
  /// caminho "build sem ditado" precisa ser exercitável sem recompilar.
  final bool _canDictate;

  final SttService _stt;
  final MicPermissionService _permissions;
  final TranslatorViewModel _translator;

  StreamSubscription<SttResult>? _resultsSub;
  StreamSubscription<double>? _amplitudeSub;
  Timer? _elapsedTimer;

  SpeechState _state = SpeechState.idle;
  String _partialText = '';
  String _finalText = '';
  int _elapsedSeconds = 0;
  ErrorCode? _errorCode;
  SuggestedAction _errorAction = SuggestedAction.none;

  /// Texto do campo de origem no instante em que a escuta começou — o que o
  /// cancelamento restaura (AC-M2-4).
  String _textBeforeListening = '';

  /// Histórico rolante do nível do microfone (0..1) que alimenta a onda da
  /// §5.7. Tamanho fixo: a onda tem largura fixa, e uma lista que só cresce
  /// vazaria memória numa escuta de 60 s.
  static const int _waveformBars = 32;
  // `growable: true` é obrigatório: o histórico rola com removeAt/add, e uma
  // lista de tamanho fixo lançaria UnsupportedError no primeiro nível que
  // chegasse do microfone.
  final List<double> _levels = List<double>.filled(
    _waveformBars,
    0,
    growable: true,
  );

  SpeechState get state => _state;

  /// Transcrição em curso. Cada emissão SUBSTITUI a anterior (contrato de
  /// [SttResult]); a UI nunca deve concatenar.
  String get partialText => _partialText;

  /// Última transcrição finalizada da sessão.
  String get finalText => _finalText;

  /// Segundos de escuta, para o cronômetro mm:ss e o teto de 60 s.
  int get elapsedSeconds => _elapsedSeconds;

  ErrorCode? get errorCode => _errorCode;

  /// Níveis do microfone para a onda, do mais antigo ao mais recente.
  ///
  /// Todos zerados significa que a fonte de áudio não sabe medir — a UI então
  /// não desenha onda, em vez de inventar movimento (§5.7).
  List<double> get waveformLevels => List<double>.unmodifiable(_levels);

  /// A fonte está entregando nível real? Quando `false`, nada de onda.
  bool get hasAudioLevel => _levels.any((level) => level > 0);

  /// Ação que a UI oferece junto do erro (tentar de novo, abrir configurações).
  SuggestedAction get errorAction => _errorAction;

  /// Escuta ativa? Trava o campo de texto e silencia o TTS (RF-M2-07).
  bool get isDictating =>
      _state == SpeechState.listening || _state == SpeechState.processing;

  /// Este build tem ditado? Espelha o flavor sem expor a constante à `ui/`.
  bool get canDictate => _canDictate;

  /// Segundos restantes até o auto-stop de 60 s (RF-M2-06).
  int get remainingSeconds =>
      (sttMaxDuration.inSeconds - _elapsedSeconds).clamp(0, 60);

  /// Inicia o ditado no idioma de ORIGEM do tradutor.
  ///
  /// [onPermissionNeeded] é o diálogo explicativo prévio da F2.5: devolve
  /// `true` se o usuário concordou em prosseguir para o pedido do sistema.
  /// Sem ele, o pedido vai direto — comportamento aceitável em teste, nunca
  /// no produto (PRD §4.5).
  Future<void> start({Future<bool> Function()? onPermissionNeeded}) async {
    if (_state != SpeechState.idle) return; // transição inválida: ignore
    if (!canDictate) return;

    _textBeforeListening = _translator.sourceText;
    _partialText = '';
    _finalText = '';
    _elapsedSeconds = 0;
    _resetLevels();
    _clearError();
    _setState(SpeechState.initializing);

    try {
      if (!await _ensurePermission(onPermissionNeeded)) return;

      await _stt.start(_translator.sourceLang);
      if (_state != SpeechState.initializing) return; // cancelado na carga

      _setState(SpeechState.listening);
      _startElapsedTimer();
    } on AppException catch (e) {
      _fail(e);
    }
  }

  /// Encerra a escuta e espera o texto final (RF-M2-05 manual).
  Future<void> stop() async {
    if (_state != SpeechState.listening) return; // transição inválida
    _stopElapsedTimer();
    _setState(SpeechState.processing);
    try {
      await _stt.stop();
    } on AppException catch (e) {
      _fail(e);
    }
  }

  /// Descarta a escuta e restaura o texto anterior (AC-M2-4).
  ///
  /// A restauração é explícita mesmo quando nada foi ditado: os parciais NÃO
  /// tocam no campo de origem durante a escuta, então na prática isto é um
  /// no-op — mas deixa a garantia no código, e não numa suposição sobre a UI.
  Future<void> cancel() async {
    if (_state == SpeechState.idle) return; // transição inválida
    _stopElapsedTimer();
    _resetLevels();
    _partialText = '';
    _finalText = '';
    _clearError();
    _setState(SpeechState.idle);

    try {
      await _stt.cancel();
    } on AppException catch (e) {
      _fail(e);
      return;
    }

    if (_translator.sourceText != _textBeforeListening) {
      _translator.restoreSourceText(_textBeforeListening);
    }
  }

  /// RN-07 — o app foi para segundo plano. Chamado pela UI (F2.5) a partir de
  /// um `AppLifecycleListener`.
  ///
  /// FINALIZA em vez de cancelar: a fala já dita vale mais que a sessão.
  void onAppBackgrounded() {
    if (_state != SpeechState.listening) return;
    unawaited(stop());
  }

  /// Limpa o erro depois que a UI o exibiu, devolvendo o botão ao normal.
  void acknowledgeError() {
    if (_state != SpeechState.error) return;
    _clearError();
    _setState(SpeechState.idle);
  }

  /// Abre as configurações do sistema (ação do erro `micPermission` permanente).
  Future<void> openAppSettings() => _permissions.openSettings();

  // ── Interno ──────────────────────────────────────────────────────────────

  Future<bool> _ensurePermission(
    Future<bool> Function()? onPermissionNeeded,
  ) async {
    var permission = await _permissions.current();

    if (permission == MicPermission.denied) {
      // Diálogo explicativo ANTES do diálogo do sistema (PRD §4.5).
      final proceed = await onPermissionNeeded?.call() ?? true;
      if (!proceed) {
        _setState(SpeechState.idle);
        return false;
      }
      permission = await _permissions.request();
    }

    final error = MicPermissionService.toException(permission);
    if (error != null) {
      _fail(error);
      return false;
    }
    return true;
  }

  void _onResult(SttResult result) {
    if (_state != SpeechState.listening && _state != SpeechState.processing) {
      return; // resultado de uma sessão que o usuário já cancelou
    }

    if (!result.isFinal) {
      _partialText = result.text;
      notifyListeners();
      return;
    }

    _stopElapsedTimer();
    _resetLevels();
    _finalText = result.text;
    _partialText = '';
    _setState(SpeechState.idle);

    // Texto vazio (silêncio de 60 s, ou o usuário desistiu de falar) não vira
    // uma tradução vazia nem apaga o que já estava no campo.
    if (result.text.trim().isNotEmpty) {
      _translator.acceptDictatedText(result.text);
    }
  }

  /// Empurra o nível novo para o fim da fila e descarta o mais antigo.
  void _onAmplitude(double level) {
    if (_state != SpeechState.listening) return;
    _levels
      ..removeAt(0)
      ..add(level.clamp(0.0, 1.0));
    notifyListeners();
  }

  void _resetLevels() => _levels.fillRange(0, _waveformBars, 0);

  void _onEngineError(Object error) {
    _stopElapsedTimer();
    _fail(
      error is AppException ? error : const AppException(ErrorCode.sttEngine),
    );
  }

  void _startElapsedTimer() {
    _stopElapsedTimer();
    _elapsedTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      _elapsedSeconds++;
      notifyListeners();
    });
  }

  void _stopElapsedTimer() {
    _elapsedTimer?.cancel();
    _elapsedTimer = null;
  }

  void _fail(AppException error) {
    _errorCode = error.code;
    _errorAction = error.suggestedAction;
    _partialText = '';
    _setState(SpeechState.error);
  }

  void _clearError() {
    _errorCode = null;
    _errorAction = SuggestedAction.none;
  }

  void _setState(SpeechState next) {
    if (_state == next) return;
    _state = next;
    notifyListeners();
  }

  @override
  void dispose() {
    _stopElapsedTimer();
    // O serviço é injetado (não é nosso para descartar), mas a SESSÃO em curso
    // é: morrer deixando o microfone aberto e o teto de 60 s armado vazaria
    // recurso nativo e um timer.
    if (isDictating) unawaited(_stt.cancel());
    unawaited(_resultsSub?.cancel() ?? Future<void>.value());
    _resultsSub = null;
    unawaited(_amplitudeSub?.cancel() ?? Future<void>.value());
    _amplitudeSub = null;
    super.dispose();
  }
}
