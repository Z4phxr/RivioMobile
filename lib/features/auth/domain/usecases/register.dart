import '../entities/user.dart';
import '../entities/tokens.dart';
import '../repositories/auth_repository.dart';

class RegisterUseCase {
  final AuthRepository repository;

  const RegisterUseCase(this.repository);

  Future<({User user, Tokens tokens})> call({
    required String username,
    required String password,
    String? email,
  }) {
    return repository.register(
      username: username,
      password: password,
      email: email,
    );
  }
}
