import '../../../../core/network/api_client.dart';
import '../../../../core/config/api_config.dart';
import '../models/mood_log_dto.dart';

class MoodRemoteDatasource {
  final ApiClient apiClient;

  const MoodRemoteDatasource(this.apiClient);

  /// GET /api/mood/ - Fetch all mood logs
  Future<List<MoodLogDto>> getMoodLogs() async {
    final response = await apiClient.get(ApiConfig.mood);
    final List<dynamic> logsJson = response.data as List<dynamic>;
    return logsJson
        .map((json) => MoodLogDto.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// POST /api/mood/ - Create or update mood log (upsert)
  Future<MoodLogDto> createOrUpdateMoodLog({
    required DateTime date,
    required int mood,
    String? note,
  }) async {
    final request = MoodLogCreateRequest(
      date: date,
      mood: mood,
      note: note,
    );
    final response = await apiClient.post(
      ApiConfig.mood,
      data: request.toJson(),
    );
    return MoodLogDto.fromJson(response.data as Map<String, dynamic>);
  }

  /// DELETE /api/mood/delete_day/?date=YYYY-MM-DD - Delete mood log for date
  Future<int> deleteMoodDay(DateTime date) async {
    final dateStr = _formatDate(date);
    final response = await apiClient.delete(
      ApiConfig.buildUrlWithQuery(ApiConfig.moodDeleteDay, {'date': dateStr}),
    );
    return response.data['deleted'] as int;
  }

  String _formatDate(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
