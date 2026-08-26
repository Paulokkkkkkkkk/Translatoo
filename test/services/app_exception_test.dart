import 'package:flutter_test/flutter_test.dart';
import 'package:translatoo/core/services/app_exception.dart';

void main() {
  group('Tabela Única de Erros — PRD §4.8 (RN-03)', () {
    test('códigos wire batem exatamente com o PRD', () {
      expect(ErrorCode.modelNotDownloaded.wireCode, 'ERR_MODEL_NOT_DOWNLOADED');
      expect(ErrorCode.downloadFailed.wireCode, 'ERR_DOWNLOAD_FAILED');
      expect(ErrorCode.wifiOnly.wireCode, 'ERR_WIFI_ONLY');
      expect(ErrorCode.micPermission.wireCode, 'ERR_MIC_PERMISSION');
      expect(ErrorCode.sttEngine.wireCode, 'ERR_STT_ENGINE');
      expect(ErrorCode.ttsVoiceMissing.wireCode, 'ERR_TTS_VOICE_MISSING');
      expect(ErrorCode.storage.wireCode, 'ERR_STORAGE');
      expect(ErrorCode.translationFailed.wireCode, 'ERR_TRANSLATION_FAILED');
      expect(ErrorCode.values.length, 8);
    });

    test('ação sugerida default é retry', () {
      const ex = AppException(ErrorCode.downloadFailed);
      expect(ex.suggestedAction, SuggestedAction.retry);
    });

    test('aceita ação específica e retém causa original', () {
      final cause = StateError('boom');
      final ex = AppException(
        ErrorCode.storage,
        suggestedAction: SuggestedAction.openSettings,
        cause: cause,
      );

      expect(ex.suggestedAction, SuggestedAction.openSettings);
      expect(ex.cause, same(cause));
    });

    test('toString expõe o código wire', () {
      const ex = AppException(ErrorCode.storage);
      expect(ex.toString(), contains('ERR_STORAGE'));
    });
  });
}
