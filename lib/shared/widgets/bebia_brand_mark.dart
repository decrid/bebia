import 'package:flutter/material.dart';

class BebiaBrandMark extends StatelessWidget {
  const BebiaBrandMark({
    super.key,
    this.size = 48,
    this.backgroundColor,
    this.foregroundColor,
    this.showBackground = true,
  });

  final double size;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final bool showBackground;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final mark = CustomPaint(
      size: Size.square(size),
      painter: _BebiaMarkPainter(
        foreground: foregroundColor ?? scheme.onPrimary,
        accent: const Color(0xFFF09A82),
      ),
    );
    return Semantics(
      label: 'Bebia',
      image: true,
      child: ExcludeSemantics(
        child: showBackground
            ? DecoratedBox(
                decoration: BoxDecoration(
                  color: backgroundColor ?? scheme.primary,
                  borderRadius: BorderRadius.circular(size * .3),
                ),
                child: mark,
              )
            : mark,
      ),
    );
  }
}

class _BebiaMarkPainter extends CustomPainter {
  const _BebiaMarkPainter({required this.foreground, required this.accent});

  final Color foreground;
  final Color accent;

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.shortestSide / 108;
    final line = Paint()
      ..color = foreground
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8 * scale
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final embrace = Path()
      ..moveTo(37 * scale, 24 * scale)
      ..lineTo(37 * scale, 84 * scale)
      ..moveTo(38 * scale, 31 * scale)
      ..cubicTo(
        64 * scale,
        21 * scale,
        78 * scale,
        31 * scale,
        76 * scale,
        45 * scale,
      )
      ..cubicTo(
        75 * scale,
        54 * scale,
        65 * scale,
        58 * scale,
        42 * scale,
        56 * scale,
      )
      ..moveTo(42 * scale, 56 * scale)
      ..cubicTo(
        72 * scale,
        53 * scale,
        82 * scale,
        65 * scale,
        76 * scale,
        78 * scale,
      )
      ..cubicTo(
        70 * scale,
        91 * scale,
        50 * scale,
        88 * scale,
        38 * scale,
        80 * scale,
      );
    canvas.drawPath(embrace, line);

    canvas.drawCircle(
      Offset(59 * scale, 69 * scale),
      5.5 * scale,
      Paint()..color = accent,
    );
  }

  @override
  bool shouldRepaint(covariant _BebiaMarkPainter oldDelegate) {
    return foreground != oldDelegate.foreground || accent != oldDelegate.accent;
  }
}
