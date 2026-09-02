import 'package:flutter/material.dart';

import '../../core/constants/app_spacing.dart';
import '../../core/constants/app_strings.dart';

/// Mini-player da leitura em voz alta (F2.8 · M3) — barra discreta exibida
/// ENQUANTO a síntese está em curso (quem decide a visibilidade é a shell, a
/// partir do `TtsViewModel`).
///
/// Anatomia (§ nova deste doc): ícone animado (pulso sutil, 60 fps) + trecho
/// falado com rolagem horizontal + ⏹. O texto longo NUNCA é cortado por
/// ellipsis: o usuário pode ler a frase inteira rolando — ela é o conteúdo que
/// está sendo falado.
///
/// Estados:
/// | Estado | Ícone | Ação |
/// |---|---|---|
/// | reproduzindo | equalizador pulsando (`colorPrimary`) | ⏹ interrompe |
///
/// A barra some quando a fala termina (ou o usuário para) — não há estado
/// "pausado" na v1 (o motor nativo não expõe resume confiável entre SOs).
class MiniPlayerTts extends StatefulWidget {
  const MiniPlayerTts({required this.text, required this.onStop, super.key});

  /// Trecho sendo falado (o texto da tradução).
  final String text;

  /// ⏹ — interrompe a reprodução (chama `TtsViewModel.stop`).
  final VoidCallback onStop;

  @override
  State<MiniPlayerTts> createState() => _MiniPlayerTtsState();
}

class _MiniPlayerTtsState extends State<MiniPlayerTts>
    with SingleTickerProviderStateMixin {
  /// Pulso sutil do equalizador — único controller da barra (meta 60 fps).
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 700),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppStrings.of(context);
    final theme = Theme.of(context);

    return Semantics(
      container: true,
      label: t.actionListen,
      child: Container(
        // Plano 2 (§3): mesma sombra difusa dos painéis, para descolar a barra
        // do conteúdo — a superfície clara sobre o fundo já separa.
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: theme.colorScheme.shadow.withValues(alpha: 0.06),
              offset: const Offset(0, -2),
              blurRadius: 16,
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          child: Row(
            children: [
              // Equalizador pulsando (ícone linear herdando a cor do contexto;
              // §6: `colorPrimary` porque a barra vive sobre `colorSurface`).
              ScaleTransition(
                scale: Tween<double>(begin: 1.0, end: 1.15).animate(
                  CurvedAnimation(parent: _pulse, curve: Curves.easeInOut),
                ),
                child: Icon(
                  Icons.graphic_eq,
                  size: 20,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Text(widget.text, style: theme.textTheme.bodyMedium),
                ),
              ),
              IconButton(
                tooltip: t.actionStopPlayback,
                onPressed: widget.onStop,
                icon: const Icon(Icons.stop),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
