import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/presentation/widgets/month_navigator.dart';
import '../../../../core/presentation/widgets/period_tabs.dart';
import '../providers/sleep_provider.dart';

class SleepMonthScreen extends ConsumerStatefulWidget {
  const SleepMonthScreen({super.key});

  @override
  ConsumerState<SleepMonthScreen> createState() => _SleepMonthScreenState();
}

class _SleepMonthScreenState extends ConsumerState<SleepMonthScreen> {
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
      await ref.read(sleepNotifierProvider.notifier).loadSleepLogs();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load sleep logs: $e')),
        );
      }
    }
  }

  List<DateTime> _getDaysInMonth(DateTime date) {
    final firstDay = DateTime(date.year, date.month, 1);
    final lastDay = DateTime(date.year, date.month + 1, 0);
    return List.generate(lastDay.day, (i) => firstDay.add(Duration(days: i)));
  }

  Color _getSleepColor(Duration? duration, ThemeData theme) {
    if (duration == null) return _getEmptyDayColor(theme);
    final hours = duration.inMinutes / 60.0;
    if (hours >= 7 && hours <= 9) return Colors.green.shade300;
    if ((hours >= 5 && hours < 7) || (hours > 9 && hours <= 10)) {
      return Colors.yellow.shade300;
    }
    return Colors.red.shade300;
  }

  Color _getEmptyDayColor(ThemeData theme) {
    return theme.brightness == Brightness.dark
        ? Colors.grey.shade800
        : Colors.grey.shade200;
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(sleepNotifierProvider);
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
          const PeriodTabs(currentPeriod: 'month', feature: 'sleep'),
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
                final duration = log?.duration;
                final theme = Theme.of(context);
                final hasData = duration != null;
                final dayTextColor =
                    !hasData && theme.brightness == Brightness.dark
                        ? Colors.white
                        : theme.colorScheme.onSurface;

                return InkWell(
                  onTap: () {
                    context.go('/sleep/day?date=${_formatDateParam(date)}');
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: _getSleepColor(duration, theme),
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
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: dayTextColor,
                          ),
                        ),
                        if (duration != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            '${duration.inHours}h ${duration.inMinutes % 60}m',
                            style: TextStyle(
                              fontSize: 9,
                              color: theme.colorScheme.onSurface,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          // Legend
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildLegendItem('7-9h', Colors.green.shade300),
                  _buildLegendItem('5-7h, 9-10h', Colors.yellow.shade300),
                  _buildLegendItem('<5h, >10h', Colors.red.shade300),
                  _buildLegendItem(
                    'No data',
                    _getEmptyDayColor(Theme.of(context)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: Colors.grey.shade400),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ],
    );
  }
}
