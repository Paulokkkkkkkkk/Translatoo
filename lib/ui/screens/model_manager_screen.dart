import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_spacing.dart';
import '../../core/constants/app_strings.dart';
import '../../core/services/app_exception.dart';
import '../../core/services/model_manager_service.dart';
import '../../models/language.dart';
import '../../models/model_state.dart';

/// Gerenciador de Modelos (F3.4 · PRD §3.5 · RF-M4-06 / AC-M4-4).
///
/// Substitui a tela de debug da F1.3 no Ajustes: o usuário vê o estado REAL
/// dos três pacotes (`Não baixado · Baixando n% · Pronto`), o tamanho
/// estimado e as ações Baixar / Cancelar / Excluir — sem nenhuma opção de
/// debug visível.
///
/// Regras implementadas aqui:
/// - download segue o `ModelManagerService` (que aplica o gate Wi-Fi); quando
///   a rede é medida e `wifiOnly` está ligado, o erro vira SnackBar com a ação
///   "Baixar mesmo assim" — a decisão NÃO altera a preferência (RF-M4-06);
/// - exclusão é destrutiva: confirmação antes, mensagem da tabela §4.8 em caso
///   de falha (nada de exceção crua).
class ModelManagerScreen extends StatelessWidget {
  const ModelManagerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppStrings.of(context);
    final manager = context.read<ModelManagerService>();

    return Scaffold(
      appBar: AppBar(title: Text(t.settingsManageModels)),
      // `ModelManagerService` NÃO é ChangeNotifier: quem reage ao download é o
      // ValueListenable `states` — por isso o ValueListenableBuilder em vez de
      // um `watch` no serviço (que nunca rebuildaria o corpo).
      body: ValueListenableBuilder<Map<Language, ModelState>>(
        valueListenable: manager.states,
        builder: (context, states, _) => ListView(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.xs,
                AppSpacing.md,
                AppSpacing.sm,
              ),
              child: Text(
                t.modelManagerHint,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            for (final language in Language.values)
              _ModelRow(
                language: language,
                state: states[language] ?? const ModelNotDownloaded(),
              ),
          ],
        ),
      ),
    );
  }
}

class _ModelRow extends StatelessWidget {
  const _ModelRow({required this.language, required this.state});

  final Language language;
  final ModelState state;

  @override
  Widget build(BuildContext context) {
    final t = AppStrings.of(context);
    final manager = context.read<ModelManagerService>();
    // Campo público de widget não promove em Dart: a local permite o type
    // promotion (`is ModelDownloading` → `progressPercent`).
    final currentState = state;

    return ListTile(
      minVerticalPadding: AppSpacing.sm,
      title: Text(
        language.displayName,
        style: Theme.of(context).textTheme.titleMedium,
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${modelStateLabel(t, currentState)} · ${t.modelSizeEstimate}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          if (currentState is ModelDownloading) ...[
            const SizedBox(height: AppSpacing.xs),
            LinearProgressIndicator(
              value: currentState.progressPercent / 100,
              minHeight: 4,
            ),
          ],
        ],
      ),
      trailing: switch (currentState) {
        ModelNotDownloaded() => IconButton(
          tooltip: t.actionDownload,
          onPressed: () => unawaited(_download(context, manager)),
          icon: const Icon(Icons.download_outlined),
        ),
        ModelDownloading() => IconButton(
          tooltip: t.actionCancel,
          onPressed: () => manager.cancelDownload(language),
          icon: const Icon(Icons.close),
        ),
        ModelReady() => IconButton(
          tooltip: t.actionDelete,
          onPressed: () => unawaited(_confirmDelete(context, manager)),
          icon: const Icon(Icons.delete_outline),
        ),
      },
    );
  }

  /// Baixa com o gate Wi-Fi do serviço; `ERR_WIFI_ONLY` vira a ação
  /// "Baixar mesmo assim" (RF-M4-06) — sem tocar na preferência.
  Future<void> _download(
    BuildContext context,
    ModelManagerService manager,
  ) async {
    try {
      await manager.downloadModel(language);
    } on AppException catch (e) {
      if (!context.mounted) return;
      final t = AppStrings.of(context);
      final messenger = ScaffoldMessenger.of(context);
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(errorMessageOf(t, e.code)),
            action: switch (e.code) {
              ErrorCode.wifiOnly => SnackBarAction(
                label: t.actionDownloadAnyway,
                onPressed: () => unawaited(_forceDownload(context, manager)),
              ),
              ErrorCode.downloadFailed => SnackBarAction(
                label: t.actionRetry,
                onPressed: () => unawaited(_download(context, manager)),
              ),
              _ => null,
            },
          ),
        );
    }
  }

  Future<void> _forceDownload(
    BuildContext context,
    ModelManagerService manager,
  ) async {
    try {
      await manager.downloadModel(language, force: true);
    } on AppException catch (e) {
      if (!context.mounted) return;
      final t = AppStrings.of(context);
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(errorMessageOf(t, e.code))));
    }
  }

  Future<void> _confirmDelete(
    BuildContext context,
    ModelManagerService manager,
  ) async {
    final t = AppStrings.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(t.modelManagerDeleteTitle(language.displayName)),
        content: Text(t.modelManagerDeleteBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(t.actionCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(t.actionDelete),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    try {
      await manager.deleteModel(language);
    } on AppException catch (e) {
      if (!context.mounted) return;
      final t = AppStrings.of(context);
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(errorMessageOf(t, e.code)),
            action: SnackBarAction(
              label: t.actionRetry,
              onPressed: () => unawaited(_confirmDelete(context, manager)),
            ),
          ),
        );
    }
  }
}
