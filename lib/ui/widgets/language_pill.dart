import 'package:flutter/material.dart';

import '../../core/constants/app_spacing.dart';
import '../../models/language.dart';

/// Pill seletora de idioma (F1.7): menu fechado com os 3 idiomas (RN-01),
/// alvo de toque ≥ 48 dp e `Semantics` própria (RN-06).
class LanguagePill extends StatelessWidget {
  const LanguagePill({
    super.key,
    required this.language,
    required this.onSelected,
    this.semanticLabel,
  });

  final Language language;
  final ValueChanged<Language> onSelected;

  /// Contexto para leitores de tela ("Idioma de origem", "de destino"…).
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Semantics(
      button: true,
      label: semanticLabel,
      child: PopupMenuButton<Language>(
        tooltip: semanticLabel ?? language.displayName,
        onSelected: onSelected,
        constraints: const BoxConstraints(minWidth: 180),
        itemBuilder: (context) => <PopupMenuItem<Language>>[
          for (final option in Language.values)
            PopupMenuItem<Language>(
              value: option,
              height: AppSpacing.minTouchTarget,
              child: Row(
                children: [
                  if (option == language)
                    Icon(Icons.check, size: 18, color: scheme.primary)
                  else
                    const SizedBox(width: 18),
                  const SizedBox(width: AppSpacing.sm),
                  Text(option.displayName),
                ],
              ),
            ),
        ],
        child: Container(
          constraints: const BoxConstraints(
            minWidth: AppSpacing.minTouchTarget,
            minHeight: AppSpacing.minTouchTarget * 0.75,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.xs,
          ),
          decoration: BoxDecoration(
            color: scheme.primaryContainer,
            borderRadius: BorderRadius.circular(AppSpacing.radius),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                language.displayName,
                style: Theme.of(context).textTheme.labelLarge
                    ?.copyWith(color: scheme.onPrimaryContainer),
              ),
              Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 18,
                color: scheme.onPrimaryContainer,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
