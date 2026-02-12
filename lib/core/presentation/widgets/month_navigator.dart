import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MonthNavigator extends StatelessWidget {
  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateChanged;

  const MonthNavigator({
    super.key,
    required this.selectedDate,
    required this.onDateChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () {
              final newDate = DateTime(
                selectedDate.year,
                selectedDate.month - 1,
                1,
              );
              onDateChanged(newDate);
            },
          ),
          Expanded(
            child: Text(
              DateFormat('MMMM yyyy').format(selectedDate),
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: () {
              final newDate = DateTime(
                selectedDate.year,
                selectedDate.month + 1,
                1,
              );
              onDateChanged(newDate);
            },
          ),
        ],
      ),
    );
  }
}
