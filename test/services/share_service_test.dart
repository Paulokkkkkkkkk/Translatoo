import 'package:flutter_test/flutter_test.dart';
import 'package:translatoo/core/services/app_exception.dart';
import 'package:translatoo/core/services/share_service.dart';
import 'package:translatoo/models/language.dart';

class _FakeShare implements SharePlatform {
  String? text;
  String? subject;
  int calls = 0;
  Object? error;

  @override
  Future<void> shareText(String value, {String? subject}) async {
    calls++;
    if (error != null) throw error!;
    text = value;
    this.subject = subject;
  }
}

void main() {
  late _FakeShare platform;
  late ShareService service;

  setUp(() {
    platform = _FakeShare();
    service = ShareService(sharePlatform: platform);
  });

  test('o texto compartilhado inclui o PAR DE IDIOMAS', () async {
    await service.shareTranslation(
      source: Language.pt,
      target: Language.en,
      sourceText: 'Bom dia',
      translatedText: 'Good morning',
    );

    // Sem o par, quem recebe "Good morning" não sabe de onde veio nem qual
    // era o original.
    expect(platform.text, 'Português: Bom dia\nEnglish: Good morning');
    expect(platform.subject, 'Good morning');
  });

  test('mandarim aparece com o nome nativo', () async {
    await service.shareTranslation(
      source: Language.en,
      target: Language.zh,
      sourceText: 'Good morning',
      translatedText: '早上好',
    );

    expect(platform.text, contains('中文: 早上好'));
  });

  test('tradução vazia não abre a folha', () async {
    await service.shareTranslation(
      source: Language.pt,
      target: Language.en,
      sourceText: 'Bom dia',
      translatedText: '   ',
    );

    expect(platform.calls, 0);
  });

  test(
    'falha da folha vira AppException, não exceção de plugin (RN-03)',
    () async {
      platform.error = StateError('sem app de compartilhamento');

      await expectLater(
        service.shareTranslation(
          source: Language.pt,
          target: Language.en,
          sourceText: 'Bom dia',
          translatedText: 'Good morning',
        ),
        throwsA(isA<AppException>()),
      );
    },
  );

  test('não toca em rede — o serviço é puro montagem de texto', () async {
    // Prova indireta do AC ("compartilhar funciona em modo avião"): a única
    // dependência é a folha do SO, e o dublê aqui não tem nada de rede.
    await service.shareTranslation(
      source: Language.pt,
      target: Language.zh,
      sourceText: 'Olá',
      translatedText: '你好',
    );

    expect(platform.calls, 1);
  });
}
