import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_constants.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/constants/app_strings.dart';
import '../../core/services/app_exception.dart';
import '../../core/services/model_manager_service.dart';
import '../../core/services/share_service.dart';
import '../../models/language.dart';
import '../../models/model_state.dart';
import '../../state/speech_view_model.dart';
import '../../state/translator_view_model.dart';
import '../../state/tts_view_model.dart';
import '../widgets/download_progress_card.dart';
import '../widgets/language_bar.dart';
import '../widgets/mic_button.dart';
import '../widgets/mode_button.dart';
import '../widgets/shimmer_box.dart';
import '../widgets/translation_panel.dart';
import '../widgets/voice_block.dart';

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

  /// Modo ativo (§9.2). Com 2 modos o botão do canto alterna direto — estado
  /// local basta: nenhum serviço nem outra tela precisa saber disto.
  TranslateMode _mode = TranslateMode.text;
  AppException? _lastShownError;
  TtsViewModel? _observedTts;
  ErrorCode? _lastTtsError;

  /// RN-07: sair para segundo plano durante a escuta ENCERRA com o parcial.
  /// O listener vive aqui, e não no ViewModel, porque `AppLifecycleListener`
  /// é API de widget — a `state/` não conhece Flutter de UI.
  late final AppLifecycleListener _lifecycle = AppLifecycleListener(
    onInactive: () => context.read<SpeechViewModel>().onAppBackgrounded(),
  );

  @override
  void initState() {
    super.initState();
    _lifecycle; // instancia o listener
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
    final tts = context.read<TtsViewModel>();
    if (!identical(_observedTts, tts)) {
      _observedTts?.removeListener(_onTtsChanged);
      _observedTts = tts..addListener(_onTtsChanged);
    }
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    _observed?.removeListener(_onViewModelChanged);
    _observedTts?.removeListener(_onTtsChanged);
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

  /// Voz ausente (AC-M3-2) também pode nascer do AUTOPLAY (ditado) — o erro é
  /// observado aqui, e não só no toque do 🔊, para valer nos dois caminhos.
  void _onTtsChanged() {
    if (!mounted) return;
    final tts = _observedTts!;
    final code = tts.errorCode;
    if (code == null || code == _lastTtsError) return;
    _lastTtsError = code;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final t = AppStrings.of(context);
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            // Persistente: instrui instalar a voz nas configurações do sistema.
            // O deep-link direto às configurações de TTS é pendência registrada
            // (nenhum plugin da lista fechada o expõe) — sem botão morto.
            duration: const Duration(seconds: 10),
            content: Text(
              errorMessageOf(
                t,
                code,
                missingLanguageLabel: tts.errorLanguage?.displayName,
              ),
            ),
          ),
        );
      // O erro já foi exibido: limpa para o próximo ciclo de fala.
      _observedTts?.acknowledgeError();
    });
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

    final voice = _mode == TranslateMode.voice;
    // Breakpoint do PRD §4.1: a partir de 600 dp cabe o par de painéis lado a
    // lado. Abaixo disso eles continuam empilhados.
    final wide = MediaQuery.sizeOf(context).width >= 600;
    // §4: bloco de marca a ~40% da altura útil no modo voz (medido no case).
    final voiceHeight = MediaQuery.sizeOf(context).height * 0.34;

    return Stack(
      // §P4: o botão de modo TRANSBORDA o limite entre bloco e painel. Sem
      // isto ele seria recortado — e é justamente o transbordo que faz dele o
      // único elemento que quebra a grade.
      clipBehavior: Clip.none,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Faixa 1 da §4: bloco de marca (só cresce no modo voz) ───────────
            AnimatedSize(
              duration: const Duration(milliseconds: 280),
              curve: Curves.easeOutCubic, // §7: painel subindo
              alignment: Alignment.topCenter,
              child: voice
                  ? VoiceBlock(height: voiceHeight)
                  : const SizedBox(width: double.infinity, height: 0),
            ),

            // ── Faixas 2 e 3 da §4: pilha de painéis ────────────────────────────
            // Painéis SANGRAM até a borda (§4) e são empilhados sem gap: o topo
            // arredondado do painel seguinte cobre a borda reta do anterior, que é
            // o que produz a "pilha" da §P1 sem nenhum offset negativo.
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Card de download só aparece com o par incompleto; é o único
                    // bloco com margem lateral, porque é aviso, não painel.
                    Selector<TranslatorViewModel, (Language, ModelState)?>(
                      selector: (_, vm) => _missingModelFor(vm),
                      builder: (context, missing, _) {
                        final entry = missing;
                        if (entry == null) return const SizedBox.shrink();
                        return Padding(
                          padding: const EdgeInsets.fromLTRB(
                            AppSpacing.md,
                            AppSpacing.md,
                            AppSpacing.md,
                            AppSpacing.sm,
                          ),
                          child: DownloadProgressCard(
                            language: entry.$1,
                            state: entry.$2,
                            onDownload: () => _observed?.retryLastAction(),
                            onCancel: () => manager.cancelDownload(entry.$1),
                          ),
                        );
                      },
                    ),
                    // 600–1024 dp: os painéis viram colunas lado a lado (PRD
                    // §4.1). Empilhados numa tela larga, cada um ficaria com
                    // uma linha de texto e metade da tela vazia.
                    if (wide)
                      IntrinsicHeight(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(
                              child: _OriginPanel(
                                controller: _controller,
                                onPaste: _pasteFromClipboard,
                                onEnterVoiceMode: _enterVoiceMode,
                              ),
                            ),
                            Expanded(
                              child: _DestinationPanel(
                                onCopy: _copyTranslation,
                              ),
                            ),
                          ],
                        ),
                      )
                    else ...[
                      _OriginPanel(
                        controller: _controller,
                        onPaste: _pasteFromClipboard,
                        onEnterVoiceMode: _enterVoiceMode,
                      ),
                      _DestinationPanel(onCopy: _copyTranslation),
                    ],
                  ],
                ),
              ),
            ),

            // ── Faixa 4 da §4: ação ancorada no polegar (§P5) ───────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.md,
                AppSpacing.md,
                AppSpacing.sm,
              ),
              child: Selector<TranslatorViewModel, bool>(
                selector: (_, vm) =>
                    !vm.isTranslating && vm.sourceText.trim().isNotEmpty,
                builder: (context, enabled, _) => FilledButton(
                  onPressed: enabled ? () => _observed!.translateNow() : null,
                  child: Text(t.buttonTranslate),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                0,
                AppSpacing.md,
                AppSpacing.md,
              ),
              child: Selector<TranslatorViewModel, (Language, Language, bool)>(
                selector: (_, vm) =>
                    (vm.sourceLang, vm.targetLang, vm.isTranslating),
                builder: (context, data, _) {
                  final (source, target, translating) = data;
                  return LanguageBar(
                    source: source,
                    target: target,
                    enabled: !translating,
                    onSelectSource: (language) => context
                        .read<TranslatorViewModel>()
                        .selectSource(language),
                    onSelectTarget: (language) => context
                        .read<TranslatorViewModel>()
                        .selectTarget(language),
                    onSwap: () => _observed!.swapLanguages(),
                    sourceSemanticLabel: t.originLabel,
                    targetSemanticLabel: t.destinationLabel,
                    swapSemanticLabel: t.actionSwapLanguages,
                  );
                },
              ),
            ),
          ],
        ),
        // Botão de modo (§5.3): metade sobre o bloco de marca, metade sobre o
        // painel. Em modo voz o limite desce junto com o bloco.
        Positioned(
          // O transbordo da §P4 só é possível quando o limite está DENTRO do
          // corpo da tela — no modo voz ele está, e o botão cavalga a fronteira
          // como o case desenha. No modo texto o limite é a própria borda do
          // `body`, que recorta: `Clip.none` no Stack não vence o recorte do
          // ancestral. Aí o botão encosta no topo em vez de ser cortado ao meio.
          top: math.max(0.0, (voice ? voiceHeight : 0) - ModeButton.size / 2),
          right: AppSpacing.md,
          child: ModeButton(mode: _mode, onToggle: _toggleMode),
        ),
      ],
    );
  }

  /// Entra no modo voz sem alternar — usado pelo 🎤 do painel de origem.
  void _enterVoiceMode() {
    if (_mode != TranslateMode.voice) {
      setState(() => _mode = TranslateMode.voice);
    }
  }

  /// Alterna Texto ↔ Voz. Sair do modo voz durante a escuta CANCELA — trocar de
  /// modo é desistir do ditado, e finalizar traduziria algo que o usuário
  /// abandonou.
  void _toggleMode() {
    final speech = context.read<SpeechViewModel>();
    setState(() {
      _mode = _mode == TranslateMode.text
          ? TranslateMode.voice
          : TranslateMode.text;
    });
    if (_mode == TranslateMode.text && speech.isDictating) {
      unawaited(speech.cancel());
    }
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

/// Painel de ORIGEM (§4 faixa 2 · §5.1). Superfície `colorBackground` — um
/// degrau mais escuro que o destino, pela inversão deliberada da §3.
class _OriginPanel extends StatelessWidget {
  const _OriginPanel({
    required this.controller,
    required this.onPaste,
    required this.onEnterVoiceMode,
  });

  final TextEditingController controller;
  final Future<void> Function() onPaste;
  final VoidCallback onEnterVoiceMode;

  @override
  Widget build(BuildContext context) {
    final t = AppStrings.of(context);

    return TranslationPanel(
      role: PanelRole.source,
      header: PanelHeader(
        languageLabel: context
            .select<TranslatorViewModel, Language>((vm) => vm.sourceLang)
            .displayName,
        semanticLabel: t.originLabel,
        onTapLanguage: () => _pickLanguage(context),
        // §5.1: a única ação do painel de origem é limpar.
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
      ),
      footer: _OriginFooter(
        onPaste: onPaste,
        onEnterVoiceMode: onEnterVoiceMode,
      ),
      // Durante a escuta o painel mostra o PARCIAL, não o campo de digitação:
      // é onde o case exibe o texto reconhecido, enquanto a onda fica no bloco
      // de marca. O parcial é preview — não toca em `sourceText`, e por isso
      // cancelar continua restaurando o texto anterior (AC-M2-4).
      child: Selector<SpeechViewModel, (bool, String)>(
        selector: (_, vm) => (vm.isDictating, vm.partialText),
        builder: (context, data, child) {
          final (dictating, partial) = data;
          if (!dictating) return child!;
          return Text(
            partial.isEmpty ? t.dictationHint : partial,
            // §5.1: parcial é itálico e secundário — sinaliza que o texto ainda
            // vai ser reescrito pelo motor.
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontStyle: FontStyle.italic,
            ),
          );
        },
        child: TextField(
          controller: controller,
          // RF-M2-07: digitar durante a escuta disputaria o mesmo campo que o
          // ditado vai preencher.
          enabled: !context.select<SpeechViewModel, bool>(
            (vm) => vm.isDictating,
          ),
          maxLines: null,
          minLines: 3,
          keyboardType: TextInputType.multiline,
          // §P3 — dentro do painel, o campo É o painel: sem contorno nenhum. Só
          // `border: none` não bastava, porque `enabledBorder` do tema tem
          // precedência e continuava desenhando a caixa do Material.
          decoration: InputDecoration(
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            disabledBorder: InputBorder.none,
            filled: false,
            isDense: true,
            contentPadding: EdgeInsets.zero,
            hintText: t.sourceHint,
          ),
        ),
      ),
    );
  }

  Future<void> _pickLanguage(BuildContext context) async {
    final vm = context.read<TranslatorViewModel>();
    final choice = await showModalBottomSheet<Language>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final option in Language.values)
              ListTile(
                title: Text(option.displayName),
                onTap: () => Navigator.of(context).pop(option),
              ),
          ],
        ),
      ),
    );
    if (choice != null) vm.selectSource(choice);
  }
}

