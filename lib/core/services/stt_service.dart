import 'dart:async';
import 'dart:typed_data';

import '../../models/language.dart';
import '../constants/app_constants.dart';
import 'app_exception.dart';
import 'whisper_model_installer.dart';

/// Resultado de transcrição emitido pelo [SttService] (F2.2).
///
/// ATENÇÃO ao contrato dos parciais — é o ponto onde o whisper.cpp difere do
/// Vosk que o plano v1.0 assumia (ver `docs/stt_spike.md`): cada parcial é o
/// texto COMPLETO da fala até agora, **progressivamente refinado**. O texto já
/// exibido pode ser reescrito. A UI da F2.5 deve substituir o bloco inteiro a
/// cada emissão — concatenar emissões produz texto duplicado.
class SttResult {
  const SttResult(this.text, {required this.isFinal});

  final String text;

  /// `true` apenas na última emissão da sessão (pausa, `stop()` ou teto de 60 s).
  final bool isFinal;

  @override
  bool operator ==(Object other) =>
      other is SttResult && other.text == text && other.isFinal == isFinal;

  @override
  int get hashCode => Object.hash(text, isFinal);

  @override
  String toString() => 'SttResult(${isFinal ? 'final' : 'parcial'}, $text)';
}

/// Fonte de áudio do ditado: **PCM16, 16 kHz, mono, little-endian** — o único
/// formato que o whisper.cpp aceita.
///
/// POR QUE É UMA INTERFACE: a lista fechada de dependências (spike F2.0) não
/// tem pacote de captura de microfone — a spike escolheu o motor e não a
/// fonte. Abstrair aqui é o mesmo movimento do `TranslationBackend` na F1.1:
/// todo o resto do M2 (F2.4, F2.5) programa contra este contrato, e a captura
/// real entra depois sem tocar em nada disto.
abstract interface class SttAudioSource {
  /// Abre o microfone e devolve o fluxo de PCM. Falhas viram
  /// `AppException(sttEngine)` na fronteira do [SttService].
  Future<Stream<Uint8List>> start();

  /// Fecha o microfone. Idempotente.
  Future<void> stop();

  /// Nível do microfone **normalizado em 0..1**, para a onda da §5.7 do design
  /// system.
  ///
  /// Fonte que não sabe medir devolve um fluxo vazio — e aí a UI não desenha
  /// onda nenhuma, em vez de inventar movimento. A §5.7 é explícita: onda falsa
  /// em app de ditado é mentira de interface.
  Stream<double> get amplitude;
}

/// Sessão de transcrição ao vivo do motor — espelha `WhisperLiveSession`.
abstract interface class SttEngineSession {
  /// Transcrições progressivamente refinadas (texto completo, não delta).
  Stream<String> get partials;

  void feed(Uint8List pcm16Bytes);

  /// Encerra, libera o contexto nativo e devolve a transcrição final.
  Future<String> stop();
}

/// Motor de STT. A implementação real embrulha
/// `WhisperController.transcribeLive`; os testes injetam um fake.
abstract interface class SttEngine {
  Future<SttEngineSession> startSession({
    required String modelPath,
    required String languageCode,
  });
}

/// Fase do ditado observável por quem chama (F2.2).
///
/// A máquina de estados COMPLETA do produto (com `error`, contagem de tempo e
/// as transições inválidas) é do `SpeechViewModel` na F2.4 — aqui ficam só as
/// fases que o serviço realmente conhece.
enum SttPhase {
  /// Sem sessão ativa.
  idle,

  /// Primeira carga: copiando o modelo para o disco e abrindo o contexto
  /// nativo. Pode levar vários segundos no primeiro uso.
  initializing,

  /// Microfone aberto, áudio fluindo para o motor.
  listening,
}

/// Ditado offline atrás de uma interface independente de fornecedor (F2.2).
///
/// REGRAS DO PRD implementadas aqui:
/// - **RF-M2-05** — pausa de [sttSentencePause] (1,5 s) encerra a frase. O
///   whisper.cpp tem um *energy gate* nativo que não entrega parcial durante
///   silêncio, então "nenhum parcial novo por 1,5 s" É a pausa. O relógio só
///   arma DEPOIS do primeiro parcial: antes disso o usuário ainda não falou, e
///   uma sessão que se encerra sozinha em 1,5 s seria inutilizável.
/// - **RF-M2-06** — teto duro de [sttMaxDuration] (60 s) com auto-stop que
///   preserva o último resultado.
/// - **RN-03** — nenhuma exceção crua atravessa: tudo vira
///   `AppException(ErrorCode.sttEngine)`.
///
/// O modelo é carregado sob demanda pelo idioma de ORIGEM. Como a spike F2.0
/// escolheu um modelo multilíngue único, trocar de idioma NÃO recarrega nada —
/// só muda o `languageCode` da próxima sessão.
class SttService {
  SttService({
    required SttEngine sttEngine,
    required SttAudioSource audioSource,
    required WhisperModelInstaller modelInstaller,
  }) : _engine = sttEngine,
       _audio = audioSource,
       _installer = modelInstaller;

  final SttEngine _engine;
  final SttAudioSource _audio;
  final WhisperModelInstaller _installer;

  final StreamController<SttResult> _results =
      StreamController<SttResult>.broadcast();

  /// Parciais e o final da sessão em curso. Ver o contrato de [SttResult].
  Stream<SttResult> get results => _results.stream;

  /// Nível do microfone (0..1) enquanto a sessão está aberta — repassado da
  /// fonte de áudio para quem desenha a onda, sem o serviço interpretar nada.
  Stream<double> get amplitude => _audio.amplitude;

  SttPhase _phase = SttPhase.idle;
  SttPhase get phase => _phase;

