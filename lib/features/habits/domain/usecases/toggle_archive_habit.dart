import '../entities/habit.dart';
import '../repositories/habit_repository.dart';

class ToggleArchiveHabitUseCase {
  final HabitRepository repository;

  const ToggleArchiveHabitUseCase(this.repository);

  Future<Habit> call(int id) {
    return repository.toggleArchive(id);
  }
}
