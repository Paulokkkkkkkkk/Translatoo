import 'package:flutter/material.dart';

import '../../core/constants/app_spacing.dart';
import '../../core/constants/app_strings.dart';
import '../../core/theme/app_theme.dart';
import '../../models/translation_record.dart';

/// Card de histórico (F3.2 · `docs/design_system.md` §5.12).
///
/// É **card com margem**, não painel sangrado como os da tela Traduzir: a lista
/// precisa de separação entre itens, e esta é a única superfície do app onde
/// vários cards coexistem verticalmente.
class HistoryCard extends StatelessWidget {
  const HistoryCard({
    required this.record,
    required this.onTap,
    required this.onToggleFavorite,
    super.key,
  });

  final TranslationRecord record;
  final VoidCallback onTap;
  final VoidCallback onToggleFavorite;

  @override
  Widget build(BuildContext context) {
    final t = AppStrings.of(context);
    final theme = Theme.of(context);
    final minutes = DateTime.now()
        .toUtc()
        .difference(record.timestamp)
        .inMinutes;

    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        // Reusar é mais comum que reler: o toque devolve a tradução ao
        // Tradutor, com texto E par de idiomas.
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _PairChip(record: record),
                  const Spacer(),
                  IconButton(
                    tooltip: t.actionFavorite,
                    onPressed: onToggleFavorite,
                    visualDensity: VisualDensity.compact,
                    icon: Icon(
                      // ★ preenchido é uma das três exceções cromáticas da §6 —
                      // a única do app que usa ícone sólido.
                      record.isFavorite ? Icons.star : Icons.star_border,
                      color: record.isFavorite
                          ? AppSemanticColors.warning_(context)
                          : theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              Text(
                record.sourceText,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                record.translatedText,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyLarge,
              ),
              const SizedBox(height: AppSpacing.sm),
              // Horário RELATIVO: a data absoluta não ajuda a reencontrar algo
              // traduzido há pouco, que é o uso real desta tela.
              Text(
                t.relativeTime(minutes),
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Chip do par de idiomas (§5.6).
class _PairChip extends StatelessWidget {
  const _PairChip({required this.record});

  final TranslationRecord record;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
      ),
      child: Text(
        '${record.sourceLang.displayName} → ${record.targetLang.displayName}',
        style: theme.textTheme.labelSmall?.copyWith(
          color: theme.colorScheme.onPrimaryContainer,
        ),
      ),
    );
  }
}
