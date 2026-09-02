import 'dart:async';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:record/record.dart';

import 'app_exception.dart';
import 'stt_service.dart';

/// Captura de microfone real (F2.2b), sobre o pacote `record`.
///
/// É o ÚNICO arquivo do projeto que importa `record` — mesma regra que isola o
/// whisper em `whisper_stt_engine.dart` e o ML Kit em
/// `mlkit_translation_backend.dart`.
///
/// O formato NÃO é negociável: o whisper.cpp aceita **PCM16, 16 kHz, mono,
/// little-endian**, e é isso que [RecordConfig] pede. Qualquer outro encoder
/// produziria bytes que o motor interpreta como ruído.
///
/// **Permissão não passa por aqui.** O `record` tem o próprio `hasPermission()`,
/// e usá-lo criaria um segundo dono da decisão, com outro fluxo de diálogo. Quem
/// manda é o `MicPermissionService` da F2.3, chamado pelo `SpeechViewModel`
/// antes de o áudio abrir.
final class RecordAudioSource implements SttAudioSource {
  RecordAudioSource({AudioRecorder? recorder})
    : _recorder = recorder ?? AudioRecorder();

  final AudioRecorder _recorder;

  final StreamController<double> _amplitude =
      StreamController<double>.broadcast();
  StreamSubscription<Amplitude>? _amplitudeSub;

  /// Piso da escala em dBFS. Abaixo disso é silêncio para efeito de desenho —
  /// o `record` chega a reportar -160 dB, e mapear a escala inteira deixaria
  /// toda fala humana espremida no topo da onda.
  static const double _floorDb = -45;

  /// Cadência da leitura de nível: ~15 Hz. Suficiente para a onda parecer viva
  /// sem acordar o canal de plataforma a cada frame.
  static const Duration _amplitudeInterval = Duration(milliseconds: 66);

  @override
  Stream<double> get amplitude => _amplitude.stream;

  @override
  Future<Stream<Uint8List>> start() async {
    try {
      final stream = await _recorder.startStream(
        const RecordConfig(
          encoder: AudioEncoder.pcm16bits,
          sampleRate: 16000,
          numChannels: 1,
          // O ganho automático mexe no nível entre blocos; o whisper tem o
          // próprio energy gate e prefere o sinal como ele é.
          autoGain: false,
          echoCancel: true,
          noiseSuppress: true,
        ),
      );
      _listenToAmplitude();
      return stream;
    } catch (e, st) {
      throw AppException(ErrorCode.sttEngine, cause: e, stackTrace: st);
    }
  }

  @override
  Future<void> stop() async {
    await _amplitudeSub?.cancel();
    _amplitudeSub = null;
    try {
      if (await _recorder.isRecording()) await _recorder.stop();
    } catch (e, st) {
      throw AppException(ErrorCode.sttEngine, cause: e, stackTrace: st);
    }
  }

  void _listenToAmplitude() {
    _amplitudeSub?.cancel();
    _amplitudeSub = _recorder.onAmplitudeChanged(_amplitudeInterval).listen(
      (level) {
        if (!_amplitude.isClosed) _amplitude.add(normalize(level.current));
      },
      // Nível é enfeite: perdê-lo apaga a onda, não a transcrição. Nunca
      // pode derrubar a sessão.
      onError: (Object _) {},
    );
  }

  /// dBFS → 0..1. Visível para teste porque é a única aritmética aqui, e errar
  /// a escala é o tipo de coisa que só aparece como "a onda não mexe".
  static double normalize(double dbfs) {
    if (dbfs.isNaN) return 0;
    // `-infinito` é silêncio digital e o piso já o absorve; `+infinito` satura
    // no topo pelo clamp. Nenhum dos dois precisa de caso especial.
    final clamped = math.max(dbfs, _floorDb);
    return ((clamped - _floorDb) / -_floorDb).clamp(0.0, 1.0);
  }

  Future<void> dispose() async {
    await _amplitudeSub?.cancel();
    await _amplitude.close();
    await _recorder.dispose();
  }
}
