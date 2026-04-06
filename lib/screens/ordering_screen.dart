import 'package:flutter/material.dart';
import '../models/partition.dart';
import '../theme/haptics.dart';
import '../theme/palette.dart';

/// Level where the player arranges partitions vertically by refinement order.
/// Teaches: A ≤ B means A is finer than B (more parts = lower).

class OrderingLevelConfig {
  final String id;
  final String title;
  final String? subtitle;
  final List<Partition> partitions;
  final List<String> elementLabels;
  final String? notationReveal;
  final String? hint;

  const OrderingLevelConfig({
    required this.id,
    required this.title,
    this.subtitle,
    required this.partitions,
    required this.elementLabels,
    this.notationReveal,
    this.hint,
  });
}

class OrderingScreen extends StatefulWidget {
  final OrderingLevelConfig config;
  final VoidCallback onComplete;

  const OrderingScreen({
    super.key,
    required this.config,
    required this.onComplete,
  });

  @override
  State<OrderingScreen> createState() => _OrderingScreenState();
}

class _OrderingScreenState extends State<OrderingScreen> {
  late List<Partition> _slots; // current arrangement (top to bottom)
  bool _levelComplete = false;
  bool _showNotation = false;

  @override
  void initState() {
    super.initState();
    // Shuffle the partitions so the player has to sort them
    _slots = List.of(widget.config.partitions)..shuffle();
  }

  bool _isCorrectOrder() {
    // Correct order: coarsest (fewest parts) at top, finest at bottom
    for (var i = 0; i < _slots.length - 1; i++) {
      if (!_slots[i + 1].isFinerOrEqual(_slots[i])) return false;
      // Also ensure they're not equal (strict ordering at each step)
      if (_slots[i].isFinerOrEqual(_slots[i + 1]) &&
          _slots[i + 1].isFinerOrEqual(_slots[i])) {
        // They're equal — that's OK for same-level items
        // But we need same-level items grouped
      }
    }
    // Simpler check: sort by numParts ascending
    for (var i = 0; i < _slots.length - 1; i++) {
      if (_slots[i].numParts > _slots[i + 1].numParts) return false;
    }
    return true;
  }

