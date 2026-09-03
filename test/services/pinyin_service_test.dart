import 'package:flutter_test/flutter_test.dart';
import 'package:translatoo/core/services/pinyin_service.dart';
import 'package:translatoo/models/language.dart';

/// Motor que explode — a linha de pinyin é apoio de leitura, e apoio que
/// falha não pode derrubar uma tradução que deu certo.
class _BrokenEngine implements PinyinEngine {
  const _BrokenEngine();

  @override
  String romanize(String text) => throw StateError('dicionário corrompido');
}

/// Motor que devolve o próprio texto: é o que acontece de verdade quando o
/// dicionário não conhece os caracteres.
class _EchoEngine implements PinyinEngine {
  const _EchoEngine();

  @override
  String romanize(String text) => text;
}

void main() {
  const service = PinyinService();

  group('quando a linha existe', () {
    test('romaniza chinês com marcas de tom', () {
      expect(service.romanizeFor(Language.zh, '谢谢'), 'xiè xie');
    });

    test('usa o mapa de EXPRESSÕES, não de caracteres', () {
      // Estes são os casos que separam uma romanização útil de uma errada:
      // 长 sozinho é `cháng`, mas em 长大 é `zhǎng`; 行 é `xíng`, mas em
      // 银行 é `háng`; 了 é `liǎo` como verbo e `le` como partícula.
      expect(service.romanizeFor(Language.zh, '长大了'), 'zhǎng dà le');
      expect(
        service.romanizeFor(Language.zh, '重要的银行'),
        'zhòng yào de yín háng',
      );
    });
  });

  group('quando a linha NÃO deve existir', () {
    test('fora do chinês não há pinyin', () {
      expect(service.romanizeFor(Language.pt, 'Bom dia'), isNull);
      expect(service.romanizeFor(Language.en, 'Good morning'), isNull);
    });

    test('texto em zh sem nenhum caractere Han', () {
      // Um resultado pode ser só um número ou uma sigla. Romanizar devolveria
      // o próprio texto — uma linha duplicada que não ensina nada.
      expect(service.romanizeFor(Language.zh, '2026'), isNull);
      expect(service.romanizeFor(Language.zh, 'WiFi'), isNull);
      expect(service.romanizeFor(Language.zh, ''), isNull);
    });

    test('romanização IGUAL ao original não vira linha', () {
      const eco = PinyinService(engine: _EchoEngine());
      expect(eco.romanizeFor(Language.zh, '谢谢'), isNull);
    });

    test('falha do dicionário devolve null, não exceção', () {
      const quebrado = PinyinService(engine: _BrokenEngine());
      // Uma tradução correta não pode virar erro por causa de um apoio.
      expect(quebrado.romanizeFor(Language.zh, '谢谢'), isNull);
    });
  });

  test('pontuação não fica solta depois de um espaço', () {
    // O pacote separa `。` como se fosse mais uma sílaba, e sai `yù shì 。`.
    // Ninguém escreve assim em nenhuma das duas escritas.
    expect(
      service.romanizeFor(Language.zh, '谢谢你的浴室。'),
      'xiè xie nǐ de yù shì。',
    );
    // 朋友 é `péng you` mesmo: a segunda sílaba é NEUTRA. Escrever `yǒu` aqui
    // seria "corrigir" o dicionário para o lado errado.
    expect(service.romanizeFor(Language.zh, '你好，朋友！'), 'nǐ hǎo，péng you！');
  });

  test('texto misto ainda ganha linha', () {
    // "Wi-Fi 密码" é o tipo de frase real que aparece numa viagem.
    final resultado = service.romanizeFor(Language.zh, 'Wi-Fi 密码');
    expect(resultado, isNotNull);
    expect(resultado, contains('mì mǎ'));
  });
}
