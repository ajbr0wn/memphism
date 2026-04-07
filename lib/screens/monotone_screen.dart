import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/haptics.dart';
import '../theme/palette.dart';

/// Level where the player draws a monotone map f: P → Q between two
/// preorders shown as Hasse diagrams. Arrows must preserve order:
/// if a ≤ b in P, then f(a) ≤ f(b) in Q.

class MonotoneLevelConfig {
  final String id;
  final String title;
  final String? subtitle;
  /// Left preorder (domain P).
  final List<String> domainLabels;
  final List<Offset> domainPositions;
  final Set<(int, int)> domainEdges; // Hasse covers
  /// Right preorder (codomain Q).
  final List<String> codomainLabels;
  final List<Offset> codomainPositions;
  final Set<(int, int)> codomainEdges;
  /// Which domain elements must be mapped (all by default).
  /// Validation: the map must be total AND monotone.
  /// If [expectedMap] is set, requires that specific map.
  /// Otherwise any valid monotone map is accepted.
  final Map<int, int>? expectedMap;
  final String? notationReveal;
  final String? hint;

  const MonotoneLevelConfig({
    required this.id,
    required this.title,
    this.subtitle,
    required this.domainLabels,
    required this.domainPositions,
    required this.domainEdges,
    required this.codomainLabels,
    required this.codomainPositions,
    required this.codomainEdges,
    this.expectedMap,
    this.notationReveal,
    this.hint,
  });
}

class MonotoneScreen extends StatefulWidget {
  final MonotoneLevelConfig config;
  final VoidCallback onComplete;

  const MonotoneScreen({
    super.key,
    required this.config,
    required this.onComplete,
  });

  @override
  State<MonotoneScreen> createState() => _MonotoneScreenState();
}

class _MonotoneScreenState extends State<MonotoneScreen> {
  /// Current mapping: domain index → codomain index.
  final Map<int, int> _mapping = {};
  int? _dragFrom;
  Offset? _dragPosition;
  bool _levelComplete = false;
  bool _showNotation = false;

  // Layout cache
  List<Offset> _domainPixels = [];
  List<Offset> _codomainPixels = [];
  Size _lastSize = Size.zero;

  /// Compute reachability (transitive closure) for monotonicity checks.
  late final Set<(int, int)> _domainReachable;
  late final Set<(int, int)> _codomainReachable;

  @override
  void initState() {
    super.initState();
    _domainReachable = _transitiveClosure(
        widget.config.domainLabels.length, widget.config.domainEdges);
    _codomainReachable = _transitiveClosure(
        widget.config.codomainLabels.length, widget.config.codomainEdges);
  }

  /// Compute transitive closure from Hasse edges.
  Set<(int, int)> _transitiveClosure(int n, Set<(int, int)> edges) {
    final reach = <(int, int)>{};
    // Add reflexive
    for (var i = 0; i < n; i++) {
      reach.add((i, i));
    }
    // Add edges
    reach.addAll(edges);
    // Floyd-Warshall
    for (var k = 0; k < n; k++) {
      for (var i = 0; i < n; i++) {
        for (var j = 0; j < n; j++) {
          if (reach.contains((i, k)) && reach.contains((k, j))) {
            reach.add((i, j));
          }
        }
      }
    }
    return reach;
  }

  /// Check if the current mapping is monotone.
  bool _isMonotone() {
    for (final (a, b) in _domainReachable) {
      if (a == b) continue;
      if (!_mapping.containsKey(a) || !_mapping.containsKey(b)) continue;
      final fa = _mapping[a]!;
      final fb = _mapping[b]!;
      if (!_codomainReachable.contains((fa, fb))) return false;
    }
    return true;
  }

  /// Check if adding domain[from] → codomain[to] would break monotonicity.
  bool _wouldBeMonotone(int from, int to) {
    final test = Map<int, int>.from(_mapping);
    test[from] = to;
    for (final (a, b) in _domainReachable) {
      if (a == b) continue;
      if (!test.containsKey(a) || !test.containsKey(b)) continue;
      final fa = test[a]!;
      final fb = test[b]!;
      if (!_codomainReachable.contains((fa, fb))) return false;
    }
    return true;
  }