/// Rodapé do cartão origem (F1.6): 🎤 placeholder F2 · colar · contador n/5000
/// com aviso de truncamento. Rebuild cirúrgico — só o rodapé reage ao texto.
class _OriginFooter extends StatelessWidget {
  const _OriginFooter({required this.onPaste, required this.onEnterVoiceMode});

  final Future<void> Function() onPaste;

  /// O 🎤 leva ao modo voz (§4): desde a #58 a escuta acontece no bloco de
  /// marca expandido, e não mais numa folha sobreposta.
  final VoidCallback onEnterVoiceMode;

  /// Toque no 🎤 (F2.5). O que fazer depende do estado, e não do que a UI
  /// acha que está acontecendo — a máquina de estados é a fonte da verdade.
  Future<void> _onMicPressed(BuildContext context) async {
    final speech = context.read<SpeechViewModel>();

    switch (speech.state) {
      case SpeechState.listening:
        await speech.stop();
      case SpeechState.initializing || SpeechState.processing:
        return; // toque sem efeito durante a carga
      case SpeechState.error:
        final blocked = speech.errorAction == SuggestedAction.openSettings;
        speech.acknowledgeError();
        if (blocked && context.mounted) await _showBlockedDialog(context);
      case SpeechState.idle:
        // RF-M2-07: o microfone e a voz não dividem o mesmo instante — se uma
        // tradução está sendo lida, o ditado a interrompe antes de começar.
        unawaited(context.read<TtsViewModel>().stop());
        // Entra no modo voz ANTES de pedir permissão: o bloco de marca já
        // cresce, e o diálogo do sistema aparece sobre a tela que vai receber
        // a fala — não sobre a tela de digitação.
        onEnterVoiceMode();
        await speech.start(
          onPermissionNeeded: () async =>
              context.mounted && await _showRationaleDialog(context),
        );
        if (!context.mounted) return;
        if (speech.errorAction == SuggestedAction.openSettings) {
          speech.acknowledgeError();
          if (context.mounted) await _showBlockedDialog(context);
        }
    }
  }

