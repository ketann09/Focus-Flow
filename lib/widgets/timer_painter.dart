import 'dart:math';
import 'package:flutter/material.dart';

class TimerPainter extends CustomPainter {
  final double progress; 
  final Color foregroundColor;
  final Color backgroundColor;

  TimerPainter({
    required this.progress,
    required this.foregroundColor,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final strokeWidth = 12.0;

    // Background arc
    final backgroundPaint = Paint()
      ..color = backgroundColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    canvas.drawCircle(center, radius, backgroundPaint);

    // Foreground arc (progress)
    final foregroundPaint = Paint()
      ..color = foregroundColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // We use -pi/2 to start at the top (12 o'clock)
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      progress * 2 * pi, // The angle of the arc
      false,
      foregroundPaint,
    );
  }

  @override
  bool shouldRepaint(covariant TimerPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}