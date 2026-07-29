// lib/widgets/semence_logo.dart
import 'package:flutter/material.dart';

class SemenceLogo extends StatelessWidget {
  final double size;

  const SemenceLogo({super.key, this.size = 84});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _SemenceLogoPainter(),
      ),
    );
  }
}

class _SemenceLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final center = Offset(w / 2, h / 2);
    final radius = w / 2;

    final circlePaint = Paint()..color = const Color(0xFF2E7D32);
    canvas.drawCircle(center, radius, circlePaint);

    final borderPaint = Paint()
      ..color = const Color(0xFFF4F7F5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.025;
    canvas.drawCircle(center, radius - (w * 0.0125), borderPaint);

    final leafPaint = Paint()..color = const Color(0xFFF4F7F5);
    final leafPath = Path();
    leafPath.moveTo(w * 0.5, h * 0.325);
    leafPath.cubicTo(
      w * 0.54, h * 0.383,
      w * 0.556, h * 0.492,
      w * 0.5, h * 0.7,
    );
    leafPath.cubicTo(
      w * 0.444, h * 0.492,
      w * 0.46, h * 0.383,
      w * 0.5, h * 0.325,
    );
    leafPath.close();
    canvas.drawPath(leafPath, leafPaint);

    final veinPaint = Paint()
      ..color = const Color(0xFF2E7D32)
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.01
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(
      Offset(w * 0.5, h * 0.375),
      Offset(w * 0.5, h * 0.675),
      veinPaint,
    );

    final vein1 = Path()
      ..moveTo(w * 0.5, h * 0.45)
      ..cubicTo(w * 0.513, h * 0.467, w * 0.522, h * 0.483, w * 0.528, h * 0.5);
    canvas.drawPath(vein1, veinPaint..strokeWidth = w * 0.007);

    final vein2 = Path()
      ..moveTo(w * 0.5, h * 0.5)
      ..cubicTo(w * 0.487, h * 0.517, w * 0.478, h * 0.533, w * 0.472, h * 0.55);
    canvas.drawPath(vein2, veinPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}