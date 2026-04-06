// Core category theory models — objects, morphisms, composition.
// These are the "game pieces" the player manipulates.

class CatObject {
  final String id;
  final String label;
  final int colorIndex;
  double x;
  double y;

  CatObject({
    required this.id,
    required this.label,
    required this.colorIndex,
    required this.x,
    required this.y,
  });
}

class Morphism {
  final String id;
  final String sourceId;
  final String targetId;
  final String? label;
  final bool isIdentity;
  final bool isPlayerCreated;

  const Morphism({
    required this.id,
    required this.sourceId,
    required this.targetId,
    this.label,
    this.isIdentity = false,
    this.isPlayerCreated = false,
  });

  /// Can this morphism compose with [other]?
  /// f: A → B composes with g: B → C to give g∘f: A → C.
  bool canComposeWith(Morphism other) => targetId == other.sourceId;
}

class Composition {
  final Morphism first;  // f: A → B
  final Morphism second; // g: B → C
  final Morphism result; // g∘f: A → C

  const Composition({
    required this.first,
    required this.second,
    required this.result,
  });
}

/// A small category with objects and morphisms.
class Category {
  final List<CatObject> objects;
  final List<Morphism> morphisms;

  const Category({
    required this.objects,
    required this.morphisms,
  });

  CatObject objectById(String id) =>
      objects.firstWhere((o) => o.id == id);

  List<Morphism> morphismsFrom(String objectId) =>
      morphisms.where((m) => m.sourceId == objectId).toList();

  List<Morphism> morphismsTo(String objectId) =>
      morphisms.where((m) => m.targetId == objectId).toList();

  /// Check if a morphism from source to target already exists.
  bool hasMorphism(String sourceId, String targetId) =>
      morphisms.any((m) => m.sourceId == sourceId && m.targetId == targetId);
}
