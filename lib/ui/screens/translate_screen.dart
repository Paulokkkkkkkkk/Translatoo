import 'package:flutter/material.dart';

import '../../core/constants/app_strings.dart';
import '../widgets/placeholder_panel.dart';

/// Tela Traduzir — placeholder da fundação. O motor M1 entra na Fase 1.
class TranslateScreen extends StatelessWidget {
  const TranslateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppStrings.of(context);
    return PlaceholderPanel(
      icon: Icons.translate,
      title: t.tabTranslate,
      message: t.translatePlaceholderBody,
    );
  }
}
