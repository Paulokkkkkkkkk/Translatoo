import 'package:share_plus/share_plus.dart';

import '../../models/language.dart';
import 'app_exception.dart';

/// Ponte MÍNIMA sobre o `share_plus`, pelo mesmo motivo das outras fronteiras
/// de plataforma do projeto: sem ela o teste precisaria de canal nativo para
/// exercitar a formatação do texto.
abstract interface class SharePlatform {
  Future<void> shareText(String text, {String? subject});
}

/// Implementação real. É o ÚNICO arquivo que importa `share_plus`.
final class PlatformShare implements SharePlatform {
  const PlatformShare();

  @override
  Future<void> shareText(String text, {String? subject}) =>
      Share.share(text, subject: subject);
}

/// Compartilhamento de tradução (F4.1 · RF-M4-06).
///
/// **Funciona em modo avião** — e não por acaso: a folha de compartilhamento é
/// do sistema operacional, e o que entregamos a ela é texto puro. Nenhuma
/// chamada de rede acontece aqui, coerente com a RN-02.
class ShareService {
  const ShareService({SharePlatform sharePlatform = const PlatformShare()})
    : _platform = sharePlatform;

  final SharePlatform _platform;

  /// Monta o texto compartilhado e abre a folha nativa.
  ///
  /// O formato inclui o PAR DE IDIOMAS porque a tradução sozinha perde o
  /// contexto: quem recebe "Good morning" não sabe se veio do português ou do
  /// mandarim, nem qual era o original.
  Future<void> shareTranslation({
    required Language source,
    required Language target,
    required String sourceText,
    required String translatedText,
  }) async {
    if (translatedText.trim().isEmpty) return;

    final text =
        '${source.displayName}: $sourceText\n'
        '${target.displayName}: $translatedText';

    try {
      await _platform.shareText(text, subject: translatedText);
    } catch (e, st) {
      // A folha é do SO: falha aqui é ambiente, não tradução. Vira erro
      // genérico em vez de deixar exceção de plugin subir (RN-03).
      throw AppException(
        ErrorCode.translationFailed,
        suggestedAction: SuggestedAction.retry,
        cause: e,
        stackTrace: st,
      );
    }
  }
}
