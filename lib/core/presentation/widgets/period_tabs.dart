import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/app_theme_provider.dart';

class PeriodTabs extends ConsumerWidget {
  final String currentPeriod; // 'day', 'week', 'month'
  final String feature; // 'habits', 'sleep', 'mood'

  const PeriodTabs({
    super.key,
    required this.currentPeriod,
    required this.feature,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appTheme = ref.watch(appThemeProvider);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          children: [
            Expanded(
              child: _buildButton(
                context,
                appTheme,
                'Day',
                'day',
                Icons.calendar_today,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildButton(
                context,
                appTheme,
                'Week',
                'week',
                Icons.view_week,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildButton(
                context,
                appTheme,
                'Month',
                'month',
                Icons.calendar_month,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildButton(
    BuildContext context,
    appTheme,
    String label,
    String period,
    IconData icon,
  ) {
    final isSelected = currentPeriod == period;

    return ElevatedButton.icon(
      onPressed: isSelected ? null : () => context.go('/$feature/$period'),
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? appTheme.primaryColor : null,
        foregroundColor: isSelected ? Colors.white : null,
        padding: const EdgeInsets.symmetric(vertical: 12),
      ),
    );
  }
}
