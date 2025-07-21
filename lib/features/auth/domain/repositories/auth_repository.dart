//Es una interfaz abstracta que define los contratos de autenticación

import 'package:per_habit/features/auth/domain/entities/auth_user.dart';

/// Contrato de autenticación abstracto para la capa de dominio.
/// Define las acciones principales sin depender de ninguna implementación concreta.
abstract class AuthRepository {
  /// Inicia sesión con correo y contraseña.
  Future<AuthUser> login({
    required String email,
    required String password,
  });

  /// Registra un nuevo usuario con correo y contraseña.
  Future<AuthUser> register({
    required String email,
    required String password,
  });

  /// Cierra la sesión del usuario actual.
  Future<void> logout();

  /// Flujo de cambios en el estado de autenticación.
  /// Devuelve un [AuthUser] cuando el usuario inicia sesión y `null` cuando cierra sesión.
  Stream<AuthUser?> authStateChanges();

  /// Envía un correo de restablecimiento de contraseña al email proporcionado.
  Future<void> resetPassword({
    required String email,
  });
}