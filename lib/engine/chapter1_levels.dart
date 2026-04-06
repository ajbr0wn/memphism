import 'package:flutter/material.dart';
import '../models/partition.dart';
import '../screens/function_screen.dart';
import '../screens/join_screen.dart';
import '../screens/ordering_screen.dart';
import '../screens/partition_screen.dart';

/// All Chapter 1 levels in order.
/// Covers: partitions, ordering, Hasse diagrams, joins.
/// Building toward Exercises 1.6, 1.7.

// ── Partition levels (from partition_levels.dart) ──

final partitionLevels = [
  PartitionLevelConfig(
    id: 'p1-touch',
    title: 'TOUCH',
    subtitle: 'Tap the dots.',
    elementLabels: const ['•', '∗'],
    type: PartitionLevelType.createTarget,
    target: Partition(const [{'•'}, {'∗'}]),
    positions: const [Offset(0.35, 0.45), Offset(0.65, 0.45)],
    hint: 'Tap until they\'re different colors.',
    notationReveal: '{•}  {∗}',
  ),
  PartitionLevelConfig(
    id: 'p2-group',
    title: 'GROUP',
    subtitle: 'Make them the same.',
    elementLabels: const ['•', '∗'],
    type: PartitionLevelType.createTarget,
    target: Partition(const [{'•', '∗'}]),
    positions: const [Offset(0.35, 0.45), Offset(0.65, 0.45)],
    hint: 'Same color = same group.',
    notationReveal: '{•, ∗}',
  ),
  PartitionLevelConfig(
    id: 'p3-all2',
    title: 'ALL',
    subtitle: 'Find every way to group two elements.',
    elementLabels: const ['•', '∗'],
    type: PartitionLevelType.findAll,
    positions: const [Offset(0.35, 0.45), Offset(0.65, 0.45)],
    notationReveal: 'A set with 2 elements has\n2 partitions',
  ),
  PartitionLevelConfig(
    id: 'p4-all3',
    title: 'FIVE',
    subtitle: 'Find every way to group three elements.',
    elementLabels: const ['1', '2', '3'],
    type: PartitionLevelType.findAll,
    positions: const [Offset(0.5, 0.3), Offset(0.3, 0.6), Offset(0.7, 0.6)],
    hint: 'There are 5 ways. Try: all together, all apart, and...',
    notationReveal: 'Bell number B₃ = 5',
  ),
  PartitionLevelConfig(
    id: 'p5-make4',
    title: 'FOUR',
    subtitle: 'Group: {1,2} and {3,4}.',
    elementLabels: const ['1', '2', '3', '4'],
    type: PartitionLevelType.createTarget,
    target: Partition(const [{'1', '2'}, {'3', '4'}]),
    positions: const [
      Offset(0.3, 0.35), Offset(0.7, 0.35),
      Offset(0.3, 0.6), Offset(0.7, 0.6),
    ],
    hint: 'Match colors: 1 with 2, and 3 with 4.',
  ),
  PartitionLevelConfig(
    id: 'p6-boss',
    title: 'BOSS',
    subtitle: 'Find every way to group four elements.',
    elementLabels: const ['1', '2', '3', '4'],
    type: PartitionLevelType.findAll,
    positions: const [
      Offset(0.3, 0.3), Offset(0.7, 0.3),
      Offset(0.3, 0.6), Offset(0.7, 0.6),
    ],
    hint: 'There are 15 ways.',
    notationReveal: 'Bell number B₄ = 15\n\nExercise 1.6 ✓',
  ),
];

// ── Ordering levels ──

final orderingLevels = [
  OrderingLevelConfig(
    id: 'o1-partitions3',
    title: 'ORDER',
    subtitle: 'Sort by fineness. Coarse top, fine bottom.',
    partitions: [
      Partition(const [{'1', '2', '3'}]),
      Partition(const [{'1', '2'}, {'3'}]),
      Partition(const [{'1'}, {'2'}, {'3'}]),
    ],
    elementLabels: const ['1', '2', '3'],
    hint: 'More groups = finer = goes lower.',
    notationReveal: '{1,2,3}\n  ≥\n{1,2}{3}\n  ≥\n{1}{2}{3}',
  ),
  OrderingLevelConfig(
    id: 'o2-partitions3-all',
    title: 'ARRANGE',
    subtitle: 'Sort ALL five partitions of {1,2,3}.',
    partitions: [
      Partition(const [{'1', '2', '3'}]),
      Partition(const [{'1', '2'}, {'3'}]),
      Partition(const [{'1', '3'}, {'2'}]),
      Partition(const [{'2', '3'}, {'1'}]),
      Partition(const [{'1'}, {'2'}, {'3'}]),
    ],
    elementLabels: const ['1', '2', '3'],
    hint: 'All-together at top, all-separate at bottom. The three "two+one" partitions are in the middle (same level).',
    notationReveal: 'A Hasse diagram!\n\nSame level = incomparable\n(neither is finer)',
  ),
];

// ── Join levels ──

