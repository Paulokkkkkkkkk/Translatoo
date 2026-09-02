import 'dart:async';
import 'dart:typed_data';

import 'package:whisper_ggml/whisper_ggml.dart';

import 'app_exception.dart';
import 'stt_service.dart';

/// Implementação real do [SttEngine] sobre o whisper.cpp (F2.2).
///
/// É o ÚNICO arquivo do projeto que importa `whisper_ggml` — a mesma regra que
/// isola o ML Kit no `MlKitTranslationBackend` (F1.2). Trocar de motor (o plano
/// B `sherpa_onnx` da spike F2.0) significa escrever um irmão deste arquivo,
/// nada mais.
final class WhisperSttEngine implements SttEngine {
  WhisperSttEngine({WhisperController? controller})
    : _controller = controller ?? WhisperController();

  final WhisperController _controller;

  /// Fluxo vazio: quem alimenta o motor é o [SttService], chamando `feed` a
  /// cada bloco de PCM que vem do [SttAudioSource]. O `transcribeLive` do
  /// pacote também aceita um Stream, mas aí ELE decidiria quando a sessão
  /// acaba — e as regras de fim de fala (RF-M2-05/06) são nossas.
  static const Stream<Uint8List> _noAudio = Stream<Uint8List>.empty();

  @override
  Future<SttEngineSession> startSession({
    required String modelPath,
    required String languageCode,
  }) async {
    try {
      final session = await _controller.transcribeLive(
        modelPath: modelPath,
        pcm16Stream: _noAudio,
        lang: languageCode,
        // Evita a recarga de vários segundos a cada ditado — a mitigação de
        // latência que a spike F2.0 registrou (docs/stt_spike.md).
        keepModelLoaded: true,
      );
      return _WhisperSession(session);
    } catch (e, st) {
      throw AppException(ErrorCode.sttEngine, cause: e, stackTrace: st);
    }
  }
}

final class _WhisperSession implements SttEngineSession {
  _WhisperSession(this._session);

  final WhisperLiveSession _session;

  @override
  Stream<String> get partials => _session.partials;

  @override
  void feed(Uint8List pcm16Bytes) => _session.feed(pcm16Bytes);

  @override
  Future<String> stop() => _session.stop();
}
