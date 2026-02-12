import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/presentation/widgets/date_navigator.dart';
import '../../../../core/presentation/widgets/period_tabs.dart';
import '../../../../core/providers/app_theme_provider.dart';
import '../providers/habits_provider.dart';

class HabitDayScreen extends ConsumerStatefulWidget {
  final DateTime? initialDate;

  const HabitDayScreen({super.key, this.initialDate});

  @override
  ConsumerState<HabitDayScreen> createState() => _HabitDayScreenState();
}

class _HabitDayScreenState extends ConsumerState<HabitDayScreen> {
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    if (widget.initialDate != null) {
      _selectedDate = DateTime(
        widget.initialDate!.year,
        widget.initialDate!.month,
        widget.initialDate!.day,
      );
    }
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

  Future<void> _toggleHabit(int habitId) async {
    try {
      await ref
          .read(habitsNotifierProvider.notifier)
          .toggleHabitLog(habitId, _selectedDate);
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
    final appTheme = ref.watch(appThemeProvider);

    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => context.go('/habits/edit'),
                  tooltip: 'Edit Habits',
                ),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: _loadData,
                  tooltip: 'Refresh',
                ),
              ],
            ),
          ),
          const PeriodTabs(currentPeriod: 'day', feature: 'habits'),
          DateNavigator(
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
                : _buildContent(state, habits, appTheme),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(state, List habits, appTheme) {
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

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: habits.length,
      itemBuilder: (context, index) {
        final habit = habits[index];
        // Use ref.watch to rebuild when state changes (including optimistic updates)
        final key = '${habit.id}_${_formatDate(_selectedDate)}';
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

        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            // Reduce opacity while pending to show it's being processed
            enabled: !isPending,
            leading: GestureDetector(
              onTap: isPending ? null : () => _toggleHabit(habit.id),
              child: Opacity(
                opacity: isPending ? 0.5 : 1.0,
                child: Icon(
                  isCompleted
                      ? Icons.check_circle
                      : Icons.radio_button_unchecked,
                  color: isCompleted ? appTheme.primaryColor : Colors.grey,
                  size: 32,
                ),
              ),
            ),
            title: Text(
              habit.name,
              style: TextStyle(
                fontSize: 16,
                decoration: isCompleted ? TextDecoration.lineThrough : null,
                color: isCompleted ? Colors.grey : null,
              ),
            ),
            onTap: () => _toggleHabit(habit.id),
          ),
        );
      },
    );
  }
}
