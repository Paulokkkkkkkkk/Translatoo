/// Códigos da Tabela Única de Erros (PRD §4.8).
///
/// O código wire (`ERR_*`) é o contrato estável usado em logs/debug; a
/// mensagem exibida NUNCA nasce aqui — ela vem de `app_strings.dart` (i18n),
/// resolvida pela UI a partir do [ErrorCode].
enum ErrorCode {
  modelNotDownloaded('ERR_MODEL_NOT_DOWNLOADED'),
  downloadFailed('ERR_DOWNLOAD_FAILED'),
  wifiOnly('ERR_WIFI_ONLY'),
  micPermission('ERR_MIC_PERMISSION'),
  sttEngine('ERR_STT_ENGINE'),
  ttsVoiceMissing('ERR_TTS_VOICE_MISSING'),
  storage('ERR_STORAGE'),
  translationFailed('ERR_TRANSLATION_FAILED');

  const ErrorCode(this.wireCode);

  final String wireCode;
}

/// Ação sugerida associada ao erro. A UI decide como apresentá-la (botão na
/// snackbar, diálogo etc.) usando os rótulos de `app_strings.dart`.
enum SuggestedAction { none, download, retry, downloadAnyway, openSettings }

/// Exceção canônica da fronteira de serviços (RN-03): nenhuma exceção de
/// plugin/crua atravessa para ViewModels ou UI sem ser convertida em
/// [AppException]. O erro original fica retido apenas para log em debug.
class AppException implements Exception {
  const AppException(
    this.code, {
    this.suggestedAction = SuggestedAction.retry,
    this.cause,
    this.stackTrace,
  });

  final ErrorCode code;
  final SuggestedAction suggestedAction;

  /// Erro original (opcional; somente para diagnóstico em modo debug).
  final Object? cause;
  final StackTrace? stackTrace;

  @override
  String toString() => 'AppException(${code.wireCode})';
}
