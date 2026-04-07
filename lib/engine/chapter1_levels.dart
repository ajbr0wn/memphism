import 'package:flutter/material.dart';
import '../models/partition.dart';
import '../screens/function_screen.dart';
import '../screens/join_screen.dart';
import '../screens/meet_join_pick_screen.dart';
import '../engine/bridge_levels.dart';
import '../screens/galois_screen.dart';
import '../screens/tap_answer_screen.dart';
import '../screens/monotone_screen.dart';
import '../screens/ordering_screen.dart';
import '../screens/partition_screen.dart';
import '../screens/preorder_screen.dart';

/// All Chapter 1 levels in order.
/// Covers: partitions, ordering, Hasse diagrams, joins, functions,
/// preorders, meets, power sets, divisibility, generative effects.
/// Building toward Exercises 1.6, 1.7, 1.24, 1.46, 1.51, 1.63, 1.87, 1.90.

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
  // New: partition with letter elements (variety)
  PartitionLevelConfig(
    id: 'p7-letters',
    title: 'SPLIT',
    subtitle: 'Make: {a,c} and {b}.',
    elementLabels: const ['a', 'b', 'c'],
    type: PartitionLevelType.createTarget,
    target: Partition(const [{'a', 'c'}, {'b'}]),
    positions: const [Offset(0.3, 0.4), Offset(0.7, 0.4), Offset(0.5, 0.65)],
    hint: 'a and c together, b alone.',
  ),
  // New: partition of symbols (Ex 1.6 callback with different elements)
  PartitionLevelConfig(
    id: 'p8-symbols',
    title: 'REMIX',
    subtitle: 'Find every way to group {♠, ♥, ♦}.',
    elementLabels: const ['♠', '♥', '♦'],
    type: PartitionLevelType.findAll,
    positions: const [Offset(0.5, 0.3), Offset(0.3, 0.6), Offset(0.7, 0.6)],
    hint: 'Same as before with different symbols — there are still 5.',
    notationReveal: 'B₃ = 5 regardless of labels!\n\nThe structure depends only\non the number of elements',
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
    id: 'j1-easy',
    title: 'JOIN',
    subtitle: 'Find A ∨ B — the smallest partition ≥ both.',
    partitionA: Partition(const [{'1'}, {'2'}, {'3'}]),
    partitionB: Partition(const [{'1', '2'}, {'3'}]),
    expectedJoin: Partition(const [{'1', '2'}, {'3'}]),
    elementLabels: const ['1', '2', '3'],
    positions: const [Offset(0.5, 0.3), Offset(0.3, 0.6), Offset(0.7, 0.6)],
    hint: 'The join must be ≥ both A and B. The finest partition is ≤ everything, so joining it with B just gives B.',
    notationReveal: '{1}{2}{3} ∨ {1,2}{3} = {1,2}{3}\n\n⊥ ∨ x = x always',
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
  // New: join that DOESN'T collapse to top (4 elements)
  JoinLevelConfig(
    id: 'j4-partial',
    title: 'PARTIAL',
    subtitle: 'Find A ∨ B. It\'s not always the top!',
    partitionA: Partition(const [{'1', '2'}, {'3'}, {'4'}]),
    partitionB: Partition(const [{'1'}, {'2'}, {'3', '4'}]),
    expectedJoin: Partition(const [{'1', '2'}, {'3', '4'}]),
    elementLabels: const ['1', '2', '3', '4'],
    positions: const [
      Offset(0.3, 0.3), Offset(0.7, 0.3),
      Offset(0.3, 0.65), Offset(0.7, 0.65),
    ],
    hint: 'In A: 1-2 together. In B: 3-4 together. No chain connects them, so the join keeps both groups separate.',
    notationReveal: '{1,2}{3}{4} ∨ {1}{2}{3,4}\n= {1,2}{3,4}\n\nNot everything merges!',
  ),
  // New: join with letters (spiral back)
  JoinLevelConfig(
    id: 'j5-letters',
    title: 'WEAVE',
    subtitle: 'Find A ∨ B.',
    partitionA: Partition(const [{'a', 'b'}, {'c', 'd'}]),
    partitionB: Partition(const [{'a', 'c'}, {'b', 'd'}]),
    expectedJoin: Partition(const [{'a', 'b', 'c', 'd'}]),
    elementLabels: const ['a', 'b', 'c', 'd'],
    positions: const [
      Offset(0.3, 0.3), Offset(0.7, 0.3),
      Offset(0.3, 0.65), Offset(0.7, 0.65),
    ],
    hint: 'a-b and c-d in A; a-c and b-d in B. Every element connects to every other through chains...',
    notationReveal: '{a,b}{c,d} ∨ {a,c}{b,d}\n= {a,b,c,d}\n\nSame generative effect,\ndifferent labels!',
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
  // New: identity function (Ex 1.23)
  FunctionLevelConfig(
    id: 'f5-identity',
    title: 'SELF',
    subtitle: 'Map each element to itself.',
    domainLabels: const ['1', '2', '3'],
    codomainLabels: const ['1', '2', '3'],
    goal: FunctionGoal.bijective,
    hint: 'The identity function: every element maps to itself. It\'s always bijective!',
    notationReveal: 'id_A : A → A\n\nid(x) = x for all x\nThe simplest bijection',
  ),
  // New: harder surjection (4→2)
  FunctionLevelConfig(
    id: 'f6-surject4',
    title: 'FLOOD',
    subtitle: 'Map 4 elements onto 2. Every output must be hit.',
    domainLabels: const ['1', '2', '3', '4'],
    codomainLabels: const ['x', 'y'],
    goal: FunctionGoal.surjective,
    hint: 'Both x and y need at least one arrow. You have 4 inputs — plenty to go around.',
    notationReveal: 'f : 4 ↠ 2\n\nA surjection from A to B\npartitions A into |B| groups',
  ),
  // New: injection into larger set (2→4)
  FunctionLevelConfig(
    id: 'f7-inject-big',
    title: 'EMBED',
    subtitle: 'Map 2 elements into 4, no sharing.',
    domainLabels: const ['α', 'β'],
    codomainLabels: const ['1', '2', '3', '4'],
    goal: FunctionGoal.injective,
    hint: 'Pick any two distinct outputs for your two inputs.',
    notationReveal: 'f : 2 ↣ 4\n\nThere are 4×3 = 12\ndifferent injections!',
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

  // Exercise 1.63: Power set P({1,2,3}) — the CUBE!
  // 8 subsets: ∅, {1}, {2}, {3}, {1,2}, {1,3}, {2,3}, {1,2,3}
  // Cover relations: each subset → add one element
  PreorderLevelConfig(
    id: 'pre3-cube',
    title: 'CUBE',
    subtitle: 'Build P({1,2,3}). Draw a→b when a ⊆ b (covers only).',
    elementLabels: const ['∅', '{1}', '{2}', '{3}', '{1,2}', '{1,3}', '{2,3}', 'X'],
    positions: const [
      Offset(0.5, 0.88),   // ∅ bottom center
      Offset(0.2, 0.65),   // {1}
      Offset(0.5, 0.65),   // {2}
      Offset(0.8, 0.65),   // {3}
      Offset(0.2, 0.38),   // {1,2}
      Offset(0.5, 0.38),   // {1,3}
      Offset(0.8, 0.38),   // {2,3}
      Offset(0.5, 0.12),   // {1,2,3} = X at top
    ],
    expectedEdges: {
      (0, 1), // ∅ → {1}
      (0, 2), // ∅ → {2}
      (0, 3), // ∅ → {3}
      (1, 4), // {1} → {1,2}
      (1, 5), // {1} → {1,3}
      (2, 4), // {2} → {1,2}
      (2, 6), // {2} → {2,3}
      (3, 5), // {3} → {1,3}
      (3, 6), // {3} → {2,3}
      (4, 7), // {1,2} → X
      (5, 7), // {1,3} → X
      (6, 7), // {2,3} → X
    },
    hint: 'Draw an edge when adding exactly one element takes you from one set to another. 12 edges total.',
    notationReveal: 'P({1,2,3}) is a cube!\n\nThe power set of an n-element\nset has 2ⁿ elements and\nlooks like an n-dimensional cube',
  ),

  // Divisibility on {1,...,8} — harder version of DIVIDE
  PreorderLevelConfig(
    id: 'pre4-divide8',
    title: 'DIVIDE²',
    subtitle: 'Divisibility on {1,...,8}. Covers only!',
    elementLabels: const ['1', '2', '3', '4', '5', '6', '7', '8'],
    positions: const [
      Offset(0.5, 0.9),    // 1 bottom
      Offset(0.2, 0.68),   // 2
      Offset(0.4, 0.68),   // 3
      Offset(0.12, 0.45),  // 4
      Offset(0.6, 0.68),   // 5
      Offset(0.4, 0.45),   // 6
      Offset(0.8, 0.68),   // 7
      Offset(0.12, 0.22),  // 8
    ],
    expectedEdges: {
      (0, 1), // 1→2
      (0, 2), // 1→3
      (0, 4), // 1→5
      (0, 6), // 1→7
      (1, 3), // 2→4
      (1, 5), // 2→6
      (2, 5), // 3→6
      (3, 7), // 4→8
    },
    hint: 'Cover = direct divisibility with nothing in between. 1→2→4→8, so 1→4 is NOT a cover. 8 edges total.',
    notationReveal: 'Divisibility on {1,...,8}\n\n4→8 but not 2→8 (because 2→4→8)\n5 and 7 are "islands" — primes\nwith no multiples in range',
  ),
];

// ── Meet/Join picking levels (Section 1.3) ──

final meetJoinPickLevels = [
  // Boolean lattice: false ≤ true
  MeetJoinPickConfig(
    id: 'mj0-bool-join',
    title: 'OR',
    subtitle: null,
    elementLabels: const ['false', 'true'],
    positions: const [
      Offset(0.5, 0.7),  // false at bottom
      Offset(0.5, 0.3),  // true at top
    ],
    edges: {(0, 1)}, // false → true
    highlighted: (0, 1), // false and true
    operation: MeetOrJoin.join,
    answer: 1, // false ∨ true = true
    hint: 'Join = least upper bound. What\'s the smallest element ≥ both false and true?',
    notationReveal: 'false ∨ true = true\n\nJoin in Bool = OR\n(∨ is "or")',
  ),
  MeetJoinPickConfig(
    id: 'mj0-bool-meet',
    title: 'AND',
    subtitle: null,
    elementLabels: const ['false', 'true'],
    positions: const [
      Offset(0.5, 0.7),  // false at bottom
      Offset(0.5, 0.3),  // true at top
    ],
    edges: {(0, 1)}, // false → true
    highlighted: (0, 1), // false and true
    operation: MeetOrJoin.meet,
    answer: 0, // false ∧ true = false
    hint: 'Meet = greatest lower bound. What\'s the largest element ≤ both false and true?',
    notationReveal: 'false ∧ true = false\n\nMeet in Bool = AND\n(∧ is "and")',
  ),

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

  // Exercise 1.7: more boolean cases (spiral back)
  MeetJoinPickConfig(
    id: 'mj5-bool-tt',
    title: 'OR²',
    subtitle: null,
    elementLabels: const ['false', 'true'],
    positions: const [
      Offset(0.5, 0.7),
      Offset(0.5, 0.3),
    ],
    edges: {(0, 1)},
    highlighted: (1, 1), // true and true
    operation: MeetOrJoin.join,
    answer: 1, // true ∨ true = true
    hint: 'What\'s true ∨ true? Remember: p ∨ p = p always.',
    notationReveal: 'true ∨ true = true\n\np ∨ p = p (idempotent)\nfor any element in any lattice',
  ),
  MeetJoinPickConfig(
    id: 'mj6-bool-ff',
    title: 'AND²',
    subtitle: null,
    elementLabels: const ['false', 'true'],
    positions: const [
      Offset(0.5, 0.7),
      Offset(0.5, 0.3),
    ],
    edges: {(0, 1)},
    highlighted: (0, 0), // false and false
    operation: MeetOrJoin.meet,
    answer: 0, // false ∧ false = false
    hint: 'What\'s false ∧ false?',
    notationReveal: 'false ∧ false = false\n\np ∧ p = p (idempotent)\nMeet with yourself = yourself',
  ),

  // Meet/join in the cube P({1,2,3})
  MeetJoinPickConfig(
    id: 'mj7-cube-meet',
    title: 'FILTER',
    subtitle: null,
    elementLabels: const ['∅', '{1}', '{2}', '{3}', '{1,2}', '{1,3}', '{2,3}', 'X'],
    positions: const [
      Offset(0.5, 0.88),
      Offset(0.2, 0.65),
      Offset(0.5, 0.65),
      Offset(0.8, 0.65),
      Offset(0.2, 0.38),
      Offset(0.5, 0.38),
      Offset(0.8, 0.38),
      Offset(0.5, 0.12),
    ],
    edges: {(0,1),(0,2),(0,3),(1,4),(1,5),(2,4),(2,6),(3,5),(3,6),(4,7),(5,7),(6,7)},
    highlighted: (4, 6), // {1,2} and {2,3}
    operation: MeetOrJoin.meet,
    answer: 2, // {1,2} ∩ {2,3} = {2}
    hint: 'Meet in a power set = intersection. What elements do {1,2} and {2,3} share?',
    notationReveal: '{1,2} ∧ {2,3} = {2}\n\nIntersection in the cube!',
  ),
  MeetJoinPickConfig(
    id: 'mj8-cube-join',
    title: 'UNION',
    subtitle: null,
    elementLabels: const ['∅', '{1}', '{2}', '{3}', '{1,2}', '{1,3}', '{2,3}', 'X'],
    positions: const [
      Offset(0.5, 0.88),
      Offset(0.2, 0.65),
      Offset(0.5, 0.65),
      Offset(0.8, 0.65),
      Offset(0.2, 0.38),
      Offset(0.5, 0.38),
      Offset(0.8, 0.38),
      Offset(0.5, 0.12),
    ],
    edges: {(0,1),(0,2),(0,3),(1,4),(1,5),(2,4),(2,6),(3,5),(3,6),(4,7),(5,7),(6,7)},
    highlighted: (1, 3), // {1} and {3}
    operation: MeetOrJoin.join,
    answer: 5, // {1} ∪ {3} = {1,3}
    hint: 'Join in a power set = union. What\'s the smallest set containing both {1} and {3}?',
    notationReveal: '{1} ∨ {3} = {1,3}\n\nUnion in the cube!',
  ),

  // Harder divisibility: meet where answer isn't obvious
  MeetJoinPickConfig(
    id: 'mj9-gcd2',
    title: 'GCD²',
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
    highlighted: (3, 4), // 4 and 5
    operation: MeetOrJoin.meet,
    answer: 0, // GCD(4,5) = 1
    hint: 'Meet = greatest common divisor. What divides both 4 and 5?',
    notationReveal: '4 ∧ 5 = 1\n\nCoprime! Their only common\ndivisor is 1 (the bottom)',
  ),
  MeetJoinPickConfig(
    id: 'mj10-lcm2',
    title: 'LCM²',
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
    highlighted: (1, 5), // 2 and 6
    operation: MeetOrJoin.join,
    answer: 5, // LCM(2,6) = 6
    hint: 'Join = least common multiple. What\'s the smallest number both 2 and 6 divide into?',
    notationReveal: '2 ∨ 6 = 6\n\nSince 2 divides 6, we have\n2 ≤ 6, so 2 ∨ 6 = 6\n(join with something above = it)',
  ),
];

// ── Monotone map levels (Section 1.2.3, Def 1.59) ──

final monotoneLevels = [
  // Bool → Bool: only 4 possible maps, 3 are monotone
  MonotoneLevelConfig(
    id: 'mon1-bool',
    title: 'PRESERVE',
    subtitle: 'Draw f: Bool → Bool that preserves order.\nIf a ≤ b then f(a) ≤ f(b).',
    domainLabels: const ['F', 'T'],
    domainPositions: const [Offset(0.5, 0.7), Offset(0.5, 0.3)],
    domainEdges: {(0, 1)},
    codomainLabels: const ['F', 'T'],
    codomainPositions: const [Offset(0.5, 0.7), Offset(0.5, 0.3)],
    codomainEdges: {(0, 1)},
    hint: 'F ≤ T, so f(F) ≤ f(T) must hold. Which maps work? Try: both to T, or F→F and T→T.',
    notationReveal: 'There are 3 monotone maps Bool → Bool:\nF↦F,T↦T (identity)\nF↦F,T↦F (constant false)\nF↦T,T↦T (constant true)\n\nOnly F↦T,T↦F breaks order!',
  ),

  // 3-chain → 2-chain: which maps preserve order?
  MonotoneLevelConfig(
    id: 'mon2-chain',
    title: 'SQUEEZE',
    subtitle: 'Map a 3-chain into a 2-chain, preserving order.',
    domainLabels: const ['1', '2', '3'],
    domainPositions: const [Offset(0.5, 0.8), Offset(0.5, 0.5), Offset(0.5, 0.2)],
    domainEdges: {(0, 1), (1, 2)},
    codomainLabels: const ['a', 'b'],
    codomainPositions: const [Offset(0.5, 0.7), Offset(0.5, 0.3)],
    codomainEdges: {(0, 1)},
    hint: '1 ≤ 2 ≤ 3, so f(1) ≤ f(2) ≤ f(3). Since a ≤ b, the only constraint is: no "going down."',
    notationReveal: 'f : 3 → 2 monotone\n\nThere are 3 monotone maps:\naaa, aab, abb\n(where the "jump" from a to b\ncan happen at any point)',
  ),

  // Diamond (P({1,2})) → 2-chain: nontrivial constraint
  MonotoneLevelConfig(
    id: 'mon3-diamond',
    title: 'FLATTEN',
    subtitle: 'Map the diamond into a 3-chain, preserving order.',
    domainLabels: const ['⊥', 'L', 'R', '⊤'],
    domainPositions: const [
      Offset(0.5, 0.85), Offset(0.2, 0.5),
      Offset(0.8, 0.5), Offset(0.5, 0.15),
    ],
    domainEdges: {(0, 1), (0, 2), (1, 3), (2, 3)},
    codomainLabels: const ['1', '2', '3'],
    codomainPositions: const [Offset(0.5, 0.8), Offset(0.5, 0.5), Offset(0.5, 0.2)],
    codomainEdges: {(0, 1), (1, 2)},
    hint: 'L and R are incomparable in the diamond, but they must each map somewhere between f(⊥) and f(⊤).',
    notationReveal: 'Monotone maps can "flatten"\nincomparable elements onto\nthe same level.\n\nOrder-preserving ≠ order-reflecting!',
  ),

  // Identity map: trivially monotone (Ex 1.70)
  MonotoneLevelConfig(
    id: 'mon4-identity',
    title: 'MIRROR',
    subtitle: 'Map each element to itself. Always monotone!',
    domainLabels: const ['a', 'b', 'c'],
    domainPositions: const [Offset(0.5, 0.8), Offset(0.3, 0.4), Offset(0.7, 0.4)],
    domainEdges: {(0, 1), (0, 2)},
    codomainLabels: const ['a', 'b', 'c'],
    codomainPositions: const [Offset(0.5, 0.8), Offset(0.3, 0.4), Offset(0.7, 0.4)],
    codomainEdges: {(0, 1), (0, 2)},
    expectedMap: {0: 0, 1: 1, 2: 2},
    hint: 'The identity map sends every element to itself.',
    notationReveal: 'id_P : P → P\n\nThe identity is always monotone.\nIt\'s the simplest example of\na structure-preserving map.',
  ),

  // Cardinality map: |·| : P({1,2}) → 3-chain (Ex 1.62–1.63)
  MonotoneLevelConfig(
    id: 'mon5-cardinality',
    title: 'COUNT',
    subtitle: 'Map each set to its size. Is it monotone?',
    domainLabels: const ['∅', '{1}', '{2}', '{1,2}'],
    domainPositions: const [
      Offset(0.5, 0.85), Offset(0.2, 0.5),
      Offset(0.8, 0.5), Offset(0.5, 0.15),
    ],
    domainEdges: {(0, 1), (0, 2), (1, 3), (2, 3)},
    codomainLabels: const ['0', '1', '2'],
    codomainPositions: const [Offset(0.5, 0.8), Offset(0.5, 0.5), Offset(0.5, 0.2)],
    codomainEdges: {(0, 1), (1, 2)},
    expectedMap: {0: 0, 1: 1, 2: 1, 3: 2}, // ∅↦0, {1}↦1, {2}↦1, {1,2}↦2
    hint: '∅ has 0 elements, {1} has 1, {2} has 1, {1,2} has 2.',
    notationReveal: '|·| : P({1,2}) → ℕ\n\nCardinality is monotone!\nA ⊆ B implies |A| ≤ |B|\n\nThis "flattens" the diamond\ninto a chain (Ex 1.63)',
  ),

  // Closure operator: compute j = g∘f (Section 1.4.4)
  // From UNSQUEEZE: f: 1↦1, 2↦1, 3↦2. g: 1↦2, 2↦3, 3↦3.
  // j = g∘f: 1↦g(1)=2, 2↦g(1)=2, 3↦g(2)=3.
  MonotoneLevelConfig(
    id: 'mon6-closure',
    title: 'CLOSURE',
    subtitle: 'Compute j = g∘f (the "round trip").\nMaps P to itself: p ≤ j(p) and j(j(p)) = j(p).',
    domainLabels: const ['1', '2', '3'],
    domainPositions: const [Offset(0.5, 0.8), Offset(0.5, 0.5), Offset(0.5, 0.2)],
    domainEdges: {(0, 1), (1, 2)},
    codomainLabels: const ['1', '2', '3'],
    codomainPositions: const [Offset(0.5, 0.8), Offset(0.5, 0.5), Offset(0.5, 0.2)],
    codomainEdges: {(0, 1), (1, 2)},
    expectedMap: {0: 1, 1: 1, 2: 2}, // j: 1↦2, 2↦2, 3↦3
    hint: 'From UNSQUEEZE: f(1)=1, f(2)=1, f(3)=2 and g(1)=2, g(2)=3, g(3)=3.\nj(p) = g(f(p)). So j(1)=g(1)=2, j(2)=g(1)=2, j(3)=g(2)=3.',
    notationReveal: 'j : 1↦2, 2↦2, 3↦3\n\nFixed points = {2, 3}\nj "rounds up" to fixed points.\n\np ≤ j(p) ✓  j(j(p)) = j(p) ✓\n\nThis is a closure operator!\n(Def 1.120, Section 1.4.4 ✓)',
  ),
];

// ── Galois connection levels (Section 1.4, Def 1.95) ──

final galoisLevels = [
  // Exercise 1.99 part 1: 3-chain to 3-chain, simple adjunction
  // f: 1↦1, 2↦2, 3↦3 (identity), g must also be identity
  GaloisLevelConfig(
    id: 'gal1-identity',
    title: 'ADJOINT',
    subtitle: 'Given f, find g such that\nf(p) ≤ q  iff  p ≤ g(q).\nDrag from Q nodes → P nodes to define g.',
    pLabels: const ['1', '2'],
    pPositions: const [Offset(0.5, 0.7), Offset(0.5, 0.3)],
    pEdges: {(0, 1)},
    qLabels: const ['a', 'b'],
    qPositions: const [Offset(0.5, 0.7), Offset(0.5, 0.3)],
    qEdges: {(0, 1)},
    givenMap: {0: 0, 1: 1}, // f: 1↦a, 2↦b (identity-like)
    fIsGiven: true,
    expectedAnswer: {0: 0, 1: 1}, // g: a↦1, b↦2
    hint: 'f is the identity (preserving labels). For f(p) ≤ q iff p ≤ g(q), try g = identity too.',
    notationReveal: 'f = g = identity!\n\nWhen f is an isomorphism,\ng = f⁻¹ (the inverse).\nGalois connections generalize\nisomorphisms.',
  ),

  // f: 2-chain → 3-chain, f(1)=1, f(2)=3. Find g.
  // g must satisfy: f(p) ≤ q iff p ≤ g(q)
  // f(1)=1 ≤ q iff 1 ≤ g(q) → always true, g(q) ≥ 1 always → g(1)≥1, g(2)≥1, g(3)≥1
  // f(2)=3 ≤ q iff 2 ≤ g(q) → 3≤1? no. 3≤2? no. 3≤3? yes → g(3)=2, g(1)=1, g(2)=1
  GaloisLevelConfig(
    id: 'gal2-floor',
    title: 'ROUND',
    subtitle: 'Given f (left adjoint), find g (right adjoint).\nDrag from Q nodes → P nodes.',
    pLabels: const ['1', '2'],
    pPositions: const [Offset(0.5, 0.7), Offset(0.5, 0.3)],
    pEdges: {(0, 1)},
    qLabels: const ['1', '2', '3'],
    qPositions: const [Offset(0.5, 0.8), Offset(0.5, 0.5), Offset(0.5, 0.2)],
    qEdges: {(0, 1), (1, 2)},
    givenMap: {0: 0, 1: 2}, // f: 1↦1, 2↦3
    fIsGiven: true,
    expectedAnswer: {0: 0, 1: 0, 2: 1}, // g: 1↦1, 2↦1, 3↦2
    hint: 'For each q, g(q) is the LARGEST p such that f(p) ≤ q.\nf(1)=1, f(2)=3. So g(1)=1 (f(1)≤1), g(2)=1 (f(1)≤2 but f(2)=3>2), g(3)=2.',
    notationReveal: 'f "embeds" {1,2} into {1,2,3}\ng "rounds down" to the nearest\nelement in the image of f\n\nLike ceiling ⌈−/3⌉ and\nfloor ⌊3×−⌋ from Ex 1.97!',
  ),

  // Bool → diamond: f(F)=⊥, f(T)=⊤. Find g.
  // g(⊥)=F (f(F)=⊥≤⊥, f(T)=⊤≰⊥), g(L)=? f(F)=⊥≤L? yes. f(T)=⊤≤L? no → g(L)=F
  // g(R)=F same reasoning. g(⊤)=T (f(T)=⊤≤⊤).
  GaloisLevelConfig(
    id: 'gal3-diamond',
    title: 'CONNECT',
    subtitle: 'Given f: Bool → Diamond, find g.\nDrag from Q nodes → P nodes.',
    pLabels: const ['F', 'T'],
    pPositions: const [Offset(0.5, 0.7), Offset(0.5, 0.3)],
    pEdges: {(0, 1)},
    qLabels: const ['⊥', 'L', 'R', '⊤'],
    qPositions: const [
      Offset(0.5, 0.85), Offset(0.2, 0.5),
      Offset(0.8, 0.5), Offset(0.5, 0.15),
    ],
    qEdges: {(0, 1), (0, 2), (1, 3), (2, 3)},
    givenMap: {0: 0, 1: 3}, // f: F↦⊥, T↦⊤
    fIsGiven: true,
    expectedAnswer: {0: 0, 1: 0, 2: 0, 3: 1}, // g: ⊥↦F, L↦F, R↦F, ⊤↦T
    hint: 'g(q) = largest p with f(p) ≤ q.\nf(F)=⊥, f(T)=⊤.\ng(⊥): f(F)=⊥≤⊥ ✓ → F. g(L): f(F)=⊥≤L ✓, f(T)=⊤≤L? ✗ → F.\ng(⊤): f(T)=⊤≤⊤ ✓ → T.',
    notationReveal: 'g collapses the middle!\nL and R both map to F.\n\nThe right adjoint "rounds down"\nto the image of f.\n\nInformation is lost — Galois\nconnections aren\'t isomorphisms.',
  ),

  // Exercise 1.99 part 1: 3-chain → 3-chain (non-crossing arrows)
  // f(1)=1, f(2)=1, f(3)=2. g must satisfy f(p)≤q iff p≤g(q).
  // f(1)=1≤1 iff 1≤g(1) → g(1)≥1. f(2)=1≤1 iff 2≤g(1) → g(1)≥2. f(3)=2≤1? no → ok.
  // So g(1)=2. f(1)=1≤2 iff 1≤g(2)→g(2)≥1. f(2)=1≤2→2≤g(2)→g(2)≥2. f(3)=2≤2→3≤g(2)→g(2)≥3.
  // So g(2)=3. f(1)=1≤3→1≤g(3). f(2)=1≤3→2≤g(3). f(3)=2≤3→3≤g(3). g(3)=3.
  GaloisLevelConfig(
    id: 'gal4-squeeze',
    title: 'UNSQUEEZE',
    subtitle: 'Given f: 3→3 (left adjoint), find g.',
    pLabels: const ['1', '2', '3'],
    pPositions: const [Offset(0.5, 0.8), Offset(0.5, 0.5), Offset(0.5, 0.2)],
    pEdges: {(0, 1), (1, 2)},
    qLabels: const ['1', '2', '3'],
    qPositions: const [Offset(0.5, 0.8), Offset(0.5, 0.5), Offset(0.5, 0.2)],
    qEdges: {(0, 1), (1, 2)},
    givenMap: {0: 0, 1: 0, 2: 1}, // f: 1↦1, 2↦1, 3↦2
    fIsGiven: true,
    expectedAnswer: {0: 1, 1: 2, 2: 2}, // g: 1↦2, 2↦3, 3↦3
    hint: 'g(q) = largest p with f(p) ≤ q.\nf maps 1,2 both to 1, and 3 to 2.\nSo g(1) must be ≥ both 1 and 2 (since f(1)=f(2)=1≤1). g(1)=2.',
    notationReveal: 'f squeezes, g stretches!\n\nf(1)=f(2)=1 collapses two elements.\ng "un-squeezes" by mapping\nto the LARGEST preimage.\n\nEx 1.99 ✓',
  ),

  // Closure operator: compute j = g∘f for the ROUND adjunction
  // f: 1↦1, 2↦3. g: 1↦1, 2↦1, 3↦2.
  // j = g∘f: 1↦g(f(1))=g(1)=1, 2↦g(f(2))=g(3)=2.
  // j is identity! (because f is injective — no info lost)
  GaloisLevelConfig(
    id: 'gal5-closure1',
    title: 'CLOSE',
    subtitle: 'Compute the closure j = g∘f.\nWhat does "round trip" f then g do?',
    pLabels: const ['1', '2'],
    pPositions: const [Offset(0.5, 0.7), Offset(0.5, 0.3)],
    pEdges: {(0, 1)},
    qLabels: const ['1', '2'],
    qPositions: const [Offset(0.5, 0.7), Offset(0.5, 0.3)],
    qEdges: {(0, 1)},
    // "Given" is f;g composite shown as a monotone map P→P
    // But we use a trick: show g as "given" (Q→P) and ask for j: P→P
    // Actually let's just make this a monotone level instead...
    // For now: give g, find f (the left adjoint going P→Q)
    givenMap: {0: 0, 1: 1}, // g: 1↦1, 2↦2 (identity on Q=P)
    fIsGiven: false, // g is given, find f
    expectedAnswer: {0: 0, 1: 1}, // f: 1↦1, 2↦2
    hint: 'g is the identity. What f makes f(p) ≤ q iff p ≤ g(q) = q? That\'s just f(p) ≤ q iff p ≤ q... f = identity!',
    notationReveal: 'When g = id, f = id too!\n\nThe closure j = g∘f = id∘id = id.\nFixed points of id = everything.\n\nDef 1.120: a closure operator j\nsatisfies p ≤ j(p) and j(j(p)) ≅ j(p)',
  ),

];

/// Unified level type for the level select screen.
enum Ch1LevelType { partition, ordering, join, function_, preorder, meetJoinPick, monotone, bridge, galois }

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
  // Monotone map levels
  for (var i = 0; i < monotoneLevels.length; i++)
    Ch1Level(
      title: monotoneLevels[i].title,
      type: Ch1LevelType.monotone,
      index: i,
    ),
  // Bridge levels (teach notation before Galois)
  for (var i = 0; i < bridgeLevels.length; i++)
    Ch1Level(
      title: bridgeLevels[i].title,
      type: Ch1LevelType.bridge,
      index: i,
    ),
  // Galois connection levels
  for (var i = 0; i < galoisLevels.length; i++)
    Ch1Level(
      title: galoisLevels[i].title,
      type: Ch1LevelType.galois,
      index: i,
    ),
];
