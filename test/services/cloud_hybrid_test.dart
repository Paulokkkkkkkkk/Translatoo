import 'package:flutter_test/flutter_test.dart';
import 'package:translatoo/core/constants/app_constants.dart';
import 'package:translatoo/core/services/app_exception.dart';
import 'package:translatoo/core/services/cloud_translation_backend.dart';
import 'package:translatoo/core/services/translation_backend.dart';
import 'package:translatoo/core/services/translation_service.dart';
import 'package:translatoo/models/language.dart';
import 'package:translatoo/models/language_pair.dart';

class _LocalBackend implements TranslationBackend {
  int calls = 0;

  @override
  String get id => 'local';

  @override
  Future<bool> isModelDownloaded(Language language) async => true;

  @override
  Future<bool> isReady(LanguagePair pair) async => true;

  @override
  Future<String> translate({
    required Language source,
    required Language target,
    required String text,
  }) async {
    calls++;
    return 'local:$text';
  }

  @override
  void dispose() {}
}

class _FakeCloudApi implements CloudTranslationApi {
  int calls = 0;
  String? result;
  Object? error;

  /// Atraso simulado — usado para provar o timeout de 2 s.
  Duration delay = Duration.zero;

  @override
  Future<String> translate({
    required String sourceCode,
    required String targetCode,
    required String text,
  }) async {
    calls++;
    if (delay > Duration.zero) await Future<void>.delayed(delay);
    if (error != null) throw error!;
    return result ?? 'cloud:$text';
  }
}

void main() {
  late _LocalBackend local;
  late _FakeCloudApi api;

  setUp(() {
    local = _LocalBackend();
    api = _FakeCloudApi();
  });

  TranslationService build({
    required bool cloudEnabled,
    required bool online,
    Duration timeout = AppConstants.cloudTimeout,
  }) => TranslationService(
    primary: local,
    cloudBackend: CloudTranslationBackend(cloudApi: api, cloudTimeout: timeout),
    isCloudEnabled: () => cloudEnabled,
    isOnline: () => online,
  );

  Future<String> translate(TranslationService service) => service.translate(
    source: Language.pt,
    target: Language.en,
    text: 'bom dia',
  );

  group('AC: com cloudEnabled = false, nada muda', () {
    test('a nuvem nem é consultada', () async {
      final service = build(cloudEnabled: false, online: true);

      expect(await translate(service), 'local:bom dia');
      expect(api.calls, 0, reason: 'default da v1: a nuvem não existe');
      expect(local.calls, 1);
      expect(service.lastResultWasLocal, isTrue);
    });

    test('sem motor de nuvem configurado o caminho é o de sempre', () async {
      final service = TranslationService(primary: local);

      expect(await translate(service), 'local:bom dia');
      expect(service.lastResultWasLocal, isTrue);
    });
  });

  group('com cloudEnabled = true', () {
    test('offline nem tenta a nuvem', () async {
      final service = build(cloudEnabled: true, online: false);

      expect(await translate(service), 'local:bom dia');
      expect(api.calls, 0, reason: 'sem rede, tentar é só perder tempo');
    });

    test('online e respondendo, a nuvem traduz', () async {
      final service = build(cloudEnabled: true, online: true);

      expect(await translate(service), 'cloud:bom dia');
      expect(local.calls, 0);
      expect(service.lastResultWasLocal, isFalse);
    });

    test('AC: timeout de 2 s cai no local SEM erro ao usuário', () async {
      api.delay = const Duration(milliseconds: 300);
      final service = build(
        cloudEnabled: true,
        online: true,
        timeout: const Duration(milliseconds: 50),
      );

      // Nenhuma exceção sobe: para o usuário, a tradução simplesmente saiu.
      expect(await translate(service), 'local:bom dia');
      expect(local.calls, 1);
      expect(
        service.lastResultWasLocal,
        isTrue,
        reason: 'é o que acende o badge "local"',
      );
    });

    test('erro da API cai no local em silêncio', () async {
      api.error = StateError('502 bad gateway');
      final service = build(cloudEnabled: true, online: true);

      expect(await translate(service), 'local:bom dia');
      expect(service.lastResultWasLocal, isTrue);
    });

    test('resposta vazia da nuvem também cai no local', () async {
      api.result = '   ';
      final service = build(cloudEnabled: true, online: true);

      // Resposta vazia é falha disfarçada: entregá-la apagaria a tradução.
      expect(await translate(service), 'local:bom dia');
    });

    test('desligar a flag entre traduções volta ao local na hora', () async {
      var enabled = true;
      final service = TranslationService(
        primary: local,
        cloudBackend: CloudTranslationBackend(cloudApi: api),
        isCloudEnabled: () => enabled,
        isOnline: () => true,
      );

      expect(await translate(service), 'cloud:bom dia');
      enabled = false;
      expect(await translate(service), 'local:bom dia');
    });
  });

  test(
    'o motor de nuvem converte QUALQUER falha em translationFailed',
    () async {
      api.error = FormatException('json quebrado');
      const backend = CloudTranslationBackend(cloudApi: _NeverApi());

      await expectLater(
        backend.translate(source: Language.pt, target: Language.en, text: 'oi'),
        throwsA(
          isA<AppException>().having(
            (e) => e.code,
            'code',
            ErrorCode.translationFailed,
          ),
        ),
      );
    },
  );
}

/// API que sempre falha — o motor não pode deixar exceção crua escapar.
class _NeverApi implements CloudTranslationApi {
  const _NeverApi();

  @override
  Future<String> translate({
    required String sourceCode,
    required String targetCode,
    required String text,
  }) => throw const FormatException('json quebrado');
}