  SttEngineSession? _session;
  StreamSubscription<Uint8List>? _audioSub;
  StreamSubscription<String>? _partialSub;
  Timer? _pauseTimer;
  Timer? _maxDurationTimer;
  String _lastText = '';

  /// Sessão atual. Incrementado a cada `start`/`stop`/`cancel` para que
  /// callbacks de uma sessão encerrada não contaminem a seguinte — mesma
  /// técnica dos tokens do `ModelManagerService` (F1.3).
  int _token = 0;

  bool get isListening => _phase == SttPhase.listening;

  /// Inicia o ditado no idioma de ORIGEM [language].
  ///
  /// Chamar com uma sessão já ativa é no-op idempotente (dois toques no 🎤 não
  /// abrem dois microfones).
  Future<void> start(Language language) async {
    if (_phase != SttPhase.idle) return;

    final token = ++_token;
    _phase = SttPhase.initializing;
    _lastText = '';

    try {
      final modelPath = await _installer.ensureInstalled();
      if (!_isCurrent(token)) return;

      final session = await _engine.startSession(
        modelPath: modelPath,
        languageCode: language.sttCode,
      );
      if (!_isCurrent(token)) {
        // Cancelado durante a carga: a sessão nasceu órfã, feche-a.
        unawaited(session.stop());
        return;
      }

      final audio = await _audio.start();
      if (!_isCurrent(token)) {
        unawaited(session.stop());
        unawaited(_audio.stop());
        return;
      }

      _session = session;
      _phase = SttPhase.listening;

      _partialSub = session.partials.listen((text) {
        if (!_isCurrent(token)) return;
        _lastText = text;
        _results.add(SttResult(text, isFinal: false));
        _armPauseTimer(token);
      });

      _audioSub = audio.listen(
        session.feed,
        onError: (Object e, StackTrace st) => _failSession(token, e, st),
        // O fluxo fechar sozinho (microfone perdido) equivale a parar.
        onDone: () => unawaited(_finish(token)),
      );

      _maxDurationTimer = Timer(
        sttMaxDuration,
        () => unawaited(_finish(token)),
      );
    } on AppException {
      _phase = SttPhase.idle;
      rethrow;
    } catch (e, st) {
      _phase = SttPhase.idle;
      await _teardown(closeSession: true);
      throw AppException(ErrorCode.sttEngine, cause: e, stackTrace: st);
    }
  }

  /// Encerra a escuta e emite o resultado final (RF-M2-05 manual).
  Future<void> stop() => _finish(_token);

  /// Descarta a sessão SEM emitir final — a F2.4 restaura o texto anterior.
  Future<void> cancel() async {
    if (_phase == SttPhase.idle) return;
    _token++;
    _phase = SttPhase.idle;
    await _teardown(closeSession: true);
  }

  bool _isCurrent(int token) => _token == token;

  /// (Re)arma a pausa de 1,5 s a cada parcial. Só é chamado de dentro do
  /// listener de parciais — daí o relógio nunca correr antes da primeira fala.
  void _armPauseTimer(int token) {
    _pauseTimer?.cancel();
    _pauseTimer = Timer(sttSentencePause, () => unawaited(_finish(token)));
  }

  /// Caminho ÚNICO de encerramento com resultado: pausa, `stop()`, teto de 60 s
  /// e fim do áudio convergem aqui, então o final é emitido exatamente uma vez.
  Future<String?> _finish(int token) async {
    if (!_isCurrent(token) || _phase == SttPhase.idle) return null;

    _token++;
    _phase = SttPhase.idle;

    final session = _session;
    await _teardown(closeSession: false);

    try {
      // O motor pode refinar o texto uma última vez ao fechar; se vier vazio,
      // vale o último parcial (RF-M2-06: o auto-stop preserva o que já havia).
      final text = await session?.stop() ?? _lastText;
      final finalText = text.isEmpty ? _lastText : text;
      _results.add(SttResult(finalText, isFinal: true));
      return finalText;
    } catch (e, st) {
      _results.addError(
        AppException(ErrorCode.sttEngine, cause: e, stackTrace: st),
      );
      return null;
    }
  }

  void _failSession(int token, Object error, StackTrace stackTrace) {
    if (!_isCurrent(token)) return;
    _token++;
    _phase = SttPhase.idle;
    unawaited(_teardown(closeSession: true));
    _results.addError(
      AppException(ErrorCode.sttEngine, cause: error, stackTrace: stackTrace),
    );
  }

  /// Solta microfone e timers.
  ///
  /// [closeSession] distingue os dois desfechos: em `cancel()` a sessão do
  /// motor tem de morrer aqui (senão o contexto nativo vaza), enquanto em
  /// [_finish] ela é preservada — é de `session.stop()` que sai o texto final.
  Future<void> _teardown({required bool closeSession}) async {
    _pauseTimer?.cancel();
    _pauseTimer = null;
    _maxDurationTimer?.cancel();
    _maxDurationTimer = null;

    // Sem `await`: cancelar já interrompe a entrega de eventos, e o future de
    // `cancel()` só sinaliza a limpeza da FONTE — esperá-lo aqui atrasaria o
    // encerramento pelo tempo de um plugin de microfone soltar o hardware.
    unawaited(_partialSub?.cancel() ?? Future<void>.value());
    _partialSub = null;
    unawaited(_audioSub?.cancel() ?? Future<void>.value());
    _audioSub = null;

    final session = _session;
    _session = null;
    await _audio.stop();

    if (closeSession && session != null) {
      // O texto é descartado de propósito: cancelar não produz resultado.
      unawaited(session.stop());
    }
  }

  Future<void> dispose() async {
    _token++;
    _phase = SttPhase.idle;
    await _teardown(closeSession: true);
    await _results.close();
  }
}
