import 'package:flutter_test/flutter_test.dart';
import 'package:translatoo/models/language.dart';
import 'package:translatoo/models/language_pair.dart';

void main() {
  group('LanguagePair (F1.1)', () {
    test('igualdade estrutural e hashCode', () {
      const a = LanguagePair(source: Language.pt, target: Language.zh);
      const b = LanguagePair(source: Language.pt, target: Language.zh);
      expect(a, equals(b));
      expect(a.hashCode, b.hashCode);
    });

    test('pares direcionados são distintos (pt→en ≠ en→pt)', () {
      const forward = LanguagePair(source: Language.pt, target: Language.en);
      const backward = LanguagePair(source: Language.en, target: Language.pt);
      expect(forward, isNot(backward));
    });

    test('swapped inverte origem/destino (botão ⇄)', () {
      const pair = LanguagePair(source: Language.pt, target: Language.zh);
      expect(
        pair.swapped(),
        const LanguagePair(source: Language.zh, target: Language.pt),
      );
    });

    test('toString expõe códigos ML Kit', () {
      const pair = LanguagePair(source: Language.pt, target: Language.en);
      expect(pair.toString(), 'pt→en');
    });

    test('usável como chave estável de mapa', () {
      const pair = LanguagePair(source: Language.en, target: Language.zh);
      final map = <LanguagePair, String>{pair: 'ok'};
      expect(
        map[const LanguagePair(source: Language.en, target: Language.zh)],
        'ok',
      );
    });
  });
}
