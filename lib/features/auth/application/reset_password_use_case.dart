import 'package:per_habit/features/auth/domain/repositories/auth_repository.dart';

/// Caso de uso para enviar un correo de recuperación de contraseña.
class ResetPasswordUseCase {
  final AuthRepository repository;

  ResetPasswordUseCase(this.repository);

  /// Envía el correo de recuperación.
  Future<void> call({
    required String email,
  }) {
    return repository.resetPassword(email: email);
  }
}