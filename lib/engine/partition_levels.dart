import 'package:flutter/material.dart';
import '../models/partition.dart';
import '../screens/partition_screen.dart';

/// Chapter 1 levels building toward Exercise 1.6.
/// Each level teaches one concept needed for the exercise.

final ch1PartitionLevels = [
  // Level 1: Touch — just tap dots, see them change color.
  // Learn: elements exist, you can interact with them.
  PartitionLevelConfig(
    id: 'p1-touch',
    title: 'TOUCH',
    subtitle: 'Tap the dots.',
    elementLabels: const ['•', '∗'],
    type: PartitionLevelType.createTarget,
    target: Partition(const [
      {'•'},
      {'∗'},
    ]),
    positions: const [Offset(0.35, 0.45), Offset(0.65, 0.45)],
    hint: 'Tap until they\'re different colors.',
    notationReveal: '{•}  {∗}',
  ),

  // Level 2: Group — put two elements in the same group.
  // Learn: things can be TOGETHER or APART.
  PartitionLevelConfig(
    id: 'p2-group',
    title: 'GROUP',
    subtitle: 'Make them the same.',
    elementLabels: const ['•', '∗'],
    type: PartitionLevelType.createTarget,
    target: Partition(const [
      {'•', '∗'},
    ]),
    positions: const [Offset(0.35, 0.45), Offset(0.65, 0.45)],
    hint: 'Same color = same group.',
    notationReveal: '{•, ∗}',
  ),

  // Level 3: Find All (2 elements) — discover BOTH partitions of {•, ∗}.
  // Learn: a set can be partitioned in different ways. Collect them.
  PartitionLevelConfig(
    id: 'p3-all2',
    title: 'ALL',
    subtitle: 'Find every way to group two elements.',
    elementLabels: const ['•', '∗'],
    type: PartitionLevelType.findAll,
    positions: const [Offset(0.35, 0.45), Offset(0.65, 0.45)],
    notationReveal: 'A set with 2 elements has\n2 partitions',
  ),

  // Level 4: Find All (3 elements) — discover all 5 partitions of {1,2,3}.
  // This is more challenging — 5 partitions to find.
  PartitionLevelConfig(
    id: 'p4-all3',
    title: 'FIVE',
    subtitle: 'Find every way to group three elements.',
    elementLabels: const ['1', '2', '3'],
    type: PartitionLevelType.findAll,
    positions: const [
      Offset(0.5, 0.3),
      Offset(0.3, 0.6),
      Offset(0.7, 0.6),
    ],
    hint: 'There are 5 ways. Try: all together, all apart, and...',
    notationReveal: 'A set with 3 elements has\n5 partitions (Bell number B₃)',
  ),

  // Level 5: Create specific partition of {1,2,3,4} — warm-up for the boss.
  PartitionLevelConfig(
    id: 'p5-make4',
    title: 'FOUR',
    subtitle: 'Group: {1,2} and {3,4}.',
    elementLabels: const ['1', '2', '3', '4'],
    type: PartitionLevelType.createTarget,
    target: Partition(const [
      {'1', '2'},
      {'3', '4'},
    ]),
    positions: const [
      Offset(0.3, 0.35),
      Offset(0.7, 0.35),
      Offset(0.3, 0.6),
      Offset(0.7, 0.6),
    ],
    hint: 'Match colors: 1 with 2, and 3 with 4.',
  ),

  // Level 6: BOSS — Find ALL partitions of {1,2,3,4}.
  // Exercise 1.6 part 2. There are 15 partitions (Bell number B₄).
  PartitionLevelConfig(
    id: 'p6-boss',
    title: 'BOSS',
    subtitle: 'Find every way to group four elements.',
    elementLabels: const ['1', '2', '3', '4'],
    type: PartitionLevelType.findAll,
    positions: const [
      Offset(0.3, 0.3),
      Offset(0.7, 0.3),
      Offset(0.3, 0.6),
      Offset(0.7, 0.6),
    ],
    hint: 'There are 15 ways. Systematic: start with all-together, then split one off...',
    notationReveal: '15 partitions — Bell number B₄\n\nExercise 1.6 ✓',
  ),
];
