import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/constants/app_strings.dart';
import '../../models/language.dart';
import '../../models/model_state.dart';

/// Cartão sobreposto de download de pacote (F1.7 / AC-M1-2): nome do idioma,
/// barra de progresso %, tamanho estimado (~30 MB) e ações Baixar/Cancelar.
///
/// Aparece quando o par corrente tem pacote ausente/em download. Após a
/// conclusão o ViewModel retoma sozinho a tradução pendente.
class DownloadProgressCard extends StatelessWidget {
  const DownloadProgressCard({
    super.key,
    required this.language,
    required this.state,
    this.onDownload,
    this.onCancel,
  });

  final Language language;
  final ModelState state;
  final VoidCallback? onDownload;
  final VoidCallback? onCancel;

  @override
  Widget build(BuildContext context) {
    final t = AppStrings.of(context);
    final scheme = Theme.of(context).colorScheme;
    final currentState = state;
    final isDownloading = currentState is ModelDownloading;
    final percent = isDownloading ? currentState.progressPercent : null;

    return Semantics(
      liveRegion: true,
      label: '${language.displayName}: ${modelStateLabel(t, state)}',
      child: Card(
        margin: EdgeInsets.zero,
        color: scheme.primaryContainer,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Icon(
                    isDownloading
                        ? Icons.cloud_download_outlined
                        : Icons.download_outlined,
                    size: 20,
                    color: scheme.onPrimaryContainer,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      language.displayName,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: scheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                  if (percent != null)
                    Text(
                      '$percent%',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: scheme.onPrimaryContainer,
                      ),
                    )
                  else
                    Text(
                      modelStateLabel(t, state),
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: scheme.onPrimaryContainer,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              ClipRRect(
                borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                child: LinearProgressIndicator(
                  value: percent == null ? null : percent / 100,
                  minHeight: 6,
                  backgroundColor: scheme.outline,
                  valueColor: AlwaysStoppedAnimation<Color>(scheme.primary),
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                '${t.modelSizeEstimate} · ${AppConstants.estimatedModelSizeMb} MB',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: scheme.onPrimaryContainer,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Align(
                alignment: Alignment.centerRight,
                child: isDownloading
                    ? OutlinedButton(
                        onPressed: onCancel,
                        child: Text(t.actionCancel),
                      )
                    : FilledButton.icon(
                        onPressed: onDownload,
                        icon: const Icon(Icons.download_outlined),
                        label: Text(t.actionDownload),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
