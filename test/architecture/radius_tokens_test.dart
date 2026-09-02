import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:translatoo/core/constants/app_spacing.dart';

/// Guarda de arquitetura da §2 do design system: raio sempre vem de token.
///
/// Sem este teste a regra é só uma frase no documento — e o próximo widget com
/// pressa vai escrever `BorderRadius.circular(28)`, porque é o caminho curto.
void main() {
  test('os quatro níveis da §2 existem e estão ordenados', () {
    expect(AppSpacing.radiusSm, 8);
    expect(AppSpacing.radiusMd, 16);
    expect(AppSpacing.radiusLg, 28);
    expect(AppSpacing.radiusSm, lessThan(AppSpacing.radiusMd));
    expect(AppSpacing.radiusMd, lessThan(AppSpacing.radiusLg));
  });

  test('AppSpacing.radius continua valendo como alias de radiusMd', () {
    // O alias existe para o código da F0/F1 não migrar num único commit.
    expect(AppSpacing.radius, AppSpacing.radiusMd);
  });

  test('nenhum raio cru em lib/', () {
    // Casa `BorderRadius.circular(12)` e `Radius.circular(28.0)`, mas não
    // `BorderRadius.circular(AppSpacing.radiusLg)`.
    final rawRadius = RegExp(r'Radius\.circular\(\s*[0-9]');

    final offenders = <String>[];
    for (final entity in Directory('lib').listSync(recursive: true)) {
      if (entity is! File || !entity.path.endsWith('.dart')) continue;
      final lines = entity.readAsLinesSync();
      for (var i = 0; i < lines.length; i++) {
        if (rawRadius.hasMatch(lines[i])) {
          offenders.add('${entity.path}:${i + 1}  ${lines[i].trim()}');
        }
      }
    }

    expect(
      offenders,
      isEmpty,
      reason:
          'Raio cru é proibido pela regra de aderência (§11). Escolha o nível '
          'em AppSpacing: radiusSm (chips, indicadores), radiusMd (botões, '
          'inputs, diálogos), radiusLg (painéis, cards, sheets).',
    );
  });
}
