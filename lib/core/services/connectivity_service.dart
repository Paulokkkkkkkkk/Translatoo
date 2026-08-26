import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

/// Expõe o estado de rede como `ValueNotifier<bool>` consumível pela UI
/// (ConnectionBadge, via ViewModel da camada `state/`).
///
/// REGRA CRÍTICA (PRD RF-M4-07): nada na v1 é BLOQUEADO por falta de
/// internet — tradução, ditado e voz são locais. Este serviço é apenas
/// informativo; qualquer falha de plataforma assume "online", porque o app
/// é offline-first e segue funcionando.
class ConnectivityService {
  ConnectivityService({Connectivity? connectivity})
    : _connectivity = connectivity ?? Connectivity();

  final Connectivity _connectivity;
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  final ValueNotifier<bool> isOnline = ValueNotifier<bool>(true);

  /// `true` quando a única rota ativa é dados móveis (rede medida). Consumido
  /// pelo ModelManagerService (F1.3) para aplicar a preferência `wifiOnly`.
  final ValueNotifier<bool> isOnMobileData = ValueNotifier<bool>(false);

  /// Lê o estado atual e assina mudanças. Idempotente.
  Future<void> start() async {
    if (_subscription != null) return;
    try {
      _apply(await _connectivity.checkConnectivity());
    } catch (e) {
      isOnline.value = true;
      isOnMobileData.value = false;
    }
    _subscription = _connectivity.onConnectivityChanged.listen(
      _apply,
      onError: (Object _) {
        isOnline.value = true;
        isOnMobileData.value = false;
      },
    );
  }

  void _apply(List<ConnectivityResult> results) {
    isOnline.value =
        results.isNotEmpty && results.any((r) => r != ConnectivityResult.none);
    isOnMobileData.value = results.contains(ConnectivityResult.mobile);
  }

  Future<void> dispose() async {
    await _subscription?.cancel();
    _subscription = null;
    isOnline.dispose();
    isOnMobileData.dispose();
  }
}
