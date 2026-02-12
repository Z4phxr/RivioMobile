import 'package:flutter/material.dart';

class WeekNavigator extends StatelessWidget {
  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateChanged;

  const WeekNavigator({
    super.key,
    required this.selectedDate,
    required this.onDateChanged,
  });

  DateTime _getWeekStart(DateTime date) {
    return date.subtract(Duration(days: date.weekday - 1));
  }

  DateTime _getWeekEnd(DateTime date) {
    final weekStart = _getWeekStart(date);
    return weekStart.add(const Duration(days: 6));
  }

  @override
  Widget build(BuildContext context) {
    final weekStart = _getWeekStart(selectedDate);
    final weekEnd = _getWeekEnd(selectedDate);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () {
              final newDate = selectedDate.subtract(const Duration(days: 7));
              onDateChanged(newDate);
            },
          ),
          Expanded(
            child: Text(
              '${weekStart.month}/${weekStart.day} - ${weekEnd.month}/${weekEnd.day}',
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: () {
              final newDate = selectedDate.add(const Duration(days: 7));
              onDateChanged(newDate);
            },
          ),
        ],
      ),
    );
  }
}
