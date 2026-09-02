import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:google_mlkit_translation/google_mlkit_translation.dart';

import '../../models/language.dart';
import '../../models/model_state.dart';
import '../constants/app_constants.dart';
import 'app_exception.dart';

/// Ponte MÍNIMA sobre o gerenciador remoto de modelos do plugin ML Kit
/// (F1.3). Existe para isolar o plugin atrás de uma interface testável:
/// os testes do [ModelManagerService] injetam fakes aqui.
abstract interface class ModelManagerApi {
  Future<bool> isModelDownloaded(Language language);

  /// [isWifiRequired] reflete a decisão da política wifi-only (o plugin
  /// repassa a restrição ao download nativo).
  Future<void> downloadModel(Language language, {required bool isWifiRequired});

  Future<void> deleteModel(Language language);
}

/// Implementação real sobre `google_mlkit_translation`. Toda exceção crua do
/// plugin é normalizada em `AppException(downloadFailed)` (tabela §4.8).
final class MlKitModelManagerApi implements ModelManagerApi {
  final OnDeviceTranslatorModelManager _manager =
      OnDeviceTranslatorModelManager();

  @override
  Future<bool> isModelDownloaded(Language language) async {
    try {
      return await _manager.isModelDownloaded(language.mlKitCode);
    } catch (e, st) {
      throw AppException(ErrorCode.downloadFailed, cause: e, stackTrace: st);
    }
  }

  @override
  Future<void> downloadModel(
    Language language, {
    required bool isWifiRequired,
  }) async {
    try {
      await _manager.downloadModel(
        language.mlKitCode,
        isWifiRequired: isWifiRequired,
      );
    } catch (e, st) {
      throw AppException(ErrorCode.downloadFailed, cause: e, stackTrace: st);
    }
  }

  @override
  Future<void> deleteModel(Language language) async {
    try {
      await _manager.deleteModel(language.mlKitCode);
    } catch (e, st) {
      throw AppException(ErrorCode.downloadFailed, cause: e, stackTrace: st);
    }
  }
}

/// Gate puro da regra `wifiOnly` (F1.3): download em dados móveis com a
/// preferência ligada → `AppException(wifiOnly)` com ação `downloadAnyway`.
/// A DECISÃO vem sempre da UI ("Baixar mesmo assim", via `force`) e NUNCA
/// altera a preferência persistida (isso é papel da F3/Ajustes).
AppException? evaluateDownloadGate({
  required bool wifiOnlyPreference,
  required bool online,
  required bool onMobileData,
  required bool force,
}) {
  if (force || !wifiOnlyPreference || !online || !onMobileData) return null;
  return const AppException(
    ErrorCode.wifiOnly,
    suggestedAction: SuggestedAction.downloadAnyway,
  );
}

/// Gerenciador de pacotes de idiomas (F1.3): download com progresso (%),
/// cancelamento, exclusão e consulta de estado por idioma
/// (`notDownloaded | downloading(n%) | ready`) via [states].
///
/// NOTA TÉCNICA — progresso estimado: o plugin ML Kit não expõe progresso
/// nativo de download. Enquanto aguardamos a conclusão real
/// ([ModelManagerApi.downloadModel]), emitimos incrementos determinísticos
/// (+[AppConstants.modelDownloadProgressStep]/tick, teto 90%) a cada
/// [AppConstants.modelDownloadPollInterval]; a confirmação real salta para
/// `ready`. Cancelar desacopla o app do processo nativo (o plugin não oferece
/// abort; se o SO concluir depois, `refresh()` refletirá `ready` — inofensivo).
class ModelManagerService {
  ModelManagerService({
    required ModelManagerApi api,
    ValueListenable<bool>? online,
    ValueListenable<bool>? onMobileData,
    bool Function()? wifiOnlyPreference,
  }) {
    _api = api;
    _online = online;
    _onMobileData = onMobileData;
    _wifiOnly = wifiOnlyPreference;
  }

  late final ModelManagerApi _api;
  late final ValueListenable<bool>? _online;
  late final ValueListenable<bool>? _onMobileData;

  /// Preferência `wifiOnly` do usuário (F3.6). Resolvida NA CHAMADA — lê o
  /// `StorageService` no momento do download, então uma troca em Ajustes vale
  /// já no próximo toque, sem reconstruir o serviço.
  bool Function()? _wifiOnly;

  bool _wifiOnlyValue() => _wifiOnly?.call() ?? true;

  final Map<Language, ModelState> _internalStates = <Language, ModelState>{
    for (final language in Language.values)
      language: const ModelNotDownloaded(),
  };

