import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Guarda de arquitetura da F2.1b: o flavor entra no Dart em UM único ponto
/// (`AppConstants.sttModelAsset`) e chega à `ui/` apenas via ViewModel.
///
/// Sem este teste a regra é só uma frase no plano — e a primeira tela que
/// precisar esconder o 🎤 vai consultar a constante direto, porque é o
/// caminho mais curto.
void main() {
  test('nenhum arquivo de lib/ui/ conhece o flavor ou o modelo de STT', () {
    const forbidden = <String>[
      'sttModelAsset',
      'hasEmbeddedSttModels',
      'STT_MODEL_ASSET',
      'appFlavor',
    ];

    final offenders = <String>[];
    for (final entity in Directory('lib/ui').listSync(recursive: true)) {
      if (entity is! File || !entity.path.endsWith('.dart')) continue;
      final source = entity.readAsStringSync();
      for (final token in forbidden) {
        if (source.contains(token)) {
          offenders.add('${entity.path}: $token');
        }
      }
    }

    expect(
      offenders,
      isEmpty,
      reason:
          'A ui/ deve perguntar ao ViewModel (ex.: TranslatorViewModel.canDictate), '
          'nunca ao flavor. Ver implementation_plan.md §F2.1b.',
    );
  });
}
