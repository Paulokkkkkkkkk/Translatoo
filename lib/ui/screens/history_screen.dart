import 'package:flutter/material.dart';

import '../../core/constants/app_strings.dart';
import '../widgets/placeholder_panel.dart';

/// Tela Histórico — placeholder da fundação. M4 (histório/favoritos) na F3.
class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppStrings.of(context);
    return PlaceholderPanel(
      icon: Icons.history,
      title: t.tabHistory,
      message: t.historyPlaceholderBody,
    );
  }
}
