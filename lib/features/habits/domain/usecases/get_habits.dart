import '../entities/habit.dart';
import '../repositories/habit_repository.dart';

class GetHabitsUseCase {
  final HabitRepository repository;

  const GetHabitsUseCase(this.repository);

  Future<List<Habit>> call() {
    return repository.getHabits();
  }
}
