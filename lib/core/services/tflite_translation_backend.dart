import '../../models/language.dart';
import '../../models/language_pair.dart';
import 'app_exception.dart';
import 'translation_backend.dart';

/// Plano B (F1.4 — RF-M1-07 / AC-M1-4): motor alternativo para aparelhos sem
/// Google Play Services (cenário China), atrás da MESMA [TranslationBackend].
///
/// ── RESULTADO DA SPIKE (docs/tflite_spike.md) ─────────────────────────────
/// Nenhum modelo NMT compacto cobrindo os 3 pares mostrou-se viável hoje
/// (conversão OPUS-MT/Marian → LiteRT imatura + ausência de tokenizador
/// SentencePiece no runtime Dart + 40–80 MB por par vs ~30 MB do ML Kit).
/// Decisão do plano ("limitação honesta"): backend permanece atrás da
/// interface com feature-flag DESLIGADA
/// ([AppConstants.enableAlternativeEngine]) e nota técnica — o fluxo
/// AC-M1-4 continua 100% testável via fakes/mocks da interface.
///
/// Quando um modelo+tokenizador viável for embutido em
/// `assets/models/tflite/`, ESTE arquivo evolui para carregar o
/// interpretador — nenhum contrato acima muda, a UI nunca vê a diferença
/// além do badge discreto "motor alternativo".
final class TfliteTranslationBackend implements TranslationBackend {
  @override
  String get id => 'tflite';

  /// Sem modelo embutido: nenhum idioma está pronto.
  @override
  Future<bool> isModelDownloaded(Language language) async => false;

  @override
  Future<bool> isReady(LanguagePair pair) async => false;

  /// Indisponível enquanto a spike não embutir modelo — erro canônico da
  /// tabela §4.8, JAMAIS stacktrace cru.
  @override
  Future<String> translate({
    required Language source,
    required Language target,
    required String text,
  }) async {
    throw const AppException(ErrorCode.translationFailed);
  }

  @override
  void dispose() {}
}
