class Habit {
  final int id;
  final String name;
  final bool isArchived;
  final DateTime createdAt;

  const Habit({
    required this.id,
    required this.name,
    required this.isArchived,
    required this.createdAt,
  });

  Habit copyWith({
    int? id,
    String? name,
    bool? isArchived,
    DateTime? createdAt,
  }) {
    return Habit(
      id: id ?? this.id,
      name: name ?? this.name,
      isArchived: isArchived ?? this.isArchived,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
