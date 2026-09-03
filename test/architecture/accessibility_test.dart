import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:translatoo/core/constants/app_spacing.dart';

/// Guardas de acessibilidade e privacidade (F4.5).
///
/// Auditoria manual envelhece: passa uma vez e o próximo widget reintroduz o
/// problema. Estes testes transformam as regras da RN-06 e da MS-03 em trava
/// de build.
void main() {
  List<File> dartFiles(String dir) => Directory(dir)
      .listSync(recursive: true)
      .whereType<File>()
      .where((f) => f.path.endsWith('.dart'))
      .toList();

  test('todo IconButton tem tooltip (RN-06)', () {
    // Tooltip é o que o leitor de tela anuncia num botão só de ícone. Sem ele,
    // o usuário ouve "botão" e nada mais.
    final offenders = <String>[];

    for (final file in dartFiles('lib/ui')) {
      final source = file.readAsStringSync();
      for (final match in RegExp('IconButton\\(').allMatches(source)) {
        final end = (match.start + 420).clamp(0, source.length);
        final chunk = source.substring(match.start, end);
        if (!chunk.contains('tooltip:')) {
          final line =
              '\n'.allMatches(source.substring(0, match.start)).length + 1;
          offenders.add('${file.path}:$line');
        }
      }
    }

    expect(
      offenders,
      isEmpty,
      reason:
          'IconButton sem tooltip não é anunciado por leitor de tela. '
          'Use o rótulo de app_strings.dart.',
    );
  });

  test('nenhuma biblioteca de rede em lib/ (MS-03: zero coleta)', () {
    // A promessa "nenhum dado sai do seu aparelho" é verificável: a única
    // conexão permitida é o download de pacotes do ML Kit, que acontece
    // dentro do plugin. Cliente HTTP próprio em lib/ seria a porta por onde
    // conteúdo do usuário poderia vazar.
    final forbidden = <String>[
      'package:http/',
      'package:dio/',
      'package:web_socket_channel/',
      'HttpClient(',
    ];

    final offenders = <String>[];
    for (final file in dartFiles('lib')) {
      final source = file.readAsStringSync();
      for (final needle in forbidden) {
        if (source.contains(needle)) offenders.add('${file.path}: $needle');
      }
    }

    expect(
      offenders,
      isEmpty,
      reason:
          'A auditoria de tráfego da MS-03 depende de não existir cliente HTTP '
          'próprio. Se um for necessário, a exceção precisa de decisão de '
          'produto e entra na política de privacidade.',
    );
  });

  test('o alvo mínimo de toque é 48 dp e ninguém redefine isso', () {
    // Um número solto em widget é como a regra morre: o token é a fonte única.
    expect(AppSpacing.minTouchTarget, 48);

    final offenders = <String>[];
    for (final file in dartFiles('lib/ui')) {
      final source = file.readAsStringSync();
      // Só `BoxConstraints`, que é o que constrange área TOCÁVEL. A altura de
      // uma barra de progresso também é `minHeight`, e travá-la em 48 dp seria
      // aplicar a regra onde ela não vale.
      for (final match in RegExp(r'BoxConstraints\(').allMatches(source)) {
        final end = (match.start + 260).clamp(0, source.length);
        final chunk = source.substring(match.start, end);
        for (final size in RegExp(
          r'min(?:Width|Height):\s*(\d+)',
        ).allMatches(chunk)) {
          if (int.parse(size.group(1)!) < AppSpacing.minTouchTarget) {
            final line =
                '\n'.allMatches(source.substring(0, match.start)).length + 1;
            offenders.add('${file.path}:$line (${size.group(0)})');
          }
        }
      }
    }

    expect(offenders, isEmpty, reason: 'Alvo de toque abaixo de 48 dp (RN-06)');
  });

  test('o app declara só as duas permissões que usa', () {
    final manifest = File(
      'android/app/src/main/AndroidManifest.xml',
    ).readAsStringSync();

    final declared = RegExp(
      'android:name="android.permission.([A-Z_]+)"',
    ).allMatches(manifest).map((m) => m.group(1)).toSet();

    // INTERNET só para baixar pacotes de idioma (RN-02); RECORD_AUDIO para o
    // ditado on-device. Qualquer terceira permissão atrai revisão manual na
    // loja e precisa de justificativa (RF-REL-05).
    expect(declared, <String>{'INTERNET', 'RECORD_AUDIO'});
  });
}
