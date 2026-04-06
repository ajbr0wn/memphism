import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/haptics.dart';
import '../theme/palette.dart';

/// Level where the player draws arrows from set A to set B to create a function.
/// Teaches: functions, injective, surjective, bijective.

class FunctionLevelConfig {
  final String id;
  final String title;
  final String? subtitle;
  final List<String> domainLabels;   // elements of A
  final List<String> codomainLabels; // elements of B
  /// What to check for completion.
  final FunctionGoal goal;
  final String? notationReveal;
  final String? hint;

  const FunctionLevelConfig({
    required this.id,
    required this.title,
    this.subtitle,
    required this.domainLabels,
    required this.codomainLabels,
    required this.goal,
    this.notationReveal,
    this.hint,
  });
}

enum FunctionGoal {
  /// Create any valid function (every domain element mapped to exactly one).
  anyFunction,
  /// Create an injective function (no two domain elements map to same target).
  injective,
  /// Create a surjective function (every codomain element is hit).
  surjective,
  /// Create a bijective function (both injective and surjective).
  bijective,
}

class FunctionScreen extends StatefulWidget {
  final FunctionLevelConfig config;
  final VoidCallback onComplete;

  const FunctionScreen({
    super.key,
    required this.config,
    required this.onComplete,
  });

  @override
  State<FunctionScreen> createState() => _FunctionScreenState();
}

class _FunctionScreenState extends State<FunctionScreen> {
  // Mapping: domain element index → codomain element index (or -1 if unmapped)
  late List<int> _mapping;
  int? _dragFrom; // domain index being dragged
  Offset? _dragPosition;
  bool _levelComplete = false;
  bool _showNotation = false;

  @override
  void initState() {
    super.initState();
    _mapping = List.filled(widget.config.domainLabels.length, -1);
  }

  bool _isFunction() => _mapping.every((m) => m >= 0);

  bool _isInjective() {
    if (!_isFunction()) return false;
    final seen = <int>{};
    for (final m in _mapping) {
      if (seen.contains(m)) return false;
      seen.add(m);
    }
    return true;
  }

  bool _isSurjective() {
    if (!_isFunction()) return false;
    final hit = _mapping.toSet();
    return hit.length == widget.config.codomainLabels.length;
  }

  bool _isBijective() => _isInjective() && _isSurjective();

  bool _checkGoal() {
    return switch (widget.config.goal) {
      FunctionGoal.anyFunction => _isFunction(),
      FunctionGoal.injective => _isInjective(),
      FunctionGoal.surjective => _isSurjective(),
      FunctionGoal.bijective => _isBijective(),
    };
  }

  void _submit() {
    if (!_isFunction()) {
      Haptics.fizzle();
      _showSnack('Every element on the left must have exactly one arrow.');
      return;
    }
    if (_checkGoal()) {
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
      final hint = switch (widget.config.goal) {
        FunctionGoal.injective =>
            'This function isn\'t injective — two inputs map to the same output.',
        FunctionGoal.surjective =>
            'This function isn\'t surjective — some outputs aren\'t hit.',
        FunctionGoal.bijective =>
            'This function isn\'t bijective — needs to be both injective and surjective.',
        _ => 'Not quite.',
      };
      _showSnack(hint);
    }
  }

  void _reset() {
    setState(() => _mapping = List.filled(widget.config.domainLabels.length, -1));
  }

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
                child: Text(
                  widget.config.subtitle!,
                  style: const TextStyle(
                    color: Palette.textDim,
                    fontSize: 13,
                    letterSpacing: 0.5,
                  ),
                ),
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
        final domCount = widget.config.domainLabels.length;
        final codCount = widget.config.codomainLabels.length;
        final leftX = size.width * 0.25;
        final rightX = size.width * 0.75;

        // Domain positions (left side)
        final domPositions = List.generate(domCount, (i) {
          final y = size.height * (i + 1) / (domCount + 1);
          return Offset(leftX, y);
        });
        // Codomain positions (right side)
        final codPositions = List.generate(codCount, (i) {
          final y = size.height * (i + 1) / (codCount + 1);
          return Offset(rightX, y);
        });

