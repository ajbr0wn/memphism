import 'package:flutter/material.dart';
import '../engine/partition_levels.dart';
import '../screens/partition_screen.dart';
import '../theme/palette.dart';

class LevelSelectScreen extends StatefulWidget {
  const LevelSelectScreen({super.key});

  @override
  State<LevelSelectScreen> createState() => _LevelSelectScreenState();
}

class _LevelSelectScreenState extends State<LevelSelectScreen> {
  int _unlockedUpTo = 0;

  void _playLevel(int index) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            PartitionScreen(
          config: ch1PartitionLevels[index],
          onComplete: () {
            if (index >= _unlockedUpTo) {
              setState(() => _unlockedUpTo = index + 1);
            }
            Navigator.of(context).pop();
          },
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Palette.bg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(28, 32, 28, 4),
              child: Text(
                'MEMPHISM',
                style: TextStyle(
                  color: Palette.pink,
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 6,
                  shadows: [
                    Shadow(color: Palette.pink, blurRadius: 20),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(28, 0, 28, 32),
              child: Text(
                'CHAPTER 1: PARTITIONS',
                style: TextStyle(
                  color: Palette.textDim,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 3,
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                itemCount: ch1PartitionLevels.length,
                itemBuilder: (context, index) {
                  final level = ch1PartitionLevels[index];
                  final unlocked = index <= _unlockedUpTo;
                  final completed = index < _unlockedUpTo;
                  final isBoss = index == ch1PartitionLevels.length - 1;
                  return _LevelCard(
                    title: level.title,
                    index: index,
                    unlocked: unlocked,
                    completed: completed,
                    isBoss: isBoss,
                    onTap: unlocked ? () => _playLevel(index) : null,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LevelCard extends StatelessWidget {
  final String title;
  final int index;
  final bool unlocked;
  final bool completed;
  final bool isBoss;
  final VoidCallback? onTap;

  const _LevelCard({
    required this.title,
    required this.index,
    required this.unlocked,
    required this.completed,
    this.isBoss = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isBoss
        ? Palette.yellow
        : unlocked
            ? Palette.nodeColor(index)
            : Palette.textDim.withValues(alpha: 0.3);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: unlocked ? Palette.bgCard : Palette.bg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withValues(alpha: unlocked ? 0.4 : 0.15),
            width: isBoss && unlocked ? 2 : 1,
          ),
          boxShadow: unlocked
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: isBoss ? 0.2 : 0.1),
                    blurRadius: isBoss ? 20 : 12,
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: color, width: 2),
                color: completed ? color.withValues(alpha: 0.2) : null,
              ),
              child: Center(
                child: completed
                    ? Icon(Icons.check, size: 18, color: color)
                    : isBoss
                        ? Icon(Icons.star, size: 16, color: color)
                        : Text(
                            '${index + 1}',
                            style: TextStyle(
                              color: color,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
              ),
            ),
            const SizedBox(width: 16),
            Text(
              title,
              style: TextStyle(
                color: unlocked ? Palette.textPrimary : Palette.textDim,
                fontSize: 18,
                fontWeight: FontWeight.w700,
                letterSpacing: 2,
              ),
            ),
            const Spacer(),
            if (unlocked && !completed)
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: color.withValues(alpha: 0.5),
              ),
          ],
        ),
      ),
    );
  }
}
