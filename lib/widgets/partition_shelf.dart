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
