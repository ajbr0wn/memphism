import 'package:flutter/material.dart';
import '../screens/monoidal_table_screen.dart';
import '../screens/meet_join_pick_screen.dart';

/// Chapter 2: Resource Theories — Monoidal Preorders and Enrichment
/// Covers: symmetric monoidal preorders, wiring diagrams, Bool/Cost,
/// V-categories, enrichment.

// ── Monoidal table levels (Section 2.2) ──

final monoidalTableLevels = [
  // Exercise 2.27: Bool with AND — fill the truth table
  MonoidalTableConfig(
    id: 'mt1-bool-and',
    title: 'TRUTH',
    subtitle: 'Fill in the AND (∧) table for booleans.',
    elements: const ['F', 'T'],
    operationSymbol: '∧',
    expectedTable: const [
      [0, 0], // F∧F=F, F∧T=F
      [0, 1], // T∧F=F, T∧T=T
    ],
    givenCells: {(1, 1)}, // T∧T=T is given
    unitIndex: 1, // true is the unit for AND
    hint: 'AND is like multiplication: F=0, T=1.\nAnything AND false = false.',
    notationReveal: 'Bool = (𝔹, ≤, true, ∧)\n\ntrue is the monoidal unit:\ntrue ∧ x = x for all x\n\nThis is THE boolean monoidal\npreorder (Ex 2.27)',
  ),

  // Exercise 2.29: Bool with OR — what's the unit?
  MonoidalTableConfig(
    id: 'mt2-bool-or',
    title: 'EITHER',
    subtitle: 'Fill in the OR (∨) table. What\'s the unit?',
    elements: const ['F', 'T'],
    operationSymbol: '∨',
    expectedTable: const [
      [0, 1], // F∨F=F, F∨T=T
      [1, 1], // T∨F=T, T∨T=T
    ],
    givenCells: {(0, 0)}, // F∨F=F is given
    unitIndex: 0, // false is the unit for OR
    hint: 'OR is like max: F=0, T=1.\nAnything OR true = true.\nThe unit must satisfy I∨x = x.',
    notationReveal: 'Another monoidal structure on 𝔹!\n(𝔹, ≤, false, ∨)\n\nfalse is the unit: false ∨ x = x\n\nSame preorder, different\nmonoidal product! (Ex 2.29)',
  ),

  // Exercise 2.34: no → maybe → yes with "min"
  MonoidalTableConfig(
    id: 'mt3-nmy',
    title: 'MAYBE',
    subtitle: 'Fill in the "min" table for {no, maybe, yes}.',
    elements: const ['no', 'mby', 'yes'],
    operationSymbol: 'min',
    expectedTable: const [
      [0, 0, 0], // min(no,no)=no, min(no,mby)=no, min(no,yes)=no
      [0, 1, 1], // min(mby,no)=no, min(mby,mby)=mby, min(mby,yes)=mby
      [0, 1, 2], // min(yes,no)=no, min(yes,mby)=mby, min(yes,yes)=yes
    ],
    givenCells: {(2, 2), (0, 0)}, // yes min yes = yes, no min no = no
    unitIndex: 2, // yes is the unit for min
    hint: 'min picks the lower element.\nno ≤ maybe ≤ yes, so min(no, anything) = no.\nThe unit I must satisfy min(I, x) = x. Which element works?',
    notationReveal: 'NMY = (P, ≤, yes, min)\n\nyes is the unit:\nmin(yes, x) = x for all x\n\nThis is a meet-semilattice!\n(Ex 2.34)',
  ),

  // Natural numbers with addition (Example 2.30)
  MonoidalTableConfig(
    id: 'mt4-nat-add',
    title: 'ADD',
    subtitle: 'Fill in the addition table for {0, 1, 2, 3}.',
    elements: const ['0', '1', '2', '3'],
    operationSymbol: '+',
    expectedTable: const [
      [0, 1, 2, 3], // 0+0=0, 0+1=1, 0+2=2, 0+3=3
      [1, 2, 3, 3], // 1+0=1, 1+1=2, 1+2=3, 1+3=? cap at 3
      [2, 3, 3, 3], // 2+0=2, 2+1=3, 2+2=? cap at 3
      [3, 3, 3, 3], // 3+anything = 3 (capped)
    ],
    givenCells: {(0, 0), (0, 1), (0, 2), (0, 3)}, // first row given
    unitIndex: 0, // 0 is the unit for addition
    hint: 'Regular addition, but we cap at 3 (since our set is {0,1,2,3}).\n1+2=3, 2+2=3 (capped), etc.\n0 is the unit: 0+x = x.',
    notationReveal: '(ℕ≤3, ≤, 0, +)\n\n0 is the monoidal unit\nAddition is the monoidal product\n\nCapping is needed because our\nset is finite (Ex 2.30)',
  ),

  // Natural numbers with multiplication (Exercise 2.31)
  MonoidalTableConfig(
    id: 'mt5-nat-mult',
    title: 'TIMES',
    subtitle: 'Fill in × for {1, 2, 3}. What\'s the unit?',
    elements: const ['1', '2', '3'],
    operationSymbol: '×',
    expectedTable: const [
      [0, 1, 2], // 1×1=1, 1×2=2, 1×3=3
      [1, 2, 2], // 2×1=2, 2×2=4→3(cap), 2×3=6→3(cap)
      [2, 2, 2], // 3×1=3, 3×2=6→3, 3×3=9→3
    ],
    givenCells: {(0, 0), (0, 1), (0, 2)}, // first row given
    unitIndex: 0, // 1 is the unit for multiplication
    hint: 'Regular multiplication, capped at 3.\n2×2=4, but our set only goes to 3, so cap at 3.\n1 is the unit: 1×x = x.',
    notationReveal: '(ℕ≤3, ≤, 1, ×)\n\n1 is the monoidal unit\nfor multiplication\n\nTwo monoidal structures on\nthe same preorder! (Ex 2.31)',
  ),

  // Power set with intersection (Exercise 2.35)
  MonoidalTableConfig(
    id: 'mt6-powerset-cap',
    title: 'INTERSECT',
    subtitle: 'Fill in ∩ for P({1,2}) = {∅, {1}, {2}, {1,2}}.',
    elements: const ['∅', '{1}', '{2}', 'X'],
    operationSymbol: '∩',
    expectedTable: const [
      [0, 0, 0, 0], // ∅∩anything = ∅
      [0, 1, 0, 1], // {1}∩∅=∅, {1}∩{1}={1}, {1}∩{2}=∅, {1}∩X={1}
      [0, 0, 2, 2], // {2}∩∅=∅, {2}∩{1}=∅, {2}∩{2}={2}, {2}∩X={2}
      [0, 1, 2, 3], // X∩anything = anything
    ],
    givenCells: {(3, 0), (3, 1), (3, 2), (3, 3)}, // last row given (X∩x = x)
    unitIndex: 3, // X = {1,2} is the unit for intersection
    hint: 'Intersection keeps only shared elements.\n{1}∩{2} = ∅ (nothing in common).\nThe unit must satisfy I∩x = x. Which set works?',
    notationReveal: '(P({1,2}), ⊆, {1,2}, ∩)\n\nThe whole set X is the unit!\nX ∩ A = A for all A\n\nMeet = intersection (Ch 1)\nNow it\'s also the monoidal\nproduct! (Ex 2.35)',
  ),
];

/// Level types for Chapter 2.
enum Ch2LevelType { monoidalTable }

class Ch2Level {
  final String title;
  final Ch2LevelType type;
  final int index;
  final bool isBoss;

  const Ch2Level({
    required this.title,
    required this.type,
    required this.index,
    this.isBoss = false,
  });
}

final ch2AllLevels = [
  for (var i = 0; i < monoidalTableLevels.length; i++)
    Ch2Level(
      title: monoidalTableLevels[i].title,
      type: Ch2LevelType.monoidalTable,
      index: i,
    ),
];
