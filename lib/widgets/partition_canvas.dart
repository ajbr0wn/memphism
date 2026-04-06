import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/partition.dart';
import '../theme/haptics.dart';
import '../theme/palette.dart';

/// Interactive canvas for creating partitions.
/// Two interaction modes:
/// - Tap: cycle element group color (quick assignment)
/// - Lasso: draw a circle around dots to group them (tactile grouping)
class PartitionCanvas extends StatefulWidget {
  final List<SetElement> elements;
  final void Function(String elementId) onTapElement;
  final void Function(Set<String> elementIds) onLassoGroup;
  final bool showGroups;
  final double pulsePhase; // 0-1 for membrane animation

  const PartitionCanvas({
    super.key,
    required this.elements,
    required this.onTapElement,
    required this.onLassoGroup,
    this.showGroups = true,
    this.pulsePhase = 0,
  });

  @override
  State<PartitionCanvas> createState() => _PartitionCanvasState();
}

class _PartitionCanvasState extends State<PartitionCanvas> {
  List<Offset> _lassoPath = [];
  bool _isDrawingLasso = false;
  Set<String> _lassoHighlighted = {};

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = constraints.biggest;

        return GestureDetector(
          onPanStart: (details) {
            // Check if starting on a dot — if so, this is a tap, not lasso
            final nearDot = _findElementAt(details.localPosition, size);
            if (nearDot != null) return; // let tap handle it

            setState(() {
              _isDrawingLasso = true;
              _lassoPath = [details.localPosition];
              _lassoHighlighted = {};
            });
          },
          onPanUpdate: (details) {
            if (!_isDrawingLasso) return;
            setState(() {
              _lassoPath.add(details.localPosition);
              // Update highlighted elements
              _lassoHighlighted = _elementsInsideLasso(size);
            });
          },
          onPanEnd: (_) {
            if (!_isDrawingLasso) return;
            final inside = _elementsInsideLasso(size);
            setState(() {
              _isDrawingLasso = false;
              _lassoPath = [];
              _lassoHighlighted = {};
            });
            if (inside.length >= 2) {
              widget.onLassoGroup(inside);
              Haptics.compose();
            } else if (inside.length == 1) {
              Haptics.fizzle();
            }
          },
          onTapUp: (details) {
            final element = _findElementAt(details.localPosition, size);
            if (element != null) {
              widget.onTapElement(element);
            }
          },
          child: CustomPaint(
            painter: _CanvasPainter(
              elements: widget.elements,
              size: size,
              showGroups: widget.showGroups,
              lassoPath: _lassoPath,
              lassoHighlighted: _lassoHighlighted,
              pulsePhase: widget.pulsePhase,
            ),
            child: Stack(
              children: [
                for (final e in widget.elements)
                  Positioned(
                    left: e.x * size.width - 28,
                    top: e.y * size.height - 28,
                    child: _ElementDot(
                      label: e.label,
                      colorIndex: e.groupIndex,
                      highlighted: _lassoHighlighted.contains(e.id),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  String? _findElementAt(Offset position, Size size) {
    for (final e in widget.elements) {
      final pos = Offset(e.x * size.width, e.y * size.height);
      if ((position - pos).distance < 36) return e.id;
    }
    return null;
  }

  Set<String> _elementsInsideLasso(Size size) {
    if (_lassoPath.length < 3) return {};
    final result = <String>{};
    for (final e in widget.elements) {
      final pos = Offset(e.x * size.width, e.y * size.height);
      if (_isPointInPolygon(pos, _lassoPath)) {
        result.add(e.id);
      }
    }
    return result;
  }

  /// Ray casting algorithm for point-in-polygon.
  bool _isPointInPolygon(Offset point, List<Offset> polygon) {
    var inside = false;
    var j = polygon.length - 1;
    for (var i = 0; i < polygon.length; j = i++) {
      if ((polygon[i].dy > point.dy) != (polygon[j].dy > point.dy) &&
          point.dx <
              (polygon[j].dx - polygon[i].dx) *
                      (point.dy - polygon[i].dy) /
                      (polygon[j].dy - polygon[i].dy) +
                  polygon[i].dx) {
        inside = !inside;
      }
    }
    return inside;
  }
}

class _ElementDot extends StatelessWidget {
  final String label;
  final int colorIndex;
  final bool highlighted;

  const _ElementDot({
    required this.label,
    required this.colorIndex,
    this.highlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = Palette.nodeColor(colorIndex);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: highlighted ? 64 : 56,
      height: highlighted ? 64 : 56,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: highlighted
            ? color.withValues(alpha: 0.15)
            : Palette.bgCard,
        border: Border.all(
          color: color,
          width: highlighted ? 3 : 2.5,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: highlighted ? 0.6 : 0.4),
            blurRadius: highlighted ? 24 : 16,
            spreadRadius: highlighted ? 4 : 2,
          ),
        ],
      ),
      child: Center(
        child: Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 20,
            fontWeight: FontWeight.w700,
            shadows: [
              Shadow(color: color.withValues(alpha: 0.8), blurRadius: 8),
            ],
          ),
        ),
      ),
    );
  }
}

/// Paints group membranes and the active lasso path.
class _CanvasPainter extends CustomPainter {
  final List<SetElement> elements;
  final Size size;
  final bool showGroups;
  final List<Offset> lassoPath;
  final Set<String> lassoHighlighted;
  final double pulsePhase;

