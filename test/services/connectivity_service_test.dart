import 'dart:async';

import 'package:connectivity_plus_platform_interface/connectivity_plus_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:translatoo/core/services/connectivity_service.dart';

class _FakePlatform extends ConnectivityPlatform {
  _FakePlatform(this.initialResults);

  final List<ConnectivityResult> initialResults;
  final StreamController<List<ConnectivityResult>> events =
      StreamController<List<ConnectivityResult>>.broadcast();

  @override
  Future<List<ConnectivityResult>> checkConnectivity() async => initialResults;

  @override
  Stream<List<ConnectivityResult>> get onConnectivityChanged => events.stream;
}

/// Drena microtasks/timers pendentes para eventos de stream broadcast.
Future<void> _drainEventLoop() async {
  await Future<void>.delayed(Duration.zero);
  await Future<void>.delayed(Duration.zero);
}

void main() {
  group('ConnectivityService (F0.7)', () {
    late ConnectivityPlatform original;

    setUp(() {
      original = ConnectivityPlatform.instance;
    });

    tearDown(() {
      ConnectivityPlatform.instance = original;
    });

    test('inicia online e reage às transições da rede', () async {
      final platform = _FakePlatform([ConnectivityResult.wifi]);
      ConnectivityPlatform.instance = platform;

      final service = ConnectivityService();
      await service.start();

      expect(service.isOnline.value, isTrue);

      platform.events.add([ConnectivityResult.none]);
      await _drainEventLoop();
      expect(service.isOnline.value, isFalse);

      platform.events.add([ConnectivityResult.mobile]);
      await _drainEventLoop();
      expect(service.isOnline.value, isTrue);

      await service.dispose();
    });

    test('qualquer resultado != none conta como online', () async {
      final platform = _FakePlatform([ConnectivityResult.ethernet]);
      ConnectivityPlatform.instance = platform;

      final service = ConnectivityService();
      await service.start();

      expect(service.isOnline.value, isTrue);
      await service.dispose();
    });

    test('start é idempotente', () async {
      final platform = _FakePlatform([ConnectivityResult.none]);
      ConnectivityPlatform.instance = platform;

      final service = ConnectivityService();
      await service.start();
      await service.start(); // segunda chamada não deve re-assinar

      expect(service.isOnline.value, isFalse);
      await service.dispose();
    });
  });
}
