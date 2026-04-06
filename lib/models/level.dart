import 'category.dart';

enum GoalType {
  /// Player must create a specific morphism (by composing or direct).
  createMorphism,
  /// Player must create all possible compositions.
  completeCompositions,
  /// Player must find the identity morphism for each object.
  findIdentities,
  /// Freeform — explore until a condition is met.
  freeplay,
}

class LevelGoal {
  final GoalType type;
  final String description;
  final bool Function(Category category, List<Morphism> playerMorphisms) check;

  const LevelGoal({
    required this.type,
    required this.description,
    required this.check,
  });
}

class Level {
  final String id;
  final String title;
  final String? subtitle;
  final List<CatObject> initialObjects;
  final List<Morphism> initialMorphisms;
  final List<LevelGoal> goals;
  /// Which morphisms the player is allowed to create (null = any).
  final bool Function(String sourceId, String targetId)? allowedMorphisms;
  /// Notation to reveal after completing the level.
  final String? notationReveal;
  /// Hint shown after a delay if the player is stuck.
  final String? hint;

  const Level({
    required this.id,
    required this.title,
    this.subtitle,
    required this.initialObjects,
    this.initialMorphisms = const [],
    required this.goals,
    this.allowedMorphisms,
    this.notationReveal,
    this.hint,
  });
}
