import '../../models/language.dart';
import '../../models/language_pair.dart';
import '../constants/app_constants.dart';
import 'app_exception.dart';
import 'translation_backend.dart';

/// Provedor de tradução em nuvem (F4.3 · P2).
///
/// Fica ABSTRATO de propósito: qual API usar é decisão comercial que o PRD não
/// tomou. Esta interface é o contrato mínimo que qualquer provedor precisa
/// cumprir para o modo híbrido funcionar.
abstract interface class CloudTranslationApi {
  /// Traduz [text]. Pode lançar o que quiser — quem chama trata tudo como
  /// "a nuvem não respondeu".
  Future<String> translate({
    required String sourceCode,
    required String targetCode,
    required String text,
  });
}

/// Motor de tradução em nuvem (F4.3), atrás do MESMO `TranslationBackend` que
/// o ML Kit e o TFLite — foi para isto que a interface da F1.1 existe.
///
/// **Nunca é o motor único.** O `TranslationService` só o consulta quando há
/// rede e a flag está ligada, e trata qualquer falha como motivo para usar o
/// on-device. Um app que promete funcionar offline não pode ter caminho em que
/// a nuvem é obrigatória.
final class CloudTranslationBackend implements TranslationBackend {
  const CloudTranslationBackend({
    required CloudTranslationApi cloudApi,
    Duration cloudTimeout = AppConstants.cloudTimeout,
  }) : _api = cloudApi,
       _timeout = cloudTimeout;

  final CloudTranslationApi _api;

  /// Teto de espera (2 s, `AppConstants.cloudTimeout`). Passou disso, o
  /// on-device responde mais rápido do que continuar esperando.
  final Duration _timeout;

  @override
  String get id => 'cloud';

  /// A nuvem não tem pacote para baixar: se há rede, está pronta. Quem decide
  /// se há rede é o `TranslationService`, que conhece a conectividade.
  @override
  Future<bool> isModelDownloaded(Language language) async => true;

  @override
  Future<bool> isReady(LanguagePair pair) async => true;

  @override
  Future<String> translate({
    required Language source,
    required Language target,
    required String text,
  }) async {
    try {
      final result = await _api
          .translate(
            sourceCode: source.bcp47Code,
            targetCode: target.bcp47Code,
            text: text,
          )
          .timeout(_timeout);
      if (result.trim().isEmpty) {
        throw const AppException(ErrorCode.translationFailed);
      }
      return result;
    } catch (e, st) {
      // TUDO vira `translationFailed`: timeout, HTTP, JSON quebrado, cota
      // estourada. Quem chama não decide nada com base no motivo — só volta
      // para o on-device.
      throw AppException(ErrorCode.translationFailed, cause: e, stackTrace: st);
    }
  }

  @override
  void dispose() {}
}