        return GestureDetector(
          onPanStart: (details) {
            // Check if starting from a domain element
            for (var i = 0; i < domCount; i++) {
              if ((details.localPosition - domPositions[i]).distance < 32) {
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
              // Check if ending on a codomain element
              for (var i = 0; i < codCount; i++) {
                if ((_dragPosition! - codPositions[i]).distance < 36) {
                  setState(() => _mapping[_dragFrom!] = i);
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
            painter: _FunctionPainter(
              domPositions: domPositions,
              codPositions: codPositions,
              mapping: _mapping,
              dragFrom: _dragFrom != null ? domPositions[_dragFrom!] : null,
              dragTo: _dragPosition,
            ),
            child: Stack(
              children: [
                // Set labels
                Positioned(
                  left: leftX - 15,
                  top: 8,
                  child: Text('A',
                      style: TextStyle(
                          color: Palette.pink.withValues(alpha: 0.5),
                          fontSize: 14,
                          fontWeight: FontWeight.w700)),
                ),
                Positioned(
                  left: rightX - 15,
                  top: 8,
                  child: Text('B',
                      style: TextStyle(
                          color: Palette.cyan.withValues(alpha: 0.5),
                          fontSize: 14,
                          fontWeight: FontWeight.w700)),
                ),
                // Domain elements
                for (var i = 0; i < domCount; i++)
                  Positioned(
                    left: domPositions[i].dx - 24,
                    top: domPositions[i].dy - 24,
                    child: _FunctionDot(
                      label: widget.config.domainLabels[i],
                      color: Palette.pink,
                      mapped: _mapping[i] >= 0,
                      active: _dragFrom == i,
                    ),
                  ),
                // Codomain elements
                for (var i = 0; i < codCount; i++)
                  Positioned(
                    left: codPositions[i].dx - 24,
                    top: codPositions[i].dy - 24,
                    child: _FunctionDot(
                      label: widget.config.codomainLabels[i],
                      color: Palette.cyan,
                      mapped: _mapping.contains(i),
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

class _FunctionDot extends StatelessWidget {
  final String label;
  final Color color;
  final bool mapped;
  final bool active;

  const _FunctionDot({
    required this.label,
    required this.color,
    this.mapped = false,
    this.active = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: mapped ? color.withValues(alpha: 0.1) : Palette.bgCard,
        border: Border.all(
          color: active ? color : color.withValues(alpha: mapped ? 0.8 : 0.4),
          width: active ? 3 : 2,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: active ? 0.5 : mapped ? 0.3 : 0.1),
            blurRadius: active ? 20 : 12,
          ),
        ],
      ),
      child: Center(
        child: Text(label,
            style: TextStyle(
                color: color,
                fontSize: 16,
                fontWeight: FontWeight.w700,
                shadows: [
                  Shadow(
                      color: color.withValues(alpha: 0.6), blurRadius: 6),
                ])),
      ),
    );
  }
}

class _FunctionPainter extends CustomPainter {
  final List<Offset> domPositions;
  final List<Offset> codPositions;
  final List<int> mapping;
  final Offset? dragFrom;
  final Offset? dragTo;

  _FunctionPainter({
    required this.domPositions,
    required this.codPositions,
    required this.mapping,
    this.dragFrom,
    this.dragTo,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Draw set enclosures
    _drawSetEnclosure(canvas, domPositions, Palette.pink);
    _drawSetEnclosure(canvas, codPositions, Palette.cyan);

    // Draw existing mappings
    for (var i = 0; i < mapping.length; i++) {
      if (mapping[i] >= 0) {
        _drawArrow(canvas, domPositions[i], codPositions[mapping[i]],
            Palette.textPrimary.withValues(alpha: 0.6));
      }
    }

    // Draw drag arrow
    if (dragFrom != null && dragTo != null) {
      _drawArrow(canvas, dragFrom!, dragTo!,
          Palette.cyan.withValues(alpha: 0.4));
    }
  }

  void _drawSetEnclosure(
      Canvas canvas, List<Offset> positions, Color color) {
    if (positions.isEmpty) return;
    final centerY = positions.map((p) => p.dy).reduce((a, b) => a + b) /
        positions.length;
    final centerX = positions.first.dx;
    final maxDist = positions
        .map((p) => (p - Offset(centerX, centerY)).distance)
        .reduce(math.max);
    final rect = Rect.fromCenter(
      center: Offset(centerX, centerY),
      width: 80,
      height: maxDist * 2 + 80,
    );
    final paint = Paint()
      ..color = color.withValues(alpha: 0.06)
      ..style = PaintingStyle.fill;
    canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(20)), paint);
    final borderPaint = Paint()
      ..color = color.withValues(alpha: 0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(20)), borderPaint);
  }

  void _drawArrow(Canvas canvas, Offset from, Offset to, Color color) {
    final delta = to - from;
    final dist = delta.distance;
    if (dist < 1) return;
    final dir = delta / dist;
    final start = from + dir * 24;
    final end = to - dir * 24;

    // Glow
    final glowPaint = Paint()
      ..color = color.withValues(alpha: 0.15)
      ..strokeWidth = 5
      ..style = PaintingStyle.stroke
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    canvas.drawLine(start, end, glowPaint);

    // Line
    final linePaint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    canvas.drawLine(start, end, linePaint);

    // Arrowhead
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
  bool shouldRepaint(_FunctionPainter oldDelegate) => true;
}
