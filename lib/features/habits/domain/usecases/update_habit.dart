import '../entities/habit.dart';
import '../repositories/habit_repository.dart';

class UpdateHabitUseCase {
  final HabitRepository repository;

  const UpdateHabitUseCase(this.repository);

  Future<Habit> call(int id, String name) {
    return repository.updateHabit(id, name);
  }
}
