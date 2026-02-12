import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';
import '../../domain/entities/habit.dart';
import '../../domain/repositories/habit_repository.dart';
import '../../domain/usecases/get_habits.dart';
import '../../domain/usecases/create_habit.dart';
import '../../domain/usecases/update_habit.dart';
import '../../domain/usecases/delete_habit.dart';
import '../../domain/usecases/toggle_archive_habit.dart';
import '../../domain/usecases/toggle_habit_log.dart';
import '../../data/datasources/habits_remote_datasource.dart';
import '../../data/datasources/habit_completion_storage.dart';
import '../../data/repositories/habit_repository_impl.dart';

// Storage provider
final habitCompletionStorageProvider = Provider<HabitCompletionStorageService>((
  ref,
) {
  return HabitCompletionStorageService();
});

// Datasource provider
final habitsRemoteDatasourceProvider = Provider<HabitsRemoteDatasource>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return HabitsRemoteDatasource(apiClient);
});

// Repository provider
final habitRepositoryProvider = Provider<HabitRepository>((ref) {
  final remoteDatasource = ref.watch(habitsRemoteDatasourceProvider);
  return HabitRepositoryImpl(remoteDatasource);
});

// Use case providers
final getHabitsUseCaseProvider = Provider<GetHabitsUseCase>((ref) {
  final repository = ref.watch(habitRepositoryProvider);
  return GetHabitsUseCase(repository);
});

final createHabitUseCaseProvider = Provider<CreateHabitUseCase>((ref) {
  final repository = ref.watch(habitRepositoryProvider);
  return CreateHabitUseCase(repository);
});

final updateHabitUseCaseProvider = Provider<UpdateHabitUseCase>((ref) {
  final repository = ref.watch(habitRepositoryProvider);
  return UpdateHabitUseCase(repository);
});

final deleteHabitUseCaseProvider = Provider<DeleteHabitUseCase>((ref) {
  final repository = ref.watch(habitRepositoryProvider);
  return DeleteHabitUseCase(repository);
});

final toggleArchiveHabitUseCaseProvider = Provider<ToggleArchiveHabitUseCase>((
  ref,
) {
  final repository = ref.watch(habitRepositoryProvider);
  return ToggleArchiveHabitUseCase(repository);
});

final toggleHabitLogUseCaseProvider = Provider<ToggleHabitLogUseCase>((ref) {
  final repository = ref.watch(habitRepositoryProvider);
  return ToggleHabitLogUseCase(repository);
});

// State
class HabitsState {
  final List<Habit> habits;
  final bool isLoading;
  final String? error;
  final Map<String, bool> optimisticToggles; // habitId_date -> isCompleted
  final Set<String> pendingToggles; // habitId_date keys currently being toggled

  const HabitsState({
    this.habits = const [],
    this.isLoading = false,
    this.error,
    this.optimisticToggles = const {},
    this.pendingToggles = const {},
  });

  HabitsState copyWith({
    List<Habit>? habits,
    bool? isLoading,
    String? error,
    Map<String, bool>? optimisticToggles,
    Set<String>? pendingToggles,
  }) {
    return HabitsState(
      habits: habits ?? this.habits,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      optimisticToggles: optimisticToggles ?? this.optimisticToggles,
      pendingToggles: pendingToggles ?? this.pendingToggles,
    );
  }

  List<Habit> get activeHabits => habits.where((h) => !h.isArchived).toList();

  List<Habit> get archivedHabits => habits.where((h) => h.isArchived).toList();
}

// Notifier
class HabitsNotifier extends StateNotifier<HabitsState> {
  final GetHabitsUseCase getHabitsUseCase;
  final CreateHabitUseCase createHabitUseCase;
  final UpdateHabitUseCase updateHabitUseCase;
  final DeleteHabitUseCase deleteHabitUseCase;
  final ToggleArchiveHabitUseCase toggleArchiveUseCase;
  final ToggleHabitLogUseCase toggleHabitLogUseCase;
  final HabitCompletionStorageService completionStorage;

  // Debounce storage saves to prevent race conditions with rapid toggles
  DateTime? _lastStorageSave;
  static const _storageSaveDebounce = Duration(milliseconds: 500);

