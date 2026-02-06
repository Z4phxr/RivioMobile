import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/presentation/widgets/month_navigator.dart';
import '../../../../core/presentation/widgets/period_tabs.dart';
import '../providers/habits_provider.dart';

class HabitMonthScreen extends ConsumerStatefulWidget {
  const HabitMonthScreen({super.key});

  @override
  ConsumerState<HabitMonthScreen> createState() => _HabitMonthScreenState();
}

class _HabitMonthScreenState extends ConsumerState<HabitMonthScreen> {
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    Future.microtask(() => _loadData());
  }

  Future<void> _loadData() async {
    try {
      await ref.read(habitsNotifierProvider.notifier).loadHabits();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load habits: $e')),
        );
      }
    }
  }

  List<DateTime> _getDaysInMonth(DateTime date) {
    final firstDay = DateTime(date.year, date.month, 1);
    final lastDay = DateTime(date.year, date.month + 1, 0);
    return List.generate(lastDay.day, (i) => firstDay.add(Duration(days: i)));
  }

  double _getCompletionRatio(DateTime date, List habits) {
    if (habits.isEmpty) return 0.0;
    // Get current state to calculate completion
    final currentState = ref.read(habitsNotifierProvider);
    final dateKey = _formatDate(date);
    int completed = 0;
    for (var habit in habits) {
      final key = '${habit.id}_$dateKey';
      if (currentState.optimisticToggles[key] ?? false) {
        completed++;
      }
    }
    return completed / habits.length;
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  Color _getCompletionColor(double ratio, BuildContext context) {
    final theme = Theme.of(context);
    if (ratio == 0) {
      return theme.brightness == Brightness.dark
          ? Colors.grey.shade800
          : Colors.grey.shade200;
    }
    if (ratio < 0.5) return Colors.orange.shade300;
    return Colors.green.withValues(alpha: 0.3 + (ratio * 0.7));
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(habitsNotifierProvider);
    final habits = state.activeHabits;
    final monthDays = _getDaysInMonth(_selectedDate);

    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: _loadData,
                  tooltip: 'Refresh',
                ),
              ],
            ),
          ),
          const PeriodTabs(currentPeriod: 'month', feature: 'habits'),
          MonthNavigator(
            selectedDate: _selectedDate,
            onDateChanged: (date) {
              setState(() {
                _selectedDate = date;
              });
            },
          ),
          const Divider(),
          Expanded(
            child: state.isLoading
                ? const Center(child: CircularProgressIndicator())
                : _buildContent(state, habits, monthDays),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(state, List habits, List<DateTime> monthDays) {
    if (state.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text('Error: ${state.error}'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadData,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (habits.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.playlist_add_check, size: 48, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No habits yet',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            SizedBox(height: 8),
            Text(
              'Add habits in the Edit screen',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    // Build calendar grid
    final firstDayOfMonth =
        DateTime(_selectedDate.year, _selectedDate.month, 1);
    final firstWeekday = firstDayOfMonth.weekday;
    final daysInMonth = monthDays.length;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Day names header
          Row(
            children: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']
                .map(
                  (day) => Expanded(
                    child: Center(
                      child: Text(
                        day,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 8),
          // Calendar grid
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                mainAxisSpacing: 4,
                crossAxisSpacing: 4,
              ),
              itemCount: firstWeekday - 1 + daysInMonth,
              itemBuilder: (context, index) {
                if (index < firstWeekday - 1) {
                  // Empty cells before first day of month
                  return Container();
                }

                final dayIndex = index - (firstWeekday - 1);
                final date = monthDays[dayIndex];
                final ratio = _getCompletionRatio(date, habits);
                final completed = (ratio * habits.length).round();

                return InkWell(
                  onTap: () {
                    context.go('/habits/day?date=${_formatDate(date)}');
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: _getCompletionColor(ratio, context),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: date.day == DateTime.now().day &&
                                date.month == DateTime.now().month &&
                                date.year == DateTime.now().year
                            ? Colors.blue
                            : Colors.grey.shade300,
                        width: date.day == DateTime.now().day &&
                                date.month == DateTime.now().month &&
                                date.year == DateTime.now().year
                            ? 2
                            : 1,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${date.day}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (ratio > 0) ...[
                          const SizedBox(height: 2),
                          Text(
                            '$completed/${habits.length}',
                            style: const TextStyle(
                              fontSize: 10,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
