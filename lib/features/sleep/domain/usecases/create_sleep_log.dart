import '../entities/sleep_log.dart';
import '../repositories/sleep_repository.dart';

class CreateSleepLogUseCase {
  final SleepRepository repository;

  const CreateSleepLogUseCase(this.repository);

  Future<SleepLog> call(DateTime start, DateTime end) {
    return repository.createSleepLog(start, end);
  }
}
