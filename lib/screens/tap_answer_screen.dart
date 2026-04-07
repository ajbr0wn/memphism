import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/haptics.dart';
import '../theme/palette.dart';

/// Generic "tap the correct node" screen for map application,
/// composition, and ordering questions over a Hasse diagram.

class TapAnswerConfig {
  final String id;
  final String title;
  final String? subtitle;

  /// The question displayed (can use rich formatting).
  final String question;

  /// Elements in the diagram.
  final List<String> elementLabels;
  final List<Offset> positions;

  /// Hasse edges (covers): from index → to index.
  final Set<(int, int)> edges;

  /// Optional: arrows showing a given map (drawn as dashed yellow lines).
  /// Each entry is (fromIndex, toIndex) — NOT Hasse edges, but map arrows.
  final List<(int, int)> mapArrows;

  /// Correct answer index.
  final int answer;

  /// Optional highlighted elements (e.g., the input being mapped).
  final Set<int> highlighted;
  final String? notationReveal;
  final String? hint;

  const TapAnswerConfig({
    required this.id,
    required this.title,
    this.subtitle,
    required this.question,
    required this.elementLabels,
    required this.positions,
    required this.edges,
    this.mapArrows = const [],
    required this.answer,
    this.highlighted = const {},
    this.notationReveal,
    this.hint,
  });
}

class TapAnswerScreen extends StatefulWidget {
  final TapAnswerConfig config;
  final VoidCallback onComplete;

  const TapAnswerScreen({
    super.key,
    required this.config,
    required this.onComplete,
  });

  @override
  State<TapAnswerScreen> createState() => _TapAnswerScreenState();
}

