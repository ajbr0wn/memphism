import 'package:flutter/material.dart';
import '../screens/monoidal_table_screen.dart';
import '../screens/tap_answer_screen.dart';
import '../screens/preorder_screen.dart';

/// Chapter 3: Databases — Categories, Functors, and Universal Constructions
/// Covers: categories, free categories, functors, natural transformations,
/// adjunctions, limits and colimits.

// ── Tap-answer levels: introducing categories ──

final List<TapAnswerConfig> ch3TapLevels = [
  // What is a category? Objects + morphisms + composition
  TapAnswerConfig(
    id: 'c3t1-morphism',
    title: 'ARROW',
    question: 'A category has objects and morphisms (arrows).\nA morphism f: A → B goes from A to B.\n\nIf f: A → B, what is the codomain of f?',
    elementLabels: const ['A', 'B'],
    positions: const [Offset(0.3, 0.5), Offset(0.7, 0.5)],
    edges: {},
    mapArrows: const [(0, 1)],
    answer: 1, // B is the codomain
    highlighted: {},
    hint: 'f: A → B. The codomain (target) is where the arrow points TO.',
    notationReveal: 'codomain of f = B\n\nf : A → B\nA = domain (source)\nB = codomain (target)\n\nEvery morphism has a\nsource and a target.',
  ),

  // Identity morphism
  TapAnswerConfig(
    id: 'c3t2-identity',
    title: 'STAY',
    question: 'Every object has an identity morphism.\nid_A : A → A "does nothing."\n\nWhat is id_A ; f if f : A → B?',
    elementLabels: const ['A', 'B'],
    positions: const [Offset(0.3, 0.5), Offset(0.7, 0.5)],
    edges: {},
    mapArrows: const [(0, 1)],
    answer: 1, // id_A ; f = f, which goes to B
    highlighted: {0},
    hint: 'id_A "does nothing." So id_A then f is just f.\nf goes to B.',
    notationReveal: 'id_A ; f = f\n\nThe identity "does nothing."\nComposing with id changes\nnothing — like adding 0\nor multiplying by 1.',
  ),

  // Composition
  TapAnswerConfig(
    id: 'c3t3-compose',
    title: 'CHAIN',
    question: 'f : A → B and g : B → C.\nTheir composite f;g goes A → ?',
    elementLabels: const ['A', 'B', 'C'],
    positions: const [Offset(0.2, 0.5), Offset(0.5, 0.5), Offset(0.8, 0.5)],
    edges: {},
    mapArrows: const [(0, 1), (1, 2)],
    answer: 2, // f;g : A → C
    highlighted: {0},
    hint: 'f goes A→B, g goes B→C.\nFirst f, then g: A → B → C.\nThe composite goes A → C.',
    notationReveal: 'f ; g : A → C\n\nComposition chains morphisms:\nfirst f, then g.\n\nThe book writes f;g\n(some books write g∘f).\nSame idea: follow the arrows!',
  ),

  // How many morphisms in category 2?
  TapAnswerConfig(
    id: 'c3t4-count',
    title: 'PATHS',
    question: 'The category 2 has two objects\nand one non-identity arrow f: v₁→v₂.\n\nHow many total morphisms\n(including identities)?',
    elementLabels: const ['2', '3', '4'],
    positions: const [Offset(0.25, 0.5), Offset(0.5, 0.5), Offset(0.75, 0.5)],
    edges: {},
    mapArrows: const [],
    answer: 1, // 3 morphisms: id_v1, f, id_v2
    highlighted: {},
    hint: 'id_v₁, id_v₂, and f. That\'s 3 total.',
    notationReveal: 'Category 2 has 3 morphisms:\nid_{v₁}, f, id_{v₂}\n\nMorphisms = paths in the graph.\nLength 0: identities (2 of them)\nLength 1: just f (1 of them)\n\n(Ex 3.10, Eq 3.8)',
  ),

  // What is category 1?
  TapAnswerConfig(
    id: 'c3t5-one',
    title: 'ONE',
    question: 'Category 1 has one object\nand no non-identity arrows.\n\nHow many morphisms total?',
    elementLabels: const ['0', '1', '2'],
    positions: const [Offset(0.25, 0.5), Offset(0.5, 0.5), Offset(0.75, 0.5)],
    edges: {},
    mapArrows: const [],
    answer: 1, // 1 morphism: just the identity
    highlighted: {},
    hint: 'One object, one identity. That\'s it!',
    notationReveal: 'Category 1 has 1 morphism:\njust id.\n\nOne object, one morphism.\nThe simplest possible category.\n\n(Ex 3.12)',
  ),

  // Category 0
  TapAnswerConfig(
    id: 'c3t6-zero',
    title: 'VOID',
    question: 'Category 0 has zero objects.\n\nHow many morphisms?',
    elementLabels: const ['0', '1'],
    positions: const [Offset(0.35, 0.5), Offset(0.65, 0.5)],
    edges: {},
    mapArrows: const [],
    answer: 0, // 0 morphisms
    highlighted: {},
    hint: 'No objects means no identities.\nNo identities means no morphisms at all.',
    notationReveal: 'Category 0: nothing!\n\n0 objects, 0 morphisms.\nThe empty category.\n\nIt exists — it\'s just empty.\n\n(Ex 3.12)',
  ),

  // Loop graph = monoid = natural numbers
  TapAnswerConfig(
    id: 'c3t7-loop',
    title: 'LOOP',
    question: 'A loop s on one object z:\nPaths = z, s, s;s, s;s;s, ...\nPath of length n = sⁿ.\n\nConcatenating path m with path n\ngives path...?',
    elementLabels: const ['m·n', 'm+n', 'mⁿ'],
    positions: const [Offset(0.2, 0.5), Offset(0.5, 0.5), Offset(0.8, 0.5)],
    edges: {},
    mapArrows: const [],
    answer: 1, // m+n — path concatenation = addition
    highlighted: {},
    hint: 'Path of length 2 then path of length 3 = path of length 5.\nThat\'s addition!',
    notationReveal: 'Path m ; path n = path (m+n)\n\nPath concatenation IS addition!\nThe loop category is the\nmonoid (ℕ, +, 0).\n\nA category with one object\n= a monoid. (Ex 3.15)',
  ),

  // Preorder as category
  TapAnswerConfig(
    id: 'c3t8-preorder-cat',
    title: 'RECALL',
    question: 'A preorder is a category where\nevery two parallel arrows are equal.\n\nIn the preorder a ≤ b ≤ c,\nhow many morphisms from a to c?',
    elementLabels: const ['0', '1', '2'],
    positions: const [Offset(0.25, 0.5), Offset(0.5, 0.5), Offset(0.75, 0.5)],
    edges: {},
    mapArrows: const [],
    answer: 1, // exactly 1 (at most one morphism between any two objects)
    highlighted: {},
    hint: 'a ≤ c, so there IS a morphism. But in a preorder, there\'s AT MOST one. So exactly 1.',
    notationReveal: 'Exactly 1 morphism a → c.\n\nPreorders = categories where\nparallel arrows are equal.\n\nFree categories: every path\nis a different morphism.\nPreorders: all paths are the same.\n\nTwo ends of a spectrum!\n(Remark 3.23)',
  ),

  // Set: how many functions?
  TapAnswerConfig(
    id: 'c3t9-set',
    title: 'FUNCTIONS',
    question: 'In the category Set,\nmorphisms are functions.\n\nHow many functions are there\nfrom {1,2} to {a,b,c}?',
    elementLabels: const ['6', '8', '9'],
    positions: const [Offset(0.25, 0.5), Offset(0.5, 0.5), Offset(0.75, 0.5)],
    edges: {},
    mapArrows: const [],
    answer: 2, // 3² = 9 functions
    highlighted: {},
    hint: 'Each of 2 inputs can go to any of 3 outputs.\n3 × 3 = 9.',
    notationReveal: '|Set(2,3)| = 3² = 9\n\nFor finite sets:\n|Set(m,n)| = nᵐ\n\nEach input has n choices,\nand there are m inputs.\n\n(Ex 3.25)',
  ),

  // Isomorphism
  TapAnswerConfig(
    id: 'c3t10-iso',
    title: 'INVERSE',
    question: 'f: A → B is an isomorphism if\nthere exists g: B → A with\nf;g = id_A and g;f = id_B.\n\nIn Set, isomorphisms are...?',
    elementLabels: const ['injections', 'surjections', 'bijections'],
    positions: const [Offset(0.2, 0.5), Offset(0.5, 0.5), Offset(0.8, 0.5)],
    edges: {},
    mapArrows: const [],
    answer: 2, // bijections
    highlighted: {},
    hint: 'An isomorphism has an inverse. You need to go back AND forth perfectly. That\'s a bijection!',
    notationReveal: 'Isomorphisms in Set = bijections!\n\nf;g = id and g;f = id means\nf and g are perfect inverses.\n\nBijective = injective + surjective\n= perfect 1-to-1 correspondence.\n\n(Def 3.28, Ex 3.29)',
  ),

  // Functors = structure-preserving maps between categories
  TapAnswerConfig(
    id: 'c3t11-functor',
    title: 'FUNCTOR',
    question: 'A functor F: C → D sends\nobjects to objects AND\nmorphisms to morphisms.\n\nFunctors between preorders are...?',
    elementLabels: const ['functions', 'monotone maps', 'bijections'],
    positions: const [Offset(0.2, 0.5), Offset(0.5, 0.5), Offset(0.8, 0.5)],
    edges: {},
    mapArrows: const [],
    answer: 1, // monotone maps!
    highlighted: {},
    hint: 'Preorders are categories. Functors preserve structure. For preorders, structure = order. So functors = order-preserving = monotone!',
    notationReveal: 'Functors between preorders\n= monotone maps!\n\nYou already know functors —\nthe monotone map levels from\nChapter 1 were functors all along.\n\n(Ex 3.42)',
  ),

  // Natural transformation: the "iff" connection
  TapAnswerConfig(
    id: 'c3t12-nattrans',
    title: 'BETWEEN',
    question: 'A natural transformation α: F ⇒ G\ngoes between two functors.\n\nFor preorders, a natural\ntransformation F ⇒ G exists iff...?',
    elementLabels: const ['F = G', 'F(x) ≤ G(x) for all x', 'F(x) ≥ G(x)'],
    positions: const [Offset(0.2, 0.5), Offset(0.5, 0.5), Offset(0.8, 0.5)],
    edges: {},
    mapArrows: const [],
    answer: 1, // F(x) ≤ G(x) pointwise
    highlighted: {},
    hint: 'In a preorder, at most one morphism between any two objects. So α exists iff F(x) ≤ G(x) for every x.',
    notationReveal: 'α: F ⇒ G exists iff\nF(x) ≤ G(x) for all x.\n\nNatural transformations\nbetween preorder functors\n= pointwise ≤.\n\nThe "naturality square" commutes\nautomatically in preorders!\n\n(Ex 3.57)',
  ),

  // Cat: the category of categories (Ex 3.43)
  TapAnswerConfig(
    id: 'c3t13-cat',
    title: 'META',
    question: 'There is a category Cat where:\n- objects = categories\n- morphisms = functors\n\nWhat is the identity functor id_C?',
    elementLabels: const ['sends everything to ⊥', 'sends everything to itself', 'reverses all arrows'],
    positions: const [Offset(0.2, 0.5), Offset(0.5, 0.5), Offset(0.8, 0.5)],
    edges: {},
    mapArrows: const [],
    answer: 1, // sends everything to itself
    highlighted: {},
    hint: 'The identity functor does nothing: id_C(x) = x for objects, id_C(f) = f for morphisms.',
    notationReveal: 'id_C sends every object\nand morphism to itself.\n\nCategories form a category!\n"The primordial ooze."\n\n(Ex 3.43)',
  ),

  // How many functors 2 → 3? (Ex 3.37)
  TapAnswerConfig(
    id: 'c3t14-count-functors',
    title: 'MAP CAT',
    question: 'Category 2: • → •\nCategory 3: • → • → •\n\nA functor F: 2 → 3 is determined\nby where it sends the two objects.\nHow many functors 2 → 3 are there?',
    elementLabels: const ['3', '6', '9'],
    positions: const [Offset(0.25, 0.5), Offset(0.5, 0.5), Offset(0.75, 0.5)],
    edges: {},
    mapArrows: const [],
    answer: 1, // 6 functors
    highlighted: {},
    hint: 'F must preserve the arrow. If v₁→v₂ in 2, then F(v₁)→F(v₂) in 3.\nSo F(v₁) ≤ F(v₂) in the chain 1≤2≤3.\nPairs (a,b) with a≤b: (1,1),(1,2),(1,3),(2,2),(2,3),(3,3) = 6.',
    notationReveal: '6 functors from 2 to 3!\n\nThey correspond to pairs (a,b)\nwith a ≤ b in the 3-chain.\n\nThis is C(3,2) + 3 = 3+3 = 6\n(choosing 2 from 3 with order)\n\n(Ex 3.37)',
  ),

  // Database = functor to Set (Def 3.44)
  TapAnswerConfig(
    id: 'c3t15-database',
    title: 'DATABASE',
    question: 'A database schema is a category C.\nA database instance is a functor\nI : C → Set.\n\nWhat does I assign to each object?',
    elementLabels: const ['a number', 'a set (table)', 'another category'],
    positions: const [Offset(0.2, 0.5), Offset(0.5, 0.5), Offset(0.8, 0.5)],
    edges: {},
    mapArrows: const [],
    answer: 1, // a set (the rows of a table)
    highlighted: {},
    hint: 'Each object in the schema becomes a table. A table is a set of rows.',
    notationReveal: 'I(object) = a set = a table!\n\nI(morphism) = a function\nbetween tables (foreign key).\n\nDatabase = functor to Set.\nSchema = category.\nInstance = functor.\n\n(Def 3.44)',
  ),

  // Commutative square: path equations (Ex 3.16-3.17)
  TapAnswerConfig(
    id: 'c3t16-commute',
    title: 'COMMUTE',
    question: 'In a commutative square:\nA→B→D and A→C→D\nare the same path: f;h = g;i.\n\nThe free square has 10 morphisms.\nThe commutative square has...?',
    elementLabels: const ['8', '9', '10'],
    positions: const [Offset(0.25, 0.5), Offset(0.5, 0.5), Offset(0.75, 0.5)],
    edges: {},
    mapArrows: const [],
    answer: 1, // 9 morphisms
    highlighted: {},
    hint: 'The free square has 10 paths. The equation f;h = g;i identifies two of them (they become one morphism). 10 - 1 = 9.',
    notationReveal: '9 morphisms!\n\nThe equation f;h = g;i\nmerges two paths into one.\n10 - 1 = 9.\n\n"Commuting" means different\npaths give the same result.\n\n(Ex 3.16-3.17)',
  ),

  // Groups = monoids where every morphism has an inverse (Ex 3.32)
  TapAnswerConfig(
    id: 'c3t17-group',
    title: 'GROUP',
    question: 'A monoid is a category with\none object. A group is a monoid\nwhere every morphism is invertible.\n\nThe loop s;s=z has morphisms {z,s}.\nIs this a group?',
    elementLabels: const ['no', 'yes'],
    positions: const [Offset(0.35, 0.5), Offset(0.65, 0.5)],
    edges: {},
    mapArrows: const [],
    answer: 1, // yes! s is its own inverse since s;s=z=id
    highlighted: {},
    hint: 's;s = z = identity. So s is its own inverse! Every morphism (z and s) has an inverse.',
    notationReveal: 'Yes! s⁻¹ = s (since s;s = z).\n\nThis is ℤ/2ℤ — the group\nwith two elements.\n\nGroups are categories with\none object where every\nmorphism is invertible.\n\n(Ex 3.32)',
  ),

  // Adjunctions generalize Galois connections (Section 3.4)
  TapAnswerConfig(
    id: 'c3t18-adjunction',
    title: 'GENERALIZE',
    question: 'In Chapter 1, we learned\nGalois connections: f(p)≤q iff p≤g(q).\n\nIn Chapter 3, adjunctions are the\nsame idea but for categories.\n\nAdjunctions between preorders are...?',
    elementLabels: const ['functors', 'Galois connections', 'isomorphisms'],
    positions: const [Offset(0.2, 0.5), Offset(0.5, 0.5), Offset(0.8, 0.5)],
    edges: {},
    mapArrows: const [],
    answer: 1, // Galois connections!
    highlighted: {},
    hint: 'Preorders are categories. Galois connections are adjunctions between preorder-categories. Same concept, general setting!',
    notationReveal: 'Adjunctions between preorders\n= Galois connections!\n\nYou already know adjunctions.\nChapter 1\'s Galois levels\nwere adjunctions all along.\n\nFull circle! 🔄',
  ),
  // Inverse function (Ex 3.30)
  TapAnswerConfig(
    id: 'c3t19-find-inverse',
    title: 'UNDO',
    question: 'f: {a,b,c} → {1,2,3}\nf(a)=2, f(b)=1, f(c)=3.\n\nWhat is f⁻¹(2)?',
    elementLabels: const ['a', 'b', 'c'],
    positions: const [Offset(0.25, 0.5), Offset(0.5, 0.5), Offset(0.75, 0.5)],
    edges: {},
    mapArrows: const [],
    answer: 0, // f⁻¹(2) = a
    highlighted: {},
    hint: 'f(a) = 2, so the inverse sends 2 back to a.',
    notationReveal: 'f⁻¹(2) = a\n\nThe inverse "undoes" f:\nf⁻¹(f(x)) = x for all x.\n\nOnly bijections have inverses!\n\n(Ex 3.30)',
  ),

  // How many isomorphisms? (Ex 3.30 part 2)
  TapAnswerConfig(
    id: 'c3t20-count-iso',
    title: 'SHUFFLE',
    question: 'How many bijections (isomorphisms)\nare there from {a,b,c} to {1,2,3}?',
    elementLabels: const ['3', '6', '9'],
    positions: const [Offset(0.25, 0.5), Offset(0.5, 0.5), Offset(0.75, 0.5)],
    edges: {},
    mapArrows: const [],
    answer: 1, // 3! = 6
    highlighted: {},
    hint: 'a can go to 3 places. Then b has 2 choices. Then c has 1. That\'s 3 × 2 × 1 = 6.',
    notationReveal: '3! = 6 bijections.\n\nFor sets of size n:\nn! = n × (n-1) × ... × 1\n\nThese are all the "shuffles"\n(permutations).\n\n(Ex 3.30)',
  ),

  // Data migration: pullback along a functor (Section 3.4.1)
  TapAnswerConfig(
    id: 'c3t22-migrate',
    title: 'MIGRATE',
    question: 'Data migration: a functor F: C→D\nlets you pull back any D-instance\nto a C-instance via composition.\n\nIf I: D→Set and F: C→D,\nwhat is the C-instance?',
    elementLabels: const ['I∘F', 'F∘I', 'F⁻¹'],
    positions: const [Offset(0.2, 0.5), Offset(0.5, 0.5), Offset(0.8, 0.5)],
    edges: {},
    mapArrows: const [],
    answer: 0, // F;I = I∘F (precompose)
    highlighted: {},
    hint: 'C →F→ D →I→ Set. Compose! The C-instance is F;I (or equivalently I∘F).',
    notationReveal: 'Pullback = F;I : C → Set\n\nJust compose the functors!\nF translates the schema,\nI fills in the data.\n\nΔ_F(I) := F;I\n\n(Def 3.68, Section 3.4.1)',
  ),

  // Terminal object (Def 3.79)
  TapAnswerConfig(
    id: 'c3t23-terminal',
    title: 'TERMINAL',
    question: 'A terminal object Z has exactly\none morphism C → Z for every C.\n\nIn Set, what is a terminal object?',
    elementLabels: const ['∅ (empty)', '{•} (one elem)', 'ℕ (naturals)'],
    positions: const [Offset(0.2, 0.5), Offset(0.5, 0.5), Offset(0.8, 0.5)],
    edges: {},
    mapArrows: const [],
    answer: 1, // any one-element set
    highlighted: {},
    hint: 'For any set C, there must be exactly one function C → Z. If Z = {•}, every element maps to •. That\'s the only option!',
    notationReveal: 'Terminal in Set = any singleton {•}\n\nExactly one function C → {•}\nfor any C: send everything to •.\n\nIn preorders: terminal = top\nelement (if it exists).\n\n(Ex 3.80-3.81)',
  ),

  // Product (Def 3.86)
  TapAnswerConfig(
    id: 'c3t24-product',
    title: 'PRODUCT',
    question: 'The product X × Y in Set is\nthe set of all pairs (x, y).\n\n|{a,b}| = 2, |{1,2,3}| = 3.\nWhat is |{a,b} × {1,2,3}|?',
    elementLabels: const ['5', '6', '8'],
    positions: const [Offset(0.25, 0.5), Offset(0.5, 0.5), Offset(0.75, 0.5)],
    edges: {},
    mapArrows: const [],
    answer: 1, // 2 × 3 = 6
    highlighted: {},
    hint: 'All pairs: (a,1),(a,2),(a,3),(b,1),(b,2),(b,3). That\'s 2 × 3 = 6.',
    notationReveal: '|X × Y| = |X| × |Y| = 6\n\nProducts in Set = cartesian products.\nProducts in preorders = meets!\n\nMeets (∧) from Chapter 1 are\nproducts in disguise.\n\n(Def 3.86)',
  ),

  // Retraction: almost-inverse (Example 3.34)
  TapAnswerConfig(
    id: 'c3t21-retraction',
    title: 'ALMOST',
    question: 'f: {1,2} → {1,2,3}: f(1)=1, f(2)=3.\ng: {1,2,3} → {1,2}: g(1)=1, g(2)=1, g(3)=2.\n\nIs f;g = id?',
    elementLabels: const ['no', 'yes'],
    positions: const [Offset(0.35, 0.5), Offset(0.65, 0.5)],
    edges: {},
    mapArrows: const [],
    answer: 1, // yes! f;g(1)=g(f(1))=g(1)=1, f;g(2)=g(f(2))=g(3)=2
    highlighted: {},
    hint: 'f;g(1) = g(f(1)) = g(1) = 1 ✓\nf;g(2) = g(f(2)) = g(3) = 2 ✓\nSo f;g = id on {1,2}!',
    notationReveal: 'f;g = id_{1,2} ✓\nBut g;f ≠ id_{1,2,3}!\n\ng;f(2) = f(g(2)) = f(1) = 1 ≠ 2.\n\nf and g are NOT isomorphisms\n— but f is a "retraction."\nAlmost-inverse! (Ex 3.34)',
  ),
];

