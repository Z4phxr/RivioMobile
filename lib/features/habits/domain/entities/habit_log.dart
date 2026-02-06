class HabitLog {
  final int id;
  final int habitId;
  final DateTime date;
  final bool completed;

  const HabitLog({
    required this.id,
    required this.habitId,
    required this.date,
    required this.completed,
  });

  HabitLog copyWith({
    int? id,
    int? habitId,
    DateTime? date,
    bool? completed,
  }) {
    return HabitLog(
      id: id ?? this.id,
      habitId: habitId ?? this.habitId,
      date: date ?? this.date,
      completed: completed ?? this.completed,
    );
  }
}
