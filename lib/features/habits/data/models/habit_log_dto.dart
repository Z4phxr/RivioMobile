import '../../domain/entities/habit_log.dart';

class HabitLogDto {
  final int id;
  final int habitId;
  final DateTime date;
  final bool completed;

  const HabitLogDto({
    required this.id,
    required this.habitId,
    required this.date,
    required this.completed,
  });

  factory HabitLogDto.fromJson(Map<String, dynamic> json) {
    return HabitLogDto(
      id: json['id'] as int,
      habitId: json['habit'] as int,
      date: DateTime.parse(json['date'] as String),
      completed: json['completed'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'habit': habitId,
      'date': _formatDate(date),
      'completed': completed,
    };
  }

  String _formatDate(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  HabitLog toEntity() => HabitLog(
        id: id,
        habitId: habitId,
        date: date,
        completed: completed,
      );
}
