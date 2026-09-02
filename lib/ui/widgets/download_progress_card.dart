import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/constants/app_strings.dart';
import '../../models/language.dart';
import '../../models/model_state.dart';

/// Aviso compacto de pacote ausente (F1.7 / AC-M1-2): idioma, estado, tamanho
/// estimado e a ação — tudo numa linha de ~48 dp.
///
/// Era um bloco alto com barra de progresso própria e botão preenchido, que
/// dominava o topo da tela e competia com o TRADUZIR. É AVISO, não ação
/// primária: a barra só aparece durante o download e a ação virou botão de
/// texto.
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
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          child: Row(
            children: [
              Icon(
                isDownloading
                    ? Icons.cloud_download_outlined
                    : Icons.download_outlined,
                size: 20,
                color: scheme.onPrimaryContainer,
              ),
              const SizedBox(width: AppSpacing.sm),
              // Idioma, estado e tamanho numa coluna só; a barra vira uma
              // linha fina embaixo, e não mais um bloco separado.
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      language.displayName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: scheme.onPrimaryContainer,
                      ),
                    ),
                    Text(
                      percent != null
                          ? '$percent% · ${AppConstants.estimatedModelSizeMb} MB'
                          : '${modelStateLabel(t, state)} · '
                                '${AppConstants.estimatedModelSizeMb} MB',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: scheme.onPrimaryContainer,
                      ),
                    ),
                    if (isDownloading) ...[
                      const SizedBox(height: AppSpacing.xs),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(
                          AppSpacing.radiusSm,
                        ),
                        child: LinearProgressIndicator(
                          value: percent == null ? null : percent / 100,
                          minHeight: 3,
                          backgroundColor: scheme.outline,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            scheme.primary,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              // Ação vira botão de texto compacto: o aviso não disputa mais
              // atenção com o botão TRADUZIR, que é a ação primária da tela.
              if (isDownloading)
                TextButton(
                  onPressed: onCancel,
                  style: TextButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    foregroundColor: scheme.onPrimaryContainer,
                  ),
                  child: Text(t.actionCancel),
                )
              else
                TextButton(
                  onPressed: onDownload,
                  style: TextButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    foregroundColor: scheme.primary,
                  ),
                  child: Text(t.actionDownload),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
