import 'package:flutter/material.dart';

import '../../core/constants/app_spacing.dart';
import '../../models/language.dart';

/// Barra de idiomas do rodapé (§5.2 · §P5).
///
/// SUBSTITUI o par de `LanguagePill` isoladas da F1.7 e o botão ⇄ circular que
/// vivia solto entre os cards. Um único widget de largura total, partido em
/// duas metades por um botão de troca que **cavalga a junção**.
///
/// §P5 — a ação mais usada mora no rodapé, na zona do polegar. O topo é
/// informação; o fundo é ação.
///
/// **Decisão da §10 (opção C).** A barra é conteúdo da tela Traduzir, não
/// crômio do app: some em Histórico e Ajustes, e por isso convive com a
/// `NavigationBar` de 3 abas sem empilhar 128 dp de crômio fixo.
class LanguageBar extends StatelessWidget {
  const LanguageBar({
    required this.source,
    required this.target,
    required this.onSelectSource,
    required this.onSelectTarget,
    required this.onSwap,
    super.key,
    this.sourceSemanticLabel,
    this.targetSemanticLabel,
    this.swapSemanticLabel,
    this.enabled = true,
  });

  final Language source;
  final Language target;
  final ValueChanged<Language> onSelectSource;
  final ValueChanged<Language> onSelectTarget;
  final VoidCallback onSwap;

  final String? sourceSemanticLabel;
  final String? targetSemanticLabel;
  final String? swapSemanticLabel;

  /// Desabilita a troca durante uma tradução em curso.
  final bool enabled;

  /// §5.2: altura 64 dp; botão de troca 56 dp centrado na junção.
  static const double height = 64;
  static const double _swapDiameter = 56;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Row(
            children: [
              Expanded(
                child: _Half(
                  language: source,
                  onSelected: onSelectSource,
                  semanticLabel: sourceSemanticLabel,
                  isTarget: false,
                  // Espaço para o botão não cobrir o texto.
                  trailingGap: _swapDiameter / 2,
                ),
              ),
              Expanded(
                child: _Half(
                  language: target,
                  onSelected: onSelectTarget,
                  semanticLabel: targetSemanticLabel,
                  isTarget: true,
                  leadingGap: _swapDiameter / 2,
                ),
              ),
            ],
          ),
          _SwapButton(
            onPressed: enabled ? onSwap : null,
            semanticLabel: swapSemanticLabel,
          ),
        ],
      ),
    );
  }
}

/// Metade da barra: alvo de toque próprio que abre o seletor dos 3 idiomas
/// (RN-01). O texto trunca com reticências — o botão de troca não pode encolher
/// para caber idioma de nome longo (§5.2).
class _Half extends StatelessWidget {
  const _Half({
    required this.language,
    required this.onSelected,
    required this.isTarget,
    this.semanticLabel,
    this.leadingGap = 0,
    this.trailingGap = 0,
  });

  final Language language;
  final ValueChanged<Language> onSelected;
  final bool isTarget;
  final String? semanticLabel;
  final double leadingGap;
  final double trailingGap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    // §5.2: metade de origem em `colorSurface`, metade de destino em
    // `colorPrimary`. A assimetria é o que diz para onde o texto está indo.
    final background = isTarget ? colors.primary : colors.surface;
    final foreground = isTarget ? colors.onPrimary : colors.onSurface;

    return Semantics(
      button: true,
      label: semanticLabel,
      value: language.displayName,
      child: Material(
        color: background,
        borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
          onTap: () => _showPicker(context),
          child: Padding(
            padding: EdgeInsets.only(
              left: AppSpacing.md + leadingGap,
              right: AppSpacing.md + trailingGap,
            ),
            child: Align(
              alignment: isTarget
                  ? Alignment.centerLeft
                  : Alignment.centerRight,
              child: Text(
                language.displayName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelLarge?.copyWith(color: foreground),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showPicker(BuildContext context) async {
    final choice = await showModalBottomSheet<Language>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final option in Language.values)
              ListTile(
                title: Text(option.displayName),
                trailing: option == language
                    ? Icon(
                        Icons.check,
                        color: Theme.of(context).colorScheme.primary,
                      )
                    : null,
                onTap: () => Navigator.of(context).pop(option),
              ),
          ],
        ),
      ),
    );
    if (choice != null) onSelected(choice);
  }
}

/// Botão de troca que cavalga a junção das duas metades (§5.2, plano 3).
///
/// Gira 180° a cada troca, em 200 ms — o movimento da §7 que explica que os
/// dois lados trocaram de lugar.
class _SwapButton extends StatefulWidget {
  const _SwapButton({required this.onPressed, this.semanticLabel});

  final VoidCallback? onPressed;
  final String? semanticLabel;

  @override
  State<_SwapButton> createState() => _SwapButtonState();
}

class _SwapButtonState extends State<_SwapButton> {
  double _turns = 0;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Semantics(
      button: true,
      label: widget.semanticLabel,
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          // Plano 3 (§3): y+4, blur 20, ~12% preto.
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: colors.shadow.withValues(alpha: 0.12),
              offset: const Offset(0, 4),
              blurRadius: 20,
            ),
          ],
        ),
        child: Material(
          color: colors.surface,
          shape: const CircleBorder(),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: widget.onPressed == null
                ? null
                : () {
                    setState(() => _turns += 0.5);
                    widget.onPressed!();
                  },
            child: SizedBox.square(
              dimension: LanguageBar._swapDiameter,
              child: AnimatedRotation(
                turns: _turns,
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                child: Icon(
                  Icons.swap_horiz,
                  color: widget.onPressed == null
                      ? colors.onSurfaceVariant
                      : colors.primary,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