  /// Hit-test pan start against domain nodes.
  void _onPanStart(Offset position) {
    if (_levelComplete) return;
    for (var i = 0; i < _domainPixels.length; i++) {
      if ((_domainPixels[i] - position).distance < 36) {
        setState(() => _dragFrom = i);
        Haptics.tap();
        return;
      }
    }
  }

  void _onDragUpdate(Offset position) {
    if (_dragFrom == null) return;
    setState(() => _dragPosition = position);
  }

  void _onDragEnd() {
    if (_dragFrom == null || _dragPosition == null) return;

    // Find nearest codomain node
    int? nearest;
    double nearestDist = 40; // max snap distance
    for (var i = 0; i < _codomainPixels.length; i++) {
      final d = (_codomainPixels[i] - _dragPosition!).distance;
      if (d < nearestDist) {
        nearestDist = d;
        nearest = i;
      }
    }

    if (nearest != null) {
      if (_wouldBeMonotone(_dragFrom!, nearest)) {
        setState(() {
          _mapping[_dragFrom!] = nearest!;
        });
        Haptics.snap();
      } else {
        Haptics.fizzle();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Not monotone! If a ≤ b then f(a) ≤ f(b) must hold.',
                style: TextStyle(color: Palette.textPrimary)),
            backgroundColor: Palette.bgCard,
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 2),
          ),
        );
      }
    }

    setState(() {
      _dragFrom = null;
      _dragPosition = null;
    });
  }

  void _submit() {
    final n = widget.config.domainLabels.length;
    if (_mapping.length < n) {
      Haptics.fizzle();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Map all ${n} elements first!',
              style: const TextStyle(color: Palette.textPrimary)),
          backgroundColor: Palette.bgCard,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (!_isMonotone()) {
      Haptics.fizzle();
      return;
    }

    // Check specific expected map if provided
    if (widget.config.expectedMap != null) {
      for (final entry in widget.config.expectedMap!.entries) {
        if (_mapping[entry.key] != entry.value) {
          Haptics.fizzle();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('That\'s monotone, but not the specific map we need!',
                  style: TextStyle(color: Palette.textPrimary)),
              backgroundColor: Palette.bgCard,
              behavior: SnackBarBehavior.floating,
              duration: Duration(seconds: 2),
            ),
          );
          return;
        }
      }
    }

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
  }

  void _reset() {
    setState(() => _mapping.clear());
  }

  void _removeLast() {
    if (_mapping.isNotEmpty) {
      setState(() {
        final lastKey = _mapping.keys.last;
        _mapping.remove(lastKey);
      });
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
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Palette.textSecondary,
                    fontSize: 14,
                  ),
                ),
              ),
            const SizedBox(height: 8),
            // Main diagram area
            Expanded(child: _buildDiagramArea()),
            if (!_levelComplete) _buildControls(),
            if (_showNotation) _buildNotation(),
            if (_levelComplete) _buildContinue(),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildDiagramArea() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = constraints.biggest;
        if (size != _lastSize) {
          _lastSize = size;
          // Left half for domain, right half for codomain
          final halfW = size.width * 0.42;
          final leftOffset = size.width * 0.04;
          final rightOffset = size.width * 0.54;

          _domainPixels = widget.config.domainPositions
              .map((p) => Offset(
                  leftOffset + p.dx * halfW, p.dy * size.height))
              .toList();
          _codomainPixels = widget.config.codomainPositions
              .map((p) => Offset(
                  rightOffset + p.dx * halfW, p.dy * size.height))
              .toList();
        }

        return GestureDetector(
          onPanStart: (d) => _onPanStart(d.localPosition),
          onPanUpdate: (d) => _onDragUpdate(d.localPosition),
          onPanEnd: (_) => _onDragEnd(),
          child: CustomPaint(
            painter: _MonotonePainter(
              domainPixels: _domainPixels,
              codomainPixels: _codomainPixels,
              domainEdges: widget.config.domainEdges,
              codomainEdges: widget.config.codomainEdges,
              mapping: _mapping,
              dragFrom: _dragFrom != null ? _domainPixels[_dragFrom!] : null,
              dragTo: _dragPosition,
              dividerX: size.width * 0.5,
            ),
            child: Stack(
              children: [
                // Labels
                Positioned(
                  left: 16,
                  top: 4,
                  child: Text('P',
                      style: TextStyle(
                          color: Palette.pink.withValues(alpha: 0.6),
                          fontSize: 16,
                          fontWeight: FontWeight.w800)),
                ),
                Positioned(
                  right: 16,
                  top: 4,
                  child: Text('Q',
                      style: TextStyle(
                          color: Palette.cyan.withValues(alpha: 0.6),
                          fontSize: 16,
                          fontWeight: FontWeight.w800)),
                ),
                // Domain nodes (draggable via outer GestureDetector)
                for (var i = 0; i < _domainPixels.length; i++)
                  Positioned(
                    left: _domainPixels[i].dx - 24,
                    top: _domainPixels[i].dy - 24,
                    child: IgnorePointer(
                      child: _buildNode(
                        label: widget.config.domainLabels[i],
                        color: Palette.pink,
                        isMapped: _mapping.containsKey(i),
                        isDragging: _dragFrom == i,
                      ),
                    ),
                  ),
                // Codomain nodes
                for (var i = 0; i < _codomainPixels.length; i++)
                  Positioned(
                    left: _codomainPixels[i].dx - 24,
                    top: _codomainPixels[i].dy - 24,
                    child: IgnorePointer(
                      child: _buildNode(
                        label: widget.config.codomainLabels[i],
                        color: Palette.cyan,
                        isMapped: _mapping.values.contains(i),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildNode({
    required String label,
    required Color color,
    bool isMapped = false,
    bool isDragging = false,
  }) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isMapped ? color.withValues(alpha: 0.12) : Palette.bgCard,
        border: Border.all(
          color: isDragging ? Palette.yellow : color,
          width: isDragging ? 3 : 2,
        ),
        boxShadow: [
          BoxShadow(
            color: (isDragging ? Palette.yellow : color)
                .withValues(alpha: isDragging ? 0.5 : 0.2),
            blurRadius: isDragging ? 16 : 10,
          ),
        ],
      ),
      child: Center(
        child: Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: label.length > 3 ? 9 : 13,
            fontWeight: FontWeight.w700,
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
          Text(widget.config.title,
              style: const TextStyle(
                  color: Palette.textPrimary,
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 2)),
          const SizedBox(width: 12),
          // Arrow count
          Text('${_mapping.length}/${widget.config.domainLabels.length}',
              style: TextStyle(
                  color: Palette.textDim.withValues(alpha: 0.6),
                  fontSize: 14)),
          const Spacer(),
          if (widget.config.hint != null && !_levelComplete)
            GestureDetector(
              onTap: () => ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(widget.config.hint!,
                    style: const TextStyle(color: Palette.textPrimary)),
                backgroundColor: Palette.bgCard,
                behavior: SnackBarBehavior.floating,
              )),
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
              onPressed: _mapping.isEmpty ? null : _removeLast,
              style: OutlinedButton.styleFrom(
                foregroundColor: Palette.textSecondary,
                side: BorderSide(
                    color: Palette.textDim.withValues(alpha: 0.3)),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('UNDO', style: TextStyle(letterSpacing: 2)),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: OutlinedButton(
              onPressed: _mapping.isEmpty ? null : _reset,
              style: OutlinedButton.styleFrom(
                foregroundColor: Palette.textSecondary,
                side: BorderSide(
                    color: Palette.textDim.withValues(alpha: 0.3)),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('RESET', style: TextStyle(letterSpacing: 2)),
            ),
          ),
          const SizedBox(width: 8),
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
        child: Text(widget.config.notationReveal!,
            textAlign: TextAlign.center,
            style: const TextStyle(
                color: Palette.cyan,
                fontSize: 18,
                fontWeight: FontWeight.w600,
                letterSpacing: 1,
                height: 1.6)),
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

class _MonotonePainter extends CustomPainter {
  final List<Offset> domainPixels;
  final List<Offset> codomainPixels;
  final Set<(int, int)> domainEdges;
  final Set<(int, int)> codomainEdges;
  final Map<int, int> mapping;
  final Offset? dragFrom;
  final Offset? dragTo;
  final double dividerX;

  _MonotonePainter({
    required this.domainPixels,
    required this.codomainPixels,
    required this.domainEdges,
    required this.codomainEdges,
    required this.mapping,
    this.dragFrom,
    this.dragTo,
    required this.dividerX,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Divider line
    final divPaint = Paint()
      ..color = Palette.textDim.withValues(alpha: 0.1)
      ..strokeWidth = 1;
    canvas.drawLine(
        Offset(dividerX, 20), Offset(dividerX, size.height - 20), divPaint);

    // Domain edges (pink)
    _drawEdges(canvas, domainPixels, domainEdges, Palette.pink);
    // Codomain edges (cyan)
    _drawEdges(canvas, codomainPixels, codomainEdges, Palette.cyan);

    // Mapping arrows (dashed, yellow)
    final arrowPaint = Paint()
      ..color = Palette.yellow.withValues(alpha: 0.7)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    for (final entry in mapping.entries) {
      final from = domainPixels[entry.key];
      final to = codomainPixels[entry.value];
      _drawDashedArrow(canvas, from, to, arrowPaint);
    }

    // Active drag line
    if (dragFrom != null && dragTo != null) {
      final dragPaint = Paint()
        ..color = Palette.yellow.withValues(alpha: 0.5)
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke;
      canvas.drawLine(dragFrom!, dragTo!, dragPaint);
    }
  }

  void _drawEdges(
      Canvas canvas, List<Offset> positions, Set<(int, int)> edges, Color color) {
    for (final (from, to) in edges) {
      final fromPos = positions[from];
      final toPos = positions[to];
      final delta = toPos - fromPos;
      final dist = delta.distance;
      if (dist < 1) continue;
      final dir = delta / dist;
      final start = fromPos + dir * 24;
      final end = toPos - dir * 24;

      final glowPaint = Paint()
        ..color = color.withValues(alpha: 0.08)
        ..strokeWidth = 4
        ..style = PaintingStyle.stroke
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
      canvas.drawLine(start, end, glowPaint);

      final linePaint = Paint()
        ..color = color.withValues(alpha: 0.3)
        ..strokeWidth = 1.5
        ..style = PaintingStyle.stroke;
      canvas.drawLine(start, end, linePaint);

      // Arrowhead
      final angle = math.atan2(delta.dy, delta.dx);
      const headLen = 7.0;
      const headAngle = 0.4;
      canvas.drawLine(
        end,
        Offset(end.dx - headLen * math.cos(angle - headAngle),
            end.dy - headLen * math.sin(angle - headAngle)),
        linePaint,
      );
      canvas.drawLine(
        end,
        Offset(end.dx - headLen * math.cos(angle + headAngle),
            end.dy - headLen * math.sin(angle + headAngle)),
        linePaint,
      );
    }
  }

  void _drawDashedArrow(Canvas canvas, Offset from, Offset to, Paint paint) {
    final delta = to - from;
    final dist = delta.distance;
    if (dist < 1) return;
    final dir = delta / dist;
    final start = from + dir * 24;
    final end = to - dir * 24;

    // Draw dashed line
    const dashLen = 6.0;
    const gapLen = 4.0;
    var d = 0.0;
    final lineDir = (end - start);
    final lineDist = lineDir.distance;
    final lineNorm = lineDir / lineDist;
    while (d < lineDist) {
      final segEnd = math.min(d + dashLen, lineDist);
      canvas.drawLine(
        start + lineNorm * d,
        start + lineNorm * segEnd,
        paint,
      );
      d = segEnd + gapLen;
    }

    // Arrowhead
    final angle = math.atan2(delta.dy, delta.dx);
    const headLen = 8.0;
    const headAngle = 0.4;
    final headPaint = Paint()
      ..color = paint.color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    canvas.drawLine(
      end,
      Offset(end.dx - headLen * math.cos(angle - headAngle),
          end.dy - headLen * math.sin(angle - headAngle)),
      headPaint,
    );
    canvas.drawLine(
      end,
      Offset(end.dx - headLen * math.cos(angle + headAngle),
          end.dy - headLen * math.sin(angle + headAngle)),
      headPaint,
    );
  }

  @override
  bool shouldRepaint(_MonotonePainter oldDelegate) => true;
}
