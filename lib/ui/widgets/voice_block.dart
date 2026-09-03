import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_spacing.dart';
import '../../core/constants/app_strings.dart';
import '../../state/speech_view_model.dart';
import 'waveform.dart';

/// Bloco de marca expandido do modo voz (§4 · §5.7 · plano 1 da §3).
///
/// Ocupa ~40% da altura útil — proporção MEDIDA na prancha de voz do case, não
/// estimada. No modo texto o bloco de marca é só a barra superior (12–15%);
/// aqui ele cresce para caber a onda, o cronômetro e a pílula de estado.
///
/// Continua visualmente a `AppBar`: mesma superfície `colorPrimary`, sem
/// separador. As duas lidas juntas são o bloco de marca da §4.
///
/// SUBSTITUI a folha de escuta da F2.5. A decisão está registrada na
/// [#58](../../issues/58): o case não tem sheet, e manter as duas dobraria a
/// superfície de teste do M2 sem ganho para o usuário.
class VoiceBlock extends StatelessWidget {
  const VoiceBlock({required this.height, super.key});

  /// Altura já resolvida pelo chamador (~40% da altura útil, §4).
  final double height;

  static String _mmss(int seconds) {
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    return '$minutes:${(seconds % 60).toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final t = AppStrings.of(context);
    final theme = Theme.of(context);
    final onBrand = theme.colorScheme.onPrimary;

    return Container(
      height: height,
      width: double.infinity,
      color: theme.colorScheme.primary,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Consumer<SpeechViewModel>(
        builder: (context, vm, _) {
          final listening = vm.state == SpeechState.listening;

          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Center(
                  // §5.7: sobre o bloco de marca as barras são `colorOnPrimary`
                  // — na folha da F2.5 eram `colorPrimary` porque a superfície
                  // era clara. A geometria não muda.
                  child: vm.hasAudioLevel
                      ? Waveform(
                          levels: vm.waveformLevels,
                          color: onBrand,
                          height: height * 0.4,
                        )
                      : _IdleHint(label: t.dictationHint, color: onBrand),
                ),
              ),
              // §5.7: abaixo da onda, tempo decorrido + pílula de estado com o
              // ponto de gravação em `colorError`.
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.lg),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _mmss(vm.elapsedSeconds),
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: onBrand,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    _StatePill(listening: listening),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Sem nível de microfone não há onda (§5.7) — mas o bloco não pode ficar vazio.
/// Uma linha de instrução é honesta: diz o que fazer sem fingir atividade.
class _IdleHint extends StatelessWidget {
  const _IdleHint({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) => Text(
    label,
    textAlign: TextAlign.center,
    style: Theme.of(
      context,
    ).textTheme.bodyMedium?.copyWith(color: color.withValues(alpha: 0.8)),
  );
}

/// Pílula "falar agora / ouvindo" com o ponto de gravação (§5.7 · §5.6).
///
/// É o controle que inicia e encerra a escuta. Fica na superfície clara sobre o
/// bloco de marca — texto pequeno direto sobre `colorPrimary` não passaria em
/// contraste (§8 regra 2).
class _StatePill extends StatelessWidget {
  const _StatePill({required this.listening});

  final bool listening;

  @override
  Widget build(BuildContext context) {
    final t = AppStrings.of(context);
    final theme = Theme.of(context);
    final vm = context.read<SpeechViewModel>();

    return Semantics(
      button: true,
      label: listening ? t.actionStopDictation : t.actionSpeakNow,
      child: Material(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
          onTap: () => listening ? vm.stop() : _start(context, vm),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  listening ? t.dictationListening : t.actionSpeakNow,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                // Ponto de gravação — uma das três exceções cromáticas da §6.
                AnimatedOpacity(
                  opacity: listening ? 1 : 0.35,
                  duration: const Duration(milliseconds: 200),
                  child: Container(
                    width: AppSpacing.sm + AppSpacing.xs,
                    height: AppSpacing.sm + AppSpacing.xs,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: theme.colorScheme.error,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _start(BuildContext context, SpeechViewModel vm) {
    HapticFeedback.selectionClick();
    vm.start();
  }
}
