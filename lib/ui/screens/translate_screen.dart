import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_constants.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/constants/app_strings.dart';
import '../../core/services/app_exception.dart';
import '../../core/services/model_manager_service.dart';
import '../../models/language.dart';
import '../../models/model_state.dart';
import '../../state/translator_view_model.dart';
import '../widgets/download_progress_card.dart';
import '../widgets/language_pill.dart';
import '../widgets/shimmer_box.dart';
import '../widgets/translation_card.dart';

/// Tela Traduzir (F1.6 — PRD §3.1): cartões duplos origem/destino com ⇄
/// central, tradução automática por debounce e fluxo de download embutido.
///
/// REGRA ARQUITETURAL (R7 do plano): o campo de texto NUNCA lê o ViewModel no
/// build — sincroniza via [TextEditingController] ↔ listener do VM, evitando
/// rebuild que roube foco/cursor. Demais regiões usam [Selector] cirúrgico.
class TranslateScreen extends StatefulWidget {
  const TranslateScreen({super.key});

  @override
  State<TranslateScreen> createState() => _TranslateScreenState();
}

class _TranslateScreenState extends State<TranslateScreen> {
  final TextEditingController _controller = TextEditingController();
  TranslatorViewModel? _observed;
  AppException? _lastShownError;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      context.read<TranslatorViewModel>().onTextChanged(_controller.text);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final vm = context.read<TranslatorViewModel>();
    if (!identical(_observed, vm)) {
      _observed?.removeListener(_onViewModelChanged);
      _observed = vm..addListener(_onViewModelChanged);
      if (_controller.text != vm.sourceText) {
        _controller.value = TextEditingValue(
          text: vm.sourceText,
          selection: TextSelection.collapsed(offset: vm.sourceText.length),
        );
      }
    }
  }

  @override
  void dispose() {
    _observed?.removeListener(_onViewModelChanged);
    _controller.dispose();
    super.dispose();
  }

  /// Sincronização externa → campo (swap/limpar/ditado) sem roubar foco:
  /// só toca no controller quando o texto diverge do digitado.
  void _onViewModelChanged() {
    if (!mounted) return;
    final vm = _observed!;
    if (_controller.text != vm.sourceText) {
      _controller.value = TextEditingValue(
        text: vm.sourceText,
        selection: TextSelection.collapsed(offset: vm.sourceText.length),
      );
    }
    final error = vm.error;
    if (error != null && !identical(error, _lastShownError)) {
      _lastShownError = error;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _showErrorSnackBar(error);
      });
    }
  }

  /// Tabela §4.8: mensagem i18n + ação sugerida — nunca stacktrace.
  void _showErrorSnackBar(AppException error) {
    final t = AppStrings.of(context);
    final vm = context.read<TranslatorViewModel>();
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            errorMessageOf(
              t,
              error.code,
              missingLanguageLabel: vm.blockedLanguageLabel,
            ),
          ),
          action: switch (error.suggestedAction) {
            SuggestedAction.downloadAnyway => SnackBarAction(
              label: t.actionDownloadAnyway,
              onPressed: () => vm.confirmDownloadAnyway(),
            ),
            SuggestedAction.retry || SuggestedAction.download => SnackBarAction(
              label: t.actionRetry,
              onPressed: () => vm.retryLastAction(),
            ),
            SuggestedAction.none ||
            SuggestedAction.openSettings => null, // openSettings: uso na F2
          },
        ),
      );
  }

  Future<void> _pasteFromClipboard() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    final text = data?.text;
    if (text == null || text.isEmpty) return;
    final selection = _controller.selection;
    final base = _controller.text;
    var start = selection.isValid ? selection.start : base.length;
    var end = selection.isValid
        ? (selection.isCollapsed ? selection.start : selection.end)
        : base.length;
    start = start.clamp(0, base.length);
    end = end.clamp(0, base.length);
    final merged = base.replaceRange(start, end, text);
    if (!mounted) return;
    context.read<TranslatorViewModel>().onTextChanged(merged);
  }

  Future<void> _copyTranslation(String text) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (!mounted) return;
    final t = AppStrings.of(context);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(t.feedbackCopied)));
  }

  // ── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final t = AppStrings.of(context);
    final manager = context.read<ModelManagerService>();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Cartão de download sobreposto quando o par corrente está incompleto.
          Selector<TranslatorViewModel, (Language, ModelState)?>(
            selector: (_, vm) => _missingModelFor(vm),
            builder: (context, missing, _) {
              final entry = missing;
              if (entry == null) return const SizedBox.shrink();
              return DownloadProgressCard(
                language: entry.$1,
                state: entry.$2,
                onDownload: () => _observed?.retryLastAction(),
                onCancel: () => manager.cancelDownload(entry.$1),
              );
            },
          ),
          const SizedBox(height: AppSpacing.sm),

          // ── Cartão ORIGEM ────────────────────────────────────────────────
          TranslationCard(
            leading: LanguagePill(
              language: context.select<TranslatorViewModel, Language>(
                (vm) => vm.sourceLang,
              ),
              onSelected: (language) =>
                  context.read<TranslatorViewModel>().selectSource(language),
              semanticLabel: t.originLabel,
            ),
            actions: [
              Selector<TranslatorViewModel, bool>(
                selector: (_, vm) => vm.sourceText.isNotEmpty,
                builder: (context, hasText, _) => IconButton(
                  tooltip: t.actionClear,
                  onPressed: hasText
                      ? () => context.read<TranslatorViewModel>().clearSource()
                      : null,
                  icon: const Icon(Icons.close),
                ),
              ),
            ],
            footer: _OriginFooter(onPaste: _pasteFromClipboard),
            child: TextField(
              controller: _controller,
              maxLines: null,
              minLines: 3,
              keyboardType: TextInputType.multiline,
              decoration: InputDecoration(
                border: InputBorder.none,
                filled: false,
                hintText: t.sourceHint,
              ),
            ),
          ),

          // ── Botão ⇄ circular central (56 dp, elevação 2) ─────────────────
          Center(
            child: Semantics(
              button: true,
              label: t.actionSwapLanguages,
              child: Material(
                elevation: 2,
                shape: CircleBorder(
                  side: BorderSide(
                    color: Theme.of(context).colorScheme.outline,
                  ),
                ),
                color: Theme.of(context).colorScheme.surface,
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap:
                      context.select<TranslatorViewModel, bool>(
                        (vm) => vm.isTranslating,
                      )
                      ? null
                      : () => _observed!.swapLanguages(),
                  child: SizedBox.square(
                    dimension: 56,
                    child: Icon(
                      Icons.swap_horiz,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
              ),
            ),
          ),
          _DestinationSection(onCopy: _copyTranslation),
          const SizedBox(height: AppSpacing.md),

          // ── Botão primário TRADUZIR ──────────────────────────────────────
          Selector<TranslatorViewModel, bool>(
            selector: (_, vm) =>
                !vm.isTranslating && vm.sourceText.trim().isNotEmpty,
            builder: (context, enabled, _) => FilledButton(
              onPressed: enabled ? () => _observed!.translateNow() : null,
              child: Text(t.buttonTranslate),
            ),
          ),
        ],
      ),
    );
  }

  /// Primeiro idioma do par corrente que impede a tradução (download em curso
  /// tem prioridade visual sobre ausência simples).
  static (Language, ModelState)? _missingModelFor(TranslatorViewModel vm) {
    final entries = <(Language, ModelState)>[
      (vm.sourceLang, vm.stateFor(vm.sourceLang)),
      (vm.targetLang, vm.stateFor(vm.targetLang)),
    ];
    for (final entry in entries) {
      if (entry.$2 is ModelDownloading) return entry;
    }
    for (final entry in entries) {
      if (entry.$2 is ModelNotDownloaded) return entry;
    }
    return null;
  }
}

