import 'dart:typed_data';

import 'app_exception.dart';
import 'stt_service.dart';

/// [SttAudioSource] que não captura nada, porque não há como capturar (F2.5).
///
/// A lista fechada de dependências não tem pacote de microfone — a spike F2.0
/// escolheu o MOTOR e não a FONTE (ver o desvio da F2.2 no README). Esta é a
/// implementação que o app monta enquanto a decisão de reabrir a lista não
/// acontece.
///
/// **Falha alto, não em silêncio.** Tocar no 🎤 leva o `SpeechViewModel` ao
/// estado `error` com `ERR_STT_ENGINE`, que a UI já sabe exibir (§5.8). A
/// alternativa — esconder o botão — faria `canDictate` mentir sobre o flavor:
/// o modelo ESTÁ embutido, e o que falta é outra coisa.
///
/// Substituir por uma fonte real é trocar esta linha na composição do `main`;
/// nada mais no M2 muda.
final class UnavailableAudioSource implements SttAudioSource {
  const UnavailableAudioSource();

  @override
  Future<Stream<Uint8List>> start() async =>
      throw const AppException(ErrorCode.sttEngine);

  @override
  Future<void> stop() async {}
}
