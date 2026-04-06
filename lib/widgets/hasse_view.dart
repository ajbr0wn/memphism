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

class _PartitionNode extends StatelessWidget {
  final Partition partition;
  final List<String> elementIds;

  const _PartitionNode({
    required this.partition,
    required this.elementIds,
  });

  @override
  Widget build(BuildContext context) {
    final colorMap = <String, int>{};
    for (var gi = 0; gi < partition.parts.length; gi++) {
      for (final id in partition.parts[gi]) {
        colorMap[id] = gi;
      }
    }

    return Container(
      width: 48,
      height: 48,
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
      child: Center(
        child: Wrap(
          spacing: 2,
          runSpacing: 2,
          alignment: WrapAlignment.center,
          children: [
            for (final id in elementIds)
              Container(
                width: elementIds.length <= 3 ? 10 : 7,
                height: elementIds.length <= 3 ? 10 : 7,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Palette.nodeColor(colorMap[id] ?? 0),
                  boxShadow: [
                    BoxShadow(
                      color: Palette.nodeColor(colorMap[id] ?? 0)
                          .withValues(alpha: 0.5),
                      blurRadius: 3,
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
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
