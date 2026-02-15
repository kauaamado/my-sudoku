import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';

class SettingsDrawer extends StatelessWidget {
  const SettingsDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    colorScheme.primaryContainer,
                    colorScheme.primary.withValues(alpha: 0.15),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.settings, size: 36, color: colorScheme.primary),
                  const SizedBox(height: 12),
                  Text(
                    'Configurações',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // Theme Toggle
            SwitchListTile(
              secondary: Icon(
                settings.isDarkMode ? Icons.dark_mode : Icons.light_mode,
                color: colorScheme.primary,
              ),
              title: const Text('Modo Escuro'),
              subtitle: Text(
                settings.isDarkMode ? 'Tema escuro ativo' : 'Tema claro ativo',
              ),
              value: settings.isDarkMode,
              onChanged: (_) => settings.toggleDarkMode(),
            ),

            const Divider(indent: 16, endIndent: 16),

            // Error Limit Toggle
            SwitchListTile(
              secondary: Icon(Icons.favorite, color: colorScheme.error),
              title: const Text('Limite de Erros'),
              subtitle: const Text('Game over após 3 erros'),
              value: settings.errorLimitEnabled,
              onChanged: (_) => settings.toggleErrorLimit(),
            ),

            const Divider(indent: 16, endIndent: 16),

            // Visual Aid Toggle
            SwitchListTile(
              secondary: Icon(Icons.grid_on, color: colorScheme.tertiary),
              title: const Text('Auxílio Visual'),
              subtitle: const Text('Destaque linha, coluna e bloco'),
              value: settings.visualAidEnabled,
              onChanged: (_) => settings.toggleVisualAid(),
            ),

            const Divider(indent: 16, endIndent: 16),

            // Stats Button
            ListTile(
              leading: Icon(Icons.bar_chart, color: colorScheme.secondary),
              title: const Text('Estatísticas'),
              subtitle: const Text('Veja seu desempenho'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _showStatsDialog(context, settings),
            ),

            const Spacer(),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'KSudoku v1.0\npor Kauã Amado',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showStatsDialog(BuildContext context, SettingsProvider settings) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.emoji_events, color: colorScheme.primary),
            const SizedBox(width: 8),
            const Text('Estatísticas'),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildStatCard(ctx, 'Fácil', 'easy', settings),
              const SizedBox(height: 12),
              _buildStatCard(ctx, 'Normal', 'normal', settings),
              const SizedBox(height: 12),
              _buildStatCard(ctx, 'Difícil', 'hard', settings),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('FECHAR'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String label,
    String key,
    SettingsProvider settings,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final stat = settings.stats[key]!;
    final won = stat['won'] as int;
    final played = stat['played'] as int;
    final bestTime = stat['bestTime'] as int?;
    final rate = settings.winRate(key);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.primary,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _miniStat(context, Icons.emoji_events, '$won', 'Vitórias'),
              _miniStat(
                context,
                Icons.timer,
                settings.formatTime(bestTime),
                'Melhor',
              ),
              _miniStat(
                context,
                Icons.percent,
                '${(rate * 100).toStringAsFixed(0)}%',
                'Taxa',
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '$played jogos no total',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _miniStat(
    BuildContext context,
    IconData icon,
    String value,
    String label,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      children: [
        Icon(icon, size: 18, color: colorScheme.secondary),
        const SizedBox(height: 2),
        Text(
          value,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(label, style: theme.textTheme.bodySmall),
      ],
    );
  }
}
