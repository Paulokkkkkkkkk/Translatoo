import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:google_mlkit_translation/google_mlkit_translation.dart';

import '../../models/language.dart';
import '../../models/language_pair.dart';
import 'app_exception.dart';
import 'translation_backend.dart';

/// Plano A (F1.2): wrapper do `google_mlkit_translation`.
///
/// Ciclo de vida: um `OnDeviceTranslator` por par direcionado, criado sob
/// demanda e cacheado; `close()` nativo apenas em [dispose]. Antes de traduzir,
/// `isReady` verifica os DOIS pacotes (origem e destino) — falha de consulta
/// vira `AppException(translationFailed)`, nunca exceção crua do plugin.
final class MlKitTranslationBackend implements TranslationBackend {
  @override
  String get id => 'mlkit';

  final Map<LanguagePair, OnDeviceTranslator> _translators =
      <LanguagePair, OnDeviceTranslator>{};

  /// Nosso enum fechado (RN-01) → valores do enum do plugin.
  static TranslateLanguage _toPlugin(Language language) => switch (language) {
    Language.pt => TranslateLanguage.portuguese,
    Language.en => TranslateLanguage.english,
    Language.zh => TranslateLanguage.chinese,
  };

  OnDeviceTranslator _translatorFor(LanguagePair pair) =>
      _translators.putIfAbsent(
        pair,
        () => OnDeviceTranslator(
          sourceLanguage: _toPlugin(pair.source),
          targetLanguage: _toPlugin(pair.target),
        ),
      );

  @override
  Future<bool> isModelDownloaded(Language language) async {
    try {
      return await OnDeviceTranslatorModelManager().isModelDownloaded(
        language.mlKitCode,
      );
    } catch (e, st) {
      throw AppException(ErrorCode.translationFailed, cause: e, stackTrace: st);
    }
  }

  @override
  Future<bool> isReady(LanguagePair pair) async =>
      await isModelDownloaded(pair.source) &&
      await isModelDownloaded(pair.target);

  @override
  Future<String> translate({
    required Language source,
    required Language target,
    required String text,
  }) async {
    try {
      return await _translatorFor(LanguagePair(source: source, target: target))
          .translateText(text);
    } on AppException {
      rethrow;
    } catch (e, st) {
      throw AppException(_mapError(e), cause: e, stackTrace: st);
    }
  }

  /// Heurística de mapeamento: o plugin lança `PlatformException` genérica;
  /// mensagens conhecidas de pacote ausente viram `modelNotDownloaded`
  /// (aciona fluxo de download), todo o resto vira `translationFailed`
  /// (aciona fallback transparente p/ motor alternativo).
  ErrorCode _mapError(Object error) {
    final message = error.toString().toLowerCase();
    if (message.contains('model') && message.contains('download')) {
      return ErrorCode.modelNotDownloaded;
    }
    return ErrorCode.translationFailed;
  }

  @override
  void dispose() {
    if (kDebugMode) {
      debugPrint(
        '[Translatoo] fechando ${_translators.length} tradutor(es) ML Kit',
      );
    }
    for (final translator in _translators.values) {
      unawaited(translator.close());
    }
    _translators.clear();
  }
}
