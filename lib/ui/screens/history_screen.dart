import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_spacing.dart';
import '../../core/constants/app_strings.dart';
import '../../models/language.dart';
import '../../models/language_pair.dart';
import '../../models/translation_record.dart';
import '../../state/library_view_model.dart';
import '../../state/translator_view_model.dart';
import '../widgets/history_card.dart';
import '../widgets/placeholder_panel.dart';

/// Tela Histórico (F3.2 · PRD §3.4).
///
/// Busca fixa no topo, chips de filtro roláveis, swipe-to-delete com
/// "Desfazer" por 5 s e "Limpar tudo" com confirmação.
///
/// A tela não guarda estado nenhum: busca, filtro e a pendência de undo vivem
/// no [LibraryViewModel]. Sair da aba e voltar não perde o filtro aplicado.
class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  /// Duração da janela de desfazer (AC-M4-2).
  static const Duration undoWindow = Duration(seconds: 5);

  @override
  Widget build(BuildContext context) {
    final t = AppStrings.of(context);

    return Consumer<LibraryViewModel>(
      builder: (context, library, _) {
        final visible = library.visibleHistory;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _SearchBar(
              onChanged: library.search,
              onClearAll: library.history.isEmpty
                  ? null
                  : () => _confirmClearAll(context, library),
            ),
            _FilterChips(
              selected: library.pairFilter,
              onSelected: library.filterBy,
            ),
            Expanded(
              child: visible.isEmpty
                  ? PlaceholderPanel(
                      icon: Icons.history,
                      title: t.tabHistory,
                      message: t.historyEmpty,
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.md,
                        AppSpacing.sm,
                        AppSpacing.md,
                        AppSpacing.xl,
                      ),
                      itemCount: visible.length,
                      itemBuilder: (context, index) {
                        final record = visible[index];
                        return Dismissible(
                          key: ValueKey<String>(record.id),
                          direction: DismissDirection.endToStart,
                          background: const _DeleteBackground(),
                          onDismissed: (_) =>
                              _deleteWithUndo(context, library, record),
                          child: HistoryCard(
                            record: record,
                            onTap: () => _reopen(context, record),
                            onToggleFavorite: () =>
                                library.toggleFavorite(record.id),
                          ),
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }

  /// Devolve a tradução ao Tradutor: texto E par de idiomas (§5.12).
  void _reopen(BuildContext context, TranslationRecord record) {
    context.read<TranslatorViewModel>()
      ..selectSource(record.sourceLang)
      ..selectTarget(record.targetLang)
      ..onTextChanged(record.sourceText);
  }

  void _deleteWithUndo(
    BuildContext context,
    LibraryViewModel library,
    TranslationRecord record,
  ) {
    final t = AppStrings.of(context);
    library.delete(record.id);

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
            SnackBar(
              content: Text(t.actionDelete),
              duration: undoWindow,
              action: SnackBarAction(
                label: t.actionUndo,
                onPressed: library.undoDelete,
              ),
            ),
          )
          // Expirada a janela, a pendência é descartada — senão um "Desfazer"
          // de minutos atrás ressuscitaria algo que o usuário já esqueceu.
          .closed
          .then((reason) {
            if (reason != SnackBarClosedReason.action) library.forgetUndo();
          });
  }

  Future<void> _confirmClearAll(
    BuildContext context,
    LibraryViewModel library,
  ) async {
    final t = AppStrings.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(t.confirmClearHistoryTitle),
        // O corpo diz explicitamente que favoritos sobrevivem: sem isso, o
        // usuário hesita em limpar por medo de perder o que guardou.
        content: Text(t.confirmClearHistoryBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(t.actionCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(t.actionClearAll),
          ),
        ],
      ),
    );
    if (confirmed ?? false) library.clearHistory();
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar({required this.onChanged, required this.onClearAll});

  final ValueChanged<String> onChanged;
  final VoidCallback? onClearAll;

  @override
  Widget build(BuildContext context) {
    final t = AppStrings.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.sm,
        AppSpacing.sm,
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              onChanged: onChanged,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: t.historySearchHint,
                prefixIcon: const Icon(Icons.search),
                isDense: true,
              ),
            ),
          ),
          TextButton(onPressed: onClearAll, child: Text(t.actionClearAll)),
        ],
      ),
    );
  }
}

/// Chips de filtro (§5.5): três pares + "Todos". Bidirecionais — ver
/// `LibraryViewModel.filterBy`.
class _FilterChips extends StatelessWidget {
  const _FilterChips({required this.selected, required this.onSelected});

  final PairFilter selected;
  final ValueChanged<PairFilter> onSelected;

  static const List<LanguagePair> _pairs = <LanguagePair>[
    LanguagePair(source: Language.pt, target: Language.en),
    LanguagePair(source: Language.pt, target: Language.zh),
    LanguagePair(source: Language.en, target: Language.zh),
  ];

  @override
  Widget build(BuildContext context) {
    final t = AppStrings.of(context);
    return SizedBox(
      height: AppSpacing.minTouchTarget,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        children: [
          _Chip(
            label: t.filterAll,
            selected: selected == null,
            onTap: () => onSelected(null),
          ),
          for (final pair in _pairs)
            _Chip(
              label: '${pair.source.displayName} ↔ ${pair.target.displayName}',
              selected: selected == pair,
              onTap: () => onSelected(pair),
            ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(right: AppSpacing.sm),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onTap(),
        labelStyle: theme.textTheme.labelMedium?.copyWith(
          color: selected
              ? theme.colorScheme.onPrimaryContainer
              : theme.colorScheme.onSurfaceVariant,
        ),
        // §P3 — borda de 1 dp só em selecionável NÃO selecionado.
        showCheckmark: false,
        selectedColor: theme.colorScheme.primaryContainer,
        backgroundColor: theme.colorScheme.surface,
      ),
    );
  }
}

/// Fundo revelado pelo swipe (§5.12).
class _DeleteBackground extends StatelessWidget {
  const _DeleteBackground();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.only(right: AppSpacing.lg),
      alignment: Alignment.centerRight,
      decoration: BoxDecoration(
        color: theme.colorScheme.error,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      ),
      child: Icon(Icons.delete_outline, color: theme.colorScheme.onError),
    );
  }
}
