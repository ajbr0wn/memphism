import 'package:flutter/material.dart';
import '../models/category.dart';
import '../models/level.dart';
import '../theme/haptics.dart';
import '../theme/palette.dart';
import '../widgets/arrow_painter.dart';
import '../widgets/node_widget.dart';

class GameScreen extends StatefulWidget {
  final Level level;
  final VoidCallback onComplete;

  const GameScreen({
    super.key,
    required this.level,
    required this.onComplete,
  });

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
  late List<CatObject> _objects;
  late List<Morphism> _fixedMorphisms;
  final List<Morphism> _playerMorphisms = [];

  String? _dragSourceId;
  Offset? _dragPosition;
  int _morphismCounter = 0;

  bool _levelComplete = false;
  String? _notationReveal;
  bool _showNotation = false;

  late AnimationController _glowController;
  late AnimationController _successController;

  @override
  void initState() {
    super.initState();
    _objects = widget.level.initialObjects
        .map((o) => CatObject(
              id: o.id,
              label: o.label,
              colorIndex: o.colorIndex,
              x: o.x,
              y: o.y,
            ))
        .toList();
    _fixedMorphisms = List.of(widget.level.initialMorphisms);

    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();

    _successController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
  }

  @override
  void dispose() {
    _glowController.dispose();
    _successController.dispose();
    super.dispose();
  }

  List<Morphism> get _allMorphisms => [..._fixedMorphisms, ..._playerMorphisms];

  Category get _category => Category(
        objects: _objects,
        morphisms: _allMorphisms,
      );

  Offset _objectPosition(String id, Size size) {
    final obj = _objects.firstWhere((o) => o.id == id);
    return Offset(obj.x * size.width, obj.y * size.height);
  }

  void _onDragStart(String objectId) {
    setState(() => _dragSourceId = objectId);
    Haptics.tap();
  }

  void _onDragUpdate(Offset position) {
    setState(() => _dragPosition = position);
  }

  void _onDragEnd(String? targetId) {
    if (_dragSourceId != null && targetId != null) {
      _tryCreateMorphism(_dragSourceId!, targetId);
    }
    setState(() {
      _dragSourceId = null;
      _dragPosition = null;
    });
  }

  void _tryCreateMorphism(String sourceId, String targetId) {
    // Check if this morphism already exists
    if (_allMorphisms.any(
        (m) => m.sourceId == sourceId && m.targetId == targetId)) {
      Haptics.fizzle();
      return;
    }

    // Check if allowed
    if (widget.level.allowedMorphisms != null &&
        !widget.level.allowedMorphisms!(sourceId, targetId)) {
      Haptics.fizzle();
      return;
    }

    final isIdentity = sourceId == targetId;
    final morphism = Morphism(
      id: 'player-${_morphismCounter++}',
      sourceId: sourceId,
      targetId: targetId,
      isIdentity: isIdentity,
      isPlayerCreated: true,
    );

    setState(() => _playerMorphisms.add(morphism));

    if (isIdentity) {
      Haptics.identity();
    } else {
      // Check if this is a composition (path exists through intermediate)
      final isComposition = _allMorphisms.any((m1) =>
          _allMorphisms.any((m2) =>
              m1.targetId == m2.sourceId &&
              m1.sourceId == sourceId &&
              m2.targetId == targetId &&
              m1.id != morphism.id &&
              m2.id != morphism.id));
      if (isComposition) {
        Haptics.compose();
      } else {
        Haptics.snap();
      }
    }

    _checkGoals();
  }

