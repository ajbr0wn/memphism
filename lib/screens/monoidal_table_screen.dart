import 'package:flutter/material.dart';
import '../theme/haptics.dart';
import '../theme/palette.dart';

class MonoidalTableConfig {
  final String id;
  final String title;
  final String? subtitle;
  final List<String> elements;
  final String operationSymbol;

  /// expectedTable[i][j] = index of elements[i] ⊗ elements[j]
  final List<List<int>> expectedTable;

  /// Pre-filled cells given as hints. Set of (row, col).
  final Set<(int, int)> givenCells;

  /// The monoidal unit element index (highlighted in headers).
  final int? unitIndex;
  final String? notationReveal;
  final String? hint;

  const MonoidalTableConfig({
    required this.id,
    required this.title,
    this.subtitle,
    required this.elements,
    required this.operationSymbol,
    required this.expectedTable,
    this.givenCells = const {},
    this.unitIndex,
    this.notationReveal,
    this.hint,
  });
}

class MonoidalTableScreen extends StatefulWidget {
  final MonoidalTableConfig config;
  final VoidCallback onComplete;

  const MonoidalTableScreen({
    super.key,
    required this.config,
    required this.onComplete,
  });

  @override
  State<MonoidalTableScreen> createState() => _MonoidalTableScreenState();
}

class _MonoidalTableScreenState extends State<MonoidalTableScreen> {
  /// Player's current answers: playerTable[i][j] = element index or -1 (blank).
  late List<List<int>> _playerTable;

  /// Cells that were wrong on the last submit attempt — flash red.
  Set<(int, int)> _wrongCells = {};

  bool _levelComplete = false;
  bool _showNotation = false;

  MonoidalTableConfig get _cfg => widget.config;
  int get _n => _cfg.elements.length;

  @override
  void initState() {
    super.initState();
    _resetTable();
  }

  void _resetTable() {
    _playerTable = List.generate(
      _n,
      (i) => List.generate(_n, (j) {
        if (_cfg.givenCells.contains((i, j))) {
          return _cfg.expectedTable[i][j];
        }
        return -1; // blank
      }),
    );
    _wrongCells = {};
  }

  void _onCellTap(int row, int col) {
    if (_levelComplete) return;
    if (_cfg.givenCells.contains((row, col))) return;

    Haptics.tap();

    setState(() {
      _wrongCells = {};
      final current = _playerTable[row][col];
      // Cycle: -1 → 0 → 1 → ... → n-1 → -1
      _playerTable[row][col] = (current + 2) % (_n + 1) - 1;
    });
  }

