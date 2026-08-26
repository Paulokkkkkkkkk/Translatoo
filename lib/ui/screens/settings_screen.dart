import 'package:flutter/material.dart';

import '../../core/constants/app_strings.dart';
import '../widgets/placeholder_panel.dart';

/// Tela Ajustes — placeholder da fundação. Preferências completas na F3.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppStrings.of(context);
    return PlaceholderPanel(
      icon: Icons.settings,
      title: t.tabSettings,
      message: t.settingsPlaceholderBody,
    );
  }
}
