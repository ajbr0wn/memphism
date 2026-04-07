# Memphism

A game that teaches category theory through play. Neon Memphis Milano aesthetics, escalating puzzles, haptic feedback, flow state.

Based on [Seven Sketches in Compositionality](https://arxiv.org/abs/1803.05316) by Brendan Fong & David Spivak.

## 109 levels across 3 chapters

### Chapter 1: Orders & Adjunctions (59 levels)

| Mechanic | What you do | Concept |
|----------|-------------|---------|
| **Partition** | Tap dots to color-group them | Equivalence classes, Bell numbers |
| **Ordering** | Drag to sort partitions by fineness | Refinement order, Hasse diagrams |
| **Join** | Build the smallest partition above both A and B | Joins, generative effects |
| **Function** | Drag arrows from domain to codomain | Injective, surjective, bijective |
| **Preorder** | Draw Hasse diagram edges | Divisibility, power sets, the cube |
| **Meet/Join Pick** | Tap the correct answer in a Hasse diagram | GCD/LCM, intersection/union, AND/OR |
| **Monotone Map** | Drag arrows between two Hasse diagrams | Order-preserving maps, cardinality |
| **Bridge** | Tap-the-answer notation practice | f(p), f(p)≤q, g∘f, the Galois iff |
| **Galois Connection** | Given one adjoint, find the other | Adjunctions, closure operators |

### Chapter 2: Monoidal Preorders (25 levels)

| Mechanic | What you do | Concept |
|----------|-------------|---------|
| **Monoidal Table** | Fill in a multiplication/operation table | Bool, Cost, power sets, ℕ, enrichment |
| **Tap Answer** | Answer notation questions | ⊗, units, monotonicity, symmetry, wiring diagrams, quantales |

### Chapter 3: Categories (25 levels)

| Mechanic | What you do | Concept |
|----------|-------------|---------|
| **Tap Answer** | Answer questions about categories | Morphisms, functors, natural transformations, adjunctions |
| **Composition Table** | Fill in morphism composition | Free categories, path composition |

## Design

- **Discovery through play**: you experience the concept before seeing the notation
- **Notation reveal**: after solving, the mathematical notation appears — naming something you already understand
- **Bridge levels**: teach notation through simple tap-the-answer interactions before advanced mechanics
- **Spiral learning**: concepts return in new contexts (meets = products, monotone maps = functors, Galois = adjunctions)
- **Blind playtested**: automated agents verify the learning flow works

## Build

```
flutter build apk --release
flutter build web --release    # playtest via Playwright
```

## License

MIT