  void _onReorder(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) newIndex--;
      final item = _slots.removeAt(oldIndex);
      _slots.insert(newIndex, item);
    });
    Haptics.snap();

    if (_isCorrectOrder() && !_levelComplete) {
      setState(() => _levelComplete = true);
      Haptics.triumph();

      if (widget.config.notationReveal != null) {
        Future.delayed(const Duration(milliseconds: 800), () {
          if (mounted) setState(() => _showNotation = true);
          Haptics.reveal();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Palette.bg,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            if (widget.config.subtitle != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Text(
                  widget.config.subtitle!,
                  style: const TextStyle(
                    color: Palette.textDim,
                    fontSize: 13,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            const SizedBox(height: 8),
            // Arrow showing direction: coarse at top, fine at bottom
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Row(
                children: [
                  Text('coarse',
                      style: TextStyle(
                          color: Palette.textDim.withValues(alpha: 0.5),
                          fontSize: 11)),
                  const Spacer(),
                ],
              ),
            ),
            Expanded(
              child: ReorderableListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                itemCount: _slots.length,
                onReorder: _onReorder,
                proxyDecorator: (child, index, animation) {
                  return Material(
                    color: Colors.transparent,
                    child: child,
                  );
                },
                itemBuilder: (context, index) {
                  final partition = _slots[index];
                  final isCorrectPosition = !_levelComplete
                      ? null
                      : true; // all correct when complete
                  return _PartitionCard(
                    key: ValueKey(partition.toString()),
                    partition: partition,
                    elementIds: widget.config.elementLabels,
                    isCorrect: isCorrectPosition,
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Row(
                children: [
                  Text('fine',
                      style: TextStyle(
                          color: Palette.textDim.withValues(alpha: 0.5),
                          fontSize: 11)),
                  const Spacer(),
                ],
              ),
            ),
            if (_showNotation) _buildNotation(),
            if (_levelComplete) _buildContinue(),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: [
          Text(
            widget.config.title,
            style: const TextStyle(
              color: Palette.textPrimary,
              fontSize: 24,
              fontWeight: FontWeight.w800,
              letterSpacing: 2,
            ),
          ),
          const Spacer(),
          if (widget.config.hint != null && !_levelComplete)
            GestureDetector(
              onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(widget.config.hint!,
                      style: const TextStyle(color: Palette.textPrimary)),
                  backgroundColor: Palette.bgCard,
                  behavior: SnackBarBehavior.floating,
                  duration: const Duration(seconds: 2),
                ),
              ),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Palette.bgCard,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: Palette.textDim.withValues(alpha: 0.3)),
                ),
                child:
                    const Text('?', style: TextStyle(color: Palette.textDim)),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildNotation() {
    return AnimatedOpacity(
      opacity: _showNotation ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 600),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 32, vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: BoxDecoration(
          color: Palette.bgCard,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Palette.cyan.withValues(alpha: 0.3)),
          boxShadow: [
            BoxShadow(
                color: Palette.cyan.withValues(alpha: 0.1), blurRadius: 20),
          ],
        ),
        child: Text(
          widget.config.notationReveal!,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Palette.cyan,
            fontSize: 18,
            fontWeight: FontWeight.w600,
            letterSpacing: 1,
            height: 1.6,
          ),
        ),
      ),
    );
  }

  Widget _buildContinue() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: widget.onComplete,
          style: ElevatedButton.styleFrom(
            backgroundColor: Palette.green.withValues(alpha: 0.15),
            foregroundColor: Palette.green,
            side: BorderSide(color: Palette.green.withValues(alpha: 0.5)),
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
          ),
          child: const Text(
            'CONTINUE',
            style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.w700, letterSpacing: 3),
          ),
        ),
      ),
    );
  }
}

class _PartitionCard extends StatelessWidget {
  final Partition partition;
  final List<String> elementIds;
  final bool? isCorrect;

  const _PartitionCard({
    super.key,
    required this.partition,
    required this.elementIds,
    this.isCorrect,
  });

  @override
  Widget build(BuildContext context) {
    // Normalize colors by structure
    final sortedParts = partition.parts.toList()
      ..sort((a, b) {
        if (a.length != b.length) return a.length.compareTo(b.length);
        final aMin = (a.toList()..sort()).first;
        final bMin = (b.toList()..sort()).first;
        return aMin.compareTo(bMin);
      });

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Palette.bgCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCorrect == true
              ? Palette.green.withValues(alpha: 0.5)
              : Palette.textDim.withValues(alpha: 0.2),
        ),
        boxShadow: [
          if (isCorrect == true)
            BoxShadow(
                color: Palette.green.withValues(alpha: 0.1), blurRadius: 12),
        ],
      ),
      child: Row(
        children: [
          Icon(Icons.drag_handle,
              color: Palette.textDim.withValues(alpha: 0.3), size: 20),
          const SizedBox(width: 12),
          // Show partition as grouped elements with notation
          Expanded(
            child: Wrap(
              spacing: 12,
              children: [
                for (var gi = 0; gi < sortedParts.length; gi++)
                  _GroupChip(
                    elements: sortedParts[gi].toList()..sort(),
                    colorIndex: gi,
                  ),
              ],
            ),
          ),
          // Show set notation
          Text(
            partition.toString(),
            style: TextStyle(
              color: Palette.textDim.withValues(alpha: 0.5),
              fontSize: 12,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }
}

class _GroupChip extends StatelessWidget {
  final List<String> elements;
  final int colorIndex;

  const _GroupChip({required this.elements, required this.colorIndex});

  @override
  Widget build(BuildContext context) {
    final color = Palette.nodeColor(colorIndex);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
        color: color.withValues(alpha: 0.08),
      ),
      child: Text(
        '{${elements.join(', ')}}',
        style: TextStyle(
          color: color,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
