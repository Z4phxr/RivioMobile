import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/login.dart';
import '../../domain/usecases/register.dart';
import '../../domain/usecases/logout.dart';
import '../../domain/usecases/get_current_user.dart';
import '../../domain/usecases/delete_account.dart';
import '../../data/datasources/auth_remote_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';

// Auth State
class AuthState {
  final User? user;
  final bool isLoading;
  final String? error;

  const AuthState({
    this.user,
    this.isLoading = false,
    this.error,
  });

  bool get isAuthenticated => user != null;

  AuthState copyWith({
    User? user,
    bool? isLoading,
    String? error,
  }) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  AuthState clearError() => copyWith(error: '');
}

// Providers
final authRemoteDatasourceProvider = Provider<AuthRemoteDatasource>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return AuthRemoteDatasource(apiClient);
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final remoteDatasource = ref.watch(authRemoteDatasourceProvider);
  final secureStorage = ref.watch(secureStorageServiceProvider);
  return AuthRepositoryImpl(
    remoteDatasource: remoteDatasource,
    secureStorage: secureStorage,
  );
});

final loginUseCaseProvider = Provider<LoginUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return LoginUseCase(repository);
});

final registerUseCaseProvider = Provider<RegisterUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return RegisterUseCase(repository);
});

final logoutUseCaseProvider = Provider<LogoutUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return LogoutUseCase(repository);
});

final getCurrentUserUseCaseProvider = Provider<GetCurrentUserUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return GetCurrentUserUseCase(repository);
});

final deleteAccountUseCaseProvider = Provider<DeleteAccountUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return DeleteAccountUseCase(repository);
});

// Auth Notifier
class AuthNotifier extends StateNotifier<AuthState> {
  final LoginUseCase loginUseCase;
  final RegisterUseCase registerUseCase;
  final LogoutUseCase logoutUseCase;
  final GetCurrentUserUseCase getCurrentUserUseCase;
  final DeleteAccountUseCase deleteAccountUseCase;

  AuthNotifier({
    required this.loginUseCase,
    required this.registerUseCase,
    required this.logoutUseCase,
    required this.getCurrentUserUseCase,
    required this.deleteAccountUseCase,
  }) : super(const AuthState()) {
    // Check auth status on initialization
    checkAuthStatus();
  }

  Future<void> checkAuthStatus() async {
    debugPrint('🔐 AuthNotifier: Checking auth status...');
    state = state.copyWith(isLoading: true);
    try {
      final user = await getCurrentUserUseCase();
      if (user != null) {
        debugPrint('✅ AuthNotifier: User authenticated - ${user.username}');
        state = AuthState(user: user, isLoading: false);
      } else {
        debugPrint('❌ AuthNotifier: No valid session found');
        state = const AuthState(isLoading: false);
      }
    } catch (e) {
      // Don't clear auth on temporary network errors
      // Only clear if it's an auth error (401/403)
      debugPrint(' AuthNotifier: Auth check failed - $e');
      state = const AuthState(isLoading: false);
    }
  }

  /// Called when token refresh fails - force logout
  void handleTokenRefreshFailure() {
    debugPrint('🚫 AuthNotifier: Token refresh failed, forcing logout');
    state = const AuthState();
  }

  Future<void> login({
    required String username,
    required String password,
  }) async {
    debugPrint('🔐 AuthNotifier: Attempting login for user: $username');
    state = state.copyWith(isLoading: true, error: '');
    try {
      final result = await loginUseCase(username: username, password: password);
      debugPrint('✅ AuthNotifier: Login successful - ${result.user.username}');
      state = AuthState(user: result.user, isLoading: false);
    } catch (e) {
      debugPrint('❌ AuthNotifier: Login failed - $e');
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  Future<void> register({
    required String username,
    required String password,
    String? email,
  }) async {
    state = state.copyWith(isLoading: true, error: '');
    try {
      final result = await registerUseCase(
        username: username,
        password: password,
        email: email,
      );
      state = AuthState(user: result.user, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  Future<void> logout() async {
    debugPrint('🚪 AuthNotifier: Logging out user');
    await logoutUseCase();
    state = const AuthState();
    debugPrint('✅ AuthNotifier: Logout complete');
  }

  /// Invalidate all domain data providers on logout
  Future<void> deleteAccount() async {
    await deleteAccountUseCase();
    state = const AuthState();
  }

  void invalidateAllData(WidgetRef ref) {
    // This will be called by the UI layer to clear all cached data
    // The ref parameter allows invalidating providers from outside
  }
}

final authNotifierProvider =
    StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(
    loginUseCase: ref.watch(loginUseCaseProvider),
    registerUseCase: ref.watch(registerUseCaseProvider),
    logoutUseCase: ref.watch(logoutUseCaseProvider),
    getCurrentUserUseCase: ref.watch(getCurrentUserUseCaseProvider),
    deleteAccountUseCase: ref.watch(deleteAccountUseCaseProvider),
  );
});
