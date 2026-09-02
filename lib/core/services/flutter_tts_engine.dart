import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter_tts/flutter_tts.dart';

import 'tts_service.dart';

/// Motor de produção do M3: embrulha o plugin `flutter_tts`, que fala pelo
/// motor NATIVO do SO (RF-M3-01 — o plano proíbe motor de síntese de terceiros
/// embutido no app).
///
/// O plugin não identifica a sessão nos eventos (`speak.onStart/Complete/…`);
/// estes guardas resolvem a ambiguidade de fila única:
/// - um novo [speak] interrompe o anterior (o plugin usa QUEUE_FLUSH no
///   Android e o iOS para a fala corrente ao falar de novo) e zera
///   [_hasStarted] — o `cancelled` atrasado da fala velha chega com
///   `_hasStarted == false` e é descartado;
/// - [stop] só emite `cancelled` se a fala REALMENTE chegou a começar
///   ([_hasStarted]); interromper a janela entre `speak()` e o `started`
///   nativo é no-op silencioso (o serviço já sabe que mandou parar).
///
/// Mapeamento do modelo normalizado de voz (`AppSettings`) para o contrato do
/// plugin:
/// - `rate` (normalizado 0..1; 0,5 ≈ normal): no Android o `setSpeechRate`
///   espera ~0,5–2,0 com 1,0 normal — dobramos; no iOS espera 0..1 com 0,5
///   normal (padrão `AVSpeechUtterance`).
/// - `pitch`: 0,5–2,0 com 1,0 normal — o `setPitch` do plugin já usa essa
///   escala.
class FlutterTtsEngine implements TtsEngine {
  FlutterTtsEngine({FlutterTts? tts}) : _tts = tts ?? FlutterTts() {
    _tts.setStartHandler(_onStarted);
    _tts.setCompletionHandler(_onCompleted);
    _tts.setCancelHandler(_onCancelled);
    _tts.setErrorHandler(_onError);
  }

  final FlutterTts _tts;

  final StreamController<TtsEvent> _events =
      StreamController<TtsEvent>.broadcast();

  bool _active = false;
  bool _hasStarted = false;

  @override
  Stream<TtsEvent> get events => _events.stream;

  @override
  Future<bool> isLanguageAvailable(String ttsCode) async {
    // Retorno varia por plataforma (bool no iOS, int no Android): normaliza.
    final result = await _tts.isLanguageAvailable(ttsCode);
    return result == true || result == 1;
  }

  @override
  Future<void> configure({
    required String languageCode,
    required double rate,
    required double pitch,
  }) async {
    await _tts.setLanguage(languageCode);
    await _tts.setSpeechRate(_androidRate(rate));
    await _tts.setPitch(pitch.clamp(0.5, 2.0));
  }

  /// Dobra a velocidade normalizada (0..1) para a escala do Android
  /// (0,5–2,0; 1,0 = normal). iOS recebe o valor cru.
  static double _androidRate(double normalized) => Platform.isAndroid
      ? normalized.clamp(0.25, 1.0) * 2
      : normalized.clamp(0.0, 1.0);

  @override
  Future<void> speak(String text) async {
    _active = true;
    _hasStarted = false;
    await _tts.stop(); // garante a fila única mesmo em engines sem QUEUE_FLUSH
    final result = await _tts.speak(text);
    // Android responde 1 (ok) / 0 (falhou) no próprio retorno do speak.
    if (Platform.isAndroid && result == 0) {
      _active = false;
      throw StateError('flutter_tts: speak falhou (sem voz/engine disponível)');
    }
  }

  @override
  Future<void> stop() async {
    if (!_active) return;
    final wasLive = _hasStarted;
    _active = false;
    _hasStarted = false;
    await _tts.stop();
    if (wasLive) _events.add(const TtsEvent(TtsEventKind.cancelled));
  }

  @override
  Future<void> dispose() async {
    await stop();
    await _events.close();
  }

  // ── Handlers do plugin ──────────────────────────────────────────────────

  void _onStarted() {
    if (!_active) return;
    _hasStarted = true;
    _events.add(const TtsEvent(TtsEventKind.started));
  }

  void _onCompleted() {
    if (!_active || !_hasStarted) return;
    _active = false;
    _hasStarted = false;
    _events.add(const TtsEvent(TtsEventKind.completed));
  }

  void _onCancelled() {
    if (!_active || !_hasStarted) return; // cancel da fala que já morreu
    _active = false;
    _hasStarted = false;
    _events.add(const TtsEvent(TtsEventKind.cancelled));
  }

  void _onError(dynamic message) {
    if (!_active) return;
    _active = false;
    _hasStarted = false;
    _events.addError(message is Exception ? message : StateError('$message'));
  }
}
