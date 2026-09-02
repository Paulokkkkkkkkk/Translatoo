import 'package:flutter/foundation.dart';

import '../../models/language.dart';
import '../../models/language_pair.dart';
import '../constants/app_constants.dart';
import 'app_exception.dart';
import 'text_chunker.dart';
import 'translation_backend.dart';

/// Fachada do motor M1 (F1.2): ÚNICO ponto de entrada dos ViewModels.
///
/// Responsabilidades:
/// - **Fatiamento** (RF-M1-05): textos > 4.500 chars são divididos
///   ([chunkText]), traduzidos sequencialmente e concatenados preservando a
///   ordem — a recombinação é exata;
/// - **Fail-fast de pacotes**: `isReady` antes da 1ª chamada; ausente →
///   `AppException(modelNotDownloaded)` (a UI abre o fluxo de download);
/// - **Fallback transparente** (F1.4 / AC-M1-4): falha de ENGINE no plano A
///   (`translationFailed`) troca para o motor alternativo quando a flag está
///   ligada e ele existe — exposto só como `usesAlternativeEngine`
///   (badge discreto); nunca stacktrace;
/// - **Latência**: cronometrada por chamada; logada SOMENTE em debug
///   (RN-05), contra o alvo de 300 ms.
class TranslationService {
  TranslationService({
    required TranslationBackend primary,
    TranslationBackend? fallback,
    bool fallbackEnabled = AppConstants.enableAlternativeEngine,
    TranslationBackend? cloudBackend,
    bool Function()? isCloudEnabled,
    bool Function()? isOnline,
  }) : _fallback = fallback,
       _fallbackEnabled = fallbackEnabled && fallback != null,
       _cloud = cloudBackend,
       _cloudEnabled = isCloudEnabled,
       _online = isOnline {
    _primary = primary;
  }

  late final TranslationBackend _primary;
  final TranslationBackend? _fallback;
  final bool _fallbackEnabled;

  /// Motor de nuvem do modo híbrido (F4.3). `null` na v1 — o provedor de API
  /// é decisão comercial ainda não tomada.
  final TranslationBackend? _cloud;

  /// Preferência `cloudEnabled`, resolvida NA CHAMADA: o usuário pode desligar
  /// nos Ajustes entre uma tradução e a seguinte.
  final bool Function()? _cloudEnabled;

  final bool Function()? _online;

  bool _usingFallback = false;

  /// A última tradução veio do motor ON-DEVICE? (F4.3)
  ///
  /// Serve ao badge discreto "local": com o modo híbrido ligado, o usuário tem
  /// direito de saber quando a nuvem não respondeu e o aparelho assumiu. Com o
  /// modo desligado é sempre `true` e a UI não mostra nada.
  bool _lastWasLocal = true;
  bool get lastResultWasLocal => _lastWasLocal;

  /// O modo híbrido está configurado E ligado? A UI só mostra o badge "local"
  /// quando isto é verdade.
  bool get cloudActive => _cloud != null && (_cloudEnabled?.call() ?? false);

  /// A nuvem deve ser tentada AGORA? Precisa das três coisas ao mesmo tempo.
  bool get _shouldTryCloud =>
      _cloud != null &&
      (_cloudEnabled?.call() ?? false) &&
      (_online?.call() ?? false);

  /// Motor efetivamente em uso (pós-fallback).
  TranslationBackend get activeBackend =>
      (_usingFallback ? _fallback : null) ?? _primary;

  /// Flag interna `alternativeEngine` (F1.4): UI mostra apenas um badge
  /// discreto "motor alternativo" quando true.
  bool get usesAlternativeEngine => _usingFallback && _fallback != null;

  /// O par está pronto no motor ativo? Falha rápida antes de traduzir.
  Future<bool> isReady(LanguagePair pair) => activeBackend.isReady(pair);

  Future<String> translate({
    required Language source,
    required Language target,
    required String text,
  }) async {
    final pair = LanguagePair(source: source, target: target);

    // MODO HÍBRIDO (F4.3). Tentado ANTES do caminho on-device e falhando em
    // silêncio: qualquer erro ou o timeout de 2 s cai no motor local sem
    // mensagem nenhuma ao usuário. Com `cloudEnabled = false` — o default da
    // v1 — este bloco inteiro é pulado, e o comportamento é idêntico ao de
    // antes da F4.3.
    if (_shouldTryCloud) {
      try {
        final result = await _translateChunks(_cloud!, pair, text);
        _lastWasLocal = false;
        return result;
      } on AppException catch (e) {
        if (kDebugMode) {
          debugPrint(
            '[Translatoo] nuvem falhou (${e.code.wireCode}) → on-device',
          );
        }
        // Segue para o caminho local. Nenhum erro sobe: para o usuário, a
        // tradução simplesmente aconteceu.
      }
    }
    _lastWasLocal = true;

    var backend = activeBackend;

    if (!await backend.isReady(pair)) {
      throw const AppException(
        ErrorCode.modelNotDownloaded,
        suggestedAction: SuggestedAction.download,
      );
    }

    try {
      return await _translateChunks(backend, pair, text);
    } on AppException catch (e) {
      // Fallback transparente: apenas falha de ENGINE (nunca modelo ausente
      // nem erros de política), uma única vez, se habilitado e existente.
      final alternative = _fallback;
      final canFallback =
          _fallbackEnabled &&
          alternative != null &&
          !identical(backend, alternative) &&
          e.code == ErrorCode.translationFailed;
      if (!canFallback) rethrow;

      if (kDebugMode) {
        debugPrint(
          '[Translatoo] engine "${backend.id}" falhou '
          '(${e.code.wireCode}) → fallback "${alternative.id}"',
        );
      }
      _usingFallback = true;
      backend = alternative;
      if (!await backend.isReady(pair)) {
        _usingFallback = false;
        rethrow;
      }
      return _translateChunks(backend, pair, text);
    }
  }

  Future<String> _translateChunks(
    TranslationBackend backend,
    LanguagePair pair,
    String text,
  ) async {
    final chunks = chunkText(text);
    final stopwatch = Stopwatch()..start();
    try {
      final output = StringBuffer();
      for (final chunk in chunks) {
        output.write(
          await backend.translate(
            source: pair.source,
            target: pair.target,
            text: chunk,
          ),
        );
      }
      stopwatch.stop();
      _logLatency(
        pair,
        text.length,
        chunks.length,
        stopwatch.elapsedMilliseconds,
      );
      return output.toString();
    } on AppException {
      stopwatch.stop();
      _logLatency(
        pair,
        text.length,
        chunks.length,
        stopwatch.elapsedMilliseconds,
        failed: true,
      );
      rethrow;
    }
  }

  /// RN-05: medição interna de latência, logada EXCLUSIVAMENTE em debug.
  void _logLatency(
    LanguagePair pair,
    int charCount,
    int chunkCount,
    int elapsedMs, {
    bool failed = false,
  }) {
    if (!kDebugMode) return;
    final verdict = elapsedMs <= AppConstants.translationLatencyTargetMs
        ? 'ok'
        : 'SLOW';
    debugPrint(
      '[Translatoo] $pair ${activeBackend.id} · $elapsedMs ms ($verdict) · '
      '$chunkCount bloco(s) · $charCount chars${failed ? ' · FALHOU' : ''}',
    );
  }

  void dispose() {
    _primary.dispose();
    _fallback?.dispose();
  }
}
