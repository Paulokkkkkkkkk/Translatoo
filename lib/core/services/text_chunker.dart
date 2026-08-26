import '../constants/app_constants.dart';

/// Fatiamento de textos longos (RF-M1-05 / plano F1.2): blocos de até
/// [AppConstants.chunkBlockChars] (4.500) caracteres, cortados preferindo
/// quebras naturais — parágrafo (`\n`) → frase (`. ! ? 。 ！？ ;`) → vírgula →
/// espaço — com hard-cut como último recurso.
///
/// GARANTIAS (cobertas por teste):
/// - `''.join(chunks)` recompõe EXATAMENTE o texto original;
/// - todo bloco tem ≤ maxChars (exceto quando impossível: 1º char já é corte);
/// - pares surrogate (emoji/CJK extraplano) nunca são partidos ao meio.
List<String> chunkText(String text, {int? maxChars}) {
  final max = maxChars ?? AppConstants.chunkBlockChars;
  if (max <= 0) {
    throw ArgumentError.value(maxChars, 'maxChars', 'deve ser > 0');
  }
  if (text.length <= max) return <String>[text];

  final chunks = <String>[];
  var remaining = text;
  while (remaining.length > max) {
    final cut = _findCutIndex(remaining, max);
    chunks.add(remaining.substring(0, cut));
    remaining = remaining.substring(cut);
  }
  if (remaining.isNotEmpty) chunks.add(remaining);
  return chunks;
}

/// Unidades UTF-16 que caracterizam uma quebra natural aceitável.
const Set<int> _breakUnits = <int>{
  0x0A, // \n (parágrafo/linha)
  0x2E, // .   0x21 !   0x3F ?   0x3B ;
  0x2C, // ,
  0x20, // espaço
  0x3002, // 。  0xFF01 ！  0xFF1F ？  0xFF1B ；  0xFF0C ，(CJK fullwidth)
};

int _findCutIndex(String s, int max) {
  // Recua para não partir um par surrogate no meio.
  var index = max;
  while (_splitsSurrogatePair(s, index)) {
    index--;
  }
  // Procura a quebra natural mais próxima ANTES do limite.
  for (var i = index - 1; i > 0; i--) {
    if (_breakUnits.contains(s.codeUnitAt(i))) return i + 1;
  }
  return index; // hard-cut (string sem nenhuma quebra utilizável)
}

bool _splitsSurrogatePair(String s, int index) {
  if (index <= 0 || index >= s.length) return false;
  final high = s.codeUnitAt(index - 1);
  final low = s.codeUnitAt(index);
  return high >= 0xD800 && high <= 0xDBFF && low >= 0xDC00 && low <= 0xDFFF;
}
