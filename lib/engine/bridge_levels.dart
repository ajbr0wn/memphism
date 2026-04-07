import 'package:flutter/material.dart';
import '../screens/tap_answer_screen.dart';

/// Bridge levels that teach map application, composition, and the
/// Galois connection condition step by step. These go BETWEEN the
/// monotone map levels and the Galois connection levels.
///
/// The goal: by the time you reach ADJOINT, f(p)≤q iff p≤g(q)
/// should feel obvious because you've already experienced each
/// piece through play.

final bridgeLevels = [
  // Level 1: Where does f send an element? (simplest possible)
  TapAnswerConfig(
    id: 'br1-apply',
    title: 'SEND',
    question: 'f sends 1 to a and 2 to b.\nWhere does f send 1?',
    elementLabels: const ['a', 'b'],
    positions: const [Offset(0.5, 0.7), Offset(0.5, 0.3)],
    edges: {(0, 1)},
    mapArrows: const [],
    answer: 0, // f(1) = a
    highlighted: {},
    hint: 'f(1) = a. Just tap where 1 lands.',
    notationReveal: 'f(1) = a\n\nf : P → Q maps each element\nof P to an element of Q.\n\n"Where does f send p?"\nmeans "what is f(p)?"',
  ),

  // Level 2: Apply a map shown with arrows
  TapAnswerConfig(
    id: 'br2-follow',
    title: 'FOLLOW',
    question: 'Follow the arrow from F.\nWhere does f send F?',
    elementLabels: const ['F', 'T', 'F', 'T'],
    positions: const [
      Offset(0.2, 0.7), Offset(0.2, 0.3), // P side: F, T
      Offset(0.8, 0.7), Offset(0.8, 0.3), // Q side: F, T
    ],
    edges: {(0, 1), (2, 3)}, // P: F≤T, Q: F≤T
    mapArrows: const [(0, 2), (1, 3)], // f: F↦F, T↦T (identity)
    answer: 2, // f(F) = F (index 2 in the combined list)
    highlighted: {0}, // highlight the input F
    hint: 'Follow the dashed arrow from F on the left.\nIt goes to F on the right.',
    notationReveal: 'f(F) = F\n\nThe dashed arrows show\nwhere f sends each element.\nFollow the arrow from the\nhighlighted element!',
  ),

  // Level 3: Apply a non-identity map
  TapAnswerConfig(
    id: 'br3-nonid',
    title: 'SHIFT',
    question: 'f sends 1↦2 and 2↦3.\nWhere does f send 1?',
    elementLabels: const ['1', '2', '3'],
    positions: const [Offset(0.5, 0.8), Offset(0.5, 0.5), Offset(0.5, 0.2)],
    edges: {(0, 1), (1, 2)},
    mapArrows: const [],
    answer: 1, // f(1) = 2
    highlighted: {0}, // highlight 1
    hint: 'f(1) = 2. Tap the element that 1 maps to.',
    notationReveal: 'f(1) = 2\n\nf "shifts up" by one.\nThis is monotone because\n1 ≤ 2 implies f(1)=2 ≤ f(2)=3 ✓',
  ),

  // Level 4: Is f(p) ≤ q? (comparison in codomain)
  // Show f(1)=2 in {1,2,3}. Is f(1) ≤ 3? → yes (tap T)
  TapAnswerConfig(
    id: 'br4-compare',
    title: 'COMPARE',
    question: 'f(1) = 2.\nIs f(1) ≤ 3?',
    elementLabels: const ['no', 'yes'],
    positions: const [Offset(0.35, 0.5), Offset(0.65, 0.5)],
    edges: {},
    mapArrows: const [],
    answer: 1, // yes, 2 ≤ 3
    highlighted: {},
    hint: 'f(1) = 2. Is 2 ≤ 3? Yes!',
    notationReveal: 'f(1) = 2, and 2 ≤ 3.\nSo f(1) ≤ 3 is TRUE.\n\n"Is f(p) ≤ q?" just means:\napply f to p, then check\nif the result is ≤ q.',
  ),

  // Level 5: Is f(p) ≤ q? (false case)
  TapAnswerConfig(
    id: 'br5-compare2',
    title: 'COMPARE²',
    question: 'f(2) = 3.\nIs f(2) ≤ 2?',
    elementLabels: const ['no', 'yes'],
    positions: const [Offset(0.35, 0.5), Offset(0.65, 0.5)],
    edges: {},
    mapArrows: const [],
    answer: 0, // no, 3 ≰ 2
    highlighted: {},
    hint: 'f(2) = 3. Is 3 ≤ 2? No! 3 is bigger.',
    notationReveal: 'f(2) = 3, and 3 ≰ 2.\nSo f(2) ≤ 2 is FALSE.\n\nThe answer depends on where\nf sends p, not on p itself.',
  ),

  // Level 6: Composition g∘f
  TapAnswerConfig(
    id: 'br6-compose',
    title: 'COMPOSE',
    question: 'f(1) = a, g(a) = x.\nWhat is g(f(1))?',
    elementLabels: const ['x', 'y'],
    positions: const [Offset(0.35, 0.5), Offset(0.65, 0.5)],
    edges: {},
    mapArrows: const [],
    answer: 0, // g(f(1)) = g(a) = x
    highlighted: {},
    hint: 'First apply f: f(1) = a.\nThen apply g: g(a) = x.\nSo g(f(1)) = x.',
    notationReveal: 'g(f(1)) = g(a) = x\n\ng∘f means "first f, then g."\nApply f to get an intermediate,\nthen apply g to that.\n\nComposition!',
  ),

  // Level 7: The iff condition (specific case)
  TapAnswerConfig(
    id: 'br7-iff',
    title: 'IFF',
    question: 'f(1)=1, g(1)=1, g(2)=2.\nf(1) ≤ 2 is true.\nIs 1 ≤ g(2) also true?',
    elementLabels: const ['no', 'yes'],
    positions: const [Offset(0.35, 0.5), Offset(0.65, 0.5)],
    edges: {},
    mapArrows: const [],
    answer: 1, // yes, 1 ≤ g(2) = 2
    highlighted: {},
    hint: 'g(2) = 2. Is 1 ≤ 2? Yes!\nSo f(1) ≤ 2 AND 1 ≤ g(2) — both true.',
    notationReveal: 'f(1) ≤ 2 ✓  AND  1 ≤ g(2) ✓\n\nBoth sides of the "iff" are true!\n\nGalois connection:\nf(p) ≤ q  ⟺  p ≤ g(q)\n\nWhen this holds for ALL p,q\nwe say f is left adjoint to g.',
  ),

  // Level 8: The iff condition (both false)
  TapAnswerConfig(
    id: 'br8-iff2',
    title: 'IFF²',
    question: 'f(2)=2, g(1)=1.\nf(2) ≤ 1 is false.\nIs 2 ≤ g(1) also false?',
    elementLabels: const ['no (different)', 'yes (same!)'],
    positions: const [Offset(0.3, 0.5), Offset(0.7, 0.5)],
    edges: {},
    mapArrows: const [],
    answer: 1, // yes, both false — the iff holds!
    highlighted: {},
    hint: 'g(1) = 1. Is 2 ≤ 1? No!\nSo f(2) ≤ 1 is false AND 2 ≤ g(1) is false.\nBoth sides agree!',
    notationReveal: 'f(2) ≤ 1 ✗  AND  2 ≤ g(1) ✗\n\nBoth false — they still agree!\n\nThe "iff" means: the two\nquestions ALWAYS have the\nsame answer (both true or\nboth false).\n\nThat\'s a Galois connection.',
  ),
];
