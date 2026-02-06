import '../entities/sleep_log.dart';

abstract class SleepRepository {
  /// Fetch all sleep logs for the authenticated user
  Future<List<SleepLog>> getSleepLogs();

  /// Create a sleep log (auto-deletes overlapping logs)
  Future<SleepLog> createSleepLog(DateTime start, DateTime end);

  /// Delete sleep log(s) for a specific date
  /// Returns count of deleted logs
  Future<int> deleteSleepDay(DateTime date);
}
