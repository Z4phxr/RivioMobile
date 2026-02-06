import '../repositories/habit_repository.dart';

class DeleteHabitUseCase {
  final HabitRepository repository;

  const DeleteHabitUseCase(this.repository);

  Future<void> call(int id) {
    return repository.deleteHabit(id);
  }
}
