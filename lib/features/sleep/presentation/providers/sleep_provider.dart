import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';
import '../../domain/entities/sleep_log.dart';
import '../../domain/repositories/sleep_repository.dart';
import '../../domain/usecases/get_sleep_logs.dart';
import '../../domain/usecases/create_sleep_log.dart';
import '../../domain/usecases/delete_sleep_day.dart';
import '../../data/datasources/sleep_remote_datasource.dart';
import '../../data/repositories/sleep_repository_impl.dart';

// Datasource provider
final sleepRemoteDatasourceProvider = Provider<SleepRemoteDatasource>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return SleepRemoteDatasource(apiClient);
});

// Repository provider
final sleepRepositoryProvider = Provider<SleepRepository>((ref) {
  final remoteDatasource = ref.watch(sleepRemoteDatasourceProvider);
  return SleepRepositoryImpl(remoteDatasource);
});

// Use case providers
final getSleepLogsUseCaseProvider = Provider<GetSleepLogsUseCase>((ref) {
  final repository = ref.watch(sleepRepositoryProvider);
  return GetSleepLogsUseCase(repository);
});

final createSleepLogUseCaseProvider = Provider<CreateSleepLogUseCase>((ref) {
  final repository = ref.watch(sleepRepositoryProvider);
  return CreateSleepLogUseCase(repository);
});

final deleteSleepDayUseCaseProvider = Provider<DeleteSleepDayUseCase>((ref) {
  final repository = ref.watch(sleepRepositoryProvider);
  return DeleteSleepDayUseCase(repository);
});

// State
class SleepState {
  final List<SleepLog> logs;
  final bool isLoading;
  final String? error;

  const SleepState({this.logs = const [], this.isLoading = false, this.error});

  SleepState copyWith({List<SleepLog>? logs, bool? isLoading, String? error}) {
    return SleepState(
      logs: logs ?? this.logs,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  /// Get sleep log for a specific date
  SleepLog? getLogForDate(DateTime date) {
    final dateOnly = DateTime(date.year, date.month, date.day);
    return logs.where((log) {
      final logDate = DateTime(
        log.sleepDate.year,
        log.sleepDate.month,
        log.sleepDate.day,
      );
      return logDate == dateOnly;
    }).firstOrNull;
  }

  /// Get average sleep duration for a list of logs
  Duration? getAverageDuration(List<SleepLog> logs) {
    if (logs.isEmpty) return null;
    final totalSeconds = logs.fold<int>(
      0,
      (sum, log) => sum + log.duration.inSeconds,
    );
    return Duration(seconds: totalSeconds ~/ logs.length);
  }
}

// Notifier
class SleepNotifier extends StateNotifier<SleepState> {
  final GetSleepLogsUseCase getSleepLogsUseCase;
  final CreateSleepLogUseCase createSleepLogUseCase;
  final DeleteSleepDayUseCase deleteSleepDayUseCase;

  SleepNotifier({
    required this.getSleepLogsUseCase,
    required this.createSleepLogUseCase,
    required this.deleteSleepDayUseCase,
  }) : super(const SleepState());

  Future<void> loadSleepLogs() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final logs = await getSleepLogsUseCase();
      state = state.copyWith(logs: logs, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  Future<void> createSleepLog(DateTime start, DateTime end) async {
    try {
      final log = await createSleepLogUseCase(start, end);
      // Remove any existing logs for the same date and add new one
      final dateOnly = DateTime(
        log.sleepDate.year,
        log.sleepDate.month,
        log.sleepDate.day,
      );
      final updatedLogs = state.logs.where((existingLog) {
        final existingDate = DateTime(
          existingLog.sleepDate.year,
          existingLog.sleepDate.month,
          existingLog.sleepDate.day,
        );
        return existingDate != dateOnly;
      }).toList();
      updatedLogs.add(log);
      updatedLogs.sort(
        (a, b) => b.end.compareTo(a.end),
      ); // Sort by end time descending
      state = state.copyWith(logs: updatedLogs);
    } catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }

  Future<void> deleteSleepDay(DateTime date) async {
    try {
      await deleteSleepDayUseCase(date);
      final dateOnly = DateTime(date.year, date.month, date.day);
      final updatedLogs = state.logs.where((log) {
        final logDate = DateTime(
          log.sleepDate.year,
          log.sleepDate.month,
          log.sleepDate.day,
        );
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
final sleepNotifierProvider = StateNotifierProvider<SleepNotifier, SleepState>((
  ref,
) {
  return SleepNotifier(
    getSleepLogsUseCase: ref.watch(getSleepLogsUseCaseProvider),
    createSleepLogUseCase: ref.watch(createSleepLogUseCaseProvider),
    deleteSleepDayUseCase: ref.watch(deleteSleepDayUseCaseProvider),
  );
});
