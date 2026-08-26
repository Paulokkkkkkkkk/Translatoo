import 'dart:async';

import 'package:fake_async/fake_async.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:translatoo/core/constants/app_constants.dart';
import 'package:translatoo/core/services/app_exception.dart';
import 'package:translatoo/core/services/model_manager_service.dart';
import 'package:translatoo/models/language.dart';
import 'package:translatoo/models/model_state.dart';

/// API fake (F1.3): downloads ficam PENDENTES até o teste completá-los,
/// permitindo inspecionar progresso, cancelamento e falha de forma
/// determinística sob [FakeAsync].
class _FakeApi implements ModelManagerApi {
  final Set<Language> installed = <Language>{};
  final Map<Language, Completer<void>> pending = <Language, Completer<void>>{};

  @override
  Future<bool> isModelDownloaded(Language language) async =>
      installed.contains(language);

  @override
  Future<void> downloadModel(
    Language language, {
    required bool isWifiRequired,
  }) {
    final completer = Completer<void>();
    pending[language] = completer;
    return completer.future;
  }

  void completeDownload(Language language) {
    installed.add(language);
    pending.remove(language)!.complete();
  }

  void failDownload(Language language, Object error) {
    pending.remove(language)!.completeError(error);
  }

  @override
  Future<void> deleteModel(Language language) async {
    installed.remove(language);
  }
}

void main() {
  test('refresh reflete o estado real dos pacotes no aparelho', () {
    fakeAsync((async) {
      final api = _FakeApi()..installed.add(Language.en);
      final service = ModelManagerService(api: api);

      unawaited(service.refreshAll());
      async.elapse(Duration.zero);

      expect(service.stateFor(Language.en), const ModelReady());
      expect(service.stateFor(Language.pt), const ModelNotDownloaded());
      service.dispose();
    });
  });

  test('download emite progresso determinístico e termina READY', () {
    fakeAsync((async) {
      final api = _FakeApi();
      final service = ModelManagerService(
        api: api,
        online: ValueNotifier<bool>(true),
        onMobileData: ValueNotifier<bool>(false),
      );

      unawaited(service.downloadModel(Language.pt));
      async.elapse(Duration.zero);
      expect(service.stateFor(Language.pt), const ModelDownloading(0));

      async.elapse(AppConstants.modelDownloadPollInterval);
      expect(
        service.stateFor(Language.pt),
        const ModelDownloading(AppConstants.modelDownloadProgressStep),
      );

      api.completeDownload(Language.pt);
      async.elapse(Duration.zero);

      expect(service.stateFor(Language.pt), const ModelReady());
      expect(api.pending, isNot(contains(Language.pt)));
      service.dispose();
    });
  });
  test('progresso simulado estaciona no teto até a confirmação real', () {
    fakeAsync((async) {
      final api = _FakeApi();
      final service = ModelManagerService(api: api);

      unawaited(service.downloadModel(Language.zh));
      async.elapse(AppConstants.modelDownloadPollInterval * 30); // >> teto 90%

      expect(
        service.stateFor(Language.zh),
        const ModelDownloading(AppConstants.modelDownloadProgressCap),
      );
      service.dispose();
    });
  });

  test(
    'gate wifiOnly bloqueia em rede medida; force libera SEM mudar prefs',
    () {
      fakeAsync((async) {
        final api = _FakeApi();
        final service = ModelManagerService(
          api: api,
          online: ValueNotifier<bool>(true),
          onMobileData: ValueNotifier<bool>(true), // rede medida
        );

        Object? caught;
        unawaited(
          service
              .downloadModel(Language.pt)
              .catchError((Object e) => caught = e),
        );
        async.elapse(Duration.zero);

        expect(caught, isA<AppException>());
        expect((caught! as AppException).code, ErrorCode.wifiOnly);
        expect(service.stateFor(Language.pt), const ModelNotDownloaded());

        // Decisão "Baixar mesmo assim" vem da UI via `force`.
        unawaited(service.downloadModel(Language.pt, force: true));
        async.elapse(Duration.zero);
        expect(service.stateFor(Language.pt), const ModelDownloading(0));

        service.dispose();
      });
    },
  );

  test('cancelar reseta o estado e ignora conclusão obsoleta do plugin', () {
    fakeAsync((async) {
      final api = _FakeApi();
      final service = ModelManagerService(api: api);

      unawaited(service.downloadModel(Language.pt));
      async.elapse(AppConstants.modelDownloadPollInterval * 2);

      service.cancelDownload(Language.pt);
      expect(service.stateFor(Language.pt), const ModelNotDownloaded());

      api.completeDownload(Language.pt); // nativo conclui depois…
      async.elapse(AppConstants.modelDownloadPollInterval * 3);

      // …mas a geração antiga é ignorada (refresh traria Ready se válido).
      expect(service.stateFor(Language.pt), const ModelNotDownloaded());
      service.dispose();
    });
  });

  test('falha de download normaliza para ERR_DOWNLOAD_FAILED e volta a ND', () {
    fakeAsync((async) {
      final api = _FakeApi();
      final service = ModelManagerService(api: api);

      Object? caught;
      unawaited(
        service.downloadModel(Language.en).catchError((Object e) => caught = e),
      );
      async.elapse(Duration.zero);
      expect(service.stateFor(Language.en), const ModelDownloading(0));

      api.failDownload(
        Language.en,
        const AppException(ErrorCode.downloadFailed),
      );
      async.elapse(Duration.zero);

      expect(caught, isA<AppException>());
      expect((caught! as AppException).code, ErrorCode.downloadFailed);
      expect(service.stateFor(Language.en), const ModelNotDownloaded());
      service.dispose();
    });
  });

  test('download de pacote já pronto é no-op idempotente', () {
    fakeAsync((async) {
      final api = _FakeApi()..installed.add(Language.pt);
      final service = ModelManagerService(api: api);

      unawaited(service.downloadModel(Language.pt));
      async.elapse(Duration.zero);

      // A API fake é "gatada": concluímos manualmente como o SO faria.
      api.completeDownload(Language.pt);
      async.elapse(Duration.zero);

      expect(service.stateFor(Language.pt), const ModelReady());
      expect(api.pending.containsKey(Language.pt), isFalse);
      service.dispose();
    });
  });

  test('deleteModel remove o pacote e volta ao estado não instalado', () {
    fakeAsync((async) {
      final api = _FakeApi()..installed.add(Language.zh);
      final service = ModelManagerService(api: api);

      unawaited(service.deleteModel(Language.zh));
      async.elapse(Duration.zero);

      expect(service.stateFor(Language.zh), const ModelNotDownloaded());
      expect(api.installed, isNot(contains(Language.zh)));
      service.dispose();
    });
  });
}