final joinLevels = [
  JoinLevelConfig(
    id: 'j1-bool',
    title: 'JOIN',
    subtitle: 'What is false ∨ true?',
    partitionA: Partition(const [{'false'}]),
    partitionB: Partition(const [{'true'}]),
    expectedJoin: Partition(const [{'true'}]),
    elementLabels: const ['true', 'false'],
    positions: const [Offset(0.5, 0.35), Offset(0.5, 0.65)],
    hint: 'The join is the smallest element ≥ both.',
    notationReveal: 'false ∨ true = true',
  ),
  JoinLevelConfig(
    id: 'j2-partitions',
    title: 'MERGE',
    subtitle: 'Find A ∨ B.',
    partitionA: Partition(const [{'1', '2'}, {'3'}]),
    partitionB: Partition(const [{'1'}, {'2', '3'}]),
    expectedJoin: Partition(const [{'1', '2', '3'}]),
    elementLabels: const ['1', '2', '3'],
    positions: const [Offset(0.5, 0.3), Offset(0.3, 0.6), Offset(0.7, 0.6)],
    hint: '1 is with 2 in A, and 2 is with 3 in B. So in the join...',
    notationReveal: '{1,2}{3} ∨ {1}{2,3} = {1,2,3}\n\nA ≤ A∨B  and  B ≤ A∨B',
  ),
  JoinLevelConfig(
    id: 'j3-partitions4',
    title: 'FUSE',
    subtitle: 'Find A ∨ B.',
    partitionA: Partition(const [{'1', '2'}, {'3', '4'}]),
    partitionB: Partition(const [{'1', '3'}, {'2', '4'}]),
    expectedJoin: Partition(const [{'1', '2', '3', '4'}]),
    elementLabels: const ['1', '2', '3', '4'],
    positions: const [
      Offset(0.3, 0.3), Offset(0.7, 0.3),
      Offset(0.3, 0.65), Offset(0.7, 0.65),
    ],
    hint: 'In A: 1 is with 2, 3 is with 4. In B: 1 is with 3, 2 is with 4. So in the join, everyone is connected to everyone...',
    notationReveal: '{1,2}{3,4} ∨ {1,3}{2,4} = {1,2,3,4}\n\nGenerative effect!',
  ),
];

// ── Function levels (Ex 1.24) ──

final functionLevels = [
  FunctionLevelConfig(
    id: 'f1-any',
    title: 'MAP',
    subtitle: 'Draw arrows from A to B. Every element needs one.',
    domainLabels: const ['1', '2', '3'],
    codomainLabels: const ['a', 'b'],
    goal: FunctionGoal.anyFunction,
    hint: 'Drag from each left element to a right element. Every left element needs exactly one arrow.',
    notationReveal: 'f : A → B\n\nA function maps every input\nto exactly one output',
  ),
  FunctionLevelConfig(
    id: 'f2-injective',
    title: 'INJECT',
    subtitle: 'Map so no two inputs share an output.',
    domainLabels: const ['1', '2'],
    codomainLabels: const ['a', 'b', 'c'],
    goal: FunctionGoal.injective,
    hint: 'Each output can be used at most once.',
    notationReveal: 'f : A ↣ B\n\nInjective: different inputs →\ndifferent outputs',
  ),
  FunctionLevelConfig(
    id: 'f3-surjective',
    title: 'COVER',
    subtitle: 'Map so every output is hit.',
    domainLabels: const ['1', '2', '3'],
    codomainLabels: const ['a', 'b'],
    goal: FunctionGoal.surjective,
    hint: 'Every element on the right must have at least one arrow pointing to it.',
    notationReveal: 'f : A ↠ B\n\nSurjective: every output\nis reached',
  ),
  FunctionLevelConfig(
    id: 'f4-bijective',
    title: 'MATCH',
    subtitle: 'Map so it\'s both injective AND surjective.',
    domainLabels: const ['1', '2', '3'],
    codomainLabels: const ['a', 'b', 'c'],
    goal: FunctionGoal.bijective,
    hint: 'A perfect pairing — every input to a unique output, every output used.',
    notationReveal: 'f : A ≅ B\n\nBijective: a perfect\ncorrespondence',
  ),
];

/// Unified level type for the level select screen.
enum Ch1LevelType { partition, ordering, join, function_ }

class Ch1Level {
  final String title;
  final Ch1LevelType type;
  final int index; // index within its type's list
  final bool isBoss;

  const Ch1Level({
    required this.title,
    required this.type,
    required this.index,
    this.isBoss = false,
  });
}

final ch1AllLevels = [
  // Partition levels
  for (var i = 0; i < partitionLevels.length; i++)
    Ch1Level(
      title: partitionLevels[i].title,
      type: Ch1LevelType.partition,
      index: i,
      isBoss: partitionLevels[i].id == 'p6-boss',
    ),
  // Ordering levels
  for (var i = 0; i < orderingLevels.length; i++)
    Ch1Level(
      title: orderingLevels[i].title,
      type: Ch1LevelType.ordering,
      index: i,
    ),
  // Join levels
  for (var i = 0; i < joinLevels.length; i++)
    Ch1Level(
      title: joinLevels[i].title,
      type: Ch1LevelType.join,
      index: i,
    ),
  // Function levels
  for (var i = 0; i < functionLevels.length; i++)
    Ch1Level(
      title: functionLevels[i].title,
      type: Ch1LevelType.function_,
      index: i,
    ),
];
