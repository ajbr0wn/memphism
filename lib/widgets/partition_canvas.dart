import 'package:flutter/material.dart';
import '../models/partition.dart';
import '../theme/palette.dart';

/// Interactive canvas for creating partitions by tapping elements
/// to cycle their group color.
class PartitionCanvas extends StatelessWidget {
  final List<SetElement> elements;
  final void Function(String elementId) onTapElement;
  final bool showGroups;

  const PartitionCanvas({
    super.key,
    required this.elements,
    required this.onTapElement,
    this.showGroups = true,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = constraints.biggest;

        return CustomPaint(
          painter: _GroupPainter(
            elements: elements,
            size: size,
            showGroups: showGroups,
          ),
          child: Stack(
            children: [
              for (final e in elements)
                Positioned(
                  left: e.x * size.width - 28,
                  top: e.y * size.height - 28,
                  child: _ElementDot(
                    label: e.label,
                    colorIndex: e.groupIndex,
                    onTap: () => onTapElement(e.id),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _ElementDot extends StatelessWidget {
  final String label;
  final int colorIndex;
  final VoidCallback onTap;

  const _ElementDot({
    required this.label,
    required this.colorIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = Palette.nodeColor(colorIndex);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Palette.bgCard,
          border: Border.all(color: color, width: 2.5),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.4),
              blurRadius: 16,
              spreadRadius: 2,
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
      ),
    );
  }
}

/// Draws glowing membrane outlines around groups of elements.
class _GroupPainter extends CustomPainter {
  final List<SetElement> elements;
  final Size size;
  final bool showGroups;

  _GroupPainter({
    required this.elements,
    required this.size,
    required this.showGroups,
  });

  @override
  void paint(Canvas canvas, Size canvasSize) {
    if (!showGroups) return;

    // Group elements by their groupIndex
    final groups = <int, List<SetElement>>{};
    for (final e in elements) {
      groups.putIfAbsent(e.groupIndex, () => []).add(e);
    }

    for (final entry in groups.entries) {
      final group = entry.value;
      if (group.length < 2) continue; // no membrane for single elements

      final color = Palette.nodeColor(entry.key);
      final positions = group
          .map((e) => Offset(e.x * size.width, e.y * size.height))
          .toList();

      // Calculate bounding circle for the group
      final centerX = positions.map((p) => p.dx).reduce((a, b) => a + b) /
          positions.length;
      final centerY = positions.map((p) => p.dy).reduce((a, b) => a + b) /
          positions.length;
      final center = Offset(centerX, centerY);

      var maxDist = 0.0;
      for (final p in positions) {
        final d = (p - center).distance;
        if (d > maxDist) maxDist = d;
      }
      final radius = maxDist + 44; // padding around nodes

      // Glow membrane
      final glowPaint = Paint()
        ..color = color.withValues(alpha: 0.08)
        ..style = PaintingStyle.fill
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);
      canvas.drawCircle(center, radius, glowPaint);

      // Border membrane
      final borderPaint = Paint()
        ..color = color.withValues(alpha: 0.25)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
      canvas.drawCircle(center, radius, borderPaint);
    }
  }

  @override
  bool shouldRepaint(_GroupPainter oldDelegate) => true;
}
