import 'package:flutter_test/flutter_test.dart';
import 'package:translatoo/models/app_settings.dart';
import 'package:translatoo/models/language.dart';

void main() {
  group('AppSettings (F0.6)', () {
    test('defaults seguem o PRD §M4', () {
      final settings = AppSettings.defaults();
      expect(settings.srcLang, Language.pt);
      expect(settings.tgtLang, Language.en);
      expect(settings.ttsRate, 0.5);
      expect(settings.ttsPitch, 1.0);
      expect(settings.autoPlay, isFalse);
      expect(settings.wifiOnly, isTrue);
      expect(settings.cloudEnabled, isFalse); // flag P2 desligada na v1
      expect(settings.themeMode, SettingsThemeMode.system);
      expect(settings.schemaVersion, 1);
    });

    test('copyWith é imutável — base permanece intacta', () {
      final base = AppSettings.defaults();
      final changed = base.copyWith(tgtLang: Language.zh, wifiOnly: false);

      expect(changed.tgtLang, Language.zh);
      expect(changed.wifiOnly, isFalse);
      expect(base.tgtLang, Language.en);
      expect(base.wifiOnly, isTrue);
    });

    test('JSON round-trip preserva todos os campos', () {
      const settings = AppSettings(
        srcLang: Language.pt,
        tgtLang: Language.zh,
        ttsRate: 0.75,
        ttsPitch: 1.25,
        autoPlay: true,
        wifiOnly: false,
        cloudEnabled: false,
        themeMode: SettingsThemeMode.dark,
        schemaVersion: 1,
      );

      final restored = AppSettings.fromJson(settings.toJson());
      expect(restored, settings);
    });

    test('fromJson tolerante cai nos defaults', () {
      final restored = AppSettings.fromJson(const <String, dynamic>{});
      expect(restored, AppSettings.defaults());
    });

    test('igualdade estrutural funciona', () {
      expect(AppSettings.defaults(), AppSettings.defaults());
      expect(
        AppSettings.defaults(),
        isNot(AppSettings.defaults().copyWith(autoPlay: true)),
      );
    });
  });
}
