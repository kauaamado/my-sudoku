import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/sudoku_provider.dart';
import '../providers/settings_provider.dart';

class NumberPad extends StatelessWidget {
  const NumberPad({super.key});

  @override
  Widget build(BuildContext context) {
    final sudoku = context.watch<SudokuProvider>();
    final settings = context.read<SettingsProvider>();
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      children: [
        // Numbers 1-9
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(9, (i) {
            final number = i + 1;
            final count = sudoku.countOfNumber(number);
            final isComplete = count >= 9;

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3),
              child: SizedBox(
                width: 36,
                height: 52,
                child: ElevatedButton(
                  onPressed: isComplete || sudoku.isGameOver || sudoku.isWon
                      ? null
                      : () => sudoku.placeNumber(
                            number,
                            errorLimitEnabled: settings.errorLimitEnabled,
                          ),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.zero,
                    backgroundColor: sudoku.highlightedNumber == number
                        ? colorScheme.primaryContainer
                        : colorScheme.surface,
                    foregroundColor: isComplete
                        ? colorScheme.onSurface.withValues(alpha: 0.3)
                        : colorScheme.onSurface,
                    elevation: isComplete ? 0 : 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: BorderSide(
                        color: sudoku.highlightedNumber == number
                            ? colorScheme.primary
                            : colorScheme.outlineVariant,
                        width: sudoku.highlightedNumber == number ? 2 : 1,
                      ),
                    ),
                  ),
                  child: Text(
                    '$number',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: isComplete
                          ? colorScheme.onSurface.withValues(alpha: 0.3)
                          : null,
                    ),
                  ),
                ),
              ),
            );
          }),
        ),

        const SizedBox(height: 12),

        // Erase button
        SizedBox(
          width: 140,
          height: 44,
          child: OutlinedButton.icon(
            onPressed: sudoku.isGameOver || sudoku.isWon
                ? null
                : () => sudoku.eraseCell(),
            icon: const Icon(Icons.backspace_outlined, size: 20),
            label: const Text('Apagar'),
            style: OutlinedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
