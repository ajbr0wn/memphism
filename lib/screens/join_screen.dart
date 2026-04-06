import 'package:flutter/material.dart';
import '../models/partition.dart';
import '../theme/haptics.dart';
import '../theme/palette.dart';

/// Level where the player finds the join (A ∨ B) of two partitions.
/// The join is the coarsest partition that's finer than both A and B —
/// equivalently, the smallest partition ≥ both A and B.

class JoinLevelConfig {
  final String id;
  final String title;
  final String? subtitle;
  final Partition partitionA;
  final Partition partitionB;
  final Partition expectedJoin;
  final List<String> elementLabels;
  final List<Offset> positions;
  final String? notationReveal;
  final String? hint;

  const JoinLevelConfig({
    required this.id,
    required this.title,
    this.subtitle,
    required this.partitionA,
    required this.partitionB,
    required this.expectedJoin,
    required this.elementLabels,
    required this.positions,
    this.notationReveal,
    this.hint,
  });
}

class JoinScreen extends StatefulWidget {
  final JoinLevelConfig config;
  final VoidCallback onComplete;

  const JoinScreen({
    super.key,
    required this.config,
    required this.onComplete,
  });

  @override
  State<JoinScreen> createState() => _JoinScreenState();
}

class _JoinScreenState extends State<JoinScreen> {
  late List<SetElement> _elements;
  bool _levelComplete = false;
  bool _showNotation = false;
  int _maxGroups = 1;

  @override
  void initState() {
    super.initState();
    final labels = widget.config.elementLabels;
    _elements = List.generate(
      labels.length,
      (i) => SetElement(
        id: labels[i],
        label: labels[i],
        shapeIndex: i,
        x: widget.config.positions[i].dx,
        y: widget.config.positions[i].dy,
        groupIndex: 0,
      ),
    );
    _maxGroups = labels.length;
  }

  Partition get _currentPartition => Partition.fromElements(_elements);

  void _onTapElement(String id) {
    if (_levelComplete) return;
    setState(() {
      final idx = _elements.indexWhere((e) => e.id == id);
      if (idx < 0) return;
      _elements[idx] = _elements[idx].copyWith(
        groupIndex: (_elements[idx].groupIndex + 1) % _maxGroups,
      );
    });
    Haptics.tap();
  }

  void _submit() {
    if (_currentPartition == widget.config.expectedJoin) {
      setState(() => _levelComplete = true);
      Haptics.triumph();
      if (widget.config.notationReveal != null) {
        Future.delayed(const Duration(milliseconds: 800), () {
          if (mounted) {
            setState(() => _showNotation = true);
            Haptics.reveal();
          }
        });
      }
    } else {
      Haptics.fizzle();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Not quite — find the SMALLEST partition ≥ both.',
              style: TextStyle(color: Palette.textPrimary)),
          backgroundColor: Palette.bgCard,
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _reset() {
    setState(() {
      for (var i = 0; i < _elements.length; i++) {
        _elements[i] = _elements[i].copyWith(groupIndex: 0);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Palette.bg,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            // Show the two partitions to join
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  Expanded(child: _PartitionDisplay(
                    label: 'A',
                    partition: widget.config.partitionA,
                    elementIds: widget.config.elementLabels,
                    color: Palette.pink,
                  )),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      '∨',
                      style: TextStyle(
                        color: Palette.yellow,
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        shadows: [
                          Shadow(
                            color: Palette.yellow.withValues(alpha: 0.5),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(child: _PartitionDisplay(
                    label: 'B',
                    partition: widget.config.partitionB,
                    elementIds: widget.config.elementLabels,
                    color: Palette.cyan,
                  )),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      '=',
                      style: TextStyle(
                        color: Palette.textDim,
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const Text(
                    '?',
                    style: TextStyle(
                      color: Palette.green,
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            // Play area for building the answer
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: _buildPlayArea(),
              ),
            ),
            if (!_levelComplete) _buildControls(),
            if (_showNotation) _buildNotation(),
            if (_levelComplete) _buildContinue(),
          ],
        ),
      ),
    );
  }

  Widget _buildPlayArea() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = constraints.biggest;
        return Stack(
          children: [
            for (final e in _elements)
              Positioned(
                left: e.x * size.width - 28,
                top: e.y * size.height - 28,
                child: GestureDetector(
                  onTap: () => _onTapElement(e.id),
                  child: _buildDot(e),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildDot(SetElement e) {
    final color = Palette.nodeColor(e.groupIndex);
    return Container(
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
          e.label,
          style: TextStyle(
            color: Palette.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w800,
            shadows: [
              Shadow(color: color.withValues(alpha: 0.6), blurRadius: 6),
            ],
          ),
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

  Widget _buildControls() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: _reset,
              style: OutlinedButton.styleFrom(
                foregroundColor: Palette.textSecondary,
                side: BorderSide(
                    color: Palette.textDim.withValues(alpha: 0.3)),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              child:
                  const Text('RESET', style: TextStyle(letterSpacing: 2)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: Palette.green.withValues(alpha: 0.15),
                foregroundColor: Palette.green,
                side: BorderSide(
                    color: Palette.green.withValues(alpha: 0.4)),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('SUBMIT',
                  style: TextStyle(
                      fontWeight: FontWeight.w700, letterSpacing: 2)),
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
      padding: const EdgeInsets.all(24),
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
          child: const Text('CONTINUE',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 3)),
        ),
      ),
    );
  }
}

/// Compact display of a partition with label.
class _PartitionDisplay extends StatelessWidget {
  final String label;
  final Partition partition;
  final List<String> elementIds;
  final Color color;

  const _PartitionDisplay({
    required this.label,
    required this.partition,
    required this.elementIds,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final sortedParts = partition.parts.toList()
      ..sort((a, b) {
        if (a.length != b.length) return a.length.compareTo(b.length);
        return (a.toList()..sort()).first.compareTo((b.toList()..sort()).first);
      });

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label,
              style: TextStyle(
                  color: color, fontSize: 12, fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text(
            sortedParts
                .map((p) => '{${(p.toList()..sort()).join(',')}}')
                .join(' '),
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w600,
              fontFamily: 'monospace',
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
