import '../repositories/mood_repository.dart';

class DeleteMoodDayUseCase {
  final MoodRepository repository;

  const DeleteMoodDayUseCase(this.repository);

  Future<int> call(DateTime date) {
    return repository.deleteMoodDay(date);
  }
}
