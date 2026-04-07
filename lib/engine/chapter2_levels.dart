import 'package:flutter/material.dart';
import '../screens/monoidal_table_screen.dart';
import '../screens/meet_join_pick_screen.dart';
import '../screens/tap_answer_screen.dart';

/// Chapter 2: Resource Theories — Monoidal Preorders and Enrichment
/// Covers: symmetric monoidal preorders, wiring diagrams, Bool/Cost,
/// V-categories, enrichment.

// ── Monoidal table levels (Section 2.2) ──

final List<MonoidalTableConfig> monoidalTableLevels = [
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

  // Bool-category matrix from a Hasse diagram (Ex 2.47, Thm 2.49)
  // Preorder: p ≤ q ≤ r (3-chain). X(x,y) = true if x≤y, false otherwise.
  MonoidalTableConfig(
    id: 'mt7-bool-cat',
    title: 'ENRICH',
    subtitle: 'Fill in X(x,y): true if x ≤ y, false otherwise.\nThis IS a Bool-category!',
    elements: const ['p', 'q', 'r'],
    operationSymbol: '≤?',
    expectedTable: const [
      [1, 1, 1], // p≤p=T, p≤q=T, p≤r=T
      [0, 1, 1], // q≤p=F, q≤q=T, q≤r=T
      [0, 0, 1], // r≤p=F, r≤q=F, r≤r=T
    ],
    givenCells: {(0, 0), (1, 1), (2, 2)}, // diagonal always true
    unitIndex: null,
    hint: 'The preorder is p ≤ q ≤ r (a 3-chain).\nX(x,y) = true if x ≤ y.\nThe diagonal is always true (reflexivity).',
    notationReveal: 'A Bool-category!\n\nThm 2.49: preorders and\nBool-categories are the same thing.\n\nThe matrix IS the preorder,\njust written differently.',
  ),

  // Bool-enriched: Ex 2.50 round trip (preorder → Bool-cat → preorder)
  // Use 2-chain: a ≤ b. Show the Bool matrix, then show it's the same preorder.
  MonoidalTableConfig(
    id: 'mt8-roundtrip',
    title: 'OOZE',
    subtitle: 'A preorder IS a Bool-category.\nFill in X(x,y) = true iff x ≤ y.',
    elements: const ['a', 'b'],
    operationSymbol: '≤?',
    expectedTable: const [
      [1, 1], // a≤a=T, a≤b=T
      [0, 1], // b≤a=F, b≤b=T
    ],
    givenCells: {(0, 0)}, // just a≤a=T
    unitIndex: null,
    hint: 'a ≤ b is our preorder. X(a,a)=T (reflexive), X(a,b)=T, X(b,a)=F, X(b,b)=T.',
    notationReveal: 'Preorder ↔ Bool-category\n\n"A primordial ooze" — Peter Gates\n\nCategory theory defines\nitself in terms of itself.\nBool is a preorder, and\npreorders are Bool-categories!\n\n(Thm 2.49, Ex 2.50)',
  ),

  // Ex 2.5: Why doesn't × work on (ℝ, ≤)?
  // Because (-1)×(-1) = 1, but -1 ≤ 0 and -1 ≤ 0 don't imply 1 ≤ 0
  // We can make this a "spot the problem" level
  // Let's do it as a table where multiplication breaks monotonicity
  MonoidalTableConfig(
    id: 'mt9-broken',
    title: 'BROKEN',
    subtitle: 'Fill in × for {-1, 0, 1}.\nIs this a valid monoidal preorder?',
    elements: const ['-1', '0', '1'],
    operationSymbol: '×',
    expectedTable: const [
      [2, 1, 0], // (-1)×(-1)=1, (-1)×0=0, (-1)×1=-1
      [1, 1, 1], // 0×(-1)=0, 0×0=0, 0×1=0
      [0, 1, 2], // 1×(-1)=-1, 1×0=0, 1×1=1
    ],
    givenCells: {(1, 0), (1, 1), (1, 2)}, // middle row (0×anything=0)
    unitIndex: 2, // 1 is the unit
    hint: 'Regular multiplication.\n(-1)×(-1) = 1. But -1 ≤ 0 and -1 ≤ 0.\nDoes (-1)×(-1) ≤ 0×0? That would need 1 ≤ 0... 🤔',
    notationReveal: '× is NOT monotone on (ℝ, ≤)!\n\n-1 ≤ 0 but (-1)×(-1) = 1 > 0×0 = 0\n\nMonotonicity fails:\na≤b, c≤d does NOT imply a×c ≤ b×d\n\nThe expert was right! (Ex 2.5)',
  ),

  // Bool-category for diamond preorder (Ex 2.47 extended)
  MonoidalTableConfig(
    id: 'mt10-diamond-cat',
    title: 'MATRIX',
    subtitle: 'Build the Bool-category matrix for the diamond.\n⊥ ≤ L, ⊥ ≤ R, L ≤ ⊤, R ≤ ⊤.',
    elements: const ['⊥', 'L', 'R', '⊤'],
    operationSymbol: '≤?',
    expectedTable: const [
      [1, 1, 1, 1], // ⊥ ≤ everything
      [0, 1, 0, 1], // L ≤ L, L ≤ ⊤
      [0, 0, 1, 1], // R ≤ R, R ≤ ⊤
      [0, 0, 0, 1], // ⊤ ≤ ⊤ only
    ],
    givenCells: {(0, 0), (1, 1), (2, 2), (3, 3)}, // diagonal
    unitIndex: null,
    hint: 'X(x,y) = true iff x ≤ y.\nThe diamond: ⊥ ≤ L, ⊥ ≤ R, L ≤ ⊤, R ≤ ⊤.\nL and R are incomparable: L ≤ R? false.',
    notationReveal: 'The diamond as a Bool-category!\n\nEvery preorder IS a Bool-category\nand every Bool-category IS a\npreorder. Same structure,\ndifferent perspective.\n\n(Thm 2.49)',
  ),

  // Ex 2.84: Bool is monoidal closed — find the ⊸ operation
  // In Bool: a ∧ x ≥ y iff x ≥ (a ⊸ y)
  // a ⊸ y = (a implies y) = ¬a ∨ y
  // Table: F⊸F=T, F⊸T=T, T⊸F=F, T⊸T=T (material implication!)
  MonoidalTableConfig(
    id: 'mt11-implies',
    title: 'IMPLIES',
    subtitle: 'Find ⊸ for Bool.\na ∧ x ≥ y  iff  x ≥ (a ⊸ y).',
    elements: const ['F', 'T'],
    operationSymbol: '⊸',
    expectedTable: const [
      [1, 1], // F⊸F=T, F⊸T=T
      [0, 1], // T⊸F=F, T⊸T=T
    ],
    givenCells: {(1, 1)}, // T⊸T=T given
    unitIndex: null,
    hint: 'a ⊸ y is the largest x such that a ∧ x ≤ y.\nT ⊸ F: need largest x with T ∧ x ≤ F. T∧T=T≰F, T∧F=F≤F. So x=F.\nF ⊸ anything: F∧x=F≤anything. So x=T works.',
    notationReveal: '⊸ in Bool = implication!\n\nF⊸F=T, F⊸T=T\nT⊸F=F, T⊸T=T\n\n"false implies anything" = true\nThis is material implication!\n\nBool is monoidal closed (Ex 2.84)',
  ),
  // Cost preorder: fill in + table for {0, 1, 2, ∞} with ≥ order (Ex 2.37)
  // Cost = ([0,∞], ≥, 0, +). Note: ORDER IS REVERSED (≥ not ≤)!
  MonoidalTableConfig(
    id: 'mt12-cost',
    title: 'COST',
    subtitle: 'Fill in + for costs {0, 1, 2, ∞}.\nNote: order is ≥ (bigger = lower!)',
    elements: const ['0', '1', '2', '∞'],
    operationSymbol: '+',
    expectedTable: const [
      [0, 1, 2, 3], // 0+0=0, 0+1=1, 0+2=2, 0+∞=∞
      [1, 2, 3, 3], // 1+0=1, 1+1=2, 1+2=3→∞(cap), 1+∞=∞
      [2, 3, 3, 3], // 2+0=2, 2+1=3→∞, 2+2=4→∞, 2+∞=∞
      [3, 3, 3, 3], // ∞+anything=∞
    ],
    givenCells: {(0, 0), (0, 1), (0, 2), (0, 3)}, // first row given
    unitIndex: 0, // 0 is the unit for Cost
    hint: 'Cost = ([0,∞], ≥, 0, +).\nAdd normally, cap at ∞ if result > 2.\n0 is the unit: 0 + x = x (zero cost = free).',
    notationReveal: 'Cost = ([0,∞], ≥, 0, +)\n\nThe order is ≥ (reversed!)\n"lower cost = better"\n0 = free, ∞ = impossible\n\nCost-categories are\nLawvere metric spaces! (Def 2.53)',
  ),

  // Ex 2.103: Identity matrices for Bool and Cost
  MonoidalTableConfig(
    id: 'mt13-identity-bool',
    title: 'EYE',
    subtitle: 'Fill in the 3×3 identity matrix for Bool.\nI(x,y) = true if x=y, false otherwise.',
    elements: const ['1', '2', '3'],
    operationSymbol: 'I',
    expectedTable: const [
      [1, 0, 0], // I(1,1)=T, I(1,2)=F, I(1,3)=F
      [0, 1, 0], // I(2,1)=F, I(2,2)=T, I(2,3)=F
      [0, 0, 1], // I(3,1)=F, I(3,2)=F, I(3,3)=T
    ],
    givenCells: {(0, 0)}, // I(1,1)=T given
    unitIndex: null,
    hint: 'The identity matrix: I(x,y) = monoidal unit if x=y, monoidal zero otherwise.\nFor Bool: unit = true, zero = false.',
    notationReveal: 'The Bool identity matrix!\n\nI(x,y) = true iff x = y\n\nThis is the identity for\nV-matrix multiplication.\nI * M = M = M * I\n\n(Ex 2.103)',
  ),
];

