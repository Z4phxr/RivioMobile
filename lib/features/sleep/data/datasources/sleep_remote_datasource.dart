import '../../../../core/network/api_client.dart';
import '../../../../core/config/api_config.dart';
import '../models/sleep_log_dto.dart';

class SleepRemoteDatasource {
  final ApiClient apiClient;

  const SleepRemoteDatasource(this.apiClient);

  /// GET /api/sleep/ - Fetch all sleep logs
  Future<List<SleepLogDto>> getSleepLogs() async {
    final response = await apiClient.get(ApiConfig.sleep);
    final List<dynamic> logsJson = response.data as List<dynamic>;
    return logsJson
        .map((json) => SleepLogDto.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// POST /api/sleep/ - Create sleep log (auto-deletes overlapping)
  Future<SleepLogDto> createSleepLog(DateTime start, DateTime end) async {
    final request = SleepLogCreateRequest(start: start, end: end);
    final response = await apiClient.post(
      ApiConfig.sleep,
      data: request.toJson(),
    );
    return SleepLogDto.fromJson(response.data as Map<String, dynamic>);
  }

  /// DELETE /api/sleep/delete_day/?date=YYYY-MM-DD - Delete sleep log for date
  Future<int> deleteSleepDay(DateTime date) async {
    final dateStr = _formatDate(date);
    final response = await apiClient.delete(
      ApiConfig.buildUrlWithQuery(ApiConfig.sleepDeleteDay, {'date': dateStr}),
    );
    return response.data['deleted'] as int;
  }

  String _formatDate(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
