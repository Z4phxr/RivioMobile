import '../entities/habit.dart';
import '../repositories/habit_repository.dart';

class CreateHabitUseCase {
  final HabitRepository repository;

  const CreateHabitUseCase(this.repository);

  Future<Habit> call(String name) {
    return repository.createHabit(name);
  }
}
