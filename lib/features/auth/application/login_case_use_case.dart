import 'package:per_habit/features/auth/domain/entities/auth_user.dart';
import 'package:per_habit/features/auth/domain/repositories/auth_repository.dart';

/// Caso de uso para iniciar sesión con correo y contraseña.
class LoginUseCase {
  final AuthRepository repository;

  LoginUseCase(this.repository);

  /// Ejecuta el login y devuelve el usuario autenticado.
  Future<AuthUser> call({
    required String email,
    required String password,
  }) {
    return repository.login(email: email, password: password);
  }
}