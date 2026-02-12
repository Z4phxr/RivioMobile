import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../../domain/entities/user.dart';
import '../../domain/entities/tokens.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';
import '../models/login_request_dto.dart';
import '../models/register_request_dto.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDatasource remoteDatasource;
  final SecureStorageService secureStorage;

  const AuthRepositoryImpl({
    required this.remoteDatasource,
    required this.secureStorage,
  });

  @override
  Future<({User user, Tokens tokens})> login({
    required String username,
    required String password,
  }) async {
    final request = LoginRequestDto(username: username, password: password);
    final response = await remoteDatasource.login(request);

    // Save tokens
    await secureStorage.saveTokens(
      accessToken: response.access,
      refreshToken: response.refresh,
    );
    debugPrint('🔐 AuthRepository: Tokens saved after login');

    return (
      user: response.toUserEntity(),
      tokens: response.toTokensEntity(),
    );
  }

  @override
  Future<({User user, Tokens tokens})> register({
    required String username,
    required String password,
    String? email,
  }) async {
    final request = RegisterRequestDto(
      username: username,
      password: password,
      email: email,
    );
    final response = await remoteDatasource.register(request);

    // Save tokens
    await secureStorage.saveTokens(
      accessToken: response.access,
      refreshToken: response.refresh,
    );
    debugPrint('🔐 AuthRepository: Tokens saved after registration');

    return (
      user: response.toUserEntity(),
      tokens: response.toTokensEntity(),
    );
  }

  @override
  Future<void> logout() async {
    debugPrint('🚪 AuthRepository: Logging out...');
    try {
      // Get refresh token before clearing it
      final refreshToken = await secureStorage.getRefreshToken();
      if (refreshToken != null) {
        await remoteDatasource.logout(refreshToken);
        debugPrint('✅ AuthRepository: Server logout successful');
      }
    } finally {
      // Always clear tokens even if API call fails
      await secureStorage.clearTokens();
      debugPrint('🧹 AuthRepository: Tokens cleared from storage');
    }
  }

  @override
  Future<User?> getCurrentUser() async {
    final hasTokens = await secureStorage.hasTokens();
    if (!hasTokens) {
      debugPrint('❌ AuthRepository: No tokens found in storage');
      return null;
    }

    debugPrint('✅ AuthRepository: Tokens found, verifying with server...');
    try {
      final userDto = await remoteDatasource.getCurrentUser();
      debugPrint('✅ AuthRepository: User verified - ${userDto.username}');
      return userDto.toEntity();
    } on DioException catch (e) {
      // Only clear tokens on auth errors (401, 403)
      if (e.response?.statusCode == 401 || e.response?.statusCode == 403) {
        debugPrint('🚫 AuthRepository: Auth error (${e.response?.statusCode}), clearing tokens');
        await secureStorage.clearTokens();
        return null;
      }
      // Don't clear tokens on network errors - user might be offline
      debugPrint('⚠️ AuthRepository: Network error, keeping tokens: $e');
      rethrow;
    } catch (e) {
      // Unexpected error - clear tokens to be safe
      debugPrint('❌ AuthRepository: Unexpected error, clearing tokens: $e');
      await secureStorage.clearTokens();
      return null;
    }
  }

  @override
  Future<void> deleteAccount() async {
    try {
      await remoteDatasource.deleteAccount();
    } finally {
      // Always clear tokens even if API call fails
      await secureStorage.clearTokens();
    }
  }
}
