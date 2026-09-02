import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_spacing.dart';
import '../../core/constants/app_strings.dart';
import '../../state/speech_view_model.dart';

/// Botão de ditado (F2.5 · `docs/design_system.md` §5.8).
///
/// Um `AnimationController` ÚNICO alimenta o anel pulsante — o mesmo que a
/// folha de escuta usa no seu ponto de gravação. Dois controllers rodando a
/// mesma animação é o caminho mais curto para perder os 60 fps da meta.
///
/// Quando o build não tem modelo de STT, este widget NÃO ENTRA NA ÁRVORE —
/// ver [SpeechViewModel.canDictate] e a regra da F2.1b. Quem decide é
/// [MicButton.maybe].
class MicButton extends StatefulWidget {
  const MicButton({required this.onPressed, super.key});

  /// Disparado no toque, já resolvido o estado atual pelo chamador.
  final VoidCallback onPressed;

  /// Devolve o botão apenas quando este build sabe ditar; caso contrário
  /// `null`, para o chamador simplesmente não incluí-lo no `children`.
  static Widget? maybe(
    BuildContext context, {
    required VoidCallback onPressed,
  }) {
    if (!context.read<SpeechViewModel>().canDictate) return null;
    return MicButton(onPressed: onPressed);
  }

  @override
  State<MicButton> createState() => _MicButtonState();
}

class _MicButtonState extends State<MicButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  );

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  /// O pulso só roda enquanto escuta: animação parada é frame não gasto.
  void _syncPulse(SpeechState state) {
    final shouldPulse = state == SpeechState.listening;
    if (shouldPulse && !_pulse.isAnimating) {
      _pulse.repeat();
    } else if (!shouldPulse && _pulse.isAnimating) {
      _pulse
        ..stop()
        ..reset();
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppStrings.of(context);
    final colors = Theme.of(context).colorScheme;

    return Selector<SpeechViewModel, SpeechState>(
      selector: (_, vm) => vm.state,
      builder: (context, state, _) {
        _syncPulse(state);

        final (IconData icon, Color color, String label) = switch (state) {
          SpeechState.idle => (
            Icons.mic_none_outlined,
            colors.primary,
            t.actionDictate,
          ),
          SpeechState.initializing => (
            Icons.mic_none_outlined,
            colors.onSurfaceVariant,
            t.actionDictate,
          ),
          SpeechState.listening || SpeechState.processing => (
            Icons.mic,
            colors.error,
            t.actionStopDictation,
          ),
          SpeechState.error => (
            Icons.mic_off_outlined,
            colors.error,
            t.errMicPermission,
          ),
        };

        return Semantics(
          button: true,
          label: label,
          child: SizedBox(
            width: AppSpacing.minTouchTarget,
            height: AppSpacing.minTouchTarget,
            child: Stack(
              alignment: Alignment.center,
              children: [
                if (state == SpeechState.listening)
                  _PulseRing(animation: _pulse, color: colors.error),
                IconButton(
                  tooltip: label,
                  // `initializing` é o único estado inerte: tocar durante a
                  // carga do modelo não teria efeito nenhum.
                  onPressed: state == SpeechState.initializing
                      ? null
                      : () {
                          HapticFeedback.selectionClick();
                          widget.onPressed();
                        },
                  icon: Icon(icon, color: color),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Anel que respira em torno do ícone durante a escuta (§5.8).
class _PulseRing extends StatelessWidget {
  const _PulseRing({required this.animation, required this.color});

  final Animation<double> animation;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: animation,
        builder: (context, _) {
          // Cresce e some ao mesmo tempo: o anel "sai" do ícone.
          final progress = animation.value;
          return Opacity(
            opacity: (1 - progress) * 0.24,
            child: Container(
              width: AppSpacing.lg + progress * AppSpacing.lg,
              height: AppSpacing.lg + progress * AppSpacing.lg,
              decoration: BoxDecoration(shape: BoxShape.circle, color: color),
            ),
          );
        },
      ),
    );
  }
}
