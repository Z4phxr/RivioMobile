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

    return (
      user: response.toUserEntity(),
      tokens: response.toTokensEntity(),
    );
  }

  @override
  Future<void> logout() async {
    try {
      // Get refresh token before clearing it
      final refreshToken = await secureStorage.getRefreshToken();
      if (refreshToken != null) {
        await remoteDatasource.logout(refreshToken);
      }
    } finally {
      // Always clear tokens even if API call fails
      await secureStorage.clearTokens();
    }
  }

  @override
  Future<User?> getCurrentUser() async {
    final hasTokens = await secureStorage.hasTokens();
    if (!hasTokens) return null;

    try {
      final userDto = await remoteDatasource.getCurrentUser();
      return userDto.toEntity();
    } catch (e) {
      // If fetching user fails, clear invalid tokens
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
