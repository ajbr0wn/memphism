import 'package:flutter/material.dart';

/// Neon Memphis Milano palette — bold, maximal, cosmic.
class Palette {
  Palette._();

  // Background
  static const bg = Color(0xFF0A0A12);
  static const bgLight = Color(0xFF14141E);
  static const bgCard = Color(0xFF1A1A28);

  // Neon primaries — Memphis Milano bold
  static const pink = Color(0xFFFF2E8C);
  static const cyan = Color(0xFF00E5FF);
  static const yellow = Color(0xFFFFE500);
  static const green = Color(0xFF00FF88);
  static const orange = Color(0xFFFF8800);
  static const violet = Color(0xFFAA44FF);

  // Softer variants for text/UI
  static const textPrimary = Color(0xFFE8E8F0);
  static const textSecondary = Color(0xFF8888AA);
  static const textDim = Color(0xFF555570);

  // Semantic
  static const success = green;
  static const error = Color(0xFFFF4466);
  static const glow = cyan;

  // Node colors for category objects — each a distinct neon
  static const nodeColors = [pink, cyan, yellow, green, orange, violet];

  // Memphis pattern accents
  static const memphisAccents = [
    Color(0xFFFF2E8C), // hot pink
    Color(0xFF00E5FF), // electric cyan
    Color(0xFFFFE500), // signal yellow
    Color(0xFF44FF88), // mint
    Color(0xFFFF6633), // tangerine
    Color(0xFFBB55FF), // lavender neon
  ];

  /// Glow color for a node at index.
  static Color nodeColor(int index) =>
      nodeColors[index % nodeColors.length];

  /// Soft glow version (lower opacity) for shadows/halos.
  static Color nodeGlow(int index) =>
      nodeColor(index).withValues(alpha: 0.3);
}
