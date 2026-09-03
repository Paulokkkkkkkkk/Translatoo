import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:translatoo/core/services/storage_service.dart';
import 'package:translatoo/models/app_settings.dart';
import 'package:translatoo/models/language.dart';
import 'package:translatoo/state/settings_view_model.dart';

void main() {
  late StorageService storage;
  late SettingsViewModel vm;

  setUp(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    storage = StorageService(prefs: await SharedPreferences.getInstance());
    await storage.initialize();
    vm = SettingsViewModel(storageService: storage);
  });

  tearDown(() {
    vm.dispose();
    storage.dispose();
  });

  /// Simula o restart do app: um `StorageService` novo lendo o mesmo disco.
  /// A gravação tem debounce de 500 ms, então é preciso deixá-la acontecer.
  Future<SettingsViewModel> restart() async {
    await Future<void>.delayed(const Duration(milliseconds: 600));
    final fresh = StorageService(prefs: await SharedPreferences.getInstance());
    await fresh.initialize();
    addTearDown(fresh.dispose);
    final reopened = SettingsViewModel(storageService: fresh);
    addTearDown(reopened.dispose);
    return reopened;
  }

  test('AC-M3-4: velocidade sobrevive ao restart', () async {
    vm.setTtsRate(0.8);
    expect(vm.ttsRate, 0.8);

    final reopened = await restart();

    expect(reopened.ttsRate, 0.8);
  });

  test('AC-F3-6: tema manual persiste', () async {
    expect(vm.themeMode, SettingsThemeMode.system);

    vm.setThemeMode(SettingsThemeMode.dark);
    final reopened = await restart();

    expect(reopened.themeMode, SettingsThemeMode.dark);
  });

  test('autoplay e wifiOnly persistem', () async {
    vm
      ..setAutoPlay(true)
      ..setWifiOnly(false);

    final reopened = await restart();

    expect(reopened.autoPlay, isTrue);
    expect(reopened.wifiOnly, isFalse);
  });

  group('par de idiomas (RN-01: origem ≠ destino)', () {
    test('escolher como origem o idioma que já é destino TROCA os dois', () {
      // Estado inicial: pt → en.
      vm.setSourceLanguage(Language.en);

      expect(vm.sourceLanguage, Language.en);
      expect(
        vm.targetLanguage,
        Language.pt,
        reason: 'trocar é mais útil que recusar em silêncio',
      );
    });

    test('escolher como destino o idioma que já é origem TROCA os dois', () {
      vm.setTargetLanguage(Language.pt);

      expect(vm.targetLanguage, Language.pt);
      expect(vm.sourceLanguage, Language.en);
    });

    test('escolher um terceiro idioma não mexe no outro lado', () {
      vm.setTargetLanguage(Language.zh);

      expect(vm.sourceLanguage, Language.pt);
      expect(vm.targetLanguage, Language.zh);
    });

    test('o par escolhido sobrevive ao restart', () async {
      vm.setTargetLanguage(Language.zh);

      final reopened = await restart();

      expect(reopened.sourceLanguage, Language.pt);
      expect(reopened.targetLanguage, Language.zh);
    });
  });

  group('limites dos sliders', () {
    test('velocidade é presa em 0..1', () {
      vm.setTtsRate(5);
      expect(vm.ttsRate, 1.0);

      vm.setTtsRate(-2);
      expect(vm.ttsRate, 0.0);
    });

    test('tom é preso em 0,5..2,0 — a escala nativa do SO', () {
      vm.setTtsPitch(9);
      expect(vm.ttsPitch, 2.0);

      vm.setTtsPitch(0);
      expect(vm.ttsPitch, 0.5);
    });
  });

  test('escrever o mesmo valor não notifica à toa', () {
    var notifications = 0;
    vm.addListener(() => notifications++);

    vm
      ..setAutoPlay(false) // já é false
      ..setThemeMode(SettingsThemeMode.system); // já é system

    expect(notifications, 0);
  });
}
