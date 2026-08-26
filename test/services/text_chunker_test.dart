import 'package:flutter_test/flutter_test.dart';
import 'package:translatoo/core/constants/app_constants.dart';
import 'package:translatoo/core/services/text_chunker.dart';

void main() {
  group('chunkText (F1.2 — RF-M1-05)', () {
    test('texto curto passa intacto em bloco único', () {
      final chunks = chunkText('Bom dia');
      expect(chunks, hasLength(1));
      expect(chunks.single, 'Bom dia');
    });

    test('recomposição exata: join(chunks) == original', () {
      const original =
          'Primeiro parágrafo com texto. Segunda frase ainda aqui.\n\n'
          'Segundo parágrafo, com vírgulas, pontos. E mais frase!\n'
          'Linha final com conteúdo suficiente para o teste passar.';
      final chunks = chunkText(original);
      expect(chunks.join(), original);
    });

    test('nenhum bloco excede o limite de 4.500', () {
      final long = List.filled(300, 'Uma frase de exemplo qualquer.').join();
      final chunks = chunkText(long);
      expect(chunks.length, greaterThan(1));
      for (final chunk in chunks) {
        expect(chunk.length, lessThanOrEqualTo(AppConstants.chunkBlockChars));
      }
      expect(chunks.join(), long);
    });

    test('prefere quebra de FRASE quando existe antes do limite', () {
      final text = 'Olá mundo.${'x' * 5000}';
      final chunks = chunkText(text);
      // O ponto na posição 10 é a quebra natural mais próxima do limite.
      expect(chunks.first, 'Olá mundo.');
      expect(chunks.join(), text);
    });

    test('quebra em pontuação CJK (。)', () {
      final text = '你好世界。${'字' * 5000}';
      final chunks = chunkText(text);
      expect(chunks.first, '你好世界。');
      expect(chunks.join(), text);
    });

    test('hard-cut quando não há nenhuma quebra utilizável', () {
      final text = 'a' * 5000;
      final chunks = chunkText(text);
      expect(chunks.map((c) => c.length).toList(), <int>[4500, 500]);
      expect(chunks.join(), text);
    });

    test('nunca divide par surrogate (emoji) ao meio', () {
      final text = '${'a' * 4498}😀${'b' * 600}';
      final chunks = chunkText(text);
      expect(chunks.join(), text);
      expect(
        chunks.first.endsWith('😀'),
        isTrue,
        reason: 'emoji deve permanecer inteiro no 1º bloco',
      );
      for (final chunk in chunks) {
        // Nenhum bloco termina em alta-surrogate órfã.
        final units = chunk.codeUnits;
        final last = units.isEmpty ? null : units.last;
        final orphanHigh = last != null && last >= 0xD800 && last <= 0xDBFF;
        expect(orphanHigh, isFalse);
      }
    });

    test('respeita maxChars customizado', () {
      final chunks = chunkText('ab cd ef gh', maxChars: 5);
      expect(chunks.join(), 'ab cd ef gh');
      for (final chunk in chunks) {
        expect(chunk.length, lessThanOrEqualTo(5));
      }
    });

    test('maxChars inválido lança ArgumentError', () {
      expect(() => chunkText('abc', maxChars: 0), throwsArgumentError);
    });
  });
}
