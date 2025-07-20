import 'package:per_habit/features/auth/domain/entities/auth_user.dart';
import 'package:per_habit/features/auth/domain/repositories/auth_repository.dart';

/// Caso de uso para registrar un nuevo usuario.
class RegisterUseCase {
  final AuthRepository repository;

  RegisterUseCase(this.repository);

  /// Ejecuta el registro y devuelve el nuevo usuario.
  Future<AuthUser> call({
    required String email,
    required String password,
  }) {
    return repository.register(email: email, password: password);
  }
}