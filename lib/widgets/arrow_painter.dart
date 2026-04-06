import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Paints morphism arrows between nodes with neon glow.
class ArrowPainter extends CustomPainter {
  final List<ArrowData> arrows;
  final ArrowData? dragging;
  final double glowPhase; // 0-1, for pulsing animation

  ArrowPainter({
    required this.arrows,
    this.dragging,
    this.glowPhase = 0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final arrow in arrows) {
      _drawArrow(canvas, arrow, arrow.isNew ? 1.0 : 0.7);
    }
    if (dragging != null) {
      _drawArrow(canvas, dragging!, 0.4);
    }
  }

  void _drawArrow(Canvas canvas, ArrowData arrow, double intensity) {
    final color = arrow.color;

    if (arrow.isIdentity) {
      _drawLoopArrow(canvas, arrow, color, intensity);
      return;
    }

    final from = arrow.from;
    final to = arrow.to;
    final delta = to - from;
    final distance = delta.distance;
    if (distance < 1) return;

    final dir = delta / distance;
    // Offset from center of nodes
    final nodeRadius = 32.0;
    final start = from + dir * nodeRadius;
    final end = to - dir * (nodeRadius + 12); // room for arrowhead

    // Glow layer
    final glowPaint = Paint()
      ..color = color.withValues(alpha: 0.15 * intensity)
      ..strokeWidth = 8
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    canvas.drawLine(start, end, glowPaint);

    // Main line
    final linePaint = Paint()
      ..color = color.withValues(alpha: intensity)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(start, end, linePaint);

    // Arrowhead
    final angle = math.atan2(delta.dy, delta.dx);
    final headLength = 14.0;
    final headAngle = 0.45;
    final path = Path()
      ..moveTo(end.dx, end.dy)
      ..lineTo(
        end.dx - headLength * math.cos(angle - headAngle),
        end.dy - headLength * math.sin(angle - headAngle),
      )
      ..moveTo(end.dx, end.dy)
      ..lineTo(
        end.dx - headLength * math.cos(angle + headAngle),
        end.dy - headLength * math.sin(angle + headAngle),
      );
    final headPaint = Paint()
      ..color = color.withValues(alpha: intensity)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(path, headPaint);

    // Flow particles along the arrow (animated glow)
    if (arrow.isNew && glowPhase > 0) {
      final t = glowPhase;
      final particlePos = Offset.lerp(start, end, t)!;
      final particlePaint = Paint()
        ..color = color.withValues(alpha: 0.8)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
      canvas.drawCircle(particlePos, 4, particlePaint);
    }
  }

  void _drawLoopArrow(
      Canvas canvas, ArrowData arrow, Color color, double intensity) {
    final center = arrow.from;
    final loopRadius = 28.0;
    final loopCenter = center + const Offset(0, -44);

    final rect = Rect.fromCircle(center: loopCenter, radius: loopRadius);

    // Glow
    final glowPaint = Paint()
      ..color = color.withValues(alpha: 0.15 * intensity)
      ..strokeWidth = 8
      ..style = PaintingStyle.stroke
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    canvas.drawArc(rect, 0.3, 5.0, false, glowPaint);

    // Main arc
    final arcPaint = Paint()
      ..color = color.withValues(alpha: intensity)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(rect, 0.3, 5.0, false, arcPaint);

    // Arrowhead at the end of the arc
    final endAngle = 0.3 + 5.0;
    final endX = loopCenter.dx + loopRadius * math.cos(endAngle);
    final endY = loopCenter.dy + loopRadius * math.sin(endAngle);
    final tangentAngle = endAngle + math.pi / 2;
    final headLength = 12.0;
    final headAngle = 0.45;

    final headPath = Path()
      ..moveTo(endX, endY)
      ..lineTo(
        endX - headLength * math.cos(tangentAngle - headAngle),
        endY - headLength * math.sin(tangentAngle - headAngle),
      )
      ..moveTo(endX, endY)
      ..lineTo(
        endX - headLength * math.cos(tangentAngle + headAngle),
        endY - headLength * math.sin(tangentAngle + headAngle),
      );
    canvas.drawPath(headPath, arcPaint);
  }

  @override
  bool shouldRepaint(ArrowPainter oldDelegate) =>
      arrows != oldDelegate.arrows ||
      dragging != oldDelegate.dragging ||
      glowPhase != oldDelegate.glowPhase;
}

class ArrowData {
  final Offset from;
  final Offset to;
  final Color color;
  final bool isNew;
  final bool isIdentity;

  const ArrowData({
    required this.from,
    required this.to,
    required this.color,
    this.isNew = false,
    this.isIdentity = false,
  });
}
