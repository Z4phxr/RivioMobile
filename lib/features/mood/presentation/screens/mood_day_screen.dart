import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/presentation/widgets/date_navigator.dart';
import '../../../../core/presentation/widgets/period_tabs.dart';
import '../providers/mood_provider.dart';
import '../../domain/entities/mood_log.dart';

class MoodDayScreen extends ConsumerStatefulWidget {
  final DateTime? initialDate;

  const MoodDayScreen({super.key, this.initialDate});

  @override
  ConsumerState<MoodDayScreen> createState() => _MoodDayScreenState();
}

class _MoodDayScreenState extends ConsumerState<MoodDayScreen> {
  DateTime _selectedDate = DateTime.now();
  int? _selectedMood;
  final TextEditingController _noteController = TextEditingController();

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

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      await ref.read(moodNotifierProvider.notifier).loadMoodLogs();
      _updateMoodFromLog();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to load mood logs: $e')));
      }
    }
  }

  void _updateMoodFromLog() {
    final state = ref.read(moodNotifierProvider);
    final log = state.getLogForDate(_selectedDate);

    if (log != null) {
      setState(() {
        _selectedMood = log.mood;
        _noteController.text = log.note ?? '';
      });
    } else {
      setState(() {
        _selectedMood = null;
        _noteController.clear();
      });
    }
  }

  Color _getMoodColor(int mood) {
    if (mood <= 5) {
      // Red to Yellow (mood 1-5)
      final ratio = (mood - 1) / 4;
      return Color.lerp(Colors.red, Colors.yellow, ratio)!;
    } else {
      // Yellow to Green (mood 6-10)
      final ratio = (mood - 6) / 4;
      return Color.lerp(Colors.yellow, Colors.green, ratio)!;
    }
  }

  Future<void> _saveMood() async {
    if (_selectedMood == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select a mood')));
      return;
    }

    try {
      await ref.read(moodNotifierProvider.notifier).saveMoodLog(
            date: _selectedDate,
            mood: _selectedMood!,
            note: _noteController.text.isEmpty ? null : _noteController.text,
          );
      _updateMoodFromLog();
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Mood saved')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to save: $e')));
      }
    }
  }

  Future<void> _deleteMood() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Mood Log'),
        content: const Text('Are you sure you want to delete this mood log?'),
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
        await ref
            .read(moodNotifierProvider.notifier)
            .deleteMoodDay(_selectedDate);
        setState(() {
          _selectedMood = null;
          _noteController.clear();
        });
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Mood log deleted')));
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Failed to delete: $e')));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(moodNotifierProvider);
    final log = state.getLogForDate(_selectedDate);

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
          const PeriodTabs(currentPeriod: 'day', feature: 'mood'),
          DateNavigator(
            selectedDate: _selectedDate,
            onDateChanged: (date) {
              setState(() {
                _selectedDate = date;
              });
              _updateMoodFromLog();
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
                    'How are you feeling?',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  if (_selectedMood != null) ...[
                    Text(
                      MoodLog.getEmojiForMood(_selectedMood!),
                      style: const TextStyle(fontSize: 64),
                    ),
                    const SizedBox(height: 8),
                  ],
                  const SizedBox(height: 16),
                  Text(
                    'Select your mood (1-10)',
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Mood selector grid (2 rows x 5 columns)
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 5,
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 8,
                      childAspectRatio: 1.2,
                    ),
                    itemCount: 10,
                    itemBuilder: (context, index) {
                      final mood = index + 1;
                      final isSelected =
                          _selectedMood != null && mood <= _selectedMood!;
                      final theme = Theme.of(context);
                      // Use the color of the selected mood for ALL filled blocks
                      final color = _selectedMood != null
                          ? _getMoodColor(_selectedMood!)
                          : theme.colorScheme.surfaceContainerHighest;

                      // Unselected blocks: use a slightly tinted background for better visibility
                      final unselectedBg = theme.brightness == Brightness.dark
                          ? Colors.grey.shade700
                          : Colors.grey.shade300;

                      return FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: isSelected ? color : unselectedBg,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          setState(() {
                            _selectedMood = mood;
                          });
                        },
                        child: Text(
                          '$mood',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Notes (optional)',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _noteController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: (log?.note == null || log!.note!.trim().isEmpty)
                          ? 'How was your day?'
                          : null,
                      border: const OutlineInputBorder(),
                    ),
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
                  onPressed: _saveMood,
                  icon: const Icon(Icons.save),
                  label: const Text('Save Mood'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
              if (log != null) ...[
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: _deleteMood,
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