  _CanvasPainter({
    required this.elements,
    required this.size,
    required this.showGroups,
    required this.lassoPath,
    required this.lassoHighlighted,
    required this.pulsePhase,
  });

  @override
  void paint(Canvas canvas, Size canvasSize) {
    if (showGroups) _paintMembranes(canvas);
    if (lassoPath.length > 1) _paintLasso(canvas);
  }

  void _paintMembranes(Canvas canvas) {
    final groups = <int, List<SetElement>>{};
    for (final e in elements) {
      groups.putIfAbsent(e.groupIndex, () => []).add(e);
    }

    for (final entry in groups.entries) {
      final group = entry.value;
      if (group.length < 2) continue;

      final color = Palette.nodeColor(entry.key);
      final positions = group
          .map((e) => Offset(e.x * size.width, e.y * size.height))
          .toList();

      // Compute enclosing shape
      final centerX =
          positions.map((p) => p.dx).reduce((a, b) => a + b) / positions.length;
      final centerY =
          positions.map((p) => p.dy).reduce((a, b) => a + b) / positions.length;
      final center = Offset(centerX, centerY);

      var maxDist = 0.0;
      for (final p in positions) {
        final d = (p - center).distance;
        if (d > maxDist) maxDist = d;
      }

      // Pulse: membrane breathes with pulsePhase
      final pulse = math.sin(pulsePhase * 2 * math.pi) * 0.03 + 1.0;
      final radius = (maxDist + 44) * pulse;

      // Blended group color (average of member colors)
      final glowAlpha = 0.06 + 0.03 * math.sin(pulsePhase * 2 * math.pi);

      // Soft fill
      final fillPaint = Paint()
        ..color = color.withValues(alpha: glowAlpha)
        ..style = PaintingStyle.fill
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 16);
      canvas.drawCircle(center, radius, fillPaint);

      // Animated border
      final borderAlpha = 0.2 + 0.1 * math.sin(pulsePhase * 2 * math.pi);
      final borderPaint = Paint()
        ..color = color.withValues(alpha: borderAlpha)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
      canvas.drawCircle(center, radius, borderPaint);

      // Connection lines between grouped elements (subtle)
      for (var i = 0; i < positions.length; i++) {
        for (var j = i + 1; j < positions.length; j++) {
          final linePaint = Paint()
            ..color = color.withValues(alpha: 0.08)
            ..strokeWidth = 1
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
          canvas.drawLine(positions[i], positions[j], linePaint);
        }
      }
    }
  }

  void _paintLasso(Canvas canvas) {
    final hasCapture = lassoHighlighted.isNotEmpty;
    final color = hasCapture ? Palette.cyan : Palette.textDim;

    // Lasso trail
    final path = Path()..moveTo(lassoPath.first.dx, lassoPath.first.dy);
    for (var i = 1; i < lassoPath.length; i++) {
      path.lineTo(lassoPath[i].dx, lassoPath[i].dy);
    }

    // Glow
    final glowPaint = Paint()
      ..color = color.withValues(alpha: 0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    canvas.drawPath(path, glowPaint);

    // Line
    final linePaint = Paint()
      ..color = color.withValues(alpha: hasCapture ? 0.6 : 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(path, linePaint);
  }

  @override
  bool shouldRepaint(_CanvasPainter oldDelegate) => true;
}