  final ValueNotifier<Map<Language, ModelState>> _statesNotifier =
      ValueNotifier<Map<Language, ModelState>>(const {});

  /// Estado observável por idioma (mapa imutável — troca por inteiro).
  ValueListenable<Map<Language, ModelState>> get states => _statesNotifier;

  ModelState stateFor(Language language) =>
      _internalStates[language] ?? const ModelNotDownloaded();

  /// Tokens POR IDIOMA: invalidam conclusões/cancelamentos obsoletos de cada
  /// download independentemente (pt e en podem baixar em paralelo).
  final Map<Language, int> _tokens = <Language, int>{
    for (final language in Language.values) language: 0,
  };

  final Map<Language, Timer> _pollTimers = <Language, Timer>{};

  int _nextToken(Language language) =>
      _tokens[language] = (_tokens[language] ?? 0) + 1;
  bool _isCurrent(Language language, int token) => _tokens[language] == token;

  /// Reconsulta o estado REAL do pacote no aparelho (boot, retorno de tela…).
  Future<void> refresh(Language language) async {
    final ready = await _api.isModelDownloaded(language);
    if (_internalStates[language] is ModelDownloading) return;
    _set(language, ready ? const ModelReady() : const ModelNotDownloaded());
  }

  Future<void> refreshAll() async {
    for (final language in Language.values) {
      await refresh(language);
    }
  }

  /// Baixa o pacote do [language]. Regras:
  /// - já baixando/baixado → no-op idempotente;
  /// - `wifiOnly` + rede medida sem [force] → `AppException(wifiOnly)`
  ///   (UI decide "Baixar mesmo assim" SEM mudar a preferência);
  /// - falha → estado volta a `notDownloaded` e propaga
  ///   `AppException(downloadFailed)`.
  ///
  /// Nota: a preferência `wifiOnly` v1 é o default do produto; o override
  /// persistido (StorageService) é plugado aqui na F3 sem mudar assinatura.
  Future<void> downloadModel(Language language, {bool force = false}) async {
    final current = stateFor(language);
    if (current is ModelDownloading || current is ModelReady) return;

    final gate = evaluateDownloadGate(
      wifiOnlyPreference: _wifiOnlyValue(),
      online: _online?.value ?? true,
      onMobileData: _onMobileData?.value ?? false,
      force: force,
    );
    if (gate != null) throw gate;

    final token = _nextToken(language);
    _set(language, const ModelDownloading(0));
    _startPolling(language, token);
    try {
      // A restrição Wi-Fi também é aplicada no lado nativo do plugin.
      await _api.downloadModel(language, isWifiRequired: !force);
      if (!_isCurrent(language, token)) return; // cancelado/superseded
      _stopPolling(language);
      _set(language, const ModelReady());
    } on AppException {
      if (!_isCurrent(language, token)) return;
      _stopPolling(language);
      _set(language, const ModelNotDownloaded());
      rethrow;
    }
  }

  /// Cancela o acompanhamento do download (ver nota técnica na classe).
  void cancelDownload(Language language) {
    _nextToken(language);
    _stopPolling(language);
    if (_internalStates[language] is ModelDownloading) {
      _set(language, const ModelNotDownloaded());
    }
  }

  /// Exclui o pacote localmente (o Gerenciador de Modelos da F3 usa este caminho).
  Future<void> deleteModel(Language language) async {
    _nextToken(language);
    _stopPolling(language);
    await _api.deleteModel(language);
    if (_internalStates[language] is! ModelDownloading) {
      _set(language, const ModelNotDownloaded());
    }
  }

  void _startPolling(Language language, int token) {
    _stopPolling(language);
    _pollTimers[language] = Timer.periodic(
      AppConstants.modelDownloadPollInterval,
      (_) {
        if (!_isCurrent(language, token)) {
          _stopPolling(language);
          return;
        }
        final state = _internalStates[language];
        if (state is ModelDownloading &&
            state.progressPercent < AppConstants.modelDownloadProgressCap) {
          final next =
              state.progressPercent + AppConstants.modelDownloadProgressStep;
          _set(
            language,
            ModelDownloading(
              next.clamp(0, AppConstants.modelDownloadProgressCap),
            ),
          );
        }
      },
    );
  }

  void _stopPolling(Language language) {
    _pollTimers.remove(language)?.cancel();
  }

  void _set(Language language, ModelState state) {
    if (_internalStates[language] == state) return;
    _internalStates[language] = state;
    _statesNotifier.value = Map.unmodifiable(_internalStates);
  }

  void dispose() {
    for (final timer in _pollTimers.values) {
      timer.cancel();
    }
    _pollTimers.clear();
    _statesNotifier.dispose();
  }
}
