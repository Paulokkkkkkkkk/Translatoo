import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:translatoo/core/theme/app_theme.dart';

/// F1.9 — AC-F1-6. O mandarim só renderiza sem tofu se TODO estilo de texto
/// carregar o fallback CJK; um único estilo sem ele já produz □□□ na tela.
void main() {
  List<TextStyle?> stylesOf(TextTheme t) => <TextStyle?>[
    t.displayLarge,
    t.displayMedium,
    t.headlineMedium,
    t.titleLarge,
    t.titleMedium,
    t.titleSmall,
    t.bodyLarge,
    t.bodyMedium,
    t.bodySmall,
    t.labelLarge,
    t.labelMedium,
    t.labelSmall,
  ];

  for (final MapEntry<String, ThemeData> entry in <String, ThemeData>{
    'light': AppTheme.light(),
    'dark': AppTheme.dark(),
  }.entries) {
    group('tema ${entry.key}', () {
      final ThemeData theme = entry.value;

      test('todo estilo do TextTheme declara o fallback CJK', () {
        for (final TextStyle? style in stylesOf(theme.textTheme)) {
          expect(style?.fontFamilyFallback, AppTheme.cjkFallback);
        }
      });

      test('estilos dos temas de componente herdam o fallback', () {
        final List<TextStyle?> componentStyles = <TextStyle?>[
          theme.appBarTheme.titleTextStyle,
          theme.inputDecorationTheme.hintStyle,
          theme.inputDecorationTheme.counterStyle,
          theme.snackBarTheme.contentTextStyle,
          theme.navigationBarTheme.labelTextStyle?.resolve(<WidgetState>{}),
          theme.elevatedButtonTheme.style?.textStyle?.resolve(<WidgetState>{}),
          theme.filledButtonTheme.style?.textStyle?.resolve(<WidgetState>{}),
        ];
        for (final TextStyle? style in componentStyles) {
          expect(style, isNotNull);
          expect(style!.fontFamilyFallback, AppTheme.cjkFallback);
        }
      });
    });
  }

  test('nenhuma fonte é nomeada fora de app_theme.dart', () {
    final List<String> offenders = <String>[];
    for (final FileSystemEntity entity in Directory(
      'lib',
    ).listSync(recursive: true)) {
      if (entity is! File || !entity.path.endsWith('.dart')) continue;
      if (entity.path.endsWith('core/theme/app_theme.dart')) continue;
      if (entity.readAsStringSync().contains('fontFamily')) {
        offenders.add(entity.path);
      }
    }
    expect(offenders, isEmpty);
  });

  test('o subset embutido cabe no orçamento de 5 MB do flavor lite', () {
    final Iterable<File> fonts = Directory(
      'assets/fonts',
    ).listSync().whereType<File>().where((File f) => f.path.endsWith('.ttf'));
    expect(fonts, isNotEmpty);
    final int total = fonts.fold(0, (int sum, File f) => sum + f.lengthSync());
    expect(total, lessThanOrEqualTo(5 * 1024 * 1024));
  });
}
