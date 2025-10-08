import 'package:flutter/material.dart';
import 'dart:math';

// A simple custom painter background with gradient and floating stars / moon
class SpookyBackground extends StatelessWidget {
  const SpookyBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _SpookyPainter(), child: Container());
  }
}

class _SpookyPainter extends CustomPainter {
  final Random _r = Random(42);
  @override
  void paint(Canvas canvas, Size size) {
    // gradient sky
    final Rect r = Offset.zero & size;
    final Gradient g = LinearGradient(
      colors: [Colors.deepPurple.shade900, Colors.black87],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    );
    canvas.drawRect(r, Paint()..shader = g.createShader(r));

    // moon
    final moonCenter = Offset(size.width * 0.85, size.height * 0.18);
    canvas.drawCircle(
      moonCenter,
      40,
      Paint()..color = Colors.yellow.shade700.withOpacity(0.9),
    );

    // distant stars
    for (int i = 0; i < 40; i++) {
      final dx = _r.nextDouble() * size.width;
      final dy = _r.nextDouble() * size.height * 0.45;
      final rad = _r.nextDouble() * 1.8 + 0.3;
      canvas.drawCircle(
        Offset(dx, dy),
        rad,
        Paint()..color = Colors.white.withOpacity(0.6),
      );
    }
    // ground silhouette
    final path = Path();
    path.moveTo(0, size.height * 0.85);
    path.quadraticBezierTo(
      size.width * 0.25,
      size.height * 0.75,
      size.width * 0.5,
      size.height * 0.82,
    );
    path.quadraticBezierTo(
      size.width * 0.7,
      size.height * 0.89,
      size.width,
      size.height * 0.82,
    );
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    canvas.drawPath(path, Paint()..color = Colors.black);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
