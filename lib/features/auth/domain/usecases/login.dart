import '../entities/user.dart';
import '../entities/tokens.dart';
import '../repositories/auth_repository.dart';

class LoginUseCase {
  final AuthRepository repository;

  const LoginUseCase(this.repository);

  Future<({User user, Tokens tokens})> call({
    required String username,
    required String password,
  }) {
    return repository.login(username: username, password: password);
  }
}
