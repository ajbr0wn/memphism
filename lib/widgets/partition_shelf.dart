import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/partition.dart';
import '../theme/palette.dart';

/// Shows collected partitions as small visual thumbnails.
class PartitionShelf extends StatelessWidget {
  final List<Partition> collected;
  final int totalExpected;
  final List<String> elementIds;

  const PartitionShelf({
    super.key,
    required this.collected,
    required this.totalExpected,
    required this.elementIds,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Palette.bgCard,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        border: Border(
          top: BorderSide(
            color: Palette.textDim.withValues(alpha: 0.2),
          ),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Text(
                '${collected.length} / $totalExpected',
                style: TextStyle(
                  color: collected.length == totalExpected
                      ? Palette.green
                      : Palette.textSecondary,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: LinearProgressIndicator(
                  value: totalExpected > 0
                      ? collected.length / totalExpected
                      : 0,
                  backgroundColor: Palette.bgLight,
                  valueColor: AlwaysStoppedAnimation(
                    collected.length == totalExpected
                        ? Palette.green
                        : Palette.cyan,
                  ),
                  minHeight: 3,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 44,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: totalExpected,
              itemBuilder: (context, index) {
                final found = index < collected.length;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: found
                      ? _PartitionThumb(
                          partition: collected[index],
                          elementIds: elementIds,
                        )
                      : _EmptyThumb(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _PartitionThumb extends StatelessWidget {
  final Partition partition;
  final List<String> elementIds;

  const _PartitionThumb({
    required this.partition,
    required this.elementIds,
  });

  @override
  Widget build(BuildContext context) {
    // Assign colors to groups
    final colorMap = <String, int>{};
    for (var gi = 0; gi < partition.parts.length; gi++) {
      for (final id in partition.parts[gi]) {
        colorMap[id] = gi;
      }
    }

    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: Palette.bgLight,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Palette.cyan.withValues(alpha: 0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: Palette.cyan.withValues(alpha: 0.1),
            blurRadius: 8,
          ),
        ],
      ),
      child: CustomPaint(
        painter: _ThumbShapePainter(
          elementIds: elementIds,
          colorMap: colorMap,
        ),
      ),
    );
  }
}

class _EmptyThumb extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: Palette.bg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Palette.textDim.withValues(alpha: 0.15),
        ),
      ),
      child: const Center(
        child: Text(
          '?',
          style: TextStyle(color: Palette.textDim, fontSize: 16),
        ),
      ),
    );
  }
}

/// Draws tiny shapes in the thumbnail, colored by group.
class _ThumbShapePainter extends CustomPainter {
  final List<String> elementIds;
  final Map<String, int> colorMap;

  _ThumbShapePainter({required this.elementIds, required this.colorMap});

  @override
  void paint(Canvas canvas, Size size) {
    final count = elementIds.length;
    final dotSize = count <= 3 ? 5.0 : 4.0;
    final cols = count <= 2 ? count : 2;
    final rows = (count / cols).ceil();
    final spacingX = size.width / (cols + 1);
    final spacingY = size.height / (rows + 1);

    for (var i = 0; i < count; i++) {
      final col = i % cols;
      final row = i ~/ cols;
      final center = Offset(
        (col + 1) * spacingX,
        (row + 1) * spacingY,
      );
      final color = Palette.nodeColor(colorMap[elementIds[i]] ?? 0);
      final paint = Paint()..color = color;

      switch (i % 6) {
        case 0: // circle
          canvas.drawCircle(center, dotSize, paint);
        case 1: // star (draw as small filled star)
          final path = Path();
          for (var p = 0; p < 5; p++) {
            final outerA = (p * 2 * math.pi / 5) - math.pi / 2;
            final innerA = outerA + math.pi / 5;
            final ox = center.dx + dotSize * math.cos(outerA);
            final oy = center.dy + dotSize * math.sin(outerA);
            final ix = center.dx + dotSize * 0.4 * math.cos(innerA);
            final iy = center.dy + dotSize * 0.4 * math.sin(innerA);
            if (p == 0) path.moveTo(ox, oy); else path.lineTo(ox, oy);
            path.lineTo(ix, iy);
          }
          path.close();
          canvas.drawPath(path, paint);
        case 2: // square
          canvas.drawRect(
            Rect.fromCenter(center: center, width: dotSize * 1.6, height: dotSize * 1.6),
            paint,
          );
        case 3: // triangle
          final path = Path();
          for (var p = 0; p < 3; p++) {
            final a = (p * 2 * math.pi / 3) - math.pi / 2;
            final x = center.dx + dotSize * math.cos(a);
            final y = center.dy + dotSize * math.sin(a);
            if (p == 0) path.moveTo(x, y); else path.lineTo(x, y);
          }
          path.close();
          canvas.drawPath(path, paint);
        case 4: // diamond
          final path = Path()
            ..moveTo(center.dx, center.dy - dotSize)
            ..lineTo(center.dx + dotSize * 0.7, center.dy)
            ..lineTo(center.dx, center.dy + dotSize)
            ..lineTo(center.dx - dotSize * 0.7, center.dy)
            ..close();
          canvas.drawPath(path, paint);
        case 5: // hexagon
          final path = Path();
          for (var p = 0; p < 6; p++) {
            final a = (p * 2 * math.pi / 6) - math.pi / 6;
            final x = center.dx + dotSize * math.cos(a);
            final y = center.dy + dotSize * math.sin(a);
            if (p == 0) path.moveTo(x, y); else path.lineTo(x, y);
          }
          path.close();
          canvas.drawPath(path, paint);
      }
    }
  }

  @override
  bool shouldRepaint(_ThumbShapePainter oldDelegate) => true;
}
