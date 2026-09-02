import 'package:permission_handler/permission_handler.dart';

import 'app_exception.dart';

/// Desfecho de um pedido de microfone (F2.3 / PRD §4.5).
///
/// Os três caminhos que o produto precisa distinguir — e só eles. `restricted`,
/// `limited` e `provisional` do plugin colapsam em [permanentlyDenied]: do
/// ponto de vista do usuário são o mesmo beco sem saída, e tratá-los como
/// "negado temporário" produziria um diálogo que pede de novo algo que o SO
/// nunca mais vai perguntar.
enum MicPermission {
  /// Pode gravar.
  granted,

  /// Negado agora; perguntar de novo continua valendo a pena.
  denied,

  /// Só as configurações do sistema resolvem (AC-M2-2).
  permanentlyDenied,
}

/// Ponte MÍNIMA sobre o `permission_handler`, pelo mesmo motivo do
/// `ModelManagerApi` (F1.3): sem ela os testes precisariam de canal de
/// plataforma para exercitar três caminhos de decisão.
abstract interface class MicPermissionApi {
  Future<PermissionStatus> status();

  Future<PermissionStatus> request();

  Future<bool> openSettings();
}

/// Implementação real sobre `Permission.microphone`.
final class PlatformMicPermissionApi implements MicPermissionApi {
  @override
  Future<PermissionStatus> status() => Permission.microphone.status;

  @override
  Future<PermissionStatus> request() => Permission.microphone.request();

  @override
  Future<bool> openSettings() => openAppSettings();
}

/// Fluxo de permissão do microfone (F2.3 · RF-M2-03 · AC-M2-2).
///
/// O DIÁLOGO EXPLICATIVO PRÉVIO é da UI (F2.5) e vem ANTES de [request]: pedir
/// sem contexto queima a única chance real de o usuário conceder, porque a
/// segunda negação no Android costuma ser definitiva. Por isso este serviço
/// separa [current] (consulta, não pergunta nada) de [request] (pergunta): a UI
/// consulta, explica, e só então pede.
///
/// Nada aqui lança exceção de plugin: negação permanente vira
/// `AppException(micPermission)` com ação `openSettings` só quando o chamador
/// pede a conversão por [toException] — consultar o estado NÃO é um erro.
class MicPermissionService {
  MicPermissionService({MicPermissionApi? api})
    : _api = api ?? PlatformMicPermissionApi();

  final MicPermissionApi _api;

  /// Estado atual, sem exibir diálogo do sistema.
  Future<MicPermission> current() async => _map(await _mapCall(_api.status));

  /// Exibe o diálogo do sistema (ou devolve o estado direto, se o SO já
  /// decidiu). Chamar com permissão já concedida é barato e idempotente.
  Future<MicPermission> request() async {
    final status = await _mapCall(_api.status);
    if (status.isGranted) return MicPermission.granted;
    // Perguntar de novo depois de uma negação permanente não abre diálogo
    // nenhum no Android — evita a ida inútil à plataforma.
    if (status.isPermanentlyDenied) return MicPermission.permanentlyDenied;
    return _map(await _mapCall(_api.request));
  }

  /// Abre a tela de permissões do app (botão "Abrir configurações", AC-M2-2).
  Future<bool> openSettings() => _mapCall(_api.openSettings);

  /// Converte um desfecho não-concedido no erro da Tabela Única §4.8.
  ///
  /// A ação sugerida muda com o desfecho: negação simples merece nova
  /// tentativa; permanente só é resolvível nas configurações.
  static AppException? toException(MicPermission permission) =>
      switch (permission) {
        MicPermission.granted => null,
        MicPermission.denied => const AppException(
          ErrorCode.micPermission,
          suggestedAction: SuggestedAction.retry,
        ),
        MicPermission.permanentlyDenied => const AppException(
          ErrorCode.micPermission,
          suggestedAction: SuggestedAction.openSettings,
        ),
      };

  static MicPermission _map(PermissionStatus status) {
    if (status.isGranted) return MicPermission.granted;
    if (status.isDenied) return MicPermission.denied;
    return MicPermission.permanentlyDenied;
  }

  /// Fronteira RN-03: qualquer falha do canal de plataforma vira
  /// `AppException(micPermission)` — nenhum `PlatformException` sobe à UI.
  Future<T> _mapCall<T>(Future<T> Function() call) async {
    try {
      return await call();
    } catch (e, st) {
      throw AppException(
        ErrorCode.micPermission,
        suggestedAction: SuggestedAction.retry,
        cause: e,
        stackTrace: st,
      );
    }
  }
}
