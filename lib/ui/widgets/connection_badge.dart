import 'package:flutter/material.dart';

import '../../core/constants/app_spacing.dart';
import '../../core/constants/app_strings.dart';
import '../../core/theme/app_theme.dart';

/// Badge 🟢/⚪ no bloco de marca (RF-M4-07). Puramente informativo: nenhum
/// recurso da v1 é bloqueado por falta de internet.
///
/// É um **chip** da §5.6, e não texto solto, por causa da §8 regra 2: texto
/// pequeno sobre `colorPrimary` não tem contraste. Sobre
/// `colorPrimaryContainer` são 12,79:1.
///
/// O ponto também mudou: era `colorPrimary` sobre um fundo que virou
/// `colorPrimary` no redesenho — ou seja, invisível justamente no estado
/// "online". Agora usa `colorSuccess`, que a §6 lista como uma das três
/// exceções cromáticas legítimas.
class ConnectionBadge extends StatelessWidget {
  const ConnectionBadge({super.key, required this.isOnline});

  final bool isOnline;

  @override
  Widget build(BuildContext context) {
    final t = AppStrings.of(context);
    final scheme = Theme.of(context).colorScheme;
    final label = isOnline ? t.online : t.offline;

    return Semantics(
      label: '${t.appName}: $label',
      child: Padding(
        padding: const EdgeInsets.only(right: AppSpacing.md),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.xs,
          ),
          decoration: BoxDecoration(
            color: scheme.primaryContainer,
            borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: isOnline
                      ? AppSemanticColors.success_(context)
                      : scheme.onSurfaceVariant,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                label,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: scheme.onPrimaryContainer,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
