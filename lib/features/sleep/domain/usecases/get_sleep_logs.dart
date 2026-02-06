import '../entities/sleep_log.dart';
import '../repositories/sleep_repository.dart';

class GetSleepLogsUseCase {
  final SleepRepository repository;

  const GetSleepLogsUseCase(this.repository);

  Future<List<SleepLog>> call() {
    return repository.getSleepLogs();
  }
}