  // Active toggle operations - synchronous lock to prevent race conditions
  final Set<String> _activeToggles = {};

  HabitsNotifier({
    required this.getHabitsUseCase,
    required this.createHabitUseCase,
    required this.updateHabitUseCase,
    required this.deleteHabitUseCase,
    required this.toggleArchiveUseCase,
    required this.toggleHabitLogUseCase,
    required this.completionStorage,
  }) : super(const HabitsState()) {
    debugPrint('🐛 HabitsNotifier: Initializing...');
    _loadCompletionsFromStorage();
  }

  /// Load persisted completions from storage
  Future<void> _loadCompletionsFromStorage() async {
    debugPrint('💾 HabitsNotifier: Loading completions from local storage...');
    final completions = await completionStorage.loadCompletions();
    debugPrint(
      '✅ HabitsNotifier: Loaded ${completions.length} completions from storage',
    );
    state = state.copyWith(optimisticToggles: completions);
  }

  Future<void> loadHabits({bool skipCompletions = false}) async {
    debugPrint(
      '📋 HabitsNotifier: Loading habits (skipCompletions: $skipCompletions)...',
    );
    state = state.copyWith(isLoading: true, error: null);
    try {
      if (skipCompletions) {
        // Just load habits without completions
        final habits = await getHabitsUseCase();
        debugPrint('✅ HabitsNotifier: Loaded ${habits.length} habits');
        state = state.copyWith(habits: habits, isLoading: false);
      } else {
        // Load habits WITH completions from server
        final result = await getHabitsUseCase.callWithCompletions();
        debugPrint(
          '✅ HabitsNotifier: Loaded ${result.habits.length} habits with ${result.completions.length} server completions',
        );

        // Merge server completions with local optimistic updates
        final mergedCompletions = <String, bool>{};
        mergedCompletions.addAll(result.completions); // Start with server data

        // Overlay any pending optimistic updates (don't lose uncommitted changes)
        for (final entry in state.optimisticToggles.entries) {
          if (state.pendingToggles.contains(entry.key)) {
            // Keep pending toggles as-is
            mergedCompletions[entry.key] = entry.value;
          } else if (!result.completions.containsKey(entry.key)) {
            // Keep local-only completions (might be very recent)
            mergedCompletions[entry.key] = entry.value;
          }
        }

        debugPrint(
          '🔄 HabitsNotifier: Merged to ${mergedCompletions.length} total completions',
        );

        state = state.copyWith(
          habits: result.habits,
          optimisticToggles: mergedCompletions,
          isLoading: false,
        );

        // Persist merged state to storage
        await completionStorage.saveCompletions(mergedCompletions);
      }
    } catch (e) {
      debugPrint('❌ HabitsNotifier: Failed to load habits - $e');
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  Future<void> createHabit(String name) async {
    try {
      final habit = await createHabitUseCase(name);
      state = state.copyWith(habits: [...state.habits, habit]);
    } catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }

  Future<void> updateHabit(int id, String name) async {
    try {
      final updatedHabit = await updateHabitUseCase(id, name);
      final updatedHabits = state.habits.map((h) {
        return h.id == id ? updatedHabit : h;
      }).toList();
      state = state.copyWith(habits: updatedHabits);
    } catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }

  Future<void> deleteHabit(int id) async {
    try {
      await deleteHabitUseCase(id);
      final updatedHabits = state.habits.where((h) => h.id != id).toList();
      state = state.copyWith(habits: updatedHabits);
    } catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }

  Future<void> toggleArchive(int id) async {
    try {
      final updatedHabit = await toggleArchiveUseCase(id);
      final updatedHabits = state.habits.map((h) {
        return h.id == id ? updatedHabit : h;
      }).toList();
      state = state.copyWith(habits: updatedHabits);
    } catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }

  Future<void> toggleHabitLog(int habitId, DateTime date) async {
    final key = '${habitId}_${_formatDate(date)}';

    // SYNCHRONOUS check - prevent duplicate toggles for the same habit+date
    // This is checked BEFORE any async operations, so rapid clicks are blocked immediately
    if (_activeToggles.contains(key)) {
      debugPrint(
        '⚠️ HabitsNotifier: Toggle already in progress for $key, ignoring',
      );
      return; // Already being toggled, ignore this request
    }

    // Also check async pending state (belt and suspenders approach)
    if (state.pendingToggles.contains(key)) {
      debugPrint(
        '⚠️ HabitsNotifier: Toggle already pending for $key, ignoring',
      );
      return;
    }

    // Add to BOTH synchronous and async tracking
    _activeToggles.add(key);

    // Get ACTUAL current state BEFORE marking as pending
    final storedValue = state.optimisticToggles[key] ?? false;
    final targetValue = !storedValue;

    debugPrint(
      '🔄 HabitsNotifier: Toggling habit $habitId on ${_formatDate(date)}: $storedValue -> $targetValue',
    );

    // Optimistic update - toggle from stored value
    final currentToggles = Map<String, bool>.from(state.optimisticToggles);
    currentToggles[key] = targetValue;

    // Mark as pending and update optimistic state together
    final updatedPending = Set<String>.from(state.pendingToggles)..add(key);
    state = state.copyWith(
      optimisticToggles: currentToggles,
      pendingToggles: updatedPending,
    );

    try {
      final isCompleted = await toggleHabitLogUseCase(habitId, date);
      debugPrint(
        '✅ HabitsNotifier: Server confirmed habit $habitId on ${_formatDate(date)}: $isCompleted',
      );

      // Update state based on server response
      final updatedToggles = Map<String, bool>.from(state.optimisticToggles);
      updatedToggles[key] = isCompleted;

      // Remove from pending
      final clearedPending = Set<String>.from(state.pendingToggles)
        ..remove(key);
      state = state.copyWith(
        optimisticToggles: updatedToggles,
        pendingToggles: clearedPending,
      );

      // Debounced persist to storage (prevents race conditions with rapid toggles)
      await _debouncedSaveToStorage();
    } catch (e) {
      debugPrint('❌ HabitsNotifier: Toggle failed for $key, rolling back - $e');
      // Rollback on error - restore stored value
      final rolledBackToggles = Map<String, bool>.from(state.optimisticToggles);
      rolledBackToggles[key] = storedValue;

      // Remove from pending
      final clearedPending = Set<String>.from(state.pendingToggles)
        ..remove(key);
      state = state.copyWith(
        optimisticToggles: rolledBackToggles,
        pendingToggles: clearedPending,
        error: e.toString(),
      );

      // Save rolled back state
      await completionStorage.saveCompletions(rolledBackToggles);
      rethrow;
    } finally {
      // ALWAYS remove from synchronous lock, even on error
      _activeToggles.remove(key);
    }
  }

  /// Debounced save to storage - waits for rapid toggles to complete
  Future<void> _debouncedSaveToStorage() async {
    final now = DateTime.now();
    _lastStorageSave = now;

    // Wait for debounce period
    await Future.delayed(_storageSaveDebounce);

    // Only save if no newer save was scheduled
    if (_lastStorageSave == now) {
      await completionStorage.saveCompletions(state.optimisticToggles);
    }
  }

  /// Clear all completions (call on logout)
  Future<void> clearCompletions() async {
    debugPrint('🧹 HabitsNotifier: Clearing all completions');
    await completionStorage.clearCompletions();
    state = state.copyWith(optimisticToggles: {});
  }

  bool isHabitCompleted(int habitId, DateTime date) {
    final key = '${habitId}_${_formatDate(date)}';
    return state.optimisticToggles[key] ?? false;
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}

// Provider
final habitsNotifierProvider =
    StateNotifierProvider<HabitsNotifier, HabitsState>((ref) {
  return HabitsNotifier(
    getHabitsUseCase: ref.watch(getHabitsUseCaseProvider),
    createHabitUseCase: ref.watch(createHabitUseCaseProvider),
    updateHabitUseCase: ref.watch(updateHabitUseCaseProvider),
    deleteHabitUseCase: ref.watch(deleteHabitUseCaseProvider),
    toggleArchiveUseCase: ref.watch(toggleArchiveHabitUseCaseProvider),
    toggleHabitLogUseCase: ref.watch(toggleHabitLogUseCaseProvider),
    completionStorage: ref.watch(habitCompletionStorageProvider),
  );
});
