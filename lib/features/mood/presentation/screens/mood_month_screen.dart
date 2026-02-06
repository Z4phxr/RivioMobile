import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/presentation/widgets/month_navigator.dart';
import '../../../../core/presentation/widgets/period_tabs.dart';
import '../providers/mood_provider.dart';

class MoodMonthScreen extends ConsumerStatefulWidget {
  const MoodMonthScreen({super.key});

  @override
  ConsumerState<MoodMonthScreen> createState() => _MoodMonthScreenState();
}

class _MoodMonthScreenState extends ConsumerState<MoodMonthScreen> {
  DateTime _selectedDate = DateTime.now();

  String _formatDateParam(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  @override
  void initState() {
    super.initState();
    Future.microtask(() => _loadData());
  }

  Future<void> _loadData() async {
    try {
      await ref.read(moodNotifierProvider.notifier).loadMoodLogs();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load mood logs: $e')),
        );
      }
    }
  }

  List<DateTime> _getDaysInMonth(DateTime date) {
    final firstDay = DateTime(date.year, date.month, 1);
    final lastDay = DateTime(date.year, date.month + 1, 0);
    return List.generate(lastDay.day, (i) => firstDay.add(Duration(days: i)));
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(moodNotifierProvider);
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
          const PeriodTabs(currentPeriod: 'month', feature: 'mood'),
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
                : _buildContent(state, monthDays),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(state, List<DateTime> monthDays) {
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
                final log = state.getLogForDate(date);

                final theme = Theme.of(context);
                Color backgroundColor = theme.brightness == Brightness.dark
                    ? Colors.grey.shade800
                    : Colors.grey.shade200;
                if (log != null) {
                  final moodColor = log.color;
                  backgroundColor = Color.fromRGBO(
                    moodColor.r,
                    moodColor.g,
                    moodColor.b,
                    0.5,
                  );
                }
                final dayHasNote =
                    log?.note != null && log!.note!.trim().isNotEmpty;
                const dayNumberColor = Colors.white;

                return InkWell(
                  onTap: () {
                    context.go('/mood/day?date=${_formatDateParam(date)}');
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: backgroundColor,
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
                    child: Stack(
                      children: [
                        // Day number pinned to top-left
                        Positioned(
                          top: 4,
                          left: 4,
                          child: Text(
                            '${date.day}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: dayNumberColor,
                            ),
                          ),
                        ),
                        if (dayHasNote)
                          Positioned(
                            top: 4,
                            right: 4,
                            child: Icon(
                              Icons.chat_bubble_outline,
                              size: 14,
                              color: Colors.white.withValues(alpha: 0.9),
                            ),
                          ),
                        // Mood emoji centered
                        if (log != null)
                          Center(
                            child: Text(
                              log.emoji,
                              style: const TextStyle(fontSize: 24),
                            ),
                          ),
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
