import '../entities/mood_log.dart';
import '../repositories/mood_repository.dart';

class CreateOrUpdateMoodLogUseCase {
  final MoodRepository repository;

  const CreateOrUpdateMoodLogUseCase(this.repository);

  Future<MoodLog> call({
    required DateTime date,
    required int mood,
    String? note,
  }) {
    return repository.createOrUpdateMoodLog(
      date: date,
      mood: mood,
      note: note,
    );
  }
}
