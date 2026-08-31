import 'package:flutter_test/flutter_test.dart';
import 'package:translatoo/models/language.dart';

void main() {
  group('Language (RN-01, F0.6)', () {
    test('exibe nomes nativos, nunca traduzidos', () {
      expect(Language.pt.displayName, 'Português');
      expect(Language.en.displayName, 'English');
      expect(Language.zh.displayName, '中文');
    });

    test('expõe códigos BCP-47 / ML Kit / TTS / STT', () {
      expect(Language.pt.bcp47Code, 'pt-BR');
      expect(Language.en.bcp47Code, 'en-US');
      expect(Language.zh.bcp47Code, 'zh-CN');

      expect(Language.zh.mlKitCode, 'zh');
      expect(Language.pt.ttsCode, 'pt-BR');
      expect(Language.en.sttCode, 'en');
    });

    test('jsonCode estável para persistência', () {
      expect(Language.pt.jsonCode, 'pt');
      expect(Language.zh.jsonCode, 'zh');
    });

    group('tryFromCode tolerante', () {
      test('aceita enum, ML Kit e variações BCP-47', () {
        expect(Language.tryFromCode('pt'), Language.pt);
        expect(Language.tryFromCode('en'), Language.en);
        expect(Language.tryFromCode('zh'), Language.zh);
        expect(Language.tryFromCode('pt-BR'), Language.pt);
        expect(Language.tryFromCode('zh_CN'), Language.zh);
        expect(Language.tryFromCode('EN'), Language.en);
      });

      test('retorna null para inválidos/nulos', () {
        expect(Language.tryFromCode(null), isNull);
        expect(Language.tryFromCode(''), isNull);
        expect(Language.tryFromCode('fr'), isNull);
        expect(Language.tryFromCode('es-MX'), isNull);
      });
    });
  });
}