class _TapAnswerScreenState extends State<TapAnswerScreen>
    with SingleTickerProviderStateMixin {
  int? _selected;
  bool _levelComplete = false;
  bool _showNotation = false;

  late final AnimationController _shakeController;
  late final Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _shakeAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0, end: 6), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 6, end: -5), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -5, end: 3), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 3, end: -2), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -2, end: 0), weight: 1),
    ]).animate(_shakeController);
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  void _onTap(int index) {
    if (_levelComplete) return;
    Haptics.tap();

    setState(() => _selected = index);

    if (index == widget.config.answer) {
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
      _shakeController.forward(from: 0);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Not quite.',
              style: TextStyle(color: Palette.textPrimary)),
          backgroundColor: Palette.bgCard,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) setState(() => _selected = null);
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
            // Header
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.config.title,
                            style: const TextStyle(
                                color: Palette.textPrimary,
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 2)),
                        if (widget.config.subtitle != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(widget.config.subtitle!,
                                style: const TextStyle(
                                    color: Palette.textDim, fontSize: 13)),
                          ),
                      ],
                    ),
                  ),
                  if (widget.config.hint != null && !_levelComplete)
                    GestureDetector(
                      onTap: () =>
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text(widget.config.hint!,
                            style:
                                const TextStyle(color: Palette.textPrimary)),
                        backgroundColor: Palette.bgCard,
                        behavior: SnackBarBehavior.floating,
                      )),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Palette.bgCard,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: Palette.textDim.withValues(alpha: 0.3)),
                        ),
                        child: const Text('?',
                            style: TextStyle(color: Palette.textDim)),
                      ),
                    ),
                ],
              ),
            ),
            // Question
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Text(
                widget.config.question,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: Palette.textSecondary,
                    fontSize: 16,
                    height: 1.5),
              ),
            ),
            const SizedBox(height: 8),
            // Diagram
            Expanded(
              child: AnimatedBuilder(
                animation: _shakeController,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(_shakeAnimation.value, 0),
                    child: child,
                  );
                },
                child: _buildDiagram(),
              ),
            ),
            if (_showNotation) _buildNotation(),
            if (_levelComplete) _buildContinue(),
          ],
        ),
      ),
    );
  }

  Widget _buildDiagram() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = constraints.biggest;
        final positions = widget.config.positions
            .map((p) => Offset(p.dx * size.width, p.dy * size.height))
            .toList();

        return CustomPaint(
          painter: _DiagramPainter(
            positions: positions,
            edges: widget.config.edges,
            mapArrows: widget.config.mapArrows,
          ),
          child: Stack(
            children: [
              for (var i = 0; i < positions.length; i++)
                Positioned(
                  left: positions[i].dx - 26,
                  top: positions[i].dy - 26,
                  child: GestureDetector(
                    onTap: () => _onTap(i),
                    child: _DiagramNode(
                      label: widget.config.elementLabels[i],
                      isHighlighted: widget.config.highlighted.contains(i),
                      isSelected: _selected == i,
                      isAnswer: _levelComplete && i == widget.config.answer,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
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

class _DiagramNode extends StatelessWidget {
  final String label;
  final bool isHighlighted;
  final bool isSelected;
  final bool isAnswer;

  const _DiagramNode({
    required this.label,
    this.isHighlighted = false,
    this.isSelected = false,
    this.isAnswer = false,
  });

  @override
  Widget build(BuildContext context) {
    final Color color;
    if (isAnswer) {
      color = Palette.green;
    } else if (isHighlighted) {
      color = Palette.pink;
    } else if (isSelected) {
      color = Palette.error;
    } else {
      color = Palette.textDim;
    }

    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: (isHighlighted || isAnswer)
            ? color.withValues(alpha: 0.1)
            : Palette.bgCard,
        border: Border.all(color: color, width: isAnswer ? 3 : 2),
        boxShadow: [
          BoxShadow(
            color: color.withValues(
                alpha: isAnswer
                    ? 0.5
                    : isHighlighted
                        ? 0.4
                        : 0.15),
            blurRadius: isAnswer
                ? 20
                : isHighlighted
                    ? 16
                    : 12,
          ),
        ],
      ),
      child: Center(
        child: Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: label.length > 3 ? 10 : 14,
            fontWeight: FontWeight.w700,
            shadows: [
              Shadow(color: color.withValues(alpha: 0.6), blurRadius: 6),
            ],
          ),
        ),
      ),
    );
  }
}

class _DiagramPainter extends CustomPainter {
  final List<Offset> positions;
  final Set<(int, int)> edges;
  final List<(int, int)> mapArrows;

  _DiagramPainter({
    required this.positions,
    required this.edges,
    required this.mapArrows,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Hasse edges — solid, dim
    for (final (from, to) in edges) {
      final fromPos = positions[from];
      final toPos = positions[to];
      final delta = toPos - fromPos;
      final dist = delta.distance;
      if (dist < 1) continue;
      final dir = delta / dist;
      final start = fromPos + dir * 26;
      final end = toPos - dir * 26;

      final glowPaint = Paint()
        ..color = Palette.textDim.withValues(alpha: 0.1)
        ..strokeWidth = 4
        ..style = PaintingStyle.stroke
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
      canvas.drawLine(start, end, glowPaint);

      final linePaint = Paint()
        ..color = Palette.textDim.withValues(alpha: 0.25)
        ..strokeWidth = 1.5
        ..style = PaintingStyle.stroke;
      canvas.drawLine(start, end, linePaint);

      // Arrowhead
      final angle = math.atan2(delta.dy, delta.dx);
      const headLen = 8.0;
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

    // 2. Map arrows — dashed, yellow
    if (mapArrows.isNotEmpty) {
      for (final (from, to) in mapArrows) {
        final fromPos = positions[from];
        final toPos = positions[to];
        final delta = toPos - fromPos;
        final dist = delta.distance;
        if (dist < 1) continue;
        final dir = delta / dist;
        final start = fromPos + dir * 28;
        final end = toPos - dir * 28;

        // Dashed yellow glow
        final glowPaint = Paint()
          ..color = Palette.yellow.withValues(alpha: 0.15)
          ..strokeWidth = 5
          ..style = PaintingStyle.stroke
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
        _drawDashedLine(canvas, start, end, glowPaint, 8, 5);

        // Dashed yellow line
        final dashPaint = Paint()
          ..color = Palette.yellow.withValues(alpha: 0.7)
          ..strokeWidth = 2
          ..style = PaintingStyle.stroke;
        _drawDashedLine(canvas, start, end, dashPaint, 8, 5);

        // Arrowhead
        final angle = math.atan2(delta.dy, delta.dx);
        const headLen = 10.0;
        const headAngle = 0.4;
        final arrowPaint = Paint()
          ..color = Palette.yellow.withValues(alpha: 0.7)
          ..strokeWidth = 2
          ..style = PaintingStyle.stroke;
        canvas.drawLine(
          end,
          Offset(end.dx - headLen * math.cos(angle - headAngle),
              end.dy - headLen * math.sin(angle - headAngle)),
          arrowPaint,
        );
        canvas.drawLine(
          end,
          Offset(end.dx - headLen * math.cos(angle + headAngle),
              end.dy - headLen * math.sin(angle + headAngle)),
          arrowPaint,
        );
      }
    }
  }

  void _drawDashedLine(
      Canvas canvas, Offset from, Offset to, Paint paint, double dash, double gap) {
    final delta = to - from;
    final dist = delta.distance;
    final dir = delta / dist;
    var drawn = 0.0;
    while (drawn < dist) {
      final segEnd = math.min(drawn + dash, dist);
      canvas.drawLine(from + dir * drawn, from + dir * segEnd, paint);
      drawn = segEnd + gap;
    }
  }

  @override
  bool shouldRepaint(_DiagramPainter oldDelegate) => false;
}
