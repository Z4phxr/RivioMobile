import '../entities/habit.dart';
import '../repositories/habit_repository.dart';

class GetHabitsUseCase {
  final HabitRepository repository;

  const GetHabitsUseCase(this.repository);

  Future<List<Habit>> call() {
    return repository.getHabits();
  }

  /// Fetch habits with their completion logs
  Future<({List<Habit> habits, Map<String, bool> completions})>
      callWithCompletions() {
    return repository.getHabitsWithCompletions();
  }
}
