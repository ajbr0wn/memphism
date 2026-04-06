import 'package:flutter/material.dart';
import '../models/partition.dart';
import '../theme/haptics.dart';
import '../theme/palette.dart';
import '../widgets/hasse_view.dart';
import '../widgets/partition_canvas.dart';
import '../widgets/partition_shelf.dart';

/// Level types for partition-based gameplay.
enum PartitionLevelType {
  /// Tap elements to explore — no goal, just feel things.
  explore,
  /// Find ALL partitions of the set.
  findAll,
  /// Create a specific partition (shown as a target).
  createTarget,
}

class PartitionLevelConfig {
  final String id;
  final String title;
  final String? subtitle;
  final List<String> elementLabels;
  final PartitionLevelType type;
  /// For createTarget: the partition to create.
  final Partition? target;
  /// Notation to reveal after completion.
  final String? notationReveal;
  /// Hint text.
  final String? hint;
  /// Positions for elements (relative 0-1).
  final List<Offset> positions;

  const PartitionLevelConfig({
    required this.id,
    required this.title,
    this.subtitle,
    required this.elementLabels,
    required this.type,
    this.target,
    this.notationReveal,
    this.hint,
    required this.positions,
  });
}

class PartitionScreen extends StatefulWidget {
  final PartitionLevelConfig config;
  final VoidCallback onComplete;

  const PartitionScreen({
    super.key,
    required this.config,
    required this.onComplete,
  });

  @override
  State<PartitionScreen> createState() => _PartitionScreenState();
}

class _PartitionScreenState extends State<PartitionScreen>
    with SingleTickerProviderStateMixin {
  late List<SetElement> _elements;
  final List<Partition> _collectedPartitions = [];
  late List<Partition> _allPossible;
  bool _levelComplete = false;
  String? _notationReveal;
  bool _showNotation = false;
  int _maxGroups = 1;
  int _nextGroupIndex = 1;
  bool _showHasse = false;

  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    final labels = widget.config.elementLabels;
    _elements = List.generate(labels.length, (i) => SetElement(
      id: labels[i],
      label: labels[i],
      shapeIndex: i,
      x: widget.config.positions[i].dx,
      y: widget.config.positions[i].dy,
      groupIndex: 0,
    ));
    _allPossible = allPartitions(labels);
    _maxGroups = labels.length;

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
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

  void _onLassoGroup(Set<String> elementIds) {
    if (_levelComplete) return;
    if (elementIds.length < 2) return;

    setState(() {
      final groupIdx = _nextGroupIndex % _maxGroups;
      _nextGroupIndex++;
      for (final id in elementIds) {
        final idx = _elements.indexWhere((e) => e.id == id);
        if (idx >= 0) {
          _elements[idx] = _elements[idx].copyWith(groupIndex: groupIdx);
        }
      }
    });
  }

  void _submitPartition() {
    final current = _currentPartition;

    if (widget.config.type == PartitionLevelType.findAll) {
      // Check if already collected
      if (_collectedPartitions.any((p) => p == current)) {
        Haptics.fizzle();
        _showSnack('Already found this one!');
        return;
      }

      setState(() => _collectedPartitions.add(current));
      Haptics.compose();

      if (_collectedPartitions.length == _allPossible.length) {
        _complete();
      }
    } else if (widget.config.type == PartitionLevelType.createTarget) {
      if (current == widget.config.target) {
        _complete();
      } else {
        Haptics.fizzle();
        _showSnack('Not quite — try a different grouping.');
      }
    }
  }

  void _resetElements() {
    setState(() {
      for (var i = 0; i < _elements.length; i++) {
        _elements[i] = _elements[i].copyWith(groupIndex: 0);
      }
    });
  }

  void _complete() {
    setState(() => _levelComplete = true);
    Haptics.triumph();

    if (widget.config.notationReveal != null) {
      Future.delayed(const Duration(milliseconds: 800), () {
        if (mounted) {
          setState(() {
            _notationReveal = widget.config.notationReveal;
            _showNotation = true;
          });
          Haptics.reveal();
        }
      });
    }
  }

  void _showSnack(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text, style: const TextStyle(color: Palette.textPrimary)),
        backgroundColor: Palette.bgCard,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 1),
      ),
    );
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
                  style: TextStyle(
                    color: Palette.textDim,
                    fontSize: 13,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            Expanded(
              child: _showHasse
                  ? HasseView(
                      partitions: _collectedPartitions,
                      elementIds: widget.config.elementLabels,
                    )
                  : AnimatedBuilder(
                      animation: _pulseController,
                      builder: (context, _) => PartitionCanvas(
                        elements: _elements,
                        onTapElement: _onTapElement,
                        onLassoGroup: _onLassoGroup,
                        pulsePhase: _pulseController.value,
                      ),
                    ),
            ),
            if (!_levelComplete) _buildControls(),
            if (_showNotation) _buildNotation(),
            if (widget.config.type == PartitionLevelType.findAll)
              PartitionShelf(
                collected: _collectedPartitions,
                totalExpected: _allPossible.length,
                elementIds: widget.config.elementLabels,
              ),
            if (_levelComplete) _buildContinue(),
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
          if (widget.config.type == PartitionLevelType.findAll &&
              _collectedPartitions.length >= 2)
            GestureDetector(
              onTap: () => setState(() => _showHasse = !_showHasse),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  color: _showHasse
                      ? Palette.violet.withValues(alpha: 0.15)
                      : Palette.bgCard,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _showHasse
                        ? Palette.violet.withValues(alpha: 0.5)
                        : Palette.textDim.withValues(alpha: 0.3),
                  ),
                ),
                child: Icon(
                  Icons.account_tree_outlined,
                  size: 18,
                  color: _showHasse ? Palette.violet : Palette.textDim,
                ),
              ),
            ),
          if (widget.config.hint != null && !_levelComplete)
            GestureDetector(
              onTap: () => _showSnack(widget.config.hint!),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Palette.bgCard,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Palette.textDim.withValues(alpha: 0.3),
                  ),
                ),
                child: const Text(
                  '?',
                  style: TextStyle(color: Palette.textDim, fontSize: 14),
                ),
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
              onPressed: _resetElements,
              style: OutlinedButton.styleFrom(
                foregroundColor: Palette.textSecondary,
                side: BorderSide(
                  color: Palette.textDim.withValues(alpha: 0.3),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('RESET', style: TextStyle(letterSpacing: 2)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: _submitPartition,
              style: ElevatedButton.styleFrom(
                backgroundColor: Palette.cyan.withValues(alpha: 0.15),
                foregroundColor: Palette.cyan,
                side: BorderSide(
                  color: Palette.cyan.withValues(alpha: 0.4),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                widget.config.type == PartitionLevelType.findAll
                    ? 'COLLECT'
                    : 'SUBMIT',
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  letterSpacing: 2,
                ),
              ),
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
              color: Palette.cyan.withValues(alpha: 0.1),
              blurRadius: 20,
            ),
          ],
        ),
        child: Text(
          _notationReveal!,
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
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text(
            'CONTINUE',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              letterSpacing: 3,
            ),
          ),
        ),
      ),
    );
  }
}
