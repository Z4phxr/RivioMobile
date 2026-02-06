import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/habits_provider.dart';

class EditHabitsScreen extends ConsumerStatefulWidget {
  const EditHabitsScreen({super.key});

  @override
  ConsumerState<EditHabitsScreen> createState() => _EditHabitsScreenState();
}

class _EditHabitsScreenState extends ConsumerState<EditHabitsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _habitNameController = TextEditingController();
  final Map<int, TextEditingController> _editControllers = {};

  @override
  void initState() {
    super.initState();
    Future.microtask(() => _loadHabits());
  }

  Future<void> _loadHabits() async {
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

  Future<void> _addHabit() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      await ref
          .read(habitsNotifierProvider.notifier)
          .createHabit(_habitNameController.text.trim());
      _habitNameController.clear();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Habit added successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add habit: $e')),
        );
      }
    }
  }

  Future<void> _updateHabit(int id, String newName) async {
    try {
      await ref.read(habitsNotifierProvider.notifier).updateHabit(id, newName);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Habit updated')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update habit: $e')),
        );
      }
    }
  }

  Future<void> _deleteHabit(int id, String name) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Habit'),
        content:
            Text('Delete "$name" and all its logs? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('DELETE'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await ref.read(habitsNotifierProvider.notifier).deleteHabit(id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Habit deleted')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to delete habit: $e')),
          );
        }
      }
    }
  }

  Future<void> _toggleArchive(int id) async {
    try {
      await ref.read(habitsNotifierProvider.notifier).toggleArchive(id);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to toggle archive: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _habitNameController.dispose();
    for (var controller in _editControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(habitsNotifierProvider);

    return Scaffold(
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Add new habit form
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              'Add New Habit',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _habitNameController,
                              decoration: const InputDecoration(
                                labelText: 'Habit name',
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Please enter a habit name';
                                }
                                return null;
                              },
                              onFieldSubmitted: (_) => _addHabit(),
                            ),
                            const SizedBox(height: 12),
                            FilledButton(
                              onPressed: _addHabit,
                              child: const Text('ADD HABIT'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Active habits
                  if (state.activeHabits.isNotEmpty) ...[
                    Text(
                      'Active Habits',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    ...state.activeHabits
                        .map((habit) => _buildHabitCard(habit, false)),
                  ],

                  // Archived habits
                  if (state.archivedHabits.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    Text(
                      'Archived Habits',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    ...state.archivedHabits
                        .map((habit) => _buildHabitCard(habit, true)),
                  ],

                  // Empty state
                  if (state.activeHabits.isEmpty &&
                      state.archivedHabits.isEmpty)
                    Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        children: [
                          Icon(
                            Icons.check_circle_outline,
                            size: 64,
                            color: Theme.of(context)
                                .colorScheme
                                .primary
                                .withValues(alpha: 0.5),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No habits yet',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Add your first habit using the form above',
                            style: Theme.of(context).textTheme.bodyMedium,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
    );
  }

  Widget _buildHabitCard(habit, bool isArchived) {
    final controller = _editControllers.putIfAbsent(
      habit.id,
      () => TextEditingController(text: habit.name),
    );

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                onSubmitted: (value) => _updateHabit(habit.id, value),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: () => _updateHabit(habit.id, controller.text),
              tooltip: 'Save',
            ),
            IconButton(
              icon: Icon(isArchived ? Icons.unarchive : Icons.archive),
              onPressed: () => _toggleArchive(habit.id),
              tooltip: isArchived ? 'Unarchive' : 'Archive',
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              color: Colors.red,
              onPressed: () => _deleteHabit(habit.id, habit.name),
              tooltip: 'Delete',
            ),
          ],
        ),
      ),
    );
  }
}
