# Memphism

A game that teaches category theory through play. Neon Memphis Milano aesthetics, escalating puzzles, haptic feedback, flow state.

Based on [Seven Sketches in Compositionality](https://arxiv.org/abs/1803.05316) by Brendan Fong & David Spivak.

## Chapter 1: Orders & Adjunctions

49 levels across 8 mechanic types:

| Mechanic | What you do | Concept |
|----------|-------------|---------|
| **Partition** | Tap dots to color-group them | Equivalence classes, Bell numbers |
| **Ordering** | Drag to sort partitions by fineness | Refinement order, Hasse diagrams |
| **Join** | Build the smallest partition above both A and B | Joins, generative effects |
| **Function** | Drag arrows from domain to codomain | Injective, surjective, bijective |
| **Preorder** | Draw Hasse diagram edges | Divisibility, power sets, the cube |
| **Meet/Join Pick** | Tap the correct answer in a Hasse diagram | GCD/LCM, intersection/union, AND/OR |
| **Monotone Map** | Drag arrows between two Hasse diagrams | Order-preserving maps, cardinality |
| **Galois Connection** | Given one adjoint, find the other | Adjunctions, closure operators |

## Design

- **Discovery through play**: you experience the concept before seeing the notation
- **Notation reveal**: after solving, the mathematical notation appears — naming something you already understand
- **Spiral learning**: concepts return in new contexts (boolean joins become GCD become set union)
- **Structural identity**: shapes distinguish elements, colors show grouping, normalization prevents confusion

## Build

```
flutter build apk --release
flutter build web --release
```

## License

MIT
