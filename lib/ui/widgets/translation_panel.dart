import 'package:flutter/material.dart';

import '../../core/constants/app_spacing.dart';

/// Papel do painel na tela Traduzir — decide a superfície (§3).
enum PanelRole {
  /// Card de origem: `colorBackground`, um degrau MAIS ESCURO.
  source,

  /// Card de destino: `colorSurface`.
  ///
  /// A inversão (o painel "de baixo" mais claro que o "de cima") é deliberada:
  /// puxa o olho para a tradução, que é o resultado que importa (§3).
  target,
}

/// Painel de tradução (§5.1 · §P1 · §P3).
///
/// SUBSTITUI o `TranslationCard` da F1.7, que era um `Card` do Material com
/// borda e margem lateral. As três diferenças que carregam a identidade:
///
/// - **Sangra até a borda** da tela. Painel não tem margem lateral; só o
///   conteúdo tem padding (§4).
/// - **Canto superior esquerdo arredondado, os outros três retos.** Empilhados
///   sem gap, o painel seguinte cobre a borda inferior do anterior — é isso que
///   produz a "pilha de painéis" da §P1 sem nenhum offset negativo. A
///   assimetria foi medida no case, não estimada.
/// - **Sem borda.** Hierarquia vem da superfície e da sombra difusa, nunca de
///   contorno (§P3).
///
/// Composição fixa da §5.1, de cima para baixo: cabeçalho → texto → contador.
/// O contador é a última linha, à direita, colado no rodapé **mesmo quando o
/// texto é curto** — daí ele viver fora do corpo, e não depois dele.
class TranslationPanel extends StatelessWidget {
  const TranslationPanel({
    required this.role,
    required this.header,
    required this.child,
    super.key,
    this.footer,
    this.expandChild = false,
  });

  final PanelRole role;

  /// Linha de cabeçalho: ícone de áudio + idioma à esquerda, ações à direita.
  final Widget header;

  final Widget child;

  /// Última linha do painel — contador, ações de entrada. Ancorado embaixo.
  final Widget? footer;

  /// Corpo ocupa o espaço vertical restante (painel de destino).
  final bool expandChild;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final surface = switch (role) {
      PanelRole.source => colors.surfaceContainerLow,
      PanelRole.target => colors.surface,
    };

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: surface,
        // CURVA ASSIMÉTRICA — medida no case (`docs/design/home.webp`): canto
        // superior ESQUERDO arredondado, direito RETO. É essa assimetria que
        // faz o painel parecer deslizar por baixo do bloco de marca, em vez de
        // um cartão simétrico pousado na tela. Simetrizar mata o efeito.
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(AppSpacing.radiusLg),
        ),
        // Plano 2 (§3): difusa, y+2, blur 16, ~6% preto. A sombra existe para
        // descolar o painel do fundo, não para ser vista.
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: colors.shadow.withValues(alpha: 0.06),
            offset: const Offset(0, 2),
            blurRadius: 16,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            header,
            const SizedBox(height: AppSpacing.sm),
            if (expandChild) Expanded(child: child) else child,
            if (footer != null) ...[
              const SizedBox(height: AppSpacing.sm),
              footer!,
            ],
          ],
        ),
      ),
    );
  }
}

/// Cabeçalho da §5.1: ícone de áudio + nome do idioma à esquerda, ações à
/// direita.
///
/// O ícone `)))` do case é o gancho de leitura em voz alta (M3). Enquanto o TTS
/// não existe, [onSpeak] vem nulo e o ícone fica como rótulo do idioma — sem
/// botão inerte na tela.
class PanelHeader extends StatelessWidget {
  const PanelHeader({
    required this.languageLabel,
    required this.onTapLanguage,
    super.key,
    this.semanticLabel,
    this.actions = const <Widget>[],
  });

  final String languageLabel;
  final VoidCallback onTapLanguage;
  final String? semanticLabel;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Icon(
          Icons.graphic_eq,
          size: 20, // §6: 20 dp em cabeçalho de card.
          color: theme.colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: AppSpacing.sm),
        Flexible(
          child: Semantics(
            button: true,
            label: semanticLabel,
            child: InkWell(
              onTap: onTapLanguage,
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: AppSpacing.xs,
                  horizontal: AppSpacing.xs,
                ),
                child: Text(
                  languageLabel,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleSmall,
                ),
              ),
            ),
          ),
        ),
        const Spacer(),
        ...actions,
      ],
    );
  }
}
