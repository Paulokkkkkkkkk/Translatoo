import 'package:flutter/material.dart';

import '../../core/constants/app_spacing.dart';

/// Onda do ditado (§5.7 do design system), alimentada por nível REAL de
/// microfone.
///
/// Geometria da §5.7: barras de 2 dp com gap de 2 dp, altura proporcional à
/// amplitude, ancoradas no centro vertical. A cor muda com a superfície — sobre
/// o bloco de marca seria `colorOnPrimary`; na folha de escuta, que é
/// `colorSurface`, é `colorPrimary`.
///
/// NÃO anima sozinha: cada quadro vem de [levels], que é histórico de amplitude
/// medida. Sem nível, o chamador não deve montar este widget — onda falsa em app
/// de ditado é mentira de interface (§5.7).
class Waveform extends StatelessWidget {
  const Waveform({required this.levels, this.height = 40, super.key});

  /// Níveis normalizados em 0..1, do mais antigo ao mais recente.
  final List<double> levels;

  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: CustomPaint(
        painter: _WaveformPainter(
          levels: levels,
          color: Theme.of(context).colorScheme.primary,
        ),
        // A onda é decorativa: o estado de escuta já é anunciado pelo rótulo e
        // pelo cronômetro da folha. Duplicar isso só polui o leitor de tela.
        isComplex: false,
      ),
    );
  }
}

class _WaveformPainter extends CustomPainter {
  const _WaveformPainter({required this.levels, required this.color});

  final List<double> levels;
  final Color color;

  /// §5.7: barra de 2 dp, gap de 2 dp.
  static const double _barWidth = 2;
  static const double _gap = 2;

  @override
  void paint(Canvas canvas, Size size) {
    if (levels.isEmpty) return;

    final paint = Paint()
      ..color = color
      ..strokeWidth = _barWidth
      ..strokeCap = StrokeCap.round;

    final step = _barWidth + _gap;
    final totalWidth = levels.length * step - _gap;
    // Centraliza o bloco de barras em vez de esticá-lo: a onda mantém a mesma
    // densidade em qualquer largura de tela.
    final startX = (size.width - totalWidth) / 2 + _barWidth / 2;
    final centerY = size.height / 2;

    for (var i = 0; i < levels.length; i++) {
      // Altura mínima de 2 dp: silêncio vira uma linha de pontos, não um vazio
      // — o usuário vê que o app continua ouvindo.
      final amplitude = (levels[i].clamp(0.0, 1.0) * size.height).clamp(
        _barWidth,
        size.height,
      );
      final x = startX + i * step;
      canvas.drawLine(
        Offset(x, centerY - amplitude / 2),
        Offset(x, centerY + amplitude / 2),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_WaveformPainter old) =>
      old.color != color || !_sameLevels(old.levels, levels);

  bool _sameLevels(List<double> a, List<double> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}

/// Espaço reservado para a onda, usado quando a fonte de áudio não mede nível.
///
/// Existe para a folha não "pular" de altura entre um build com onda e outro
/// sem: o indicador de escuta neutro da §5.7 ocupa o mesmo lugar.
class WaveformPlaceholder extends StatelessWidget {
  const WaveformPlaceholder({this.height = 40, super.key});

  final double height;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: height,
    child: Center(
      child: Container(
        height: AppSpacing.xs,
        width: AppSpacing.xl,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppSpacing.xs),
          color: Theme.of(context).colorScheme.outlineVariant,
        ),
      ),
    ),
  );
}
