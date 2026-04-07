import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/haptics.dart';
import '../theme/palette.dart';

/// Level where the player finds the right adjoint g for a given left adjoint f
/// (or vice versa) in a Galois connection between two preorders.
///
/// A Galois connection is a pair f: P → Q and g: Q → P such that
/// f(p) ≤ q  iff  p ≤ g(q) for all p ∈ P and q ∈ Q.
///
/// The player is shown f (or g) and must construct the other map.

class GaloisLevelConfig {
  final String id;
  final String title;
  final String? subtitle;
  /// Left preorder P.
  final List<String> pLabels;
  final List<Offset> pPositions;
  final Set<(int, int)> pEdges;
  /// Right preorder Q.
  final List<String> qLabels;
  final List<Offset> qPositions;
  final Set<(int, int)> qEdges;
  /// The given map (shown, not editable).
  final Map<int, int> givenMap;
  /// Which direction is given: true = f is given (P→Q), find g (Q→P).
  /// false = g is given (Q→P), find f (P→Q).
  final bool fIsGiven;
  /// The expected answer map.
  final Map<int, int> expectedAnswer;
  final String? notationReveal;
  final String? hint;

  const GaloisLevelConfig({
    required this.id,
    required this.title,
    this.subtitle,
    required this.pLabels,
    required this.pPositions,
    required this.pEdges,
    required this.qLabels,
    required this.qPositions,
    required this.qEdges,
    required this.givenMap,
    required this.fIsGiven,
    required this.expectedAnswer,
    this.notationReveal,
    this.hint,
  });
}

class GaloisScreen extends StatefulWidget {
  final GaloisLevelConfig config;
  final VoidCallback onComplete;

  const GaloisScreen({
    super.key,
    required this.config,
    required this.onComplete,
  });

  @override
  State<GaloisScreen> createState() => _GaloisScreenState();
}

class _GaloisScreenState extends State<GaloisScreen> {
  final Map<int, int> _answer = {};
  int? _dragFrom;
  Offset? _dragPosition;
  bool _levelComplete = false;
  bool _showNotation = false;

  List<Offset> _pPixels = [];
  List<Offset> _qPixels = [];
  Size _lastSize = Size.zero;

  int get _answerSize => widget.config.fIsGiven
      ? widget.config.qLabels.length  // finding g: Q → P
      : widget.config.pLabels.length; // finding f: P → Q

  List<String> get _fromLabels => widget.config.fIsGiven
      ? widget.config.qLabels  // drag from Q
      : widget.config.pLabels; // drag from P

  List<String> get _toLabels => widget.config.fIsGiven
      ? widget.config.pLabels  // drag to P
      : widget.config.qLabels; // drag to Q

  List<Offset> get _fromPixels => widget.config.fIsGiven ? _qPixels : _pPixels;
  List<Offset> get _toPixels => widget.config.fIsGiven ? _pPixels : _qPixels;

