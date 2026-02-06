import '../repositories/habit_repository.dart';

class ToggleHabitLogUseCase {
  final HabitRepository repository;

  const ToggleHabitLogUseCase(this.repository);

  /// Toggle habit log for a specific date
  /// Returns true if log was created, false if removed
  Future<bool> call(int habitId, DateTime date) {
    return repository.toggleHabitLog(habitId, date);
  }
}
