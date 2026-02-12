import 'package:flutter/foundation.dart';
import '../../domain/entities/habit.dart';
import '../../domain/repositories/habit_repository.dart';
import '../datasources/habits_remote_datasource.dart';

class HabitRepositoryImpl implements HabitRepository {
  final HabitsRemoteDatasource remoteDatasource;

  const HabitRepositoryImpl(this.remoteDatasource);

  @override
  Future<List<Habit>> getHabits() async {
    final dtos = await remoteDatasource.getHabits();
    return dtos.map((dto) => dto.toEntity()).toList();
  }

  @override
  Future<({List<Habit> habits, Map<String, bool> completions})>
      getHabitsWithCompletions() async {
    debugPrint('📋 HabitRepository: Fetching habits with completions...');
    final dtos = await remoteDatasource.getHabits();

    final habits = dtos.map((dto) => dto.toEntity()).toList();

    // Merge all completion maps from all habits
    final completions = <String, bool>{};
    for (final dto in dtos) {
      completions.addAll(dto.getCompletionMap());
    }

    debugPrint(
      '✅ HabitRepository: Loaded ${habits.length} habits with ${completions.length} completions',
    );
    return (habits: habits, completions: completions);
  }

  @override
  Future<Habit> createHabit(String name) async {
    final dto = await remoteDatasource.createHabit(name);
    return dto.toEntity();
  }

  @override
  Future<Habit> updateHabit(int id, String name) async {
    final dto = await remoteDatasource.updateHabit(id, name);
    return dto.toEntity();
  }

  @override
  Future<void> deleteHabit(int id) async {
    await remoteDatasource.deleteHabit(id);
  }

  @override
  Future<Habit> toggleArchive(int id) async {
    final dto = await remoteDatasource.toggleArchive(id);
    return dto.toEntity();
  }

  @override
  Future<bool> toggleHabitLog(int habitId, DateTime date) async {
    return await remoteDatasource.toggleHabitLog(habitId, date);
  }
}
