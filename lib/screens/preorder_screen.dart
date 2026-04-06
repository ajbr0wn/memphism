import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/haptics.dart';
import '../theme/palette.dart';

/// Level where the player draws arrows between elements to build a preorder.
/// Teaches: preorders, Hasse diagrams, divisibility, power sets.

class PreorderLevelConfig {
  final String id;
  final String title;
  final String? subtitle;
  final List<String> elementLabels;
  final List<Offset> positions; // relative 0-1
  /// The correct set of edges (pairs of element indices): from ≤ to.
  /// Only direct/cover edges, not transitive closure.
  final Set<(int, int)> expectedEdges;
  final String? notationReveal;
  final String? hint;

  const PreorderLevelConfig({
    required this.id,
    required this.title,
    this.subtitle,
    required this.elementLabels,
    required this.positions,
    required this.expectedEdges,
    this.notationReveal,
    this.hint,
  });
}

class PreorderScreen extends StatefulWidget {
  final PreorderLevelConfig config;
  final VoidCallback onComplete;

  const PreorderScreen({
    super.key,
    required this.config,
    required this.onComplete,
  });

  @override
  State<PreorderScreen> createState() => _PreorderScreenState();
}

class _PreorderScreenState extends State<PreorderScreen> {
  final Set<(int, int)> _edges = {};
  int? _dragFrom;
  Offset? _dragPosition;
  bool _levelComplete = false;
  bool _showNotation = false;

  void _submit() {
    if (_edges.length == widget.config.expectedEdges.length &&
        _edges.every((e) => widget.config.expectedEdges.contains(e))) {
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
      final missing = widget.config.expectedEdges.difference(_edges);
      final extra = _edges.difference(widget.config.expectedEdges);
      if (extra.isNotEmpty) {
        _showSnack('Some arrows don\'t belong. Try removing one.');
      } else if (missing.isNotEmpty) {
        _showSnack('Missing ${missing.length} arrow${missing.length > 1 ? 's' : ''}.');
      }
    }
  }

  void _reset() => setState(() => _edges.clear());

  void _showSnack(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text, style: const TextStyle(color: Palette.textPrimary)),
        backgroundColor: Palette.bgCard,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
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
                child: Text(widget.config.subtitle!,
                    style: const TextStyle(
                        color: Palette.textDim,
                        fontSize: 13,
                        letterSpacing: 0.5)),
              ),
            Expanded(child: _buildCanvas()),
            if (!_levelComplete) _buildControls(),
            if (_showNotation) _buildNotation(),
            if (_levelComplete) _buildContinue(),
          ],
        ),
      ),
    );
  }

  Widget _buildCanvas() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = constraints.biggest;
        final positions = widget.config.positions
            .map((p) => Offset(p.dx * size.width, p.dy * size.height))
            .toList();

        return GestureDetector(
          onPanStart: (details) {
            for (var i = 0; i < positions.length; i++) {
              if ((details.localPosition - positions[i]).distance < 32) {
                setState(() {
                  _dragFrom = i;
                  _dragPosition = details.localPosition;
                });
                Haptics.tap();
                return;
              }
            }
          },
          onPanUpdate: (details) {
            if (_dragFrom != null) {
              setState(() => _dragPosition = details.localPosition);
            }
          },
          onPanEnd: (_) {
            if (_dragFrom != null && _dragPosition != null) {
              for (var i = 0; i < positions.length; i++) {
                if (i != _dragFrom &&
                    (_dragPosition! - positions[i]).distance < 36) {
                  final edge = (_dragFrom!, i);
                  setState(() {
                    if (_edges.contains(edge)) {
                      _edges.remove(edge); // toggle off
                    } else {
                      _edges.add(edge);
                    }
                  });
                  Haptics.snap();
                  break;
                }
              }
            }
            setState(() {
              _dragFrom = null;
              _dragPosition = null;
            });
          },
          child: CustomPaint(
            painter: _PreorderPainter(
              positions: positions,
              labels: widget.config.elementLabels,
              edges: _edges,
              dragFrom:
                  _dragFrom != null ? positions[_dragFrom!] : null,
              dragTo: _dragPosition,
            ),
            child: Stack(
              children: [
                for (var i = 0; i < positions.length; i++)
                  Positioned(
                    left: positions[i].dx - 22,
                    top: positions[i].dy - 22,
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Palette.bgCard,
                        border: Border.all(
                          color: Palette.nodeColor(i % 6),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Palette.nodeColor(i % 6)
                                .withValues(alpha: 0.3),
                            blurRadius: 12,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          widget.config.elementLabels[i],
                          style: TextStyle(
                            color: Palette.textPrimary,
                            fontSize:
                                widget.config.elementLabels[i].length > 2
                                    ? 10
                                    : 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
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
          const Spacer(),
          // Edge count
          Text(
            '${_edges.length} arrows',
            style: TextStyle(
              color: Palette.textDim,
              fontSize: 12,
            ),
          ),
          const SizedBox(width: 12),
          if (widget.config.hint != null && !_levelComplete)
            GestureDetector(
              onTap: () => _showSnack(widget.config.hint!),
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
              child: const Text('RESET', style: TextStyle(letterSpacing: 2)),
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

class _PreorderPainter extends CustomPainter {
  final List<Offset> positions;
  final List<String> labels;
  final Set<(int, int)> edges;
  final Offset? dragFrom;
  final Offset? dragTo;

  _PreorderPainter({
    required this.positions,
    required this.labels,
    required this.edges,
    this.dragFrom,
    this.dragTo,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Draw edges
    for (final (from, to) in edges) {
      _drawArrow(canvas, positions[from], positions[to],
          Palette.cyan.withValues(alpha: 0.6));
    }

    // Draw drag
    if (dragFrom != null && dragTo != null) {
      _drawArrow(canvas, dragFrom!, dragTo!,
          Palette.cyan.withValues(alpha: 0.3));
    }
  }

  void _drawArrow(Canvas canvas, Offset from, Offset to, Color color) {
    final delta = to - from;
    final dist = delta.distance;
    if (dist < 1) return;
    final dir = delta / dist;
    final start = from + dir * 22;
    final end = to - dir * 22;

    final glowPaint = Paint()
      ..color = color.withValues(alpha: 0.15)
      ..strokeWidth = 5
      ..style = PaintingStyle.stroke
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    canvas.drawLine(start, end, glowPaint);

    final linePaint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    canvas.drawLine(start, end, linePaint);

    final angle = math.atan2(delta.dy, delta.dx);
    final headLen = 10.0;
    final headAngle = 0.4;
    final headPaint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
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
  bool shouldRepaint(_PreorderPainter oldDelegate) => true;
}
