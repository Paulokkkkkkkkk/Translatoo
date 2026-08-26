import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_spacing.dart';
import '../../core/constants/app_strings.dart';
import '../../core/services/model_manager_service.dart';
import '../../models/language.dart';
import '../../models/model_state.dart';

/// Tela TEMPORÁRIA de debug (entregável F1.3): baixar / cancelar / excluir os
/// três pacotes diretamente. Acessível por LONGO PRESS no título do AppBar,
/// apenas em builds debug (`kDebugMode`). Na F3 é substituída pelo
/// Gerenciador de Modelos de Ajustes.
class DebugModelsScreen extends StatelessWidget {
  const DebugModelsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppStrings.of(context);
    final manager = context.watch<ModelManagerService>();
    final states = manager.states.value;

    return Scaffold(
      appBar: AppBar(title: Text(t.debugModelsTitle)),
      body: ListView(
        children: [
          for (final language in Language.values)
            _ModelTile(language: language, state: states[language]),
        ],
      ),
    );
  }
}

class _ModelTile extends StatelessWidget {
  const _ModelTile({required this.language, required this.state});

  final Language language;
  final ModelState? state;

  @override
  Widget build(BuildContext context) {
    final t = AppStrings.of(context);
    final manager = context.read<ModelManagerService>();
    final resolved = state ?? manager.stateFor(language);

    return ListTile(
      minVerticalPadding: AppSpacing.sm,
      title: Text(language.displayName),
      subtitle: Text(modelStateLabel(t, resolved)),
      trailing: switch (resolved) {
        ModelDownloading() => IconButton(
          tooltip: t.actionCancel,
          onPressed: () => manager.cancelDownload(language),
          icon: const Icon(Icons.close),
        ),
        ModelNotDownloaded() => IconButton(
          tooltip: t.actionDownload,
          onPressed: () => unawaited(manager.downloadModel(language)),
          icon: const Icon(Icons.download_outlined),
        ),
        ModelReady() => IconButton(
          tooltip: t.actionDelete,
          onPressed: () =>
              unawaited(manager.deleteModel(language).catchError((_) {})),
          icon: const Icon(Icons.delete_outline),
        ),
      },
    );
  }
}
