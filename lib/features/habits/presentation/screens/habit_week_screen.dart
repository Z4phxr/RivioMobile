import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/presentation/widgets/week_navigator.dart';
import '../../../../core/presentation/widgets/period_tabs.dart';
import '../providers/habits_provider.dart';

class HabitWeekScreen extends ConsumerStatefulWidget {
  const HabitWeekScreen({super.key});

  @override
  ConsumerState<HabitWeekScreen> createState() => _HabitWeekScreenState();
}

class _HabitWeekScreenState extends ConsumerState<HabitWeekScreen> {
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
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to load habits: $e')));
      }
    }
  }

  List<DateTime> _getWeekDates(DateTime date) {
    final weekStart = date.subtract(Duration(days: date.weekday - 1));
    return List.generate(7, (i) => weekStart.add(Duration(days: i)));
  }

  Future<void> _toggleHabit(int habitId, DateTime date) async {
    try {
      await ref
          .read(habitsNotifierProvider.notifier)
          .toggleHabitLog(habitId, date);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to toggle habit: $e')));
      }
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(habitsNotifierProvider);
    final habits = state.activeHabits;
    final weekDates = _getWeekDates(_selectedDate);

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
          const PeriodTabs(currentPeriod: 'week', feature: 'habits'),
          WeekNavigator(
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
                : _buildContent(state, habits, weekDates),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(state, List habits, List<DateTime> weekDates) {
    if (state.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text('Error: ${state.error}'),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _loadData, child: const Text('Retry')),
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

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row with day names
              Row(
                children: [
                  const SizedBox(width: 100), // Space for habit names
                  ...weekDates.map((date) {
                    final dayName = [
                      'Mon',
                      'Tue',
                      'Wed',
                      'Thu',
                      'Fri',
                      'Sat',
                      'Sun',
                    ][date.weekday - 1];
                    return SizedBox(
                      width: 48,
                      child: Center(
                        child: InkWell(
                          borderRadius: BorderRadius.circular(6),
                          onTap: () => context.go(
                            '/habits/day?date=${_formatDate(date)}',
                          ),
                          child: Column(
                            children: [
                              Text(
                                dayName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
                                ),
                              ),
                              Text(
                                DateFormat('MMM d').format(date),
                                style: const TextStyle(fontSize: 9),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ),
              const SizedBox(height: 8),
              const Divider(),
              // Habit rows
              ...habits.map((habit) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 100,
                        child: Text(
                          habit.name,
                          style: const TextStyle(fontSize: 12),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                      ...weekDates.map((date) {
                        final key = '${habit.id}_${_formatDate(date)}';
                        final isCompleted = ref.watch(
                          habitsNotifierProvider.select(
                            (state) => state.optimisticToggles[key] ?? false,
                          ),
                        );
                        final isPending = ref.watch(
                          habitsNotifierProvider.select(
                            (state) => state.pendingToggles.contains(key),
                          ),
                        );
                        return SizedBox(
                          width: 48,
                          height: 40,
                          child: Center(
                            child: InkWell(
                              onTap: isPending
                                  ? null
                                  : () => _toggleHabit(habit.id, date),
                              borderRadius: BorderRadius.circular(6),
                              child: Opacity(
                                opacity: isPending ? 0.5 : 1.0,
                                child: Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: isCompleted
                                        ? Colors.green.withValues(alpha: 0.2)
                                        : Colors.grey.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                      color: isCompleted
                                          ? Colors.green
                                          : Colors.grey,
                                      width: 2,
                                    ),
                                  ),
                                  child: Icon(
                                    isCompleted ? Icons.check : Icons.close,
                                    color: isCompleted
                                        ? Colors.green
                                        : Colors.grey,
                                    size: 20,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
