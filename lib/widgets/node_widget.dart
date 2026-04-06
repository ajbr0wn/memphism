import 'package:flutter/material.dart';
import '../theme/palette.dart';

/// A glowing neon node representing a categorical object.
class NodeWidget extends StatelessWidget {
  final String label;
  final int colorIndex;
  final bool active;
  final bool pulsing;
  final VoidCallback? onTap;

  const NodeWidget({
    super.key,
    required this.label,
    required this.colorIndex,
    this.active = false,
    this.pulsing = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = Palette.nodeColor(colorIndex);
    final glowColor = Palette.nodeGlow(colorIndex);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: active ? 72 : 64,
        height: active ? 72 : 64,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Palette.bgCard,
          border: Border.all(
            color: active ? color : color.withValues(alpha: 0.6),
            width: active ? 3 : 2,
          ),
          boxShadow: [
            BoxShadow(
              color: active ? color.withValues(alpha: 0.5) : glowColor,
              blurRadius: active ? 24 : 12,
              spreadRadius: active ? 4 : 1,
            ),
            if (pulsing)
              BoxShadow(
                color: color.withValues(alpha: 0.3),
                blurRadius: 32,
                spreadRadius: 8,
              ),
          ],
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 22,
              fontWeight: FontWeight.w700,
              letterSpacing: 1,
              shadows: [
                Shadow(color: color.withValues(alpha: 0.8), blurRadius: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
