import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/config/api_config.dart';
import '../models/login_request_dto.dart';
import '../models/register_request_dto.dart';
import '../models/auth_response_dto.dart';

class AuthRemoteDatasource {
  final ApiClient apiClient;

  const AuthRemoteDatasource(this.apiClient);

  /// Factory to create datasource from Riverpod Ref (avoids circular dependency)
  factory AuthRemoteDatasource.fromRef(Ref ref) {
    final apiClient = ref.watch(apiClientProvider);
    return AuthRemoteDatasource(apiClient);
  }

  Future<AuthResponseDto> login(LoginRequestDto request) async {
    final response = await apiClient.post(
      ApiConfig.authLogin,
      data: request.toJson(),
    );
    return AuthResponseDto.fromJson(response.data as Map<String, dynamic>);
  }

  Future<AuthResponseDto> register(RegisterRequestDto request) async {
    final response = await apiClient.post(
      ApiConfig.authRegister,
      data: request.toJson(),
    );
    return AuthResponseDto.fromJson(response.data as Map<String, dynamic>);
  }

  /// POST /api/auth/logout/ - Logout and blacklist refresh token
  /// Requires: Authorization header with access token
  /// Body: {"refresh": "refresh_token_string"}
  Future<void> logout(String refreshToken) async {
    await apiClient.post(
      ApiConfig.authLogout,
      data: {'refresh': refreshToken},
    );
  }

  Future<UserDto> getCurrentUser() async {
    final response = await apiClient.get(ApiConfig.authVerify);
    return UserDto.fromJson(response.data as Map<String, dynamic>);
  }

  /// DELETE /api/auth/delete-account/ - Delete user account
  /// Requires: Authorization header with access token
  /// Deletes the authenticated user account and all associated data
  Future<void> deleteAccount() async {
    await apiClient.delete(ApiConfig.authDeleteAccount);
  }
}
