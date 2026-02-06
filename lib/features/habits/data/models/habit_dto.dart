import '../../domain/entities/habit.dart';

class HabitDto {
  final int id;
  final String name;
  final bool isArchived;
  final DateTime createdAt;

  const HabitDto({
    required this.id,
    required this.name,
    required this.isArchived,
    required this.createdAt,
  });

  factory HabitDto.fromJson(Map<String, dynamic> json) {
    return HabitDto(
      id: json['id'] as int,
      name: json['name'] as String,
      isArchived: json['archived'] as bool,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'archived': isArchived,
      'created_at': createdAt.toIso8601String(),
    };
  }

  Habit toEntity() => Habit(
        id: id,
        name: name,
        isArchived: isArchived,
        createdAt: createdAt,
      );
}
