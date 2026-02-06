import '../entities/mood_log.dart';
import '../repositories/mood_repository.dart';

class GetMoodLogsUseCase {
  final MoodRepository repository;

  const GetMoodLogsUseCase(this.repository);

  Future<List<MoodLog>> call() {
    return repository.getMoodLogs();
  }
}