  /// Diálogo explicativo PRÉVIO (PRD §4.5): a única chance de o usuário
  /// entender o pedido antes do diálogo seco do sistema.
  Future<bool> _showRationaleDialog(BuildContext context) async {
    final t = AppStrings.of(context);
    final proceed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(t.micRationaleTitle),
        content: Text(t.micRationaleBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(t.actionCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(t.actionDictate),
          ),
        ],
      ),
    );
    return proceed ?? false;
  }

  /// Negação permanente (AC-M2-2): explica e oferece as configurações; o app
  /// segue utilizável de qualquer forma.
  Future<void> _showBlockedDialog(BuildContext context) async {
    final t = AppStrings.of(context);
    final speech = context.read<SpeechViewModel>();
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(t.errMicPermission),
        content: Text(t.micBlockedBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(t.actionCancel),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              unawaited(speech.openAppSettings());
            },
            child: Text(t.actionOpenSettings),
          ),
        ],
      ),
    );
  }

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
                // Ausente — não desabilitado — em builds sem modelo de STT
                // (F2.1b). `maybe` devolve null e o botão não entra na árvore.
                ?MicButton.maybe(
                  context,
                  onPressed: () => unawaited(_onMicPressed(context)),
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

/// Painel de DESTINO (§4 faixa 3 · §5.1). Superfície `colorSurface`, mais
/// clara que a origem: puxa o olho para a tradução, que é o resultado (§3).
///
/// §5.1 põe as ações no CABEÇALHO, não num rodapé. Ouvir (M3) ganhou botão
/// próprio 🔊 (F2.8); favoritar e copiar ficam à direita; compartilhar (F4)
/// vive no `⋮` enquanto não existe.
class _DestinationPanel extends StatelessWidget {
  const _DestinationPanel({required this.onCopy});

  final ValueChanged<String> onCopy;

  @override
  Widget build(BuildContext context) {
    final t = AppStrings.of(context);
    return Selector<TranslatorViewModel, (int, String, bool, bool)>(
      selector: (_, vm) => (
        vm.status.index,
        vm.translatedText,
        vm.usesAlternativeEngine,
        vm.resultWasLocalFallback,
      ),
      builder: (context, data, _) {
        final (statusIndex, translated, alternative, localFallback) = data;
        final translating = statusIndex == TranslatorStatus.translating.index;

        return TranslationPanel(
          role: PanelRole.target,
          header: PanelHeader(
            languageLabel: context
                .select<TranslatorViewModel, Language>((vm) => vm.targetLang)
                .displayName,
            semanticLabel: t.destinationLabel,
            onTapLanguage: () => _pickLanguage(context),
            actions: [
              if (alternative)
                Padding(
                  padding: const EdgeInsets.only(right: AppSpacing.xs),
                  child: Chip(
                    label: Text(t.engineAlternative),
                    labelStyle: Theme.of(context).textTheme.labelSmall,
                    visualDensity: VisualDensity.compact,
                  ),
                ),
              // Modo híbrido (F4.3): a nuvem não respondeu e o aparelho
              // assumiu. Badge DISCRETO — a tradução saiu, e o usuário não
              // precisa fazer nada com essa informação.
              if (localFallback)
                Padding(
                  padding: const EdgeInsets.only(right: AppSpacing.xs),
                  child: Chip(
                    label: Text(t.engineLocal),
                    labelStyle: Theme.of(context).textTheme.labelSmall,
                    visualDensity: VisualDensity.compact,
                  ),
                ),
              // 🔊 (F2.8, M3): alterna ▶/⏹; só com resultado pronto. Rebuild
              // cirúrgico: o resto do cabeçalho não reage à fala.
              Selector<TtsViewModel, bool>(
                selector: (_, vm) => vm.isSpeaking,
                builder: (context, speaking, _) => IconButton(
                  tooltip: speaking ? t.actionStopPlayback : t.actionListen,
                  onPressed: translated.isEmpty
                      ? null
                      : () => unawaited(
                          context.read<TtsViewModel>().togglePlayback(),
                        ),
                  icon: Icon(speaking ? Icons.stop : Icons.volume_up_outlined),
                ),
              ),
              IconButton(
                tooltip: '${t.actionFavorite} · ${t.comingSoon}',
                onPressed: null, // placeholder F3 (favoritos)
                icon: const Icon(Icons.star_border_outlined),
              ),
              IconButton(
                tooltip: t.actionCopy,
                onPressed: translated.isEmpty ? null : () => onCopy(translated),
                icon: const Icon(Icons.copy_outlined),
              ),
              PopupMenuButton<void>(
                icon: const Icon(Icons.more_vert),
                itemBuilder: (context) => <PopupMenuItem<void>>[
                  PopupMenuItem<void>(
                    // Compartilhar funciona OFFLINE: a folha é do SO e o que
                    // entregamos a ela é texto puro (F4.1 · RN-02).
                    enabled: translated.isNotEmpty,
                    onTap: () => unawaited(_share(context, translated)),
                    child: Text(t.actionShare),
                  ),
                ],
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

  /// Abre a folha nativa com origem, tradução e o par de idiomas (F4.1).
  Future<void> _share(BuildContext context, String translated) async {
    final vm = context.read<TranslatorViewModel>();
    await context.read<ShareService>().shareTranslation(
      source: vm.sourceLang,
      target: vm.targetLang,
      sourceText: vm.sourceText,
      translatedText: translated,
    );
  }

  Future<void> _pickLanguage(BuildContext context) async {
    final vm = context.read<TranslatorViewModel>();
    final choice = await showModalBottomSheet<Language>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final option in Language.values)
              ListTile(
                title: Text(option.displayName),
                onTap: () => Navigator.of(context).pop(option),
              ),
          ],
        ),
      ),
    );
    if (choice != null) vm.selectTarget(choice);
  }
}