  /// Hit-test pan start against draggable nodes.
  void _onPanStart(Offset position) {
    if (_levelComplete) return;
    final fromPixels = _fromPixels;
    for (var i = 0; i < fromPixels.length; i++) {
      if ((fromPixels[i] - position).distance < 36) {
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
    if (_dragFrom == null || _dragPosition == null) {
      setState(() {
        _dragFrom = null;
        _dragPosition = null;
      });
      return;
    }

    int? nearest;
    double nearestDist = 40;
    for (var i = 0; i < _toPixels.length; i++) {
      final d = (_toPixels[i] - _dragPosition!).distance;
      if (d < nearestDist) {
        nearestDist = d;
        nearest = i;
      }
    }

    if (nearest != null) {
      setState(() => _answer[_dragFrom!] = nearest!);
      Haptics.snap();
    }

    setState(() {
      _dragFrom = null;
      _dragPosition = null;
    });
  }

  void _submit() {
    if (_answer.length < _answerSize) {
      Haptics.fizzle();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Map all $_answerSize elements first!',
              style: const TextStyle(color: Palette.textPrimary)),
          backgroundColor: Palette.bgCard,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // Check against expected
    for (final entry in widget.config.expectedAnswer.entries) {
      if (_answer[entry.key] != entry.value) {
        Haptics.fizzle();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                widget.config.fIsGiven
                    ? 'Not quite — check: f(p) ≤ q iff p ≤ g(q).'
                    : 'Not quite — check: f(p) ≤ q iff p ≤ g(q).',
                style: const TextStyle(color: Palette.textPrimary)),
            backgroundColor: Palette.bgCard,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
          ),
        );
        return;
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

  void _reset() => setState(() => _answer.clear());

  @override
  Widget build(BuildContext context) {
    final givenDir = widget.config.fIsGiven ? 'f : P → Q' : 'g : Q → P';
    final findDir = widget.config.fIsGiven ? 'g : Q → P' : 'f : P → Q';

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
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        color: Palette.textSecondary, fontSize: 14)),
              ),
            // Show what's given vs what to find
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _chip(givenDir, Palette.textDim, 'given'),
                  const SizedBox(width: 16),
                  _chip(findDir, Palette.yellow, 'find'),
                ],
              ),
            ),
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

  Widget _chip(String text, Color color, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.4)),
        color: color.withValues(alpha: 0.08),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label,
              style: TextStyle(
                  color: color.withValues(alpha: 0.6),
                  fontSize: 10,
                  fontWeight: FontWeight.w600)),
          Text(text,
              style: TextStyle(
                  color: color,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'monospace')),
        ],
      ),
    );
  }

  Widget _buildDiagramArea() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = constraints.biggest;
        if (size != _lastSize) {
          _lastSize = size;
          final halfW = size.width * 0.42;
          final leftOffset = size.width * 0.04;
          final rightOffset = size.width * 0.54;

          _pPixels = widget.config.pPositions
              .map((p) =>
                  Offset(leftOffset + p.dx * halfW, p.dy * size.height))
              .toList();
          _qPixels = widget.config.qPositions
              .map((p) =>
                  Offset(rightOffset + p.dx * halfW, p.dy * size.height))
              .toList();
        }

        return GestureDetector(
          onPanStart: (d) => _onPanStart(d.localPosition),
          onPanUpdate: (d) => _onDragUpdate(d.localPosition),
          onPanEnd: (_) => _onDragEnd(),
          child: CustomPaint(
            painter: _GaloisPainter(
              pPixels: _pPixels,
              qPixels: _qPixels,
              pEdges: widget.config.pEdges,
              qEdges: widget.config.qEdges,
              givenMap: widget.config.givenMap,
              fIsGiven: widget.config.fIsGiven,
              answer: _answer,
              dragFrom: _dragFrom != null ? _fromPixels[_dragFrom!] : null,
              dragTo: _dragPosition,
              dividerX: size.width * 0.5,
            ),
            child: Stack(
              children: [
                // Labels
                Positioned(
                  left: 16, top: 4,
                  child: Text('P',
                      style: TextStyle(
                          color: Palette.pink.withValues(alpha: 0.6),
                          fontSize: 16,
                          fontWeight: FontWeight.w800)),
                ),
                Positioned(
                  right: 16, top: 4,
                  child: Text('Q',
                      style: TextStyle(
                          color: Palette.cyan.withValues(alpha: 0.6),
                          fontSize: 16,
                          fontWeight: FontWeight.w800)),
                ),
                // P nodes (no individual gesture detectors)
                for (var i = 0; i < _pPixels.length; i++)
                  _buildNodeAt(_pPixels[i], widget.config.pLabels[i],
                      Palette.pink, i),
                // Q nodes
                for (var i = 0; i < _qPixels.length; i++)
                  _buildNodeAt(_qPixels[i], widget.config.qLabels[i],
                      Palette.cyan, i),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildNodeAt(
      Offset pos, String label, Color color, int index) {
    // Check if this node is being dragged (it's a "from" node and matches _dragFrom)
    final isDragging = _dragFrom == index && _fromPixels == (
        widget.config.fIsGiven ? _qPixels : _pPixels) &&
        (widget.config.fIsGiven ? color == Palette.cyan : color == Palette.pink);

    return Positioned(
      left: pos.dx - 24,
      top: pos.dy - 24,
      child: IgnorePointer(
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Palette.bgCard,
            border: Border.all(
              color: isDragging ? Palette.yellow : color,
              width: isDragging ? 3 : 2,
            ),
            boxShadow: [
              BoxShadow(
                color: (isDragging ? Palette.yellow : color)
                    .withValues(alpha: isDragging ? 0.4 : 0.2),
                blurRadius: isDragging ? 16 : 10,
              ),
            ],
          ),
          child: Center(
            child: Text(label,
                style: TextStyle(
                    color: color,
                    fontSize: label.length > 3 ? 9 : 13,
                    fontWeight: FontWeight.w700)),
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
          Text('${_answer.length}/$_answerSize',
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
              onPressed: _answer.isEmpty ? null : _reset,
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
                fontSize: 16,
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

class _GaloisPainter extends CustomPainter {
  final List<Offset> pPixels;
  final List<Offset> qPixels;
  final Set<(int, int)> pEdges;
  final Set<(int, int)> qEdges;
  final Map<int, int> givenMap;
  final bool fIsGiven;
  final Map<int, int> answer;
  final Offset? dragFrom;
  final Offset? dragTo;
  final double dividerX;

  _GaloisPainter({
    required this.pPixels,
    required this.qPixels,
    required this.pEdges,
    required this.qEdges,
    required this.givenMap,
    required this.fIsGiven,
    required this.answer,
    this.dragFrom,
    this.dragTo,
    required this.dividerX,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Divider
    final divPaint = Paint()
      ..color = Palette.textDim.withValues(alpha: 0.1)
      ..strokeWidth = 1;
    canvas.drawLine(
        Offset(dividerX, 20), Offset(dividerX, size.height - 20), divPaint);

    // P edges (pink)
    _drawEdges(canvas, pPixels, pEdges, Palette.pink);
    // Q edges (cyan)
    _drawEdges(canvas, qPixels, qEdges, Palette.cyan);

    // Given map arrows (dim, dashed)
    final givenPaint = Paint()
      ..color = Palette.textDim.withValues(alpha: 0.4)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    for (final entry in givenMap.entries) {
      final from = fIsGiven ? pPixels[entry.key] : qPixels[entry.key];
      final to = fIsGiven ? qPixels[entry.value] : pPixels[entry.value];
      _drawDashedArrow(canvas, from, to, givenPaint);
    }

    // Answer arrows (yellow, bright)
    final answerPaint = Paint()
      ..color = Palette.yellow.withValues(alpha: 0.8)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    for (final entry in answer.entries) {
      final fromPixels = fIsGiven ? qPixels : pPixels;
      final toPixels = fIsGiven ? pPixels : qPixels;
      _drawDashedArrow(
          canvas, fromPixels[entry.key], toPixels[entry.value], answerPaint);
    }

    // Drag line
    if (dragFrom != null && dragTo != null) {
      final dragPaint = Paint()
        ..color = Palette.yellow.withValues(alpha: 0.5)
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke;
      canvas.drawLine(dragFrom!, dragTo!, dragPaint);
    }
  }

  void _drawEdges(Canvas canvas, List<Offset> positions,
      Set<(int, int)> edges, Color color) {
    for (final (from, to) in edges) {
      final fromPos = positions[from];
      final toPos = positions[to];
      final delta = toPos - fromPos;
      final dist = delta.distance;
      if (dist < 1) continue;
      final dir = delta / dist;
      final start = fromPos + dir * 24;
      final end = toPos - dir * 24;

      final linePaint = Paint()
        ..color = color.withValues(alpha: 0.3)
        ..strokeWidth = 1.5
        ..style = PaintingStyle.stroke;
      canvas.drawLine(start, end, linePaint);

      final angle = math.atan2(delta.dy, delta.dx);
      const headLen = 7.0;
      const headAngle = 0.4;
      canvas.drawLine(
          end,
          Offset(end.dx - headLen * math.cos(angle - headAngle),
              end.dy - headLen * math.sin(angle - headAngle)),
          linePaint);
      canvas.drawLine(
          end,
          Offset(end.dx - headLen * math.cos(angle + headAngle),
              end.dy - headLen * math.sin(angle + headAngle)),
          linePaint);
    }
  }

  void _drawDashedArrow(
      Canvas canvas, Offset from, Offset to, Paint paint) {
    final delta = to - from;
    final dist = delta.distance;
    if (dist < 1) return;
    final dir = delta / dist;
    final start = from + dir * 24;
    final end = to - dir * 24;

    const dashLen = 6.0;
    const gapLen = 4.0;
    var d = 0.0;
    final lineDir = end - start;
    final lineDist = lineDir.distance;
    if (lineDist < 1) return;
    final lineNorm = lineDir / lineDist;
    while (d < lineDist) {
      final segEnd = math.min(d + dashLen, lineDist);
      canvas.drawLine(start + lineNorm * d, start + lineNorm * segEnd, paint);
      d = segEnd + gapLen;
    }

    final angle = math.atan2(delta.dy, delta.dx);
    const headLen = 8.0;
    const headAngle = 0.4;
    canvas.drawLine(
        end,
        Offset(end.dx - headLen * math.cos(angle - headAngle),
            end.dy - headLen * math.sin(angle - headAngle)),
        paint);
    canvas.drawLine(
        end,
        Offset(end.dx - headLen * math.cos(angle + headAngle),
            end.dy - headLen * math.sin(angle + headAngle)),
        paint);
  }

  @override
  bool shouldRepaint(_GaloisPainter oldDelegate) => true;
}
