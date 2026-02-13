import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/sudoku_board.dart';
import '../providers/sudoku_provider.dart';
import '../providers/settings_provider.dart';
import '../widgets/sudoku_grid.dart';
import '../widgets/number_pad.dart';

class GamePage extends StatelessWidget {
  const GamePage({super.key});

  @override
  Widget build(BuildContext context) {
    final sudoku = context.watch<SudokuProvider>();
    final settings = context.watch<SettingsProvider>();
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Show dialogs after the build phase
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (sudoku.isWon) {
        _showWinDialog(context, sudoku, settings);
      } else if (sudoku.isGameOver) {
        _showGameOverDialog(context, sudoku, settings);
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: _buildDifficultyChip(context, sudoku),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => _confirmExit(context),
        ),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: theme.brightness == Brightness.dark
                ? [colorScheme.surface, colorScheme.surface]
                : [
                    colorScheme.surface,
                    colorScheme.primary.withValues(alpha: 0.04),
                  ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 8),

              // Timer & Lives row
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Timer
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHighest.withValues(
                          alpha: 0.6,
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.timer_outlined,
                            size: 18,
                            color: colorScheme.primary,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            sudoku.formattedTime,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              fontFeatures: [
                                const FontFeature.tabularFigures(),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Error / Lives indicator
                    if (settings.errorLimitEnabled)
                      Row(
                        children: List.generate(3, (i) {
                          final isFilled = i < (3 - sudoku.errors);
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 2),
                            child: Icon(
                              isFilled ? Icons.favorite : Icons.favorite_border,
                              color: isFilled
                                  ? colorScheme.error
                                  : colorScheme.onSurface.withValues(
                                      alpha: 0.3,
                                    ),
                              size: 22,
                            ),
                          );
                        }),
                      )
                    else
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: sudoku.errors > 0
                              ? colorScheme.errorContainer.withValues(
                                  alpha: 0.5,
                                )
                              : colorScheme.surfaceContainerHighest.withValues(
                                  alpha: 0.6,
                                ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.close,
                              size: 16,
                              color: sudoku.errors > 0
                                  ? colorScheme.error
                                  : colorScheme.onSurface.withValues(
                                      alpha: 0.6,
                                    ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${sudoku.errors} erro${sudoku.errors != 1 ? 's' : ''}',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: sudoku.errors > 0
                                    ? colorScheme.error
                                    : colorScheme.onSurface.withValues(
                                        alpha: 0.6,
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),

              // Sudoku Grid
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Center(child: const SudokuGrid()),
                ),
              ),

              // Number Pad
              const NumberPad(),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDifficultyChip(BuildContext context, SudokuProvider sudoku) {
    final colorScheme = Theme.of(context).colorScheme;

    String label;
    Color chipColor;
    switch (sudoku.currentDifficulty) {
      case Difficulty.easy:
        label = 'Fácil';
        chipColor = Colors.green;
        break;
      case Difficulty.normal:
        label = 'Normal';
        chipColor = Colors.orange;
        break;
      case Difficulty.hard:
        label = 'Difícil';
        chipColor = Colors.red;
        break;
      default:
        label = '';
        chipColor = colorScheme.primary;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: chipColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: chipColor.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: chipColor,
          fontWeight: FontWeight.w700,
          fontSize: 14,
        ),
      ),
    );
  }

  void _confirmExit(BuildContext context) {
    final sudoku = context.read<SudokuProvider>();
    if (sudoku.isWon || sudoku.isGameOver) {
      Navigator.pop(context);
      return;
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: const Icon(Icons.warning_amber_rounded),
        title: const Text('Sair do jogo?'),
        content: const Text('Seu progresso será perdido.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('CANCELAR'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            child: const Text('SAIR'),
          ),
        ],
      ),
    );
  }

  void _showWinDialog(
    BuildContext context,
    SudokuProvider sudoku,
    SettingsProvider settings,
  ) {
    // Avoid showing the dialog multiple times
    if (!sudoku.isWon) return;

    // Record stats
    settings.recordGame(
      difficulty: sudoku.difficultyKey,
      won: true,
      timeSeconds: sudoku.elapsedSeconds,
    );

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        icon: Icon(Icons.emoji_events, size: 48, color: Colors.amber.shade600),
        title: const Text('Parabéns! 🎉'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Você completou o Sudoku!'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.primaryContainer.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    children: [
                      const Icon(Icons.timer, size: 20),
                      const SizedBox(height: 4),
                      Text(
                        sudoku.formattedTime,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const Text('Tempo', style: TextStyle(fontSize: 12)),
                    ],
                  ),
                  Column(
                    children: [
                      const Icon(Icons.close, size: 20),
                      const SizedBox(height: 4),
                      Text(
                        '${sudoku.errors}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const Text('Erros', style: TextStyle(fontSize: 12)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          FilledButton.icon(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            icon: const Icon(Icons.home),
            label: const Text('INÍCIO'),
          ),
        ],
      ),
    );
  }

  void _showGameOverDialog(
    BuildContext context,
    SudokuProvider sudoku,
    SettingsProvider settings,
  ) {
    if (!sudoku.isGameOver) return;

    settings.recordGame(
      difficulty: sudoku.difficultyKey,
      won: false,
      timeSeconds: sudoku.elapsedSeconds,
    );

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        icon: Icon(
          Icons.heart_broken,
          size: 48,
          color: Theme.of(context).colorScheme.error,
        ),
        title: const Text('Game Over'),
        content: const Text('Você atingiu o limite de 3 erros.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            child: const Text('INÍCIO'),
          ),
          FilledButton.icon(
            onPressed: () {
              Navigator.pop(ctx);
              sudoku.startNewGame(sudoku.currentDifficulty!);
            },
            icon: const Icon(Icons.refresh),
            label: const Text('TENTAR NOVAMENTE'),
          ),
        ],
      ),
    );
  }
}
