import '../entities/user.dart';
import '../entities/tokens.dart';

abstract class AuthRepository {
  Future<({User user, Tokens tokens})> login({
    required String username,
    required String password,
  });

  Future<({User user, Tokens tokens})> register({
    required String username,
    required String password,
    String? email,
  });

  Future<void> logout();

  Future<User?> getCurrentUser();

  Future<void> deleteAccount();
}
