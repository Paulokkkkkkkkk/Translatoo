import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_spacing.dart';
import '../../core/constants/app_strings.dart';
import '../../core/services/model_manager_service.dart';
import '../../models/language.dart';
import '../../models/model_state.dart';
import '../../state/tts_view_model.dart';

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
          const Divider(height: AppSpacing.lg),
          // Sliders de voz funcionais (F2.8) — mudam a PRÓXIMA reprodução; a
          // persistência em Ajustes chega na F3 (AC-M3-4).
          const _VoiceDebugPanel(),
        ],
      ),
    );
  }
}

/// Sliders de velocidade/tom ligados ao [TtsViewModel] (F2.8 — tela de debug).
/// Migram para a tela Ajustes na F3.
class _VoiceDebugPanel extends StatelessWidget {
  const _VoiceDebugPanel();

  @override
  Widget build(BuildContext context) {
    final t = AppStrings.of(context);
    final tts = context.watch<TtsViewModel>();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            t.debugVoiceTitle,
            style: Theme.of(context).textTheme.titleSmall,
          ),
          // Velocidade: normalizada 0..1 (0,5 ≈ normal no SO).
          Text(
            t.settingsVoiceRate,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          Slider(value: tts.rate, onChanged: tts.setRate),
          // Tom: escala nativa 0,5..2,0 (1,0 = normal).
          Text(
            t.settingsVoicePitch,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          Slider(value: tts.pitch, min: 0.5, max: 2.0, onChanged: tts.setPitch),
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
