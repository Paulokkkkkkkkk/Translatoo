import '../../models/language.dart';
import '../../models/language_pair.dart';
import 'app_exception.dart';

/// CONTRATO de motor de tradução (F1.1) — a fronteira única entre o produto
/// e qualquer tecnologia de tradução (`MlKitTranslationBackend`,
/// `TfliteTranslationBackend`, futura `CloudBackend` da F4).
///
/// REGRAS INVIOÁVEIS para toda implementação:
/// 1. Nenhuma exceção crua de plugin atravessa esta interface: toda falha é
///    convertida em [AppException] com código da tabela §4.8
///    ([ErrorCode.modelNotDownloaded] ou [ErrorCode.translationFailed]).
/// 2. A implementação é 100% on-device; nada aqui pode tocar rede exceto o
///    download explícito de pacotes gerenciado pelo `ModelManagerService`.
/// 3. `dispose` encerra TODOS os recursos nativos criados (tradutores,
///    interpretadores) — chamado no teardown do app.
abstract interface class TranslationBackend {
  /// Identificador estável do motor (`mlkit`, `tflite`, …). Usado em logs de
  /// debug e pela flag interna `alternativeEngine` (nunca vira stacktrace na UI).
  String get id;

  /// Pacote individual do [language] já baixado na máquina?
  ///
  /// Falhas de consulta são convertidas em `AppException(translationFailed)`.
  Future<bool> isModelDownloaded(Language language);

  /// O [pair] está pronto para traduzir (ambos os pacotes instalados)?
  Future<bool> isReady(LanguagePair pair);

  /// Traduz [text] por inteiro (sem fatiamento — responsabilidade do
  /// `TranslationService`). Só deve ser chamado após `isReady(pair) == true`.
  ///
  /// Erros mapeados: modelo ausente → `modelNotDownloaded`; qualquer outra
  /// falha de engine → `translationFailed` (é este código que dispara o
  /// fallback transparente para o motor alternativo).
  Future<String> translate({
    required Language source,
    required Language target,
    required String text,
  });

  void dispose();
}
