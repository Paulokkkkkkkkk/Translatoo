import 'package:flutter/material.dart';

import '../../core/constants/app_spacing.dart';
import '../../core/constants/app_strings.dart';

/// Modo de tradução da v1 (§9.1). Enum FECHADO: o terceiro modo do roadmap
/// entra aqui e quebra os `switch` que precisarem mudar, em vez de cair num
/// `default` silencioso.
enum TranslateMode {
  /// Digitação — o padrão.
  text,

  /// Ditado: o bloco de marca cresce e recebe a onda (§4).
  voice,
}

/// Botão de modo (§5.3 · §P4).
///
/// Squircle de 64 dp, plano 3, ancorado no canto superior direito e posicionado
/// para **transbordar** o limite entre o bloco de marca e o painel. É o único
/// elemento que quebra a grade — e por isso é o que o olho encontra primeiro.
///
/// **Alterna direto, sem overlay.** A §9.2 é explícita: com 2 modos, um overlay
/// de tela cheia para escolher entre duas coisas é cerimônia sem conteúdo. O
/// grid da §5.4 já está especificado para quando o terceiro modo chegar; até lá
/// este botão é o seletor inteiro.
class ModeButton extends StatelessWidget {
  const ModeButton({required this.mode, required this.onToggle, super.key});

  final TranslateMode mode;
  final VoidCallback onToggle;

  /// §5.3: lado de 64 dp. Abaixo de 96 dp o raio grande deforma o quadrado em
  /// círculo, então a §2 manda usar `radiusMd` — e não `radiusLg`.
  static const double size = 64;

  @override
  Widget build(BuildContext context) {
    final t = AppStrings.of(context);
    final colors = Theme.of(context).colorScheme;

    final (IconData icon, String label) = switch (mode) {
      // O ícone mostra o modo ATIVO, não o destino do toque — é o que o case
      // faz, e o que deixa o estado legível sem rótulo.
      TranslateMode.text => (Icons.text_fields, t.modeText),
      TranslateMode.voice => (Icons.graphic_eq, t.modeVoice),
    };

    return Semantics(
      button: true,
      label: label,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          // Plano 3 (§3): y+4, blur 20, ~12% preto.
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: colors.shadow.withValues(alpha: 0.12),
              offset: const Offset(0, 4),
              blurRadius: 20,
            ),
          ],
        ),
        child: Material(
          color: colors.surface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onToggle,
            child: SizedBox.square(
              dimension: size,
              child: AnimatedSwitcher(
                // §7: 200 ms, `easeInOut`. O ícone faz cross-fade; o botão não
                // se move nem muda de forma.
                duration: const Duration(milliseconds: 200),
                switchInCurve: Curves.easeInOut,
                switchOutCurve: Curves.easeInOut,
                child: Icon(
                  icon,
                  key: ValueKey<TranslateMode>(mode),
                  size: 28,
                  color: colors.primary,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
