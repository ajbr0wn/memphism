// A partition of a set — elements grouped into non-overlapping parts.

class SetElement {
  final String id;
  final String label;
  final double x;
  final double y;
  int groupIndex; // which group this element belongs to (0-based)

  SetElement({
    required this.id,
    required this.label,
    required this.x,
    required this.y,
    this.groupIndex = 0,
  });

  SetElement copyWith({int? groupIndex}) => SetElement(
        id: id,
        label: label,
        x: x,
        y: y,
        groupIndex: groupIndex ?? this.groupIndex,
      );
}

class Partition {
  final List<Set<String>> parts; // each set is a group of element IDs

  const Partition(this.parts);

  /// Create from a list of elements using their groupIndex.
  factory Partition.fromElements(List<SetElement> elements) {
    final groups = <int, Set<String>>{};
    for (final e in elements) {
      groups.putIfAbsent(e.groupIndex, () => {}).add(e.id);
    }
    return Partition(groups.values.toList());
  }

  /// Normalized form for comparison: sorted parts, sorted within each part.
  List<List<String>> get normalized {
    final sorted = parts
        .map((p) => p.toList()..sort())
        .toList()
      ..sort((a, b) => a.first.compareTo(b.first));
    return sorted;
  }

  @override
  bool operator ==(Object other) =>
      other is Partition &&
      normalized.length == other.normalized.length &&
      (() {
        final a = normalized;
        final b = other.normalized;
        for (var i = 0; i < a.length; i++) {
          if (a[i].length != b[i].length) return false;
          for (var j = 0; j < a[i].length; j++) {
            if (a[i][j] != b[i][j]) return false;
          }
        }
        return true;
      })();

  @override
  int get hashCode => normalized.toString().hashCode;

  /// Is this partition finer than (or equal to) [other]?
  /// A ≤ B means every part of A is a subset of some part of B.
  bool isFinerOrEqual(Partition other) {
    for (final myPart in parts) {
      final contained = other.parts.any(
        (otherPart) => myPart.every((e) => otherPart.contains(e)),
      );
      if (!contained) return false;
    }
    return true;
  }

  /// Number of groups.
  int get numParts => parts.length;

  @override
  String toString() {
    final n = normalized;
    return '{${n.map((p) => '{${p.join(',')}}'  ).join(', ')}}';
  }
}

/// Generate all partitions of a set of element IDs.
/// Uses Bell number enumeration via recursive placement.
List<Partition> allPartitions(List<String> elementIds) {
  final results = <Partition>[];
  _generatePartitions(elementIds, 0, [], results);
  return results;
}

void _generatePartitions(
  List<String> elements,
  int index,
  List<Set<String>> current,
  List<Partition> results,
) {
  if (index == elements.length) {
    results.add(Partition(current.map((s) => Set.of(s)).toList()));
    return;
  }

  final element = elements[index];

  // Add to each existing group
  for (var i = 0; i < current.length; i++) {
    current[i].add(element);
    _generatePartitions(elements, index + 1, current, results);
    current[i].remove(element);
  }

  // Start a new group
  current.add({element});
  _generatePartitions(elements, index + 1, current, results);
  current.removeLast();
}