  void _submit() {
    final wrong = <(int, int)>{};
    for (var i = 0; i < _n; i++) {
      for (var j = 0; j < _n; j++) {
        if (_cfg.givenCells.contains((i, j))) continue;
        if (_playerTable[i][j] != _cfg.expectedTable[i][j]) {
          wrong.add((i, j));
        }
      }
    }

    if (wrong.isEmpty) {
      setState(() => _levelComplete = true);
      Haptics.triumph();
      if (_cfg.notationReveal != null) {
        Future.delayed(const Duration(milliseconds: 800), () {
          if (mounted) {
            setState(() => _showNotation = true);
            Haptics.reveal();
          }
        });
      }
    } else {
      Haptics.fizzle();
      setState(() => _wrongCells = wrong);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${wrong.length} cell${wrong.length == 1 ? '' : 's'} incorrect.',
            style: const TextStyle(color: Palette.textPrimary),
          ),
          backgroundColor: Palette.bgCard,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
      Future.delayed(const Duration(milliseconds: 1200), () {
        if (mounted) setState(() => _wrongCells = {});
      });
    }
  }

  void _reset() {
    if (_levelComplete) return;
    Haptics.tap();
    setState(() => _resetTable());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Palette.bg,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            if (_cfg.subtitle != null)
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 28, vertical: 0),
                child: Text(
                  _cfg.subtitle!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Palette.textSecondary,
                    fontSize: 15,
                    height: 1.4,
                  ),
                ),
              ),
            const SizedBox(height: 16),
            Expanded(child: _buildTable()),
            if (!_levelComplete) _buildActions(),
            if (_showNotation) _buildNotation(),
            if (_levelComplete) _buildContinue(),
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
            _cfg.title,
            style: const TextStyle(
              color: Palette.textPrimary,
              fontSize: 24,
              fontWeight: FontWeight.w800,
              letterSpacing: 2,
            ),
          ),
          const Spacer(),
          if (_cfg.hint != null && !_levelComplete)
            GestureDetector(
              onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    _cfg.hint!,
                    style: const TextStyle(color: Palette.textPrimary),
                  ),
                  backgroundColor: Palette.bgCard,
                  behavior: SnackBarBehavior.floating,
                ),
              ),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Palette.bgCard,
                  borderRadius: BorderRadius.circular(20),
                  border:
                      Border.all(color: Palette.textDim.withValues(alpha: 0.3)),
                ),
                child:
                    const Text('?', style: TextStyle(color: Palette.textDim)),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTable() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: _buildGrid(),
      ),
    );
  }

  Widget _buildGrid() {
    // Grid is (_n+1) x (_n+1) — first row/col are headers.
    final cellSize = _cellSize();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Header row: corner + column headers
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _cornerCell(cellSize),
            for (var j = 0; j < _n; j++) _headerCell(j, cellSize, axis: Axis.horizontal),
          ],
        ),
        // Data rows
        for (var i = 0; i < _n; i++)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _headerCell(i, cellSize, axis: Axis.vertical),
              for (var j = 0; j < _n; j++) _dataCell(i, j, cellSize),
            ],
          ),
      ],
    );
  }

  double _cellSize() {
    final screenWidth = MediaQuery.of(context).size.width;
    // Leave room for padding. Grid has _n+1 columns.
    final available = screenWidth - 32;
    final maxCell = available / (_n + 1);
    return maxCell.clamp(40.0, 64.0);
  }

  Widget _cornerCell(double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Palette.bgCard,
        border: Border.all(color: Palette.textDim.withValues(alpha: 0.2)),
      ),
      child: Center(
        child: Text(
          _cfg.operationSymbol,
          style: TextStyle(
            color: Palette.yellow,
            fontSize: size * 0.35,
            fontWeight: FontWeight.w800,
            shadows: [
              Shadow(
                  color: Palette.yellow.withValues(alpha: 0.5), blurRadius: 6),
            ],
          ),
        ),
      ),
    );
  }

  Widget _headerCell(int index, double size, {required Axis axis}) {
    final isUnit = _cfg.unitIndex == index;
    final color = isUnit ? Palette.yellow : Palette.textSecondary;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: isUnit
            ? Palette.yellow.withValues(alpha: 0.06)
            : Palette.bgCard,
        border: Border.all(
          color: isUnit
              ? Palette.yellow.withValues(alpha: 0.4)
              : Palette.textDim.withValues(alpha: 0.2),
        ),
      ),
      child: Center(
        child: Text(
          _cfg.elements[index],
          style: TextStyle(
            color: color,
            fontSize: size * 0.32,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  Widget _dataCell(int row, int col, double size) {
    final isGiven = _cfg.givenCells.contains((row, col));
    final value = _playerTable[row][col];
    final isBlank = value == -1;
    final isWrong = _wrongCells.contains((row, col));
    final isCorrectAndComplete = _levelComplete;

    Color borderColor;
    Color bgColor;
    Color textColor;

    if (isWrong) {
      borderColor = Palette.error;
      bgColor = Palette.error.withValues(alpha: 0.12);
      textColor = Palette.error;
    } else if (isCorrectAndComplete) {
      borderColor = Palette.green.withValues(alpha: 0.4);
      bgColor = Palette.green.withValues(alpha: 0.04);
      textColor = Palette.green;
    } else if (isGiven) {
      borderColor = Palette.textDim.withValues(alpha: 0.25);
      bgColor = Palette.bgCard;
      textColor = Palette.textDim;
    } else if (!isBlank) {
      borderColor = Palette.cyan.withValues(alpha: 0.5);
      bgColor = Palette.cyan.withValues(alpha: 0.06);
      textColor = Palette.cyan;
    } else {
      borderColor = Palette.textDim.withValues(alpha: 0.15);
      bgColor = Palette.bg;
      textColor = Palette.textDim;
    }

    return GestureDetector(
      onTap: () => _onCellTap(row, col),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: bgColor,
          border: Border.all(color: borderColor, width: isWrong ? 2 : 1),
          boxShadow: isWrong
              ? [
                  BoxShadow(
                      color: Palette.error.withValues(alpha: 0.3),
                      blurRadius: 8)
                ]
              : null,
        ),
        child: Center(
          child: isBlank
              ? Text(
                  '·',
                  style: TextStyle(
                    color: Palette.textDim.withValues(alpha: 0.3),
                    fontSize: size * 0.35,
                  ),
                )
              : Text(
                  _cfg.elements[value],
                  style: TextStyle(
                    color: textColor,
                    fontSize: size * 0.30,
                    fontWeight: isGiven ? FontWeight.w500 : FontWeight.w700,
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildActions() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: _reset,
              style: OutlinedButton.styleFrom(
                foregroundColor: Palette.textDim,
                side: BorderSide(
                    color: Palette.textDim.withValues(alpha: 0.3)),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text(
                'RESET',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 2,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: Palette.pink.withValues(alpha: 0.15),
                foregroundColor: Palette.pink,
                side: BorderSide(
                    color: Palette.pink.withValues(alpha: 0.5)),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text(
                'SUBMIT',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 3,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotation() {
    return AnimatedOpacity(
      opacity: _showNotation ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 600),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 32, vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: BoxDecoration(
          color: Palette.bgCard,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Palette.cyan.withValues(alpha: 0.3)),
          boxShadow: [
            BoxShadow(
                color: Palette.cyan.withValues(alpha: 0.1), blurRadius: 20),
          ],
        ),
        child: Text(
          _cfg.notationReveal!,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Palette.cyan,
            fontSize: 18,
            fontWeight: FontWeight.w600,
            letterSpacing: 1,
            height: 1.6,
          ),
        ),
      ),
    );
  }

  Widget _buildContinue() {
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
                borderRadius: BorderRadius.circular(12)),
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
