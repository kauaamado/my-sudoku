import 'dart:math';

enum Difficulty { easy, normal, hard }

class SudokuBoard {
  /// The complete solved board.
  late List<List<int>> solution;

  /// The puzzle board (0 = empty).
  late List<List<int>> puzzle;

  /// Which cells are original (given) clues.
  late List<List<bool>> original;

  final Difficulty difficulty;
  final Random _random = Random();

  SudokuBoard({required this.difficulty}) {
    solution = List.generate(9, (_) => List.filled(9, 0));
    _generateSolved(solution);
    puzzle = solution.map((row) => List<int>.from(row)).toList();
    _removeNumbers();
    original = List.generate(
      9,
      (r) => List.generate(9, (c) => puzzle[r][c] != 0),
    );
  }

  /// Creates a SudokuBoard from existing data (for restoring state, etc.).
  SudokuBoard.fromData({
    required this.solution,
    required this.puzzle,
    required this.original,
    required this.difficulty,
  });

  // ──────────────────────────────────────────
  // Generator – Backtracking
  // ──────────────────────────────────────────

  bool _generateSolved(List<List<int>> board) {
    for (int row = 0; row < 9; row++) {
      for (int col = 0; col < 9; col++) {
        if (board[row][col] == 0) {
          final numbers = List.generate(9, (i) => i + 1)..shuffle(_random);
          for (final num in numbers) {
            if (_isValid(board, row, col, num)) {
              board[row][col] = num;
              if (_generateSolved(board)) return true;
              board[row][col] = 0;
            }
          }
          return false;
        }
      }
    }
    return true;
  }

  // ──────────────────────────────────────────
  // Remove numbers ensuring unique solution
  // ──────────────────────────────────────────

  void _removeNumbers() {
    int toRemove;
    switch (difficulty) {
      case Difficulty.easy:
        toRemove = 30;
        break;
      case Difficulty.normal:
        toRemove = 40;
        break;
      case Difficulty.hard:
        toRemove = 50;
        break;
    }

    final positions = <List<int>>[];
    for (int r = 0; r < 9; r++) {
      for (int c = 0; c < 9; c++) {
        positions.add([r, c]);
      }
    }
    positions.shuffle(_random);

    int removed = 0;
    for (final pos in positions) {
      if (removed >= toRemove) break;
      final r = pos[0];
      final c = pos[1];
      final backup = puzzle[r][c];
      puzzle[r][c] = 0;

      // Check unique solution
      if (_countSolutions(puzzle, 0, 0, 0) != 1) {
        puzzle[r][c] = backup; // Restore – removing this breaks uniqueness
      } else {
        removed++;
      }
    }
  }

  // ──────────────────────────────────────────
  // Solver / counter (max 2 to detect non-unique)
  // ──────────────────────────────────────────

  int _countSolutions(List<List<int>> board, int row, int col, int count) {
    if (count > 1) return count; // Early exit: already found >1

    if (row == 9) return count + 1;

    final nextRow = col == 8 ? row + 1 : row;
    final nextCol = col == 8 ? 0 : col + 1;

    if (board[row][col] != 0) {
      return _countSolutions(board, nextRow, nextCol, count);
    }

    for (int num = 1; num <= 9; num++) {
      if (_isValid(board, row, col, num)) {
        board[row][col] = num;
        count = _countSolutions(board, nextRow, nextCol, count);
        board[row][col] = 0;
        if (count > 1) return count;
      }
    }
    return count;
  }

  // ──────────────────────────────────────────
  // Validation helper
  // ──────────────────────────────────────────

  static bool _isValid(List<List<int>> board, int row, int col, int num) {
    // Check row
    for (int c = 0; c < 9; c++) {
      if (board[row][c] == num) return false;
    }
    // Check column
    for (int r = 0; r < 9; r++) {
      if (board[r][col] == num) return false;
    }
    // Check 3×3 box
    final boxRow = (row ~/ 3) * 3;
    final boxCol = (col ~/ 3) * 3;
    for (int r = boxRow; r < boxRow + 3; r++) {
      for (int c = boxCol; c < boxCol + 3; c++) {
        if (board[r][c] == num) return false;
      }
    }
    return true;
  }
}
