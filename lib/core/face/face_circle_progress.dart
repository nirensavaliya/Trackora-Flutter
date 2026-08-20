import 'dart:math' as math;

import 'package:flutter/material.dart';

class FaceCircleProgressPainter extends CustomPainter {
  FaceCircleProgressPainter({
    required this.segmentCount,
    required this.completed,
    this.activeColor = const Color(0xFF1E5D57),
    this.trackColor = const Color(0xFFD9E3E1),
    this.ringStroke = 8,
    this.gapFactor = 0.15,
  });

  final int segmentCount;
  final Set<int> completed;
  final Color activeColor;
  final Color trackColor;
  final double ringStroke;
  final double gapFactor;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - ringStroke;

    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = trackColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = ringStroke,
    );

    final sweep = (2 * math.pi / segmentCount) * (1 - gapFactor);
    final segmentPaint = Paint()
      ..color = activeColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = ringStroke
      ..strokeCap = StrokeCap.round;

    for (final i in completed) {
      final start = -math.pi / 2 + (2 * math.pi * i / segmentCount);
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        start + (math.pi / segmentCount) * gapFactor,
        sweep,
        false,
        segmentPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant FaceCircleProgressPainter oldDelegate) {
    return oldDelegate.segmentCount != segmentCount ||
        oldDelegate.completed.length != completed.length ||
        !_sameSegments(oldDelegate.completed, completed);
  }

  bool _sameSegments(Set<int> a, Set<int> b) {
    if (a.length != b.length) return false;
    for (final v in a) {
      if (!b.contains(v)) return false;
    }
    return true;
  }
}
