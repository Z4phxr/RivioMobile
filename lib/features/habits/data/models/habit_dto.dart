import '../../domain/entities/habit.dart';
import 'habit_log_dto.dart';

class HabitDto {
  final int id;
  final String name;
  final bool isArchived;
  final DateTime createdAt;
  final List<HabitLogDto>? logs; // Optional logs array from backend

  const HabitDto({
    required this.id,
    required this.name,
    required this.isArchived,
    required this.createdAt,
    this.logs,
  });

  factory HabitDto.fromJson(Map<String, dynamic> json) {
    // Parse logs array if present
    List<HabitLogDto>? logs;
    if (json['logs'] != null) {
      final logsJson = json['logs'] as List<dynamic>;
      logs = logsJson
          .map((log) => HabitLogDto.fromJson(log as Map<String, dynamic>))
          .toList();
    }

    return HabitDto(
      id: json['id'] as int,
      name: json['name'] as String,
      isArchived: json['archived'] as bool,
      createdAt: DateTime.parse(json['created_at'] as String),
      logs: logs,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'archived': isArchived,
      'created_at': createdAt.toIso8601String(),
      if (logs != null) 'logs': logs!.map((log) => log.toJson()).toList(),
    };
  }

  Habit toEntity() => Habit(
        id: id,
        name: name,
        isArchived: isArchived,
        createdAt: createdAt,
      );

  /// Extract completion map from logs (habitId_date -> isCompleted)
  Map<String, bool> getCompletionMap() {
    if (logs == null) return {};
    
    final completionMap = <String, bool>{};
    for (final log in logs!) {
      final dateStr = _formatDate(log.date);
      final key = '${log.habitId}_$dateStr';
      completionMap[key] = log.completed;
    }
    return completionMap;
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
