import '../models/category.dart';
import '../models/level.dart';

/// Chapter 1: Composition
/// The player discovers what morphisms are and how they compose,
/// entirely through play. No text explanations.
final chapter1Levels = [
  // Level 1: Two nodes, one arrow. Drag to connect.
  // Goal: just make the connection. Feel the snap.
  Level(
    id: 'c1-01',
    title: 'Connect',
    initialObjects: [
      CatObject(id: 'a', label: 'A', colorIndex: 0, x: 0.25, y: 0.5),
      CatObject(id: 'b', label: 'B', colorIndex: 1, x: 0.75, y: 0.5),
    ],
    goals: [
      LevelGoal(
        type: GoalType.createMorphism,
        description: '',
        check: (cat, player) => player.any(
          (m) => m.sourceId == 'a' && m.targetId == 'b',
        ),
      ),
    ],
    hint: 'Drag from one dot to the other.',
  ),

  // Level 2: Three nodes in a line. Two existing arrows.
  // The player must discover composition: A→B and B→C gives A→C.
  Level(
    id: 'c1-02',
    title: 'Through',
    initialObjects: [
      CatObject(id: 'a', label: 'A', colorIndex: 0, x: 0.15, y: 0.5),
      CatObject(id: 'b', label: 'B', colorIndex: 1, x: 0.5, y: 0.5),
      CatObject(id: 'c', label: 'C', colorIndex: 2, x: 0.85, y: 0.5),
    ],
    initialMorphisms: [
      Morphism(id: 'f', sourceId: 'a', targetId: 'b', label: 'f'),
      Morphism(id: 'g', sourceId: 'b', targetId: 'c', label: 'g'),
    ],
    goals: [
      LevelGoal(
        type: GoalType.createMorphism,
        description: '',
        check: (cat, player) => player.any(
          (m) => m.sourceId == 'a' && m.targetId == 'c',
        ),
      ),
    ],
    notationReveal: 'g ∘ f',
    hint: 'Can you go from A to C?',
  ),

  // Level 3: Triangle — three objects, two arrows given, complete the third.
  // Same concept, different spatial arrangement.
  Level(
    id: 'c1-03',
    title: 'Triangle',
    initialObjects: [
      CatObject(id: 'a', label: 'A', colorIndex: 0, x: 0.5, y: 0.2),
      CatObject(id: 'b', label: 'B', colorIndex: 1, x: 0.2, y: 0.75),
      CatObject(id: 'c', label: 'C', colorIndex: 2, x: 0.8, y: 0.75),
    ],
    initialMorphisms: [
      Morphism(id: 'f', sourceId: 'a', targetId: 'b', label: 'f'),
      Morphism(id: 'g', sourceId: 'b', targetId: 'c', label: 'g'),
    ],
    goals: [
      LevelGoal(
        type: GoalType.createMorphism,
        description: '',
        check: (cat, player) => player.any(
          (m) => m.sourceId == 'a' && m.targetId == 'c',
        ),
      ),
    ],
    notationReveal: 'g ∘ f : A → C',
  ),

  // Level 4: Four objects, chain of three arrows. Two compositions possible.
  // The player must find BOTH compositions.
  Level(
    id: 'c1-04',
    title: 'Chain',
    initialObjects: [
      CatObject(id: 'a', label: 'A', colorIndex: 0, x: 0.1, y: 0.3),
      CatObject(id: 'b', label: 'B', colorIndex: 1, x: 0.37, y: 0.6),
      CatObject(id: 'c', label: 'C', colorIndex: 2, x: 0.63, y: 0.3),
      CatObject(id: 'd', label: 'D', colorIndex: 3, x: 0.9, y: 0.6),
    ],
    initialMorphisms: [
      Morphism(id: 'f', sourceId: 'a', targetId: 'b'),
      Morphism(id: 'g', sourceId: 'b', targetId: 'c'),
      Morphism(id: 'h', sourceId: 'c', targetId: 'd'),
    ],
    goals: [
      LevelGoal(
        type: GoalType.completeCompositions,
        description: '',
        check: (cat, player) {
          final hasAC = player.any(
            (m) => m.sourceId == 'a' && m.targetId == 'c',
          );
          final hasBD = player.any(
            (m) => m.sourceId == 'b' && m.targetId == 'd',
          );
          final hasAD = player.any(
            (m) => m.sourceId == 'a' && m.targetId == 'd',
          );
          return hasAC && hasBD && hasAD;
        },
      ),
    ],
    notationReveal: 'h ∘ g ∘ f : A → D\nassociativity: (h ∘ g) ∘ f = h ∘ (g ∘ f)',
    hint: 'Find all the shortcuts.',
  ),

  // Level 5: Identity — a single node. The player must connect it to itself.
  // The loop arrow. Self-morphism. Identity.
  Level(
    id: 'c1-05',
    title: 'Self',
    initialObjects: [
      CatObject(id: 'a', label: 'A', colorIndex: 4, x: 0.5, y: 0.45),
    ],
    goals: [
      LevelGoal(
        type: GoalType.findIdentities,
        description: '',
        check: (cat, player) => player.any(
          (m) => m.sourceId == 'a' && m.targetId == 'a',
        ),
      ),
    ],
    notationReveal: 'idₐ : A → A',
    hint: 'Every object has a relationship with itself.',
  ),
];
