import 'package:flutter/material.dart';

import '../../core/constants/app_spacing.dart';
import '../../core/constants/app_strings.dart';

/// Badge 🟢/⚪ no AppBar (RF-M4-07). Puramente informativo: nenhum recurso
/// da v1 é bloqueado por falta de internet.
class ConnectionBadge extends StatelessWidget {
  const ConnectionBadge({super.key, required this.isOnline});

  final bool isOnline;

  @override
  Widget build(BuildContext context) {
    final t = AppStrings.of(context);
    final scheme = Theme.of(context).colorScheme;
    final color = isOnline ? scheme.primary : scheme.outline;
    final label = isOnline ? t.online : t.offline;

    return Semantics(
      label: '${t.appName}: $label',
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: AppSpacing.xs),
            Text(label, style: Theme.of(context).textTheme.labelMedium),
          ],
        ),
      ),
    );
  }
}
