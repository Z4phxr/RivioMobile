import '../../../../core/network/api_client.dart';
import '../../../../core/config/api_config.dart';
import '../models/habit_dto.dart';

class HabitsRemoteDatasource {
  final ApiClient apiClient;

  const HabitsRemoteDatasource(this.apiClient);

  /// GET /api/habits/ - Fetch all habits with their logs
  Future<List<HabitDto>> getHabits() async {
    final response = await apiClient.get(ApiConfig.habits);
    final List<dynamic> habitsJson = response.data as List<dynamic>;
    return habitsJson
        .map((json) => HabitDto.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// POST /api/habits/add_habit/ - Create new habit
  Future<HabitDto> createHabit(String name) async {
    final response = await apiClient.post(
      ApiConfig.habitsAdd,
      data: {'name': name},
    );
    return HabitDto.fromJson(response.data as Map<String, dynamic>);
  }

  /// PATCH /api/habits/update/<id>/ - Update habit name
  Future<HabitDto> updateHabit(int id, String name) async {
    final response = await apiClient.patch(
      ApiConfig.habitsUpdate(id),
      data: {'name': name},
    );
    return HabitDto.fromJson(response.data as Map<String, dynamic>);
  }

  /// DELETE /api/habits/delete/<id>/ - Delete habit and all logs
  Future<void> deleteHabit(int id) async {
    await apiClient.delete(ApiConfig.habitsDelete(id));
  }

  /// PATCH /api/habits/archive/<id>/ - Toggle archive status
  Future<HabitDto> toggleArchive(int id) async {
    final response = await apiClient.patch(
      ApiConfig.habitsArchive(id),
      data: {}, // Send empty object to satisfy PATCH requirements
    );
    return HabitDto.fromJson(response.data as Map<String, dynamic>);
  }

  /// POST /api/habits/toggle/ - Toggle habit log (create or delete)
  Future<bool> toggleHabitLog(int habitId, DateTime date) async {
    final dateStr = _formatDate(date);
    final response = await apiClient.post(
      ApiConfig.habitsToggle,
      data: {
        'habit_id': habitId,
        'date': dateStr,
      },
    );

    // Response is either 201 (created) or 204 (removed)
    return response.statusCode == 201;
  }

  String _formatDate(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
