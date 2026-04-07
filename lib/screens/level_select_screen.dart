import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../engine/chapter1_levels.dart';
import '../engine/chapter2_levels.dart';
import '../screens/function_screen.dart';
import '../screens/join_screen.dart';
import '../screens/meet_join_pick_screen.dart';
import '../screens/galois_screen.dart';
import '../screens/monoidal_table_screen.dart';
import '../screens/monotone_screen.dart';
import '../screens/tap_answer_screen.dart';
import '../engine/bridge_levels.dart';
import '../screens/ordering_screen.dart';
import '../screens/partition_screen.dart';
import '../screens/preorder_screen.dart';
import '../theme/palette.dart';

class LevelSelectScreen extends StatefulWidget {
  const LevelSelectScreen({super.key});

  @override
  State<LevelSelectScreen> createState() => _LevelSelectScreenState();
}

// Items in the level list (either chapter headers or level cards)
sealed class _ListItem {}
class _ChapterHeader extends _ListItem {
  final String title;
  _ChapterHeader(this.title);
}
class _LevelItem extends _ListItem {
  final String title;
  final int globalIndex;
  final bool isBoss;
  final Ch1LevelType levelType; // reuse Ch1's type for icon mapping
  _LevelItem({required this.title, required this.globalIndex, this.isBoss = false, required this.levelType});
}

class _LevelSelectScreenState extends State<LevelSelectScreen> {
  int _unlockedUpTo = 0;

  static final _totalLevels = ch1AllLevels.length + ch2AllLevels.length;

  late final List<_ListItem> _allItems = _buildItems();

  List<_ListItem> _buildItems() {
    final items = <_ListItem>[];
    items.add(_ChapterHeader('CHAPTER 1: ORDERS & PARTITIONS'));
    for (var i = 0; i < ch1AllLevels.length; i++) {
      final level = ch1AllLevels[i];
      items.add(_LevelItem(
        title: level.title,
        globalIndex: i,
        isBoss: level.isBoss,
        levelType: level.type,
      ));
    }
    items.add(_ChapterHeader('CHAPTER 2: MONOIDAL PREORDERS'));
    for (var i = 0; i < ch2AllLevels.length; i++) {
      final level = ch2AllLevels[i];
      items.add(_LevelItem(
        title: level.title,
        globalIndex: ch1AllLevels.length + i,
        isBoss: level.isBoss,
        levelType: _ch2TypeToIcon(level.type),
      ));
    }
    return items;
  }

  // Map Ch2 types to Ch1 icon types for display
  static Ch1LevelType _ch2TypeToIcon(Ch2LevelType type) {
    return switch (type) {
      Ch2LevelType.monoidalTable => Ch1LevelType.meetJoinPick, // grid icon
      Ch2LevelType.tapAnswer => Ch1LevelType.bridge, // lightbulb icon
    };
  }

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _unlockedUpTo = prefs.getInt('unlockedUpTo') ?? 0;
    });
  }

  Future<void> _saveProgress() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('unlockedUpTo', _unlockedUpTo);
  }

  void _playLevel(int index) {
    // Chapter 2 levels start after ch1
    if (index >= ch1AllLevels.length) {
      final ch2Index = index - ch1AllLevels.length;
      final level = ch2AllLevels[ch2Index];
      Widget screen;
      switch (level.type) {
        case Ch2LevelType.monoidalTable:
          screen = MonoidalTableScreen(
            config: monoidalTableLevels[level.index],
            onComplete: () => _onComplete(index),
          );
        case Ch2LevelType.tapAnswer:
          screen = TapAnswerScreen(
            config: ch2BridgeLevels[level.index],
            onComplete: () => _onComplete(index),
          );
      }
      Navigator.of(context).push(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => screen,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 400),
        ),
      );
      return;
    }

    final level = ch1AllLevels[index];

    Widget screen;
    switch (level.type) {
      case Ch1LevelType.partition:
        screen = PartitionScreen(
          config: partitionLevels[level.index],
          onComplete: () => _onComplete(index),
        );
      case Ch1LevelType.ordering:
        screen = OrderingScreen(
          config: orderingLevels[level.index],
          onComplete: () => _onComplete(index),
        );
      case Ch1LevelType.join:
        screen = JoinScreen(
          config: joinLevels[level.index],
          onComplete: () => _onComplete(index),
        );
      case Ch1LevelType.function_:
        screen = FunctionScreen(
          config: functionLevels[level.index],
          onComplete: () => _onComplete(index),
        );
      case Ch1LevelType.preorder:
        screen = PreorderScreen(
          config: preorderLevels[level.index],
          onComplete: () => _onComplete(index),
        );
      case Ch1LevelType.meetJoinPick:
        screen = MeetJoinPickScreen(
          config: meetJoinPickLevels[level.index],
          onComplete: () => _onComplete(index),
        );
      case Ch1LevelType.monotone:
        screen = MonotoneScreen(
          config: monotoneLevels[level.index],
          onComplete: () => _onComplete(index),
        );
      case Ch1LevelType.bridge:
        screen = TapAnswerScreen(
          config: bridgeLevels[level.index],
          onComplete: () => _onComplete(index),
        );
      case Ch1LevelType.galois:
        screen = GaloisScreen(
          config: galoisLevels[level.index],
          onComplete: () => _onComplete(index),
        );
    }

    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => screen,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  void _onComplete(int index) {
    if (index >= _unlockedUpTo) {
      setState(() => _unlockedUpTo = index + 1);
    }
    _saveProgress();
    Navigator.of(context).pop();
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
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                itemCount: _allItems.length,
                itemBuilder: (context, index) {
                  final item = _allItems[index];
                  if (item is _ChapterHeader) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 16, bottom: 12),
                      child: Text(
                        item.title,
                        style: TextStyle(
                          color: Palette.textDim,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 3,
                        ),
                      ),
                    );
                  }
                  final card = item as _LevelItem;
                  final unlocked = card.globalIndex <= _unlockedUpTo;
                  final completed = card.globalIndex < _unlockedUpTo;
                  return _LevelCard(
                    title: card.title,
                    index: card.globalIndex,
                    unlocked: unlocked,
                    completed: completed,
                    isBoss: card.isBoss,
                    levelType: card.levelType,
                    onTap: unlocked ? () => _playLevel(card.globalIndex) : null,
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
  final Ch1LevelType levelType;
  final VoidCallback? onTap;

  const _LevelCard({
    required this.title,
    required this.index,
    required this.unlocked,
    required this.completed,
    this.isBoss = false,
    required this.levelType,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isBoss
        ? Palette.yellow
        : unlocked
            ? Palette.nodeColor(index)
            : Palette.textDim.withValues(alpha: 0.3);

    // Type indicator
    final typeIcon = switch (levelType) {
      Ch1LevelType.partition => Icons.grid_view_rounded,
      Ch1LevelType.ordering => Icons.swap_vert,
      Ch1LevelType.join => Icons.merge_type,
      Ch1LevelType.function_ => Icons.arrow_forward,
      Ch1LevelType.preorder => Icons.account_tree,
      Ch1LevelType.meetJoinPick => Icons.compress,
      Ch1LevelType.monotone => Icons.trending_up,
      Ch1LevelType.bridge => Icons.lightbulb_outline,
      Ch1LevelType.galois => Icons.sync_alt,
    };

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
            const SizedBox(width: 8),
            Icon(typeIcon, size: 16,
                color: unlocked
                    ? color.withValues(alpha: 0.4)
                    : Palette.textDim.withValues(alpha: 0.15)),
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