// ── Tap-answer bridge levels for Ch2 concepts ──

final List<TapAnswerConfig> ch2BridgeLevels = [
  // What is a ⊗ b? (teach the operation notation)
  TapAnswerConfig(
    id: 'c2b1-product',
    title: 'COMBINE',
    question: 'In Bool, the monoidal product is ∧ (AND).\nWhat is true ∧ false?',
    elementLabels: const ['false', 'true'],
    positions: const [Offset(0.5, 0.65), Offset(0.5, 0.35)],
    edges: {(0, 1)},
    mapArrows: const [],
    answer: 0, // true ∧ false = false
    highlighted: {},
    hint: 'AND: both must be true. true AND false = false.',
    notationReveal: 'true ∧ false = false\n\n∧ is the monoidal product in Bool.\na ⊗ b combines two elements\ninto one. In Bool, ⊗ = AND.',
  ),

  // What's the unit?
  TapAnswerConfig(
    id: 'c2b2-unit',
    title: 'NEUTRAL',
    question: 'The monoidal unit I satisfies\nI ⊗ x = x for all x.\nIn Bool with ∧, what is I?',
    elementLabels: const ['false', 'true'],
    positions: const [Offset(0.35, 0.5), Offset(0.65, 0.5)],
    edges: {},
    mapArrows: const [],
    answer: 1, // true is the unit for AND
    highlighted: {},
    hint: 'I ∧ x = x. Try: true ∧ false = false ✓, true ∧ true = true ✓.\nfalse ∧ true = false ✗ (should be true).',
    notationReveal: 'I = true for Bool = (𝔹, ≤, true, ∧)\n\nThe unit "does nothing":\ntrue ∧ x = x always.\n\nLike 0 for addition,\nor 1 for multiplication.',
  ),

  // Is this monotone? (check the monoidal product preserves order)
  TapAnswerConfig(
    id: 'c2b3-mono-check',
    title: 'CHECK',
    question: 'Monotonicity: if a₁ ≤ b₁ and a₂ ≤ b₂,\nthen a₁⊗a₂ ≤ b₁⊗b₂.\n\nF ≤ T and F ≤ T.\nIs F∧F ≤ T∧T?',
    elementLabels: const ['no', 'yes'],
    positions: const [Offset(0.35, 0.5), Offset(0.65, 0.5)],
    edges: {},
    mapArrows: const [],
    answer: 1, // F∧F=F, T∧T=T, F≤T ✓
    highlighted: {},
    hint: 'F∧F = F. T∧T = T. Is F ≤ T? Yes!',
    notationReveal: 'F∧F = F ≤ T = T∧T ✓\n\nMonotonicity means ⊗\npreserves the order.\nBigger inputs → bigger output.\n\nThis is axiom (a) of Def 2.2.',
  ),

  // Cost: what does 0 mean?
  TapAnswerConfig(
    id: 'c2b4-cost-unit',
    title: 'FREE',
    question: 'In Cost = ([0,∞], ≥, 0, +),\nthe unit is 0.\nWhat does "cost 0" mean?',
    elementLabels: const ['impossible', 'free'],
    positions: const [Offset(0.35, 0.5), Offset(0.65, 0.5)],
    edges: {},
    mapArrows: const [],
    answer: 1, // 0 = free
    highlighted: {},
    hint: '0 + x = x. Zero cost = no cost = free!',
    notationReveal: '0 = free (no cost)\n∞ = impossible (infinite cost)\n\nThe order is ≥ (reversed!):\n∞ ≤ 0 means "impossible is\nworse than free."\n\nCheaper = better = higher\nin the Cost order.',
  ),

  // What does ≥ mean in Cost? (reversed order!)
  TapAnswerConfig(
    id: 'c2b5-cost-order',
    title: 'CHEAPER',
    question: 'In Cost, the order is ≥.\nSo 3 ≤ 5 means 3 ≥ 5.\nIs 3 ≤ 5 in Cost?',
    elementLabels: const ['no (3 < 5)', 'yes (3 ≥ 5)'],
    positions: const [Offset(0.3, 0.5), Offset(0.7, 0.5)],
    edges: {},
    mapArrows: const [],
    answer: 0, // no! 3 < 5, so 3 is NOT ≤ 5 in Cost (where ≤ means ≥)
    highlighted: {},
    hint: 'In Cost, ≤ means ≥ on numbers. 3 ≥ 5? No! 3 < 5.\nSo 3 is NOT ≤ 5 in Cost. Cheaper is "higher" in Cost.',
    notationReveal: '3 ≰ 5 in Cost!\n\nCost reverses the usual order.\n5 ≤ 3 in Cost (because 5 ≥ 3).\n\n"More expensive ≤ cheaper"\nBigger number = worse = lower.',
  ),

  // Bool-category: what does X(a,b) = true mean?
  TapAnswerConfig(
    id: 'c2b6-bool-cat',
    title: 'MATRIX?',
    question: 'A Bool-category X has X(a,b) ∈ {T,F}.\nX(a,b) = true means a ≤ b.\n\nIf a ≤ b and b ≤ c,\nwhat is X(a,c)?',
    elementLabels: const ['false', 'true'],
    positions: const [Offset(0.35, 0.5), Offset(0.65, 0.5)],
    edges: {},
    mapArrows: const [],
    answer: 1, // true — transitivity!
    highlighted: {},
    hint: 'a ≤ b and b ≤ c implies a ≤ c (transitivity).\nSo X(a,c) = true.',
    notationReveal: 'X(a,c) = true\n\nTransitivity: a≤b and b≤c → a≤c.\n\nIn Bool-category language:\nX(a,b) ∧ X(b,c) ≤ X(a,c)\n\nThis is the V-category axiom!\n(Def 2.46)',
  ),
  // Symmetry: x ⊗ y = y ⊗ x (Def 2.2d)
  TapAnswerConfig(
    id: 'c2b7-symmetry',
    title: 'SWAP',
    question: 'Symmetry: a ⊗ b = b ⊗ a.\n\nIn (ℕ, ≤, 0, +):\nIs 3 + 5 = 5 + 3?',
    elementLabels: const ['no', 'yes'],
    positions: const [Offset(0.35, 0.5), Offset(0.65, 0.5)],
    edges: {},
    mapArrows: const [],
    answer: 1, // yes
    highlighted: {},
    hint: '3 + 5 = 8 = 5 + 3. Addition is commutative!',
    notationReveal: 'a ⊗ b = b ⊗ a (symmetry)\n\nThis is axiom (d) of Def 2.2.\nThe "symmetric" in "symmetric\nmonoidal preorder."\n\nNot all monoidal structures\nare symmetric! But ours are.',
  ),

  // Associativity: (a ⊗ b) ⊗ c = a ⊗ (b ⊗ c) (Def 2.2c)
  TapAnswerConfig(
    id: 'c2b8-assoc',
    title: 'REGROUP',
    question: 'Associativity: (a⊗b)⊗c = a⊗(b⊗c).\n\nIn Bool with ∧:\n(T ∧ F) ∧ T = ?\nT ∧ (F ∧ T) = ?',
    elementLabels: const ['different', 'both F'],
    positions: const [Offset(0.35, 0.5), Offset(0.65, 0.5)],
    edges: {},
    mapArrows: const [],
    answer: 1, // both F
    highlighted: {},
    hint: '(T∧F)∧T = F∧T = F.\nT∧(F∧T) = T∧F = F.\nSame answer either way!',
    notationReveal: '(T∧F)∧T = F = T∧(F∧T)\n\nGrouping doesn\'t matter!\nThis is axiom (c) of Def 2.2.\n\nLike (2+3)+4 = 2+(3+4) = 9.',
  ),

  // Wiring diagrams: series composition (Section 2.2.2)
  TapAnswerConfig(
    id: 'c2b9-series',
    title: 'SERIES',
    question: 'Wiring diagrams: if x ≤ y and y ≤ z,\nwe can chain them: x ≤ z.\n\nIn (ℕ, ≤, 0, +):\n2 ≤ 5 and 5 ≤ 8.\nCan we conclude 2 ≤ 8?',
    elementLabels: const ['no', 'yes'],
    positions: const [Offset(0.35, 0.5), Offset(0.65, 0.5)],
    edges: {},
    mapArrows: const [],
    answer: 1, // yes, transitivity
    highlighted: {},
    hint: '2 ≤ 5 ≤ 8, so 2 ≤ 8 by transitivity. This is "connecting boxes in series."',
    notationReveal: 'Series = transitivity!\n\nx ≤ y and y ≤ z → x ≤ z.\n\nIn wiring diagrams, connecting\nboxes end-to-end chains\ninequalities together.\n\n(Section 2.2.2)',
  ),

  // Wiring diagrams: parallel composition (monoidal product)
  TapAnswerConfig(
    id: 'c2b10-parallel',
    title: 'PARALLEL',
    question: 'Parallel: if a₁≤b₁ and a₂≤b₂,\nthen a₁⊗a₂ ≤ b₁⊗b₂.\n\nIn (ℕ,≤,0,+): 2≤5 and 3≤7.\nIs 2+3 ≤ 5+7?',
    elementLabels: const ['no', 'yes'],
    positions: const [Offset(0.35, 0.5), Offset(0.65, 0.5)],
    edges: {},
    mapArrows: const [],
    answer: 1, // 5 ≤ 12, yes
    highlighted: {},
    hint: '2+3 = 5 ≤ 12 = 5+7. Stacking valid boxes in parallel gives a valid box!',
    notationReveal: 'Parallel = monotonicity of ⊗!\n\na₁≤b₁ and a₂≤b₂\nimplies a₁+a₂ ≤ b₁+b₂.\n\nIn wiring diagrams, stacking\nboxes vertically combines\ninequalities in parallel.\n\n(Section 2.2.2, Def 2.2a)',
  ),

  // Monoidal monotone: Bool → Cost (Ex 2.43)
  TapAnswerConfig(
    id: 'c2b11-bool-cost',
    title: 'TRANSLATE',
    question: 'g: Bool → Cost maps\ng(false) = ∞ and g(true) = 0.\n\nDoes g preserve the unit?\n(g(true) = 0 = unit of Cost?)',
    elementLabels: const ['no', 'yes'],
    positions: const [Offset(0.35, 0.5), Offset(0.65, 0.5)],
    edges: {},
    mapArrows: const [],
    answer: 1, // yes! g(unit_Bool) = g(true) = 0 = unit_Cost
    highlighted: {},
    hint: 'Unit of Bool = true. Unit of Cost = 0.\ng(true) = 0. So g sends unit to unit!',
    notationReveal: 'g(I_Bool) = g(true) = 0 = I_Cost ✓\n\nA monoidal monotone must:\n(a) preserve the unit\n(b) preserve the product\n\ng maps "possible" (true) to\n"free" (cost 0) and\n"impossible" (false) to "∞".\n\n(Ex 2.43)',
  ),

  // Quantale: Bool has all joins (Ex 2.93)
  TapAnswerConfig(
    id: 'c2b12-quantale',
    title: 'QUANTALE',
    question: 'A quantale is a monoidal preorder\nwith all joins (∨ for any subset).\n\nBool = (𝔹, ≤, true, ∧).\nWhat is ∨∅ (join of empty set)?',
    elementLabels: const ['false', 'true'],
    positions: const [Offset(0.35, 0.5), Offset(0.65, 0.5)],
    edges: {},
    mapArrows: const [],
    answer: 0, // false — the bottom element
    highlighted: {},
    hint: '∨∅ = the bottom element (smallest). In Bool, that\'s false.',
    notationReveal: '∨∅ = false = ⊥\n\nThe join of nothing is the\nsmallest element.\n\nBool is a quantale! (Ex 2.93)\nSo is Cost (∨A = inf A).\n\nQuantales let us do "matrix\nmultiplication" (Section 2.5).',
  ),
];

/// Level types for Chapter 2.
enum Ch2LevelType { monoidalTable, tapAnswer }

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
  // Bridge levels teaching Ch2 notation
  for (var i = 0; i < ch2BridgeLevels.length; i++)
    Ch2Level(
      title: ch2BridgeLevels[i].title,
      type: Ch2LevelType.tapAnswer,
      index: i,
    ),
];
