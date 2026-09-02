import 'package:flutter/material.dart';

import '../../core/constants/app_spacing.dart';

/// Skeleton "shimmer" reutilizável (F1.7): placeholder animado exibido no
/// cartão destino enquanto `translating`. Cores SOMENTE do tema vigente —
/// nenhuma constante cromática aqui (RN-04).
class ShimmerBox extends StatefulWidget {
  const ShimmerBox({
    super.key,
    this.height = 16,
    this.borderRadius,
    this.lines = 1,
    this.spacing = AppSpacing.sm,
  });

  final double height;
  final BorderRadius? borderRadius;
  final int lines;
  final double spacing;

  @override
  State<ShimmerBox> createState() => _ShimmerBoxState();
}

class _ShimmerBoxState extends State<ShimmerBox>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final radius =
        widget.borderRadius ?? BorderRadius.circular(AppSpacing.radiusSm);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final dx = _controller.value * 2 - 1; // -1 … 1
        final gradient = LinearGradient(
          begin: Alignment(-2 + dx, 0),
          end: Alignment(dx, 0),
          colors: <Color>[
            scheme.surfaceContainerHighest,
            scheme.primaryContainer,
            scheme.surfaceContainerHighest,
          ],
        );
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var i = 0; i < widget.lines; i++) ...[
              if (i > 0) SizedBox(height: widget.spacing),
              Container(
                height: widget.height,
                decoration: BoxDecoration(
                  borderRadius: radius,
                  gradient: gradient,
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}
