import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/presentation/widgets/date_navigator.dart';
import '../providers/sleep_provider.dart';

class SleepDayScreen extends ConsumerStatefulWidget {
  const SleepDayScreen({super.key});

  @override
  ConsumerState<SleepDayScreen> createState() => _SleepDayScreenState();
}

class _SleepDayScreenState extends ConsumerState<SleepDayScreen> {
  DateTime _selectedDate = DateTime.now();
  RangeValues _sleepRange = const RangeValues(1380, 450); // 23:00 to 07:30

  @override
  void initState() {
    super.initState();
    Future.microtask(() => _loadData());
  }

  Future<void> _loadData() async {
    try {
      await ref.read(sleepNotifierProvider.notifier).loadSleepLogs();
      _updateRangeFromLog();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load sleep logs: $e')),
        );
      }
    }
  }

  void _updateRangeFromLog() {
    final state = ref.read(sleepNotifierProvider);
    final log = state.getLogForDate(_selectedDate);

    if (log != null) {
      final startMinutes = log.start.hour * 60 + log.start.minute;
      var endMinutes = log.end.hour * 60 + log.end.minute;

      // If end is before start, it crossed midnight
      if (log.end.isBefore(log.start) ||
          (log.end.day != log.start.day && endMinutes < startMinutes)) {
        endMinutes += 1440;
      }

      setState(() {
        _sleepRange = RangeValues(
          startMinutes.toDouble(),
          endMinutes.toDouble(),
        );
      });
    }
  }

  Future<void> _saveSleep() async {
    final startMinutes = _sleepRange.start.round();
    final endMinutes = _sleepRange.end.round();

    // Validate duration (30 min to 24 hours)
    var duration = endMinutes - startMinutes;
    if (duration < 0) duration += 1440;

    if (duration < 30) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sleep duration must be at least 30 minutes'),
        ),
      );
      return;
    }

    if (duration > 1440) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sleep duration cannot exceed 24 hours')),
      );
      return;
    }

    var normalizedEndMinutes = endMinutes;
    if (normalizedEndMinutes <= startMinutes) {
      normalizedEndMinutes += 1440; // Next day
    }

    DateTime start = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
    ).add(Duration(minutes: startMinutes));
    DateTime end = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
    ).add(Duration(minutes: normalizedEndMinutes));

    try {
      await ref.read(sleepNotifierProvider.notifier).createSleepLog(start, end);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Sleep log saved')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to save: $e')));
      }
    }
  }

  Future<void> _deleteSleep() async {
    // Get the actual sleep log to delete
    final state = ref.read(sleepNotifierProvider);
    final log = state.getLogForDate(_selectedDate);

    if (log == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('No sleep log to delete')));
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Sleep Log'),
        content: const Text('Are you sure you want to delete this sleep log?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final deleteDate = DateTime(
          log.end.toUtc().year,
          log.end.toUtc().month,
          log.end.toUtc().day,
        );
        // Backend deletes by the wake date (end date), so use log.end
        await ref
            .read(sleepNotifierProvider.notifier)
            .deleteSleepDay(deleteDate);
        // Reload to ensure UI matches backend
        await ref.read(sleepNotifierProvider.notifier).loadSleepLogs();
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Sleep log deleted')));
        }
        _updateRangeFromLog();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Failed to delete: $e')));
        }
      }
    }
  }

  String _formatTime(double minutes) {
    final totalMinutes = minutes.round();
    final hours = totalMinutes ~/ 60;
    final mins = totalMinutes % 60;
    final displayHours = hours % 24;
    final nextDay = hours >= 24 ? ' +1' : '';
    return '${displayHours.toString().padLeft(2, '0')}:${mins.toString().padLeft(2, '0')}$nextDay';
  }

  String _formatDuration(double start, double end) {
    var durationMinutes = end - start;
    if (durationMinutes < 0) durationMinutes += 1440;
    final hours = durationMinutes ~/ 60;
    final minutes = (durationMinutes % 60).round();
    return '${hours}h ${minutes}m';
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(sleepNotifierProvider);
    final log = state.getLogForDate(_selectedDate);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Rivio'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadData),
        ],
      ),
      body: Column(
        children: [
          DateNavigator(
            selectedDate: _selectedDate,
            onDateChanged: (date) {
              setState(() {
                _selectedDate = date;
              });
              _updateRangeFromLog();
            },
          ),
          const Divider(),
          Expanded(
            child: state.isLoading
                ? const Center(child: CircularProgressIndicator())
                : _buildContent(state, log),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(state, log) {
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

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Text(
                    'Sleep Time',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        children: [
                          const Text('Bedtime', style: TextStyle(fontSize: 12)),
                          const SizedBox(height: 4),
                          Text(
                            _formatTime(_sleepRange.start),
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const Icon(Icons.arrow_forward, size: 32),
                      Column(
                        children: [
                          const Text('Wake up', style: TextStyle(fontSize: 12)),
                          const SizedBox(height: 4),
                          Text(
                            _formatTime(_sleepRange.end),
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Duration: ${_formatDuration(_sleepRange.start, _sleepRange.end)}',
                    style: TextStyle(
                      fontSize: 18,
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text('Bedtime', style: TextStyle(fontSize: 12)),
                  RangeSlider(
                    values: RangeValues(
                      _sleepRange.start,
                      _sleepRange.start < 1440 ? 1440 : 2880,
                    ),
                    min: 0,
                    max: 2880,
                    divisions: 288,
                    onChanged: (values) {
                      setState(() {
                        _sleepRange = RangeValues(
                          values.start,
                          _sleepRange.end,
                        );
                      });
                    },
                  ),
                  const Text('Wake time', style: TextStyle(fontSize: 12)),
                  RangeSlider(
                    values: RangeValues(0, _sleepRange.end),
                    min: 0,
                    max: 2880,
                    divisions: 288,
                    onChanged: (values) {
                      setState(() {
                        _sleepRange = RangeValues(
                          _sleepRange.start,
                          values.end,
                        );
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _saveSleep,
                  icon: const Icon(Icons.save),
                  label: const Text('Save Sleep Log'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
              if (log != null) ...[
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: _deleteSleep,
                  icon: const Icon(Icons.delete),
                  label: const Text('Delete'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 16,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
