import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_spacing.dart';
import '../../core/constants/app_strings.dart';
import '../../state/speech_view_model.dart';
import 'waveform.dart';

/// Folha de escuta (F2.5 · `docs/design_system.md` §5.9).
///
/// Abre com [show] e se fecha SOZINHA quando o [SpeechViewModel] sai da
/// escuta — quem manda na vida da folha é a máquina de estados, não o widget.
/// Assim o auto-stop de 60 s e a pausa de 1,5 s fecham a folha sem que a UI
/// precise saber que existem (AC-M2-1 e AC-M2-3).
///
/// A onda usa **nível real** de microfone (F2.2b): quando a fonte não sabe
/// medir, `hasAudioLevel` fica falso e nada é desenhado — a §5.7 proíbe suprir
/// a falta com movimento aleatório.
class ListeningSheet extends StatelessWidget {
  const ListeningSheet._();

  /// Exibe a folha. Fechar por gesto ou `back` equivale a **Concluir**, não a
  /// Cancelar: a RN-07 prefere preservar a fala a descartá-la.
  static Future<void> show(BuildContext context) {
    final speech = context.read<SpeechViewModel>();
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      barrierColor: Theme.of(context).colorScheme.scrim,
      builder: (_) => ChangeNotifierProvider<SpeechViewModel>.value(
        value: speech,
        child: const ListeningSheet._(),
      ),
    ).whenComplete(() {
      if (speech.state == SpeechState.listening) speech.stop();
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = AppStrings.of(context);
    final theme = Theme.of(context);

    return Consumer<SpeechViewModel>(
      builder: (context, vm, _) {
        // A máquina de estados fecha a folha: idle/error significa que a
        // escuta acabou por pausa, teto de 60 s, conclusão ou falha.
        if (vm.state == SpeechState.idle || vm.state == SpeechState.error) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (Navigator.of(context).canPop()) Navigator.of(context).pop();
          });
        }

        final listening = vm.state == SpeechState.listening;

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _Header(listening: listening, elapsed: vm.elapsedSeconds),
                const SizedBox(height: AppSpacing.md),
                if (vm.hasAudioLevel)
                  Waveform(levels: vm.waveformLevels)
                else
                  const WaveformPlaceholder(),
                const SizedBox(height: AppSpacing.md),
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.sizeOf(context).height * 0.3,
                  ),
                  child: SingleChildScrollView(
                    reverse: true, // acompanha o texto que cresce
                    child: Text(
                      vm.partialText.isEmpty ? t.dictationHint : vm.partialText,
                      // Parcial é sempre itálico e secundário (§5.1): sinaliza
                      // que o texto ainda vai ser reescrito.
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: listening ? () => vm.cancel() : null,
                        child: Text(t.actionCancel),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: FilledButton(
                        onPressed: listening
                            ? () {
                                HapticFeedback.selectionClick();
                                vm.stop();
                              }
                            : null,
                        child: Text(t.actionFinishDictation),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Ponto de gravação + rótulo à esquerda, cronômetro mm:ss à direita.
class _Header extends StatelessWidget {
  const _Header({required this.listening, required this.elapsed});

  final bool listening;
  final int elapsed;

  static String _format(int seconds) {
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    return '$minutes:${(seconds % 60).toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final t = AppStrings.of(context);
    final theme = Theme.of(context);

    return Row(
      children: [
        // Ponto de gravação — uma das três exceções cromáticas da §6.
        AnimatedOpacity(
          opacity: listening ? 1 : 0.3,
          duration: const Duration(milliseconds: 200),
          child: Container(
            width: AppSpacing.sm,
            height: AppSpacing.sm,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: theme.colorScheme.error,
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Text(t.dictationListening, style: theme.textTheme.titleMedium),
        const Spacer(),
        Text(_format(elapsed), style: theme.textTheme.titleMedium),
      ],
    );
  }
}
