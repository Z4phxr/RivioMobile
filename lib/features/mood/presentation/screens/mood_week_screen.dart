import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/presentation/widgets/week_navigator.dart';
import '../../../../core/presentation/widgets/period_tabs.dart';
import '../providers/mood_provider.dart';

class MoodWeekScreen extends ConsumerStatefulWidget {
  const MoodWeekScreen({super.key});

  @override
  ConsumerState<MoodWeekScreen> createState() => _MoodWeekScreenState();
}

class _MoodWeekScreenState extends ConsumerState<MoodWeekScreen> {
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
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to load mood logs: $e')));
      }
    }
  }

  List<DateTime> _getWeekDates(DateTime date) {
    final weekStart = date.subtract(Duration(days: date.weekday - 1));
    return List.generate(7, (i) => weekStart.add(Duration(days: i)));
  }

  String _getEmoji(int mood) {
    if (mood >= 1 && mood <= 3) return '😞';
    if (mood >= 4 && mood <= 7) return '😐';
    return '😊';
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(moodNotifierProvider);
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
          const PeriodTabs(currentPeriod: 'week', feature: 'mood'),
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
            ElevatedButton(onPressed: _loadData, child: const Text('Retry')),
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
            Icon(Icons.mood, size: 48, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No mood data for this week',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            SizedBox(height: 8),
            Text(
              'Add mood logs in the Day view',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    // Calculate average mood
    final logsWithData = logs.where((log) => log != null).toList();
    final avgMood = logsWithData.isEmpty
        ? 0.0
        : logsWithData.map((log) => log!.mood).reduce((a, b) => a + b) /
              logsWithData.length;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Average mood card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _getEmoji(avgMood.round()),
                    style: const TextStyle(fontSize: 32),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Average: ${avgMood.toStringAsFixed(1)}',
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
          // Line chart
          Expanded(
            child: LineChart(
              LineChartData(
                minY: 0,
                maxY: 10,
                lineBarsData: [
                  LineChartBarData(
                    spots: logs.asMap().entries.map((entry) {
                      final log = entry.value;
                      return FlSpot(
                        entry.key.toDouble(),
                        log?.mood.toDouble() ?? 0,
                      );
                    }).toList(),
                    isCurved: false,
                    color: Colors.purple,
                    barWidth: 3,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        final log = logs[index];
                        return FlDotCirclePainter(
                          radius: log != null ? 6 : 0,
                          color: Colors.purple,
                          strokeWidth: 2,
                          strokeColor: Colors.white,
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      color: Colors.purple.withValues(alpha: 0.1),
                    ),
                  ),
                ],
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      interval: 2,
                      getTitlesWidget: (value, meta) {
                        if (value == 0) return const Text('');
                        return Text(
                          value.toInt().toString(),
                          style: const TextStyle(fontSize: 12),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 50,
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
                                    _getEmoji(log.mood),
                                    style: const TextStyle(fontSize: 14),
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
                lineTouchData: LineTouchData(
                  enabled: true,
                  touchCallback: (event, response) {
                    if (event is FlTapUpEvent) {
                      final spots = response?.lineBarSpots;
                      if (spots == null || spots.isEmpty) return;
                      final index = spots.first.x.round();
                      if (index < 0 || index >= weekDates.length) return;
                      final date = weekDates[index];
                      context.go('/mood/day?date=${_formatDateParam(date)}');
                    }
                  },
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipItems: (touchedSpots) {
                      return touchedSpots.map((spot) {
                        final log = logs[spot.x.toInt()];
                        if (log == null) return null;
                        return LineTooltipItem(
                          '${_getEmoji(log.mood)} ${log.mood}',
                          const TextStyle(color: Colors.white),
                        );
                      }).toList();
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
