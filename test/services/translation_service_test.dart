import 'package:flutter_test/flutter_test.dart';
import 'package:translatoo/core/constants/app_constants.dart';
import 'package:translatoo/core/services/app_exception.dart';
import 'package:translatoo/core/services/translation_backend.dart';
import 'package:translatoo/core/services/translation_service.dart';
import 'package:translatoo/models/language.dart';
import 'package:translatoo/models/language_pair.dart';

/// Backend fake (F1.1): eco prefixado por par — permite verificar fatiamento
/// (quantas chamadas, tamanho dos blocos) e reconstrução da saída.
class FakeEchoBackend implements TranslationBackend {
  FakeEchoBackend({this.id = 'fake', this.ready = true});

  @override
  final String id;
  bool ready;
  final List<List<String>> receivedChunks = <List<String>>[];
  Object? throwOnTranslate;

  @override
  Future<bool> isModelDownloaded(Language language) async => ready;

  @override
  Future<bool> isReady(LanguagePair pair) async => ready;

  @override
  Future<String> translate({
    required Language source,
    required Language target,
    required String text,
  }) async {
    final thrown = throwOnTranslate;
    if (thrown != null) throw thrown;
    receivedChunks.last.add(text);
    return '[${source.mlKitCode}${target.mlKitCode}]$text';
  }

  /// Abre um "slot" para a próxima tradução (permite inspecionar blocos).
  void beginCapture() => receivedChunks.add(<String>[]);

  @override
  void dispose() {}
}

void main() {
  late FakeEchoBackend primary;

  setUp(() {
    primary = FakeEchoBackend(id: 'primary');
  });

  TranslationService serviceWith({
    TranslationBackend? fallback,
    bool? enabled,
  }) => TranslationService(
    primary: primary,
    fallback: fallback,
    fallbackEnabled: enabled ?? false,
  );

  group('TranslationService (F1.2)', () {
    test('texto curto: uma única chamada, saída preservada', () async {
      primary.beginCapture();
      final service = serviceWith();

      final out = await service.translate(
        source: Language.pt,
        target: Language.en,
        text: 'Bom dia',
      );

      expect(out, '[pten]Bom dia');
      expect(primary.receivedChunks.single, hasLength(1));
      expect(service.usesAlternativeEngine, isFalse);
    });

    test(
      'texto longo é fatiado em blocos ≤ 4.500 e recomposto na ordem',
      () async {
        final long = 'palavra ' * 1300; // ~10.400 chars → 3 blocos
        primary.beginCapture();
        final service = serviceWith();

        final out = await service.translate(
          source: Language.pt,
          target: Language.zh,
          text: long,
        );

        final chunks = primary.receivedChunks.single;
        expect(chunks.length, greaterThan(1));
        for (final chunk in chunks) {
          expect(chunk.length, lessThanOrEqualTo(AppConstants.chunkBlockChars));
        }
        expect(chunks.join(), long); // ordem e integridade dos blocos
        // Saída = prefixo por bloco; removendo-os, o texto volta inteiro.
        final parts = out.split('[ptzh]');
        expect(parts.first, isEmpty);
        expect(parts.skip(1).join(), long);
      },
    );

    test('pacote ausente falha ANTES de chamar o motor (fail-fast)', () async {
      primary.ready = false;
      primary.beginCapture();
      final service = serviceWith();

      await expectLater(
        service.translate(source: Language.pt, target: Language.en, text: 'oi'),
        throwsA(
          isA<AppException>().having(
            (e) => e.code,
            'code',
            ErrorCode.modelNotDownloaded,
          ),
        ),
      );
      expect(primary.receivedChunks.single, isEmpty);
    });

    test(
      'fallback transparente em falha de ENGINE (AC-M1-4 via mock)',
      () async {
        primary.throwOnTranslate = const AppException(
          ErrorCode.translationFailed,
        );
        final alternative = FakeEchoBackend(id: 'alternative')..beginCapture();
        final service = serviceWith(fallback: alternative, enabled: true);

        final out = await service.translate(
          source: Language.pt,
          target: Language.en,
          text: 'olá',
        );

        expect(out, '[pten]olá');
        expect(service.usesAlternativeEngine, isTrue);
        expect(service.activeBackend.id, 'alternative');
        expect(alternative.receivedChunks.single, ['olá']);
      },
    );

    test('NÃO há fallback para erro de pacote ausente', () async {
      primary.throwOnTranslate = const AppException(
        ErrorCode.modelNotDownloaded,
        suggestedAction: SuggestedAction.download,
      );
      final alternative = FakeEchoBackend(id: 'alternative');
      final service = serviceWith(fallback: alternative, enabled: true);

      await expectLater(
        service.translate(source: Language.pt, target: Language.en, text: 'oi'),
        throwsA(
          isA<AppException>().having(
            (e) => e.code,
            'code',
            ErrorCode.modelNotDownloaded,
          ),
        ),
      );
      expect(service.usesAlternativeEngine, isFalse);
    });

    test('flag DESLIGADA: falha de engine propaga sem trocar motor', () async {
      primary.throwOnTranslate = const AppException(
        ErrorCode.translationFailed,
      );
      final alternative = FakeEchoBackend(id: 'alternative');
      final service = serviceWith(fallback: alternative); // default OFF

      await expectLater(
        service.translate(source: Language.pt, target: Language.en, text: 'oi'),
        throwsA(isA<AppException>()),
      );
      expect(service.usesAlternativeEngine, isFalse);
    });
  });
}
