import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/partition.dart';
import '../theme/palette.dart';

/// Displays collected partitions as a Hasse diagram.
/// Finer partitions sit lower, coarser ones float higher.
/// Arrows connect directly-related partitions.
class HasseView extends StatelessWidget {
  final List<Partition> partitions;
  final List<String> elementIds;

  const HasseView({
    super.key,
    required this.partitions,
    required this.elementIds,
  });

  @override
  Widget build(BuildContext context) {
    if (partitions.isEmpty) {
      return const Center(
        child: Text(
          'Collect partitions to see the diagram emerge.',
          style: TextStyle(color: Palette.textDim, fontSize: 14),
        ),
      );
    }

    // Arrange partitions by number of parts (more parts = finer = lower)
    final layers = <int, List<Partition>>{};
    for (final p in partitions) {
      layers.putIfAbsent(p.numParts, () => []).add(p);
    }

    final sortedKeys = layers.keys.toList()..sort(); // ascending = finer first

    // Find direct edges (covers): A < B with no C where A < C < B
    final edges = <(int, int)>[];
    for (var i = 0; i < partitions.length; i++) {
      for (var j = 0; j < partitions.length; j++) {
        if (i == j) continue;
        final a = partitions[i];
        final b = partitions[j];
        if (a.isFinerOrEqual(b) && !(b.isFinerOrEqual(a))) {
          // a < b — check if it's a cover (no c between)
          final isCover = !partitions.any((c) =>
              c != a &&
              c != b &&
              a.isFinerOrEqual(c) &&
              c.isFinerOrEqual(b) &&
              !(c.isFinerOrEqual(a)) &&
              !(b.isFinerOrEqual(c)));
          if (isCover) edges.add((i, j));
        }
      }
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final size = constraints.biggest;
        final layerCount = sortedKeys.length;
        final verticalSpacing = size.height / (layerCount + 1);

        // Position each partition
        final positions = <int, Offset>{};
        for (var li = 0; li < sortedKeys.length; li++) {
          final key = sortedKeys[li];
          final layer = layers[key]!;
          // Reverse: more parts (finer) at bottom, fewer parts (coarser) at top
          final y = size.height - (li + 1) * verticalSpacing;
          final horizontalSpacing = size.width / (layer.length + 1);
          for (var pi = 0; pi < layer.length; pi++) {
            final globalIdx = partitions.indexOf(layer[pi]);
            positions[globalIdx] = Offset(
              (pi + 1) * horizontalSpacing,
              y,
            );
          }
        }

        return CustomPaint(
          painter: _HassePainter(
            partitions: partitions,
            positions: positions,
            edges: edges,
            elementIds: elementIds,
          ),
          child: Stack(
            children: [
              for (var i = 0; i < partitions.length; i++)
                if (positions.containsKey(i))
                  Positioned(
                    left: positions[i]!.dx - 24,
                    top: positions[i]!.dy - 24,
                    child: _PartitionNode(
                      partition: partitions[i],
                      elementIds: elementIds,
                    ),
                  ),
            ],
          ),
        );
      },
    );
  }
}

/// Hasse node showing a partition as grouped dots with enclosures,
/// similar to the textbook style.
class _PartitionNode extends StatelessWidget {
  final Partition partition;
  final List<String> elementIds;

  const _PartitionNode({
    required this.partition,
    required this.elementIds,
  });

  @override
  Widget build(BuildContext context) {
    // Normalize colors by structure (same as canvas)
    final sortedParts = partition.parts.toList()
      ..sort((a, b) {
        if (a.length != b.length) return a.length.compareTo(b.length);
        final aMin = (a.toList()..sort()).first;
        final bMin = (b.toList()..sort()).first;
        return aMin.compareTo(bMin);
      });
    final colorMap = <String, int>{};
    for (var gi = 0; gi < sortedParts.length; gi++) {
      for (final id in sortedParts[gi]) {
        colorMap[id] = gi;
      }
    }

    final nodeSize = elementIds.length <= 3 ? 52.0 : 56.0;

    return Container(
      width: nodeSize,
      height: nodeSize,
      decoration: BoxDecoration(
        color: Palette.bgCard,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: Palette.cyan.withValues(alpha: 0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: Palette.cyan.withValues(alpha: 0.1),
            blurRadius: 12,
          ),
        ],
      ),
      child: CustomPaint(
        painter: _HasseNodePainter(
          elementIds: elementIds,
          colorMap: colorMap,
          sortedParts: sortedParts,
        ),
      ),
    );
  }
}

/// Draws partition dots with enclosing curves around groups,
/// like the textbook diagrams.
class _HasseNodePainter extends CustomPainter {
  final List<String> elementIds;
  final Map<String, int> colorMap;
  final List<Set<String>> sortedParts;

