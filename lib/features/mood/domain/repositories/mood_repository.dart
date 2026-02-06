import '../entities/mood_log.dart';

abstract class MoodRepository {
  /// Fetch all mood logs for the authenticated user
  Future<List<MoodLog>> getMoodLogs();

  /// Create or update mood log for a specific date (upsert)
  Future<MoodLog> createOrUpdateMoodLog({
    required DateTime date,
    required int mood,
    String? note,
  });

  /// Delete mood log for a specific date
  /// Returns count of deleted logs
  Future<int> deleteMoodDay(DateTime date);
}
