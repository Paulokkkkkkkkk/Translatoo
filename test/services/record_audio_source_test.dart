import 'package:flutter_test/flutter_test.dart';
import 'package:translatoo/core/services/record_audio_source.dart';

void main() {
  group('normalização de dBFS para 0..1', () {
    test('0 dB é o topo da escala', () {
      expect(RecordAudioSource.normalize(0), 1.0);
    });

    test('o piso de -45 dB e tudo abaixo é silêncio', () {
      expect(RecordAudioSource.normalize(-45), 0.0);
      // O `record` chega a reportar -160 dB; a escala não pode ir a negativo.
      expect(RecordAudioSource.normalize(-160), 0.0);
    });

    test('fala normal cai no meio da escala, não espremida no topo', () {
      // Se a escala fosse -160..0, uma fala a -20 dB daria 0,875 e a onda
      // ficaria praticamente reta. Com o piso em -45 dB ela respira.
      final level = RecordAudioSource.normalize(-20);
      expect(level, greaterThan(0.4));
      expect(level, lessThan(0.7));
    });

    test('é monotônica: mais alto nunca desenha barra menor', () {
      var previous = -1.0;
      for (var db = -60.0; db <= 0; db += 5) {
        final level = RecordAudioSource.normalize(db);
        expect(level, greaterThanOrEqualTo(previous));
        previous = level;
      }
    });

    test('NaN e infinito viram silêncio em vez de quebrar o desenho', () {
      expect(RecordAudioSource.normalize(double.nan), 0.0);
      expect(RecordAudioSource.normalize(double.negativeInfinity), 0.0);
      expect(RecordAudioSource.normalize(double.infinity), 1.0);
    });
  });
}