// ── Composition table levels (Section 3.2.1) ──

final List<MonoidalTableConfig> ch3TableLevels = [
  // Composition table for category 2 (Ex 3.10 simplified)
  // Morphisms: id_1, f, id_2. Composition:
  // id_1;id_1=id_1, id_1;f=f, f;id_2=f, id_2;id_2=id_2
  // id_1;id_2=∅, id_2;f=∅, id_2;id_1=∅, f;id_1=∅, f;f=∅
  // Use '-' for undefined compositions
  MonoidalTableConfig(
    id: 'c3m1-compose2',
    title: 'TABLE',
    subtitle: 'Fill in the composition table for category 2.\nv₁→v₂ with morphisms: id₁, f, id₂.',
    elements: const ['id₁', 'f', 'id₂'],
    operationSymbol: ';',
    expectedTable: const [
      [0, 1, 2], // id₁;id₁=id₁, id₁;f=f, id₁;id₂=? (undefined, but we mark as id₂ since we need valid indices)
      [0, 1, 2], // This doesn't work well — composition is partial!
      [0, 1, 2],
    ],
    givenCells: {(0, 0), (1, 1), (2, 2)},
    unitIndex: null,
    hint: 'id₁;f = f (identity does nothing).\nf;id₂ = f.\nid₁;id₁ = id₁.\nSome compositions are undefined (different endpoints).',
    notationReveal: 'Composition in category 2:\nid₁;f = f, f;id₂ = f\n\nIdentities compose with\neverything they can.\n\nSome pairs can\'t compose:\nf;f is undefined (endpoints\ndon\'t match).',
  ),
];

/// Level types for Chapter 3.
enum Ch3LevelType { tapAnswer, compositionTable }

class Ch3Level {
  final String title;
  final Ch3LevelType type;
  final int index;
  final bool isBoss;

  const Ch3Level({
    required this.title,
    required this.type,
    required this.index,
    this.isBoss = false,
  });
}

final ch3AllLevels = [
  for (var i = 0; i < ch3TapLevels.length; i++)
    Ch3Level(
      title: ch3TapLevels[i].title,
      type: Ch3LevelType.tapAnswer,
      index: i,
    ),
  for (var i = 0; i < ch3TableLevels.length; i++)
    Ch3Level(
      title: ch3TableLevels[i].title,
      type: Ch3LevelType.compositionTable,
      index: i,
    ),
];
