import 'dart:async';
import 'package:flutter/material.dart';
import '../models/sudoku_board.dart';

class SudokuProvider extends ChangeNotifier {
  SudokuBoard? _board;
  late List<List<int>> _playerBoard;
  int _selectedRow = -1;
  int _selectedCol = -1;
  int _errors = 0;
  int _elapsedSeconds = 0;
  Timer? _timer;
  bool _isGameOver = false;
  bool _isWon = false;
  int? _highlightedNumber;

  // Getters
  SudokuBoard? get board => _board;
  List<List<int>> get playerBoard => _playerBoard;
  int get selectedRow => _selectedRow;
  int get selectedCol => _selectedCol;
  int get errors => _errors;
  int get elapsedSeconds => _elapsedSeconds;
  bool get isGameOver => _isGameOver;
  bool get isWon => _isWon;
  int? get highlightedNumber => _highlightedNumber;

  Difficulty? _currentDifficulty;
  Difficulty? get currentDifficulty => _currentDifficulty;

  String get formattedTime {
    final m = _elapsedSeconds ~/ 60;
    final s = _elapsedSeconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  /// How many of number [n] are correctly placed on the board.
  int countOfNumber(int n) {
    int count = 0;
    for (int r = 0; r < 9; r++) {
      for (int c = 0; c < 9; c++) {
        if (_playerBoard[r][c] == n) count++;
      }
    }
    return count;
  }

  void startNewGame(Difficulty difficulty) {
    _currentDifficulty = difficulty;
    _board = SudokuBoard(difficulty: difficulty);
    _playerBoard =
        _board!.puzzle.map((row) => List<int>.from(row)).toList();
    _selectedRow = -1;
    _selectedCol = -1;
    _errors = 0;
    _elapsedSeconds = 0;
    _isGameOver = false;
    _isWon = false;
    _highlightedNumber = null;
    _startTimer();
    notifyListeners();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!_isGameOver && !_isWon) {
        _elapsedSeconds++;
        notifyListeners();
      }
    });
  }

  void selectCell(int row, int col) {
    _selectedRow = row;
    _selectedCol = col;

    // If the cell has a number, highlight all same numbers
    final val = _playerBoard[row][col];
    _highlightedNumber = val != 0 ? val : null;

    notifyListeners();
  }

  /// Places a number. Returns true if correct, false if error.
  bool placeNumber(int number, {required bool errorLimitEnabled}) {
    if (_selectedRow < 0 || _selectedCol < 0) return false;
    if (_isGameOver || _isWon) return false;
    if (_board!.original[_selectedRow][_selectedCol]) return false;

    final correct = _board!.solution[_selectedRow][_selectedCol] == number;

    _playerBoard[_selectedRow][_selectedCol] = number;
    _highlightedNumber = number;

    if (!correct) {
      _errors++;
      if (errorLimitEnabled && _errors >= 3) {
        _isGameOver = true;
        _timer?.cancel();
      }
    }

    // Check win
    if (_checkWin()) {
      _isWon = true;
      _timer?.cancel();
    }

    notifyListeners();
    return correct;
  }

  void eraseCell() {
    if (_selectedRow < 0 || _selectedCol < 0) return;
    if (_isGameOver || _isWon) return;
    if (_board!.original[_selectedRow][_selectedCol]) return;

    _playerBoard[_selectedRow][_selectedCol] = 0;
    _highlightedNumber = null;
    notifyListeners();
  }

  bool _checkWin() {
    for (int r = 0; r < 9; r++) {
      for (int c = 0; c < 9; c++) {
        if (_playerBoard[r][c] != _board!.solution[r][c]) return false;
      }
    }
    return true;
  }

  bool isCorrectEntry(int row, int col) {
    if (_board == null) return true;
    return _playerBoard[row][col] == 0 ||
        _playerBoard[row][col] == _board!.solution[row][col];
  }

  bool isSameNumber(int row, int col) {
    if (_highlightedNumber == null) return false;
    return _playerBoard[row][col] == _highlightedNumber;
  }

  bool isInSelectedGroup(int row, int col) {
    if (_selectedRow < 0 || _selectedCol < 0) return false;

    final sameRow = row == _selectedRow;
    final sameCol = col == _selectedCol;
    final sameBox =
        (row ~/ 3 == _selectedRow ~/ 3) && (col ~/ 3 == _selectedCol ~/ 3);

    return sameRow || sameCol || sameBox;
  }

  String get difficultyKey {
    switch (_currentDifficulty) {
      case Difficulty.easy:
        return 'easy';
      case Difficulty.normal:
        return 'normal';
      case Difficulty.hard:
        return 'hard';
      default:
        return 'easy';
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