/// Rodapé do cartão origem (F1.6): 🎤 placeholder F2 · colar · contador n/5000
/// com aviso de truncamento. Rebuild cirúrgico — só o rodapé reage ao texto.
class _OriginFooter extends StatelessWidget {
  const _OriginFooter({required this.onPaste});

  final Future<void> Function() onPaste;

  @override
  Widget build(BuildContext context) {
    final t = AppStrings.of(context);
    return Selector<TranslatorViewModel, (int, bool)>(
      selector: (_, vm) => (vm.sourceText.length, vm.isTruncated),
      builder: (context, data, _) {
        final (length, truncated) = data;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (truncated)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                // Alerta de limite — token de erro do tema vigente.
                child: Text(
                  t.charLimitReached,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
              ),
            Row(
              children: [
                IconButton(
                  tooltip: '${t.actionDictate} · ${t.comingSoon}',
                  onPressed: null, // placeholder F2 (gancho acceptDictatedText)
                  icon: const Icon(Icons.mic_none_outlined),
                ),
                IconButton(
                  tooltip: t.actionPaste,
                  onPressed: () => unawaited(onPaste()),
                  icon: const Icon(Icons.content_paste_outlined),
                ),
                const Spacer(),
                Text(
                  '$length/${AppConstants.maxInputChars}',
                  style: Theme.of(context).textTheme.labelMedium,
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}

/// Cartão DESTINO (F1.6): pill, área somente-leitura com skeleton shimmer
/// enquanto `translating`, badge "motor alternativo" (F1.4) e linha de ações
/// 🔊 F3 · copiar · ⭐ F3 · compartilhar F4 — todas com Semantics.
class _DestinationSection extends StatelessWidget {
  const _DestinationSection({required this.onCopy});

  final ValueChanged<String> onCopy;

  @override
  Widget build(BuildContext context) {
    final t = AppStrings.of(context);
    return Selector<TranslatorViewModel, (int, String, bool)>(
      selector: (_, vm) =>
          (vm.status.index, vm.translatedText, vm.usesAlternativeEngine),
      builder: (context, data, _) {
        final (statusIndex, translated, alternative) = data;
        final translating = statusIndex == TranslatorStatus.translating.index;
        return TranslationCard(
          leading: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              LanguagePill(
                language: context.select<TranslatorViewModel, Language>(
                  (vm) => vm.targetLang,
                ),
                onSelected: (language) =>
                    context.read<TranslatorViewModel>().selectTarget(language),
                semanticLabel: t.destinationLabel,
              ),
              if (alternative) ...[
                const SizedBox(width: AppSpacing.xs),
                Chip(
                  label: Text(t.engineAlternative),
                  labelStyle: Theme.of(context).textTheme.labelSmall,
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ],
          ),
          footer: Row(
            children: [
              IconButton(
                tooltip: '${t.actionListen} · ${t.comingSoon}',
                onPressed: null, // placeholder F3 (TTS)
                icon: const Icon(Icons.volume_up_outlined),
              ),
              IconButton(
                tooltip: t.actionCopy,
                onPressed: translated.isEmpty ? null : () => onCopy(translated),
                icon: const Icon(Icons.copy_outlined),
              ),
              IconButton(
                tooltip: '${t.actionFavorite} · ${t.comingSoon}',
                onPressed: null, // placeholder F3 (favoritos)
                icon: const Icon(Icons.star_border_outlined),
              ),
              IconButton(
                tooltip: '${t.actionShare} · ${t.comingSoon}',
                onPressed: null, // placeholder F4 (share_plus, P1)
                icon: const Icon(Icons.share_outlined),
              ),
            ],
          ),
          child: SizedBox(
            height: 140,
            child: translating
                ? const ShimmerBox(lines: 3)
                : SelectableText(
                    translated,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
          ),
        );
      },
    );
  }
}
