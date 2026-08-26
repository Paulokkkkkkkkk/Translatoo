import 'package:flutter/foundation.dart';

import '../core/services/connectivity_service.dart';

/// ViewModel fino (camada `state/`): traduz o serviço de conectividade para
/// a UI sem expor serviços/plugins diretamente (regra de camadas §4 — a UI
/// só conhece ViewModels).
class ConnectionViewModel extends ChangeNotifier {
  ConnectionViewModel(this._service) {
    _service.isOnline.addListener(_onChanged);
  }

  final ConnectivityService _service;

  bool get isOnline => _service.isOnline.value;

  void _onChanged() => notifyListeners();

  @override
  void dispose() {
    _service.isOnline.removeListener(_onChanged);
    super.dispose();
  }
}
