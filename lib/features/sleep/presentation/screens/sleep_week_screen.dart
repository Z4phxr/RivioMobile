import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/presentation/widgets/week_navigator.dart';
import '../../../../core/presentation/widgets/period_tabs.dart';
import '../providers/sleep_provider.dart';

class SleepWeekScreen extends ConsumerStatefulWidget {
  const SleepWeekScreen({super.key});

  @override
  ConsumerState<SleepWeekScreen> createState() => _SleepWeekScreenState();
}

class _SleepWeekScreenState extends ConsumerState<SleepWeekScreen> {
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

  List<DateTime> _getWeekDates(DateTime date) {
    final weekStart = date.subtract(Duration(days: date.weekday - 1));
    return List.generate(7, (i) => weekStart.add(Duration(days: i)));
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(sleepNotifierProvider);
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
          const PeriodTabs(currentPeriod: 'week', feature: 'sleep'),
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
                : _buildContent(state, weekDates),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(state, List<DateTime> weekDates) {
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

    final logs = weekDates.map((date) => state.getLogForDate(date)).toList();
    final hasData = logs.any((log) => log != null);

    if (!hasData) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.bedtime, size: 48, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No sleep data for this week',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            SizedBox(height: 8),
            Text(
              'Add sleep logs in the Day view',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    // Calculate average duration
    final logsWithData = logs.where((log) => log != null).toList();
    final avgDuration = logsWithData.isEmpty
        ? Duration.zero
        : Duration(
            milliseconds: logsWithData
                    .map((log) => log!.duration.inMilliseconds)
                    .reduce((a, b) => a + b) ~/
                logsWithData.length,
          );

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Average duration card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.schedule, color: Colors.blue),
                  const SizedBox(width: 8),
                  Text(
                    'Average: ${avgDuration.inHours}h ${avgDuration.inMinutes % 60}m',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Bar chart
          Expanded(
            child: BarChart(
              BarChartData(
                maxY: 12,
                minY: 0,
                barGroups: logs.asMap().entries.map((entry) {
                  final index = entry.key;
                  final log = entry.value;
                  // Parse duration from Duration object
                  final hours =
                      log != null ? log.duration.inMinutes / 60.0 : 0.0;

                  return BarChartGroupData(
                    x: index,
                    barRods: [
                      BarChartRodData(
                        toY: hours,
                        color: hours >= 7 && hours <= 9
                            ? Colors.green
                            : hours >= 5 && hours < 7 ||
                                    hours > 9 && hours <= 10
                                ? Colors.orange
                                : Colors.red,
                        width: 24,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(4),
                        ),
                      ),
                    ],
                  );
                }).toList(),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          '${value.toInt()}h',
                          style: const TextStyle(fontSize: 12),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        const days = [
                          'Mon',
                          'Tue',
                          'Wed',
                          'Thu',
                          'Fri',
                          'Sat',
                          'Sun',
                        ];
                        if (value.toInt() >= 0 && value.toInt() < 7) {
                          final log = logs[value.toInt()];
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  days[value.toInt()],
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                if (log != null) ...[
                                  const SizedBox(height: 2),
                                  Text(
                                    '${log.duration.inHours}h',
                                    style: const TextStyle(fontSize: 10),
                                  ),
                                ],
                              ],
                            ),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                gridData: const FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 2,
                ),
                borderData: FlBorderData(
                  show: true,
                  border: Border(
                    bottom: BorderSide(color: Colors.grey.shade300),
                    left: BorderSide(color: Colors.grey.shade300),
                  ),
                ),
                barTouchData: BarTouchData(
                  enabled: true,
                  touchCallback: (event, response) {
                    if (event is FlTapUpEvent) {
                      final spot = response?.spot;
                      if (spot == null) return;
                      final index = spot.touchedBarGroupIndex;
                      if (index < 0 || index >= weekDates.length) return;
                      final date = weekDates[index];
                      context.go('/sleep/day?date=${_formatDateParam(date)}');
                    }
                  },
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      final log = logs[groupIndex];
                      if (log == null) return null;
                      final hours = log.duration.inHours;
                      final minutes = log.duration.inMinutes % 60;
                      return BarTooltipItem(
                        '${hours}h ${minutes}m',
                        const TextStyle(color: Colors.white),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
