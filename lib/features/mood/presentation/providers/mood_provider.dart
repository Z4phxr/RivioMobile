import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';
import '../../domain/entities/mood_log.dart';
import '../../domain/repositories/mood_repository.dart';
import '../../domain/usecases/get_mood_logs.dart';
import '../../domain/usecases/create_or_update_mood_log.dart';
import '../../domain/usecases/delete_mood_day.dart';
import '../../data/datasources/mood_remote_datasource.dart';
import '../../data/repositories/mood_repository_impl.dart';

// Datasource provider
final moodRemoteDatasourceProvider = Provider<MoodRemoteDatasource>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return MoodRemoteDatasource(apiClient);
});

// Repository provider
final moodRepositoryProvider = Provider<MoodRepository>((ref) {
  final remoteDatasource = ref.watch(moodRemoteDatasourceProvider);
  return MoodRepositoryImpl(remoteDatasource);
});

// Use case providers
final getMoodLogsUseCaseProvider = Provider<GetMoodLogsUseCase>((ref) {
  final repository = ref.watch(moodRepositoryProvider);
  return GetMoodLogsUseCase(repository);
});

final createOrUpdateMoodLogUseCaseProvider =
    Provider<CreateOrUpdateMoodLogUseCase>((ref) {
      final repository = ref.watch(moodRepositoryProvider);
      return CreateOrUpdateMoodLogUseCase(repository);
    });

final deleteMoodDayUseCaseProvider = Provider<DeleteMoodDayUseCase>((ref) {
  final repository = ref.watch(moodRepositoryProvider);
  return DeleteMoodDayUseCase(repository);
});

// State
class MoodState {
  final List<MoodLog> logs;
  final bool isLoading;
  final String? error;

  const MoodState({this.logs = const [], this.isLoading = false, this.error});

  MoodState copyWith({List<MoodLog>? logs, bool? isLoading, String? error}) {
    return MoodState(
      logs: logs ?? this.logs,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  /// Get mood log for a specific date
  MoodLog? getLogForDate(DateTime date) {
    final dateOnly = DateTime(date.year, date.month, date.day);
    return logs.where((log) {
      final logDate = DateTime(log.date.year, log.date.month, log.date.day);
      return logDate == dateOnly;
    }).firstOrNull;
  }

  /// Get average mood for a list of logs
  double? getAverageMood(List<MoodLog> logs) {
    if (logs.isEmpty) return null;
    final totalMood = logs.fold<int>(0, (sum, log) => sum + log.mood);
    return totalMood / logs.length;
  }
}

// Notifier
class MoodNotifier extends StateNotifier<MoodState> {
  final GetMoodLogsUseCase getMoodLogsUseCase;
  final CreateOrUpdateMoodLogUseCase createOrUpdateMoodLogUseCase;
  final DeleteMoodDayUseCase deleteMoodDayUseCase;

  MoodNotifier({
    required this.getMoodLogsUseCase,
    required this.createOrUpdateMoodLogUseCase,
    required this.deleteMoodDayUseCase,
  }) : super(const MoodState());

  Future<void> loadMoodLogs() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final logs = await getMoodLogsUseCase();
      state = state.copyWith(logs: logs, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  Future<void> saveMoodLog({
    required DateTime date,
    required int mood,
    String? note,
  }) async {
    try {
      final log = await createOrUpdateMoodLogUseCase(
        date: date,
        mood: mood,
        note: note,
      );

      final normalizedDate = DateTime(date.year, date.month, date.day);
      final responseMissingDate = log.date == DateTime(0);
      final correctedLog = MoodLog(
        id: log.id,
        date: responseMissingDate ? normalizedDate : log.date,
        mood: log.mood,
        // Preserve the note we just saved if the response doesn't include it
        note: (note != null && note.isNotEmpty) ? note : log.note,
      );

      // Remove any existing log for the same date and add new one
      final dateOnly = normalizedDate;
      final updatedLogs = state.logs.where((existingLog) {
        final existingDate = DateTime(
          existingLog.date.year,
          existingLog.date.month,
          existingLog.date.day,
        );
        return existingDate != dateOnly;
      }).toList();
      updatedLogs.add(correctedLog);
      updatedLogs.sort(
        (a, b) => b.date.compareTo(a.date),
      ); // Sort by date descending
      state = state.copyWith(logs: updatedLogs);
    } catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }

  Future<void> deleteMoodDay(DateTime date) async {
    try {
      await deleteMoodDayUseCase(date);
      final dateOnly = DateTime(date.year, date.month, date.day);
      final updatedLogs = state.logs.where((log) {
        final logDate = DateTime(log.date.year, log.date.month, log.date.day);
        return logDate != dateOnly;
      }).toList();
      state = state.copyWith(logs: updatedLogs);
    } catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }
}

// Provider
final moodNotifierProvider = StateNotifierProvider<MoodNotifier, MoodState>((
  ref,
) {
  return MoodNotifier(
    getMoodLogsUseCase: ref.watch(getMoodLogsUseCaseProvider),
    createOrUpdateMoodLogUseCase: ref.watch(
      createOrUpdateMoodLogUseCaseProvider,
    ),
    deleteMoodDayUseCase: ref.watch(deleteMoodDayUseCaseProvider),
  );
});
