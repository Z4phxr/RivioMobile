import '../entities/habit.dart';

abstract class HabitRepository {
  /// Fetch all habits for the authenticated user
  Future<List<Habit>> getHabits();

  /// Fetch all habits with their completion logs
  /// Returns habits and a map of completions (habitId_date -> isCompleted)
  Future<({List<Habit> habits, Map<String, bool> completions})>
      getHabitsWithCompletions();

  /// Create a new habit
  Future<Habit> createHabit(String name);

  /// Update habit name
  Future<Habit> updateHabit(int id, String name);

  /// Delete habit and all associated logs
  Future<void> deleteHabit(int id);

  /// Toggle archive status
  Future<Habit> toggleArchive(int id);

  /// Toggle habit log for a specific date
  /// Returns true if log was created, false if removed
  Future<bool> toggleHabitLog(int habitId, DateTime date);
}
