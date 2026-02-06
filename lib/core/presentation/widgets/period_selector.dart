import 'package:flutter/material.dart';

enum Period { day, week, month }

class PeriodSelector extends StatelessWidget {
  final Period selectedPeriod;
  final ValueChanged<Period> onPeriodChanged;

  const PeriodSelector({
    super.key,
    required this.selectedPeriod,
    required this.onPeriodChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SegmentedButton<Period>(
        segments: const [
          ButtonSegment<Period>(
            value: Period.day,
            label: Text('Day'),
            icon: Icon(Icons.today),
          ),
          ButtonSegment<Period>(
            value: Period.week,
            label: Text('Week'),
            icon: Icon(Icons.view_week),
          ),
          ButtonSegment<Period>(
            value: Period.month,
            label: Text('Month'),
            icon: Icon(Icons.calendar_month),
          ),
        ],
        selected: {selectedPeriod},
        onSelectionChanged: (Set<Period> newSelection) {
          onPeriodChanged(newSelection.first);
        },
      ),
    );
  }
}
