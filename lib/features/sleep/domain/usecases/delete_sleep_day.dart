import '../repositories/sleep_repository.dart';

class DeleteSleepDayUseCase {
  final SleepRepository repository;

  const DeleteSleepDayUseCase(this.repository);

  Future<int> call(DateTime date) {
    return repository.deleteSleepDay(date);
  }
}
