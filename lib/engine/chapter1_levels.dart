import 'package:flutter/material.dart';
import '../models/partition.dart';
import '../screens/function_screen.dart';
import '../screens/join_screen.dart';
import '../screens/meet_join_pick_screen.dart';
import '../screens/ordering_screen.dart';
import '../screens/partition_screen.dart';
import '../screens/preorder_screen.dart';

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

// ── Preorder/Hasse building levels ──

final preorderLevels = [
  // Exercise 1.46: divisibility on {1,...,6}
  // Using 1-6 to keep it manageable. a → b if a divides b.
  // Hasse diagram (cover relations only):
  // 1→2, 1→3, 1→5, 2→4, 2→6, 3→6
  PreorderLevelConfig(
    id: 'pre1-divide6',
    title: 'DIVIDE',
    subtitle: 'Draw a→b when a divides b evenly. Covers only.',
    elementLabels: const ['1', '2', '3', '4', '5', '6'],
    positions: const [
      Offset(0.5, 0.85),  // 1 at bottom
      Offset(0.25, 0.6),  // 2
      Offset(0.5, 0.6),   // 3
      Offset(0.15, 0.35), // 4
      Offset(0.75, 0.6),  // 5
      Offset(0.4, 0.35),  // 6
    ],
    expectedEdges: {
      (0, 1), // 1→2
      (0, 2), // 1→3
      (0, 4), // 1→5
      (1, 3), // 2→4
      (1, 5), // 2→6
      (2, 5), // 3→6
    },
    hint: 'a divides b means b/a is a whole number. Only draw direct covers — if 1→2→4, don\'t draw 1→4.',
    notationReveal: 'Divisibility is a partial order!\n\nNot total: 2 and 3 are\nincomparable (neither divides\nthe other)',
  ),

  // Exercise 1.51: Power set P({1,2})
  // Subsets: ∅, {1}, {2}, {1,2}
  // Hasse: ∅→{1}, ∅→{2}, {1}→{1,2}, {2}→{1,2}
  PreorderLevelConfig(
    id: 'pre2-powerset',
    title: 'POWER',
    subtitle: 'Draw a→b when a ⊆ b. Build the power set lattice.',
    elementLabels: const ['∅', '{1}', '{2}', '{1,2}'],
    positions: const [
      Offset(0.5, 0.8),   // ∅ at bottom
      Offset(0.3, 0.5),   // {1}
      Offset(0.7, 0.5),   // {2}
      Offset(0.5, 0.2),   // {1,2} at top
    ],
    expectedEdges: {
      (0, 1), // ∅ → {1}
      (0, 2), // ∅ → {2}
      (1, 3), // {1} → {1,2}
      (2, 3), // {2} → {1,2}
    },
    hint: 'A ⊆ B means every element of A is also in B. ∅ is a subset of everything.',
    notationReveal: 'P({1,2}) — the power set lattice\n\nIt\'s a diamond! (a.k.a. Boolean\nalgebra B₂)',
  ),
];

// ── Meet/Join picking levels (Section 1.3) ──

final meetJoinPickLevels = [
  // GCD in divisibility (Exercise 1.90)
  // Divisibility on {1,2,3,4,5,6}: Hasse: 1→2,1→3,1→5,2→4,2→6,3→6
  MeetJoinPickConfig(
    id: 'mj1-gcd',
    title: 'GCD',
    subtitle: null,
    elementLabels: const ['1', '2', '3', '4', '5', '6'],
    positions: const [
      Offset(0.5, 0.85),  // 1
      Offset(0.25, 0.6),  // 2
      Offset(0.5, 0.6),   // 3
      Offset(0.15, 0.35), // 4
      Offset(0.75, 0.6),  // 5
      Offset(0.4, 0.35),  // 6
    ],
    edges: {(0,1),(0,2),(0,4),(1,3),(1,5),(2,5)},
    highlighted: (3, 5), // 4 and 6
    operation: MeetOrJoin.meet,
    answer: 1, // GCD(4,6) = 2
    hint: 'Meet = greatest lower bound. What\'s the largest number that divides both 4 and 6?',
    notationReveal: '4 ∧ 6 = 2\n\nMeet in divisibility = GCD\n(greatest common divisor)',
  ),

  // LCM in divisibility (Exercise 1.90)
  MeetJoinPickConfig(
    id: 'mj2-lcm',
    title: 'LCM',
    subtitle: null,
    elementLabels: const ['1', '2', '3', '4', '5', '6'],
    positions: const [
      Offset(0.5, 0.85),
      Offset(0.25, 0.6),
      Offset(0.5, 0.6),
      Offset(0.15, 0.35),
      Offset(0.75, 0.6),
      Offset(0.4, 0.35),
    ],
    edges: {(0,1),(0,2),(0,4),(1,3),(1,5),(2,5)},
    highlighted: (1, 2), // 2 and 3
    operation: MeetOrJoin.join,
    answer: 5, // LCM(2,3) = 6
    hint: 'Join = least upper bound. What\'s the smallest number that both 2 and 3 divide into?',
    notationReveal: '2 ∨ 3 = 6\n\nJoin in divisibility = LCM\n(least common multiple)',
  ),

  // Meet in power set = intersection (Example 1.87)
  MeetJoinPickConfig(
    id: 'mj3-intersect',
    title: 'MEET',
    subtitle: null,
    elementLabels: const ['∅', '{1}', '{2}', '{1,2}'],
    positions: const [
      Offset(0.5, 0.8),
      Offset(0.3, 0.5),
      Offset(0.7, 0.5),
      Offset(0.5, 0.2),
    ],
    edges: {(0,1),(0,2),(1,3),(2,3)},
    highlighted: (1, 2), // {1} and {2}
    operation: MeetOrJoin.meet,
    answer: 0, // {1} ∩ {2} = ∅
    hint: 'Meet in the power set = intersection. What do {1} and {2} have in common?',
    notationReveal: '{1} ∧ {2} = ∅\n\nMeet in P(X) = intersection\n(A ∧ B = A ∩ B)',
  ),

  // Join in power set = union (Example 1.87)
  MeetJoinPickConfig(
    id: 'mj4-union',
    title: 'JOIN²',
    subtitle: null,
    elementLabels: const ['∅', '{1}', '{2}', '{1,2}'],
    positions: const [
      Offset(0.5, 0.8),
      Offset(0.3, 0.5),
      Offset(0.7, 0.5),
      Offset(0.5, 0.2),
    ],
    edges: {(0,1),(0,2),(1,3),(2,3)},
    highlighted: (1, 2), // {1} and {2}
    operation: MeetOrJoin.join,
    answer: 3, // {1} ∪ {2} = {1,2}
    hint: 'Join in the power set = union. What\'s the smallest set containing both {1} and {2}?',
    notationReveal: '{1} ∨ {2} = {1,2}\n\nJoin in P(X) = union\n(A ∨ B = A ∪ B)',
  ),
];

/// Unified level type for the level select screen.
enum Ch1LevelType { partition, ordering, join, function_, preorder, meetJoinPick }

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
  // Preorder levels
  for (var i = 0; i < preorderLevels.length; i++)
    Ch1Level(
      title: preorderLevels[i].title,
      type: Ch1LevelType.preorder,
      index: i,
    ),
  // Meet/Join picking levels
  for (var i = 0; i < meetJoinPickLevels.length; i++)
    Ch1Level(
      title: meetJoinPickLevels[i].title,
      type: Ch1LevelType.meetJoinPick,
      index: i,
    ),
];
