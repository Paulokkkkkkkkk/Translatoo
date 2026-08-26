import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:translatoo/core/constants/app_strings.dart';

void main() {
  group('AppStrings — i18n manual (F0.5 / AC-F0-2)', () {
    test('resolve pt-BR, en-US e zh-CN', () {
      expect(
        AppStrings.forLocale(const Locale('pt', 'BR')).tabTranslate,
        'Traduzir',
      );
      expect(
        AppStrings.forLocale(const Locale('en', 'US')).tabTranslate,
        'Translate',
      );
      expect(AppStrings.forLocale(const Locale('zh', 'CN')).tabTranslate, '翻译');
    });

    test('fallback pt-BR para idiomas não suportados', () {
      expect(
        AppStrings.forLocale(const Locale('es', 'MX')).tabTranslate,
        'Traduzir',
      );
      expect(AppStrings.forLocale(const Locale('fr')).offline, 'Offline');
    });

    test('mensagens de erro §4.8 interpolam o nome do idioma', () {
      expect(
        AppStrings.forLocale(const Locale('pt')).errModelNotDownloaded('中文'),
        'Pacote de 中文 não instalado',
      );
      expect(
        AppStrings.forLocale(const Locale('zh')).errTtsVoiceMissing('English'),
        contains('English'),
      );
    });

    test('as três implementações cobrem o contrato completo', () {
      final locales = [
        const Locale('pt', 'BR'),
        const Locale('en', 'US'),
        const Locale('zh', 'CN'),
      ];
      for (final locale in locales) {
        final t = AppStrings.forLocale(locale);
        // Amostragem representativa de cada bloco do contrato:
        expect(t.appName, isNotEmpty);
        expect(t.tabHistory, isNotEmpty);
        expect(t.tabSettings, isNotEmpty);
        expect(t.online, isNotEmpty);
        expect(t.offline, isNotEmpty);
        expect(t.translatePlaceholderBody, isNotEmpty);
        expect(t.historyPlaceholderBody, isNotEmpty);
        expect(t.settingsPlaceholderBody, isNotEmpty);
        expect(t.actionCancel, isNotEmpty);
        expect(t.actionRetry, isNotEmpty);
        expect(t.actionDownloadAnyway, isNotEmpty);
        expect(t.errMicPermission, isNotEmpty);
        expect(t.errSttEngine, isNotEmpty);
        expect(t.errStorage, isNotEmpty);
        expect(t.errTranslationFailed, isNotEmpty);
        expect(t.historyEmpty, isNotEmpty);
        expect(t.settingsPrivacy, isNotEmpty);
      }
    });
  });
}