  void _checkGoals() {
    final allComplete = widget.level.goals.every(
      (goal) => goal.check(_category, _playerMorphisms),
    );

    if (allComplete && !_levelComplete) {
      setState(() => _levelComplete = true);
      Haptics.triumph();
      _successController.forward();

      if (widget.level.notationReveal != null) {
        Future.delayed(const Duration(milliseconds: 1200), () {
          if (mounted) {
            setState(() {
              _notationReveal = widget.level.notationReveal;
              _showNotation = true;
            });
            Haptics.reveal();
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Palette.bg,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(child: _buildCanvas()),
            if (_showNotation) _buildNotationReveal(),
            if (_levelComplete) _buildContinueButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: [
          Text(
            widget.level.title,
            style: const TextStyle(
              color: Palette.textPrimary,
              fontSize: 24,
              fontWeight: FontWeight.w800,
              letterSpacing: 2,
            ),
          ),
          const Spacer(),
          if (widget.level.hint != null && !_levelComplete)
            _HintButton(hint: widget.level.hint!),
        ],
      ),
    );
  }

  String? _findNodeAt(Offset position, Size size) {
    for (final obj in _objects) {
      final pos = _objectPosition(obj.id, size);
      if ((position - pos).distance < 48) return obj.id;
    }
    return null;
  }

  Widget _buildCanvas() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = constraints.biggest;

        return GestureDetector(
          onPanStart: (details) {
            final nodeId = _findNodeAt(details.localPosition, size);
            if (nodeId != null) {
              _onDragStart(nodeId);
              _onDragUpdate(details.localPosition);
            }
          },
          onPanUpdate: (details) {
            if (_dragSourceId != null) {
              _onDragUpdate(details.localPosition);
            }
          },
          onPanEnd: (_) {
            if (_dragSourceId != null && _dragPosition != null) {
              final targetId = _findNodeAt(_dragPosition!, size);
              _onDragEnd(targetId);
            }
          },
          child: AnimatedBuilder(
            animation: _glowController,
            builder: (context, _) {
              final arrows = <ArrowData>[];

              for (final m in _fixedMorphisms) {
                final from = _objectPosition(m.sourceId, size);
                final to = _objectPosition(m.targetId, size);
                final sourceObj = _category.objectById(m.sourceId);
                arrows.add(ArrowData(
                  from: from,
                  to: to,
                  color: Palette.nodeColor(sourceObj.colorIndex)
                      .withValues(alpha: 0.5),
                  isIdentity: m.isIdentity,
                ));
              }

              for (final m in _playerMorphisms) {
                final from = _objectPosition(m.sourceId, size);
                final to = _objectPosition(m.targetId, size);
                final sourceObj = _category.objectById(m.sourceId);
                arrows.add(ArrowData(
                  from: from,
                  to: to,
                  color: Palette.nodeColor(sourceObj.colorIndex),
                  isNew: true,
                  isIdentity: m.isIdentity,
                ));
              }

              ArrowData? draggingArrow;
              if (_dragSourceId != null && _dragPosition != null) {
                final from = _objectPosition(_dragSourceId!, size);
                final sourceObj = _category.objectById(_dragSourceId!);
                draggingArrow = ArrowData(
                  from: from,
                  to: _dragPosition!,
                  color: Palette.nodeColor(sourceObj.colorIndex),
                );
              }

              return CustomPaint(
                painter: ArrowPainter(
                  arrows: arrows,
                  dragging: draggingArrow,
                  glowPhase: _glowController.value,
                ),
                child: Stack(
                  children: [
                    for (final obj in _objects)
                      Positioned(
                        left: obj.x * size.width - 32,
                        top: obj.y * size.height - 32,
                        child: NodeWidget(
                          label: obj.label,
                          colorIndex: obj.colorIndex,
                          active: _dragSourceId == obj.id,
                          pulsing: _levelComplete,
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildNotationReveal() {
    return AnimatedOpacity(
      opacity: _showNotation ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 600),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 32, vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: BoxDecoration(
          color: Palette.bgCard,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Palette.cyan.withValues(alpha: 0.3),
          ),
          boxShadow: [
            BoxShadow(
              color: Palette.cyan.withValues(alpha: 0.1),
              blurRadius: 20,
            ),
          ],
        ),
        child: Text(
          _notationReveal!,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Palette.cyan,
            fontSize: 20,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.5,
            height: 1.6,
          ),
        ),
      ),
    );
  }

  Widget _buildContinueButton() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: widget.onComplete,
          style: ElevatedButton.styleFrom(
            backgroundColor: Palette.green.withValues(alpha: 0.15),
            foregroundColor: Palette.green,
            side: BorderSide(color: Palette.green.withValues(alpha: 0.5)),
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text(
            'CONTINUE',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              letterSpacing: 3,
            ),
          ),
        ),
      ),
    );
  }
}

class _HintButton extends StatefulWidget {
  final String hint;
  const _HintButton({required this.hint});

  @override
  State<_HintButton> createState() => _HintButtonState();
}

class _HintButtonState extends State<_HintButton> {
  bool _showing = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() => _showing = !_showing),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: EdgeInsets.symmetric(
          horizontal: _showing ? 16 : 12,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: Palette.bgCard,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Palette.textDim.withValues(alpha: 0.3),
          ),
        ),
        child: Text(
          _showing ? widget.hint : '?',
          style: TextStyle(
            color: _showing ? Palette.textSecondary : Palette.textDim,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}