  _HasseNodePainter({
    required this.elementIds,
    required this.colorMap,
    required this.sortedParts,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final count = elementIds.length;
    final dotSize = count <= 3 ? 5.0 : 4.0;
    final cols = count <= 2 ? count : 2;
    final rows = (count / cols).ceil();
    final spacingX = size.width / (cols + 1);
    final spacingY = size.height / (rows + 1);

    // Position each element
    final positions = <String, Offset>{};
    for (var i = 0; i < count; i++) {
      final col = i % cols;
      final row = i ~/ cols;
      positions[elementIds[i]] = Offset(
        (col + 1) * spacingX,
        (row + 1) * spacingY,
      );
    }

    // Draw enclosing curves around groups with > 1 element
    for (var gi = 0; gi < sortedParts.length; gi++) {
      final group = sortedParts[gi];
      if (group.length < 2) continue;

      final color = Palette.nodeColor(gi);
      final groupPositions = group.map((id) => positions[id]!).toList();

      // Draw enclosing rounded rect around the group
      var minX = double.infinity, minY = double.infinity;
      var maxX = double.negativeInfinity, maxY = double.negativeInfinity;
      for (final p in groupPositions) {
        if (p.dx < minX) minX = p.dx;
        if (p.dy < minY) minY = p.dy;
        if (p.dx > maxX) maxX = p.dx;
        if (p.dy > maxY) maxY = p.dy;
      }
      final enclosePaint = Paint()
        ..color = color.withValues(alpha: 0.15)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTRB(
            minX - dotSize - 3,
            minY - dotSize - 3,
            maxX + dotSize + 3,
            maxY + dotSize + 3,
          ),
          const Radius.circular(6),
        ),
        enclosePaint,
      );
    }

    // Draw dots with shapes
    for (var i = 0; i < count; i++) {
      final id = elementIds[i];
      final center = positions[id]!;
      final color = Palette.nodeColor(colorMap[id] ?? 0);
      final paint = Paint()..color = color;

      // Use shape index based on element position
      switch (i % 6) {
        case 0:
          canvas.drawCircle(center, dotSize, paint);
        case 1:
          final path = Path();
          for (var p = 0; p < 5; p++) {
            final outerA = (p * 2 * math.pi / 5) - math.pi / 2;
            final innerA = outerA + math.pi / 5;
            final ox = center.dx + dotSize * math.cos(outerA);
            final oy = center.dy + dotSize * math.sin(outerA);
            final ix = center.dx + dotSize * 0.4 * math.cos(innerA);
            final iy = center.dy + dotSize * 0.4 * math.sin(innerA);
            if (p == 0) { path.moveTo(ox, oy); } else { path.lineTo(ox, oy); }
            path.lineTo(ix, iy);
          }
          path.close();
          canvas.drawPath(path, paint);
        case 2:
          canvas.drawRect(
            Rect.fromCenter(center: center, width: dotSize * 1.6, height: dotSize * 1.6),
            paint,
          );
        case 3:
          final path = Path();
          for (var p = 0; p < 3; p++) {
            final a = (p * 2 * math.pi / 3) - math.pi / 2;
            final x = center.dx + dotSize * math.cos(a);
            final y = center.dy + dotSize * math.sin(a);
            if (p == 0) { path.moveTo(x, y); } else { path.lineTo(x, y); }
          }
          path.close();
          canvas.drawPath(path, paint);
        default:
          canvas.drawCircle(center, dotSize, paint);
      }
    }
  }

  @override
  bool shouldRepaint(_HasseNodePainter oldDelegate) => true;
}

class _HassePainter extends CustomPainter {
  final List<Partition> partitions;
  final Map<int, Offset> positions;
  final List<(int, int)> edges;
  final List<String> elementIds;

  _HassePainter({
    required this.partitions,
    required this.positions,
    required this.edges,
    required this.elementIds,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final (from, to) in edges) {
      final fromPos = positions[from];
      final toPos = positions[to];
      if (fromPos == null || toPos == null) continue;

      // Glow
      final glowPaint = Paint()
        ..color = Palette.cyan.withValues(alpha: 0.08)
        ..strokeWidth = 4
        ..style = PaintingStyle.stroke
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
      canvas.drawLine(fromPos, toPos, glowPaint);

      // Line
      final linePaint = Paint()
        ..color = Palette.cyan.withValues(alpha: 0.25)
        ..strokeWidth = 1.5
        ..style = PaintingStyle.stroke;
      canvas.drawLine(fromPos, toPos, linePaint);

      // Arrowhead pointing upward (from finer to coarser)
      final delta = toPos - fromPos;
      final angle = math.atan2(delta.dy, delta.dx);
      final headLen = 8.0;
      final headAngle = 0.4;
      final arrowPaint = Paint()
        ..color = Palette.cyan.withValues(alpha: 0.3)
        ..strokeWidth = 1.5
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      final headPoint = Offset(
        toPos.dx - (24 + 4) * math.cos(angle),
        toPos.dy - (24 + 4) * math.sin(angle),
      );
      canvas.drawLine(
        headPoint,
        Offset(
          headPoint.dx - headLen * math.cos(angle - headAngle),
          headPoint.dy - headLen * math.sin(angle - headAngle),
        ),
        arrowPaint,
      );
      canvas.drawLine(
        headPoint,
        Offset(
          headPoint.dx - headLen * math.cos(angle + headAngle),
          headPoint.dy - headLen * math.sin(angle + headAngle),
        ),
        arrowPaint,
      );
    }
  }

  @override
  bool shouldRepaint(_HassePainter oldDelegate) => true;
}
