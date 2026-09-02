import 'dart:async';
import 'dart:typed_data';

import 'package:connectivity_plus_platform_interface/connectivity_plus_platform_interface.dart';
import 'package:translatoo/core/services/model_manager_service.dart';
import 'package:translatoo/core/services/stt_service.dart';
import 'package:translatoo/core/services/translation_backend.dart';
import 'package:translatoo/core/services/tts_service.dart';
import 'package:translatoo/models/language.dart';
import 'package:translatoo/models/language_pair.dart';

/// Dublês compartilhados por testes que montam o `TranslatooApp` inteiro.
///
/// Montar o app completo é o único jeito de exercitar breakpoints que mudam a
/// SHELL — mas isso arrasta todos os serviços de plataforma junto, e nenhum
/// deles funciona sob `flutter test`.

class FakeConnectivity extends ConnectivityPlatform {
  @override
  Future<List<ConnectivityResult>> checkConnectivity() async =>
      <ConnectivityResult>[ConnectivityResult.wifi];

  @override
  Stream<List<ConnectivityResult>> get onConnectivityChanged =>
      Stream<List<ConnectivityResult>>.value(<ConnectivityResult>[
        ConnectivityResult.wifi,
      ]);
}

class ReadyModelApi implements ModelManagerApi {
  @override
  Future<bool> isModelDownloaded(Language language) async => true;

  @override
  Future<void> downloadModel(
    Language language, {
    required bool isWifiRequired,
  }) async {}

  @override
  Future<void> deleteModel(Language language) async {}
}

class EchoBackend implements TranslationBackend {
  @override
  String get id => 'echo';

  @override
  Future<bool> isModelDownloaded(Language language) async => true;

  @override
  Future<bool> isReady(LanguagePair pair) async => true;

  @override
  Future<String> translate({
    required Language source,
    required Language target,
    required String text,
  }) async => '[${source.name}${target.name}]$text';

  @override
  void dispose() {}
}

/// Microfone que nunca abre — estes testes são de layout, não de ditado.
class SilentAudio implements SttAudioSource {
  const SilentAudio();

  @override
  Future<Stream<Uint8List>> start() async => const Stream<Uint8List>.empty();

  @override
  Future<void> stop() async {}

  @override
  Stream<double> get amplitude => const Stream<double>.empty();
}

/// Motor de voz mudo, para o `TtsService` nascer sem tocar em canal nativo.
class SilentTtsEngine implements TtsEngine {
  final StreamController<TtsEvent> _events =
      StreamController<TtsEvent>.broadcast();

  @override
  Future<bool> isLanguageAvailable(String ttsCode) async => true;

  @override
  Future<void> configure({
    required String languageCode,
    required double rate,
    required double pitch,
  }) async {}

  @override
  Future<void> speak(String text) async {}

  @override
  Future<void> stop() async {}

  @override
  Stream<TtsEvent> get events => _events.stream;

  @override
  Future<void> dispose() async => _events.close();
}
