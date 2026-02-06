import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/presentation/widgets/date_navigator.dart';
import '../../../../core/presentation/widgets/period_tabs.dart';
import '../providers/sleep_provider.dart';

class SleepDayScreenSimple extends ConsumerStatefulWidget {
  final DateTime? initialDate;

  const SleepDayScreenSimple({super.key, this.initialDate});

  @override
  ConsumerState<SleepDayScreenSimple> createState() =>
      _SleepDayScreenSimpleState();
}

class _SleepDayScreenSimpleState extends ConsumerState<SleepDayScreenSimple> {
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _bedTime = const TimeOfDay(hour: 23, minute: 0);
  TimeOfDay _wakeTime = const TimeOfDay(hour: 7, minute: 30);

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
      await ref.read(sleepNotifierProvider.notifier).loadSleepLogs();
      _updateTimesFromLog();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load sleep logs: $e')),
        );
      }
    }
  }

  void _updateTimesFromLog() {
    final state = ref.read(sleepNotifierProvider);
    final log = state.getLogForDate(_selectedDate);

    if (log != null) {
      setState(() {
        _bedTime = TimeOfDay.fromDateTime(log.start);
        _wakeTime = TimeOfDay.fromDateTime(log.end);
      });
    } else {
      // Reset to defaults
      setState(() {
        _bedTime = const TimeOfDay(hour: 23, minute: 0);
        _wakeTime = const TimeOfDay(hour: 7, minute: 30);
      });
    }
  }

  Future<void> _selectBedTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: _bedTime,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );
    if (time != null) {
      setState(() {
        _bedTime = time;
      });
    }
  }

  Future<void> _selectWakeTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: _wakeTime,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );
    if (time != null) {
      setState(() {
        _wakeTime = time;
      });
    }
  }

  String _calculateDuration() {
    final bedMinutes = _bedTime.hour * 60 + _bedTime.minute;
    var wakeMinutes = _wakeTime.hour * 60 + _wakeTime.minute;

    // If wake time is before bed time, it's next day
    if (wakeMinutes <= bedMinutes) {
      wakeMinutes += 1440; // Add 24 hours
    }

    final durationMinutes = wakeMinutes - bedMinutes;
    final hours = durationMinutes ~/ 60;
    final minutes = durationMinutes % 60;

    return '${hours}h ${minutes}m';
  }

  Future<void> _saveSleep() async {
    // Create DateTime objects for start and end
    DateTime start = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _bedTime.hour,
      _bedTime.minute,
    );

    DateTime end = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _wakeTime.hour,
      _wakeTime.minute,
    );

    // If wake time is before bed time, add one day to wake time
    if (end.isBefore(start) || end.isAtSameMomentAs(start)) {
      end = end.add(const Duration(days: 1));
    }

    // Validate duration
    final duration = end.difference(start).inMinutes;
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

    try {
      await ref.read(sleepNotifierProvider.notifier).createSleepLog(start, end);
      // Reload data after save
      await ref.read(sleepNotifierProvider.notifier).loadSleepLogs();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sleep log saved')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save: $e')),
        );
      }
    }
  }

  Future<void> _deleteSleep() async {
    // Get the actual sleep log to delete
    final state = ref.read(sleepNotifierProvider);
    final log = state.getLogForDate(_selectedDate);

    if (log == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No sleep log to delete')),
      );
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
            style: TextButton.styleFrom(foregroundColor: Colors.red),
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
        // Reload data after delete
        await ref.read(sleepNotifierProvider.notifier).loadSleepLogs();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Sleep log deleted')),
          );
        }
        _updateTimesFromLog(); // Reset to defaults
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to delete: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(sleepNotifierProvider);
    final log = state.getLogForDate(_selectedDate);
    final hasLog = log != null;

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
          const PeriodTabs(currentPeriod: 'day', feature: 'sleep'),
          DateNavigator(
            selectedDate: _selectedDate,
            onDateChanged: (date) {
              setState(() {
                _selectedDate = date;
              });
              _updateTimesFromLog();
            },
          ),
          const Divider(),
          Expanded(
            child: state.isLoading
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Bed Time
                        Card(
                          child: ListTile(
                            leading:
                                const Icon(Icons.bedtime, color: Colors.indigo),
                            title: const Text('Bed Time'),
                            subtitle: Text(
                              _bedTime.format(context),
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            trailing: const Icon(Icons.access_time),
                            onTap: _selectBedTime,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Wake Time
                        Card(
                          child: ListTile(
                            leading: const Icon(
                              Icons.wb_sunny,
                              color: Colors.orange,
                            ),
                            title: const Text('Wake Time'),
                            subtitle: Text(
                              _wakeTime.format(context),
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            trailing: const Icon(Icons.access_time),
                            onTap: _selectWakeTime,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Duration
                        Card(
                          color: Colors.blue.shade50,
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              children: [
                                const Icon(
                                  Icons.schedule,
                                  size: 48,
                                  color: Colors.blue,
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  'Sleep Duration',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _calculateDuration(),
                                  style: const TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Save Button
                        ElevatedButton.icon(
                          onPressed: _saveSleep,
                          icon: const Icon(Icons.save),
                          label: Text(
                            hasLog ? 'Update Sleep Log' : 'Save Sleep Log',
                          ),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            textStyle: const TextStyle(fontSize: 16),
                          ),
                        ),

                        // Delete Button (only if log exists)
                        if (hasLog) ...[
                          const SizedBox(height: 8),
                          OutlinedButton.icon(
                            onPressed: _deleteSleep,
                            icon: const Icon(Icons.delete),
                            label: const Text('Delete Sleep Log'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.red,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              textStyle: const TextStyle(fontSize: 16),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
