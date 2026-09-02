import 'package:flutter_test/flutter_test.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:translatoo/core/services/app_exception.dart';
import 'package:translatoo/core/services/mic_permission_service.dart';

/// Plataforma fake: o teste escreve o roteiro do SO — o que `status` responde
/// antes de perguntar e o que o diálogo devolve depois.
class _FakeApi implements MicPermissionApi {
  _FakeApi(this.initial);

  PermissionStatus initial;
  PermissionStatus? afterRequest;

  int requestCount = 0;
  int openSettingsCount = 0;
  Object? platformError;

  @override
  Future<PermissionStatus> status() async {
    if (platformError != null) throw platformError!;
    return initial;
  }

  @override
  Future<PermissionStatus> request() async {
    requestCount++;
    return initial = afterRequest ?? initial;
  }

  @override
  Future<bool> openSettings() async {
    openSettingsCount++;
    return true;
  }
}

void main() {
  group('os três caminhos do PRD §4.5', () {
    test('conceder', () async {
      final api = _FakeApi(PermissionStatus.denied)
        ..afterRequest = PermissionStatus.granted;

      final result = await MicPermissionService(api: api).request();

      expect(result, MicPermission.granted);
      expect(MicPermissionService.toException(result), isNull);
      expect(api.requestCount, 1);
    });

    test('negar — vale a pena perguntar de novo', () async {
      final api = _FakeApi(PermissionStatus.denied)
        ..afterRequest = PermissionStatus.denied;

      final result = await MicPermissionService(api: api).request();

      expect(result, MicPermission.denied);
      final error = MicPermissionService.toException(result)!;
      expect(error.code, ErrorCode.micPermission);
      expect(error.suggestedAction, SuggestedAction.retry);
    });

    test(
      'negar permanentemente → ação "Abrir configurações" (AC-M2-2)',
      () async {
        final api = _FakeApi(PermissionStatus.permanentlyDenied);
        final service = MicPermissionService(api: api);

        final result = await service.request();

        expect(result, MicPermission.permanentlyDenied);
        final error = MicPermissionService.toException(result)!;
        expect(error.code, ErrorCode.micPermission);
        expect(error.suggestedAction, SuggestedAction.openSettings);

        // Não adianta abrir diálogo do SO que ele nunca mais vai exibir.
        expect(api.requestCount, 0);

        await service.openSettings();
        expect(api.openSettingsCount, 1);
      },
    );
  });

  test('permissão já concedida não reabre o diálogo do sistema', () async {
    final api = _FakeApi(PermissionStatus.granted);

    expect(
      await MicPermissionService(api: api).request(),
      MicPermission.granted,
    );
    expect(api.requestCount, 0);
  });

  test('current() consulta sem perguntar nada ao usuário', () async {
    final api = _FakeApi(PermissionStatus.denied);

    expect(
      await MicPermissionService(api: api).current(),
      MicPermission.denied,
    );
    expect(api.requestCount, 0);
  });

  test('restricted/limited contam como beco sem saída', () async {
    for (final status in <PermissionStatus>[
      PermissionStatus.restricted,
      PermissionStatus.limited,
      PermissionStatus.provisional,
    ]) {
      final api = _FakeApi(status);
      expect(
        await MicPermissionService(api: api).current(),
        MicPermission.permanentlyDenied,
        reason: 'status $status',
      );
    }
  });

  test('falha do canal de plataforma vira AppException (RN-03)', () async {
    final api = _FakeApi(PermissionStatus.denied)
      ..platformError = Exception('canal indisponível');

    await expectLater(
      MicPermissionService(api: api).current(),
      throwsA(
        isA<AppException>().having(
          (e) => e.code,
          'code',
          ErrorCode.micPermission,
        ),
      ),
    );
  });
}
