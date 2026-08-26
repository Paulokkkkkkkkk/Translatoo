import 'package:flutter/material.dart';

import '../../core/constants/app_spacing.dart';

/// Cartão base origem/destino (F1.7): cabeçalho com pill à esquerda e ações à
/// direita, corpo expansível e rodapé opcional — visual 100% do tema (§3).
class TranslationCard extends StatelessWidget {
  const TranslationCard({
    super.key,
    required this.child,
    this.leading,
    this.actions = const <Widget>[],
    this.footer,
    this.expandChild = false,
  });

  final Widget child;
  final Widget? leading;
  final List<Widget> actions;
  final Widget? footer;

  /// Quando true, o corpo ocupa o espaço vertical restante (cartão destino).
  final bool expandChild;

  @override
  Widget build(BuildContext context) {
    final body = expandChild ? Expanded(child: child) : child;
    return Card(
      clipBehavior: Clip.antiAlias,
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(children: [?leading, const Spacer(), ...actions]),
            const SizedBox(height: AppSpacing.sm),
            body,
            if (footer != null) ...[
              const SizedBox(height: AppSpacing.xs),
              footer!,
            ],
          ],
        ),
      ),
    );
  }
}
