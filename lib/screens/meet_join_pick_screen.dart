import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/haptics.dart';
import '../theme/palette.dart';

/// Level where the player taps the correct meet or join of two
/// highlighted elements in a Hasse diagram.

enum MeetOrJoin { meet, join }

class MeetJoinPickConfig {
  final String id;
  final String title;
  final String? subtitle;
  final List<String> elementLabels;
  final List<Offset> positions;
  /// Hasse diagram edges (covers): from index → to index (upward).
  final Set<(int, int)> edges;
  /// The two highlighted elements.
  final (int, int) highlighted;
  /// Which operation to find.
  final MeetOrJoin operation;
  /// Index of the correct answer.
  final int answer;
  final String? notationReveal;
  final String? hint;

  const MeetJoinPickConfig({
    required this.id,
    required this.title,
    this.subtitle,
    required this.elementLabels,
    required this.positions,
    required this.edges,
    required this.highlighted,
    required this.operation,
    required this.answer,
    this.notationReveal,
    this.hint,
  });
}

class MeetJoinPickScreen extends StatefulWidget {
  final MeetJoinPickConfig config;
  final VoidCallback onComplete;

  const MeetJoinPickScreen({
    super.key,
    required this.config,
    required this.onComplete,
  });

  @override
  State<MeetJoinPickScreen> createState() => _MeetJoinPickScreenState();
}

class _MeetJoinPickScreenState extends State<MeetJoinPickScreen> {
  int? _selected;
  bool _levelComplete = false;
  bool _showNotation = false;

  void _onTap(int index) {
    if (_levelComplete) return;

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
      final opName = widget.config.operation == MeetOrJoin.meet
          ? 'meet (greatest lower bound)'
          : 'join (least upper bound)';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Not quite — find the $opName.',
              style: const TextStyle(color: Palette.textPrimary)),
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
    final opSymbol =
        widget.config.operation == MeetOrJoin.meet ? '∧' : '∨';
    final (hiA, hiB) = widget.config.highlighted;

    return Scaffold(
      backgroundColor: Palette.bg,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
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
                  if (widget.config.hint != null && !_levelComplete)
                    GestureDetector(
                      onTap: () =>
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text(widget.config.hint!,
                            style: const TextStyle(
                                color: Palette.textPrimary)),
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
              child: RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: const TextStyle(
                      color: Palette.textSecondary, fontSize: 16),
                  children: [
                    const TextSpan(text: 'Find '),
                    TextSpan(
                      text: widget.config.elementLabels[hiA],
                      style: const TextStyle(
                          color: Palette.pink, fontWeight: FontWeight.w700),
                    ),
                    TextSpan(
                      text: ' $opSymbol ',
                      style: const TextStyle(
                          color: Palette.yellow,
                          fontWeight: FontWeight.w800,
                          fontSize: 20),
                    ),
                    TextSpan(
                      text: widget.config.elementLabels[hiB],
                      style: const TextStyle(
                          color: Palette.cyan, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
            ),
            // Diagram
            Expanded(child: _buildDiagram()),
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
        final (hiA, hiB) = widget.config.highlighted;

        return CustomPaint(
          painter: _DiagramPainter(
            positions: positions,
            edges: widget.config.edges,
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
                      isHighlightedA: i == hiA,
                      isHighlightedB: i == hiB,
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
  final bool isHighlightedA;
  final bool isHighlightedB;
  final bool isSelected;
  final bool isAnswer;

  const _DiagramNode({
    required this.label,
    this.isHighlightedA = false,
    this.isHighlightedB = false,
    this.isSelected = false,
    this.isAnswer = false,
  });

  @override
  Widget build(BuildContext context) {
    final Color color;
    if (isAnswer) {
      color = Palette.green;
    } else if (isHighlightedA) {
      color = Palette.pink;
    } else if (isHighlightedB) {
      color = Palette.cyan;
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
        color: (isHighlightedA || isHighlightedB || isAnswer)
            ? color.withValues(alpha: 0.1)
            : Palette.bgCard,
        border: Border.all(color: color, width: isAnswer ? 3 : 2),
        boxShadow: [
          BoxShadow(
            color: color.withValues(
                alpha: isAnswer ? 0.5 : isHighlightedA || isHighlightedB ? 0.4 : 0.15),
            blurRadius: isAnswer ? 20 : 12,
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

  _DiagramPainter({required this.positions, required this.edges});

  @override
  void paint(Canvas canvas, Size size) {
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
      final headLen = 8.0;
      final headAngle = 0.4;
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

  @override
  bool shouldRepaint(_DiagramPainter oldDelegate) => false;
}
