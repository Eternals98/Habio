import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:per_habit/features/auth/application/login_case_use_case.dart';
import 'package:per_habit/features/auth/application/register_use_case.dart';
import 'package:per_habit/features/auth/application/reset_password_use_case.dart';
import 'package:per_habit/features/auth/domain/entities/auth_user.dart';
import 'package:per_habit/features/auth/domain/repositories/auth_repository.dart';

/// Códigos de error conocidos durante la autenticación
enum AuthErrorCode {
  invalidEmail,
  invalidCredential,
  userDisabled,
  userNotFound,
  wrongPassword,
  emailAlreadyInUse,
  weakPassword,
  tooManyRequests,
  operationNotAllowed,
  unknown,
}

/// Representa un error de autenticación con un código y un mensaje amigable
class AuthError {
  final AuthErrorCode code;
  final String message;

  const AuthError({required this.code, required this.message});

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AuthError && other.code == code && other.message == message;
  }

  @override
  int get hashCode => Object.hash(code, message);
}

/// Estado del controlador de autenticación
class AuthState {
  final bool loading;
  final AuthUser? user;
  final AuthError? error;

  const AuthState({this.loading = false, this.user, this.error});

  AuthState copyWith({bool? loading, AuthUser? user, AuthError? error}) {
    return AuthState(
      loading: loading ?? this.loading,
      user: user ?? this.user,
      error: error,
    );
  }
}

/// Controlador de autenticación con lógica desacoplada de la UI
class AuthController extends StateNotifier<AuthState> {
  final LoginUseCase loginUseCase;
  final RegisterUseCase registerUseCase;
  final ResetPasswordUseCase resetPasswordUseCase;
  final AuthRepository repository;

  AuthController({
    required this.loginUseCase,
    required this.registerUseCase,
    required this.resetPasswordUseCase,
    required this.repository,
  }) : super(const AuthState());

  Future<void> login(String email, String password) async {
    state = state.copyWith(loading: true, error: null);
    try {
      final user = await loginUseCase(email: email, password: password);
      state = state.copyWith(loading: false, user: user);
    } on FirebaseAuthException catch (e) {
      state = state.copyWith(
        loading: false,
        error: _mapFirebaseAuthException(e),
      );
    } catch (e) {
      state = state.copyWith(loading: false, error: _mapUnknownError(e));
    }
  }

  Future<void> register(String email, String password) async {
    state = state.copyWith(loading: true, error: null);
    try {
      final user = await registerUseCase(email: email, password: password);
      state = state.copyWith(loading: false, user: user);
    } on FirebaseAuthException catch (e) {
      state = state.copyWith(
        loading: false,
        error: _mapFirebaseAuthException(e),
      );
    } catch (e) {
      state = state.copyWith(loading: false, error: _mapUnknownError(e));
    }
  }

  Future<void> resetPassword(String email) async {
    state = state.copyWith(loading: true, error: null);
    try {
      await resetPasswordUseCase(email: email);
      state = state.copyWith(loading: false);
    } on FirebaseAuthException catch (e) {
      state = state.copyWith(
        loading: false,
        error: _mapFirebaseAuthException(e),
      );
    } catch (e) {
      state = state.copyWith(loading: false, error: _mapUnknownError(e));
    }
  }

  Future<void> logout() async {
    state = state.copyWith(loading: true, error: null);
    try {
      await repository.logout(); // Cierra sesión en Firebase
      state = const AuthState(user: null, loading: false);
    } on FirebaseAuthException catch (e) {
      state = state.copyWith(
        loading: false,
        error: _mapFirebaseAuthException(e),
      );
    } catch (e) {
      state = state.copyWith(loading: false, error: _mapUnknownError(e));
    }
  }

  AuthError _mapFirebaseAuthException(FirebaseAuthException exception) {
    switch (exception.code) {
      case 'invalid-email':
        return const AuthError(
          code: AuthErrorCode.invalidEmail,
          message: 'El correo electrónico tiene un formato inválido.',
        );
      case 'invalid-credential':
        return const AuthError(
          code: AuthErrorCode.invalidCredential,
          message: 'Credenciales incorrectas. Verifica tus datos.',
        );
      case 'user-disabled':
        return const AuthError(
          code: AuthErrorCode.userDisabled,
          message:
              'La cuenta ha sido deshabilitada. Contacta al soporte para más información.',
        );
      case 'user-not-found':
        return const AuthError(
          code: AuthErrorCode.userNotFound,
          message: 'No se encontró una cuenta con ese correo.',
        );
      case 'wrong-password':
        return const AuthError(
          code: AuthErrorCode.wrongPassword,
          message: 'La contraseña es incorrecta.',
        );
      case 'email-already-in-use':
        return const AuthError(
          code: AuthErrorCode.emailAlreadyInUse,
          message: 'El correo electrónico ya está en uso.',
        );
      case 'weak-password':
        return const AuthError(
          code: AuthErrorCode.weakPassword,
          message: 'La contraseña es demasiado débil.',
        );
      case 'too-many-requests':
        return const AuthError(
          code: AuthErrorCode.tooManyRequests,
          message:
              'Has realizado demasiados intentos. Inténtalo nuevamente más tarde.',
        );
      case 'operation-not-allowed':
        return const AuthError(
          code: AuthErrorCode.operationNotAllowed,
          message: 'Esta operación no está habilitada. Contacta al soporte.',
        );
      default:
        return AuthError(
          code: AuthErrorCode.unknown,
          message:
              exception.message ??
              'Ocurrió un error inesperado. Inténtalo más tarde.',
        );
    }
  }

  AuthError _mapUnknownError(Object error) {
    return AuthError(code: AuthErrorCode.unknown, message: error.toString());
  }
}
