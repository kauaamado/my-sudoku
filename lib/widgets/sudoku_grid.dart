import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/sudoku_provider.dart';
import '../providers/settings_provider.dart';

class SudokuGrid extends StatelessWidget {
  const SudokuGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final sudoku = context.watch<SudokuProvider>();
    final settings = context.watch<SettingsProvider>();
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (sudoku.board == null) return const SizedBox.shrink();

    return AspectRatio(
      aspectRatio: 1,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: colorScheme.onSurface, width: 2.5),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Column(
          children: List.generate(9, (row) {
            return Expanded(
              child: Row(
                children: List.generate(9, (col) {
                  return Expanded(
                    child: _buildCell(
                      context, row, col, sudoku, settings, colorScheme,
                    ),
                  );
                }),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildCell(
    BuildContext context,
    int row,
    int col,
    SudokuProvider sudoku,
    SettingsProvider settings,
    ColorScheme colorScheme,
  ) {
    final value = sudoku.playerBoard[row][col];
    final isOriginal = sudoku.board!.original[row][col];
    final isSelected = sudoku.selectedRow == row && sudoku.selectedCol == col;
    final isInGroup =
        settings.visualAidEnabled && sudoku.isInSelectedGroup(row, col);
    final isSameNumber = sudoku.isSameNumber(row, col);
    final isCorrect = sudoku.isCorrectEntry(row, col);

    // Determine cell background color
    Color bgColor;
    if (isSelected) {
      bgColor = colorScheme.primaryContainer;
    } else if (isSameNumber && value != 0) {
      bgColor = colorScheme.tertiaryContainer.withValues(alpha: 0.7);
    } else if (isInGroup) {
      bgColor = colorScheme.primaryContainer.withValues(alpha: 0.35);
    } else {
      bgColor = Colors.transparent;
    }

    // Determine text color
    Color textColor;
    if (isOriginal) {
      textColor = colorScheme.onSurface;
    } else if (value != 0 && !isCorrect) {
      textColor = colorScheme.error;
    } else if (value != 0) {
      textColor = Colors.blue.shade600;
    } else {
      textColor = colorScheme.onSurface;
    }

    // Borders – thicker for 3×3 blocks
    final rightBorder = (col + 1) % 3 == 0 && col < 8 ? 2.0 : 0.5;
    final bottomBorder = (row + 1) % 3 == 0 && row < 8 ? 2.0 : 0.5;
    final borderColor = colorScheme.onSurface.withValues(alpha: 0.5);

    return GestureDetector(
      onTap: () => sudoku.selectCell(row, col),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          color: bgColor,
          border: Border(
            right: BorderSide(width: rightBorder, color: borderColor),
            bottom: BorderSide(width: bottomBorder, color: borderColor),
          ),
        ),
        child: Center(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: Text(
              value == 0 ? '' : '$value',
              key: ValueKey('${row}_${col}_$value'),
              style: TextStyle(
                fontSize: 18,
                fontWeight:
                    isOriginal ? FontWeight.w800 : FontWeight.w500,
                color: textColor,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
