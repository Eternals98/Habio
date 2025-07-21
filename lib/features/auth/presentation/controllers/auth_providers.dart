import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:per_habit/features/auth/application/login_case_use_case.dart';
import 'package:per_habit/features/auth/application/register_use_case.dart';
import 'package:per_habit/features/auth/application/reset_password_use_case.dart';
import 'package:per_habit/features/auth/data/auth_repository_impl.dart';
import 'package:per_habit/features/auth/data/datasources/firebase_auth_datasource.dart';
import 'package:per_habit/features/auth/domain/repositories/auth_repository.dart';
import 'package:per_habit/features/user/presentation/controllers/user_provider.dart';

import 'auth_controller.dart';

/// Provider para el datasource de FirebaseAuth
final firebaseAuthDatasourceProvider = Provider<FirebaseAuthDatasource>((ref) {
  return FirebaseAuthDatasource();
});

/// Provider para el repositorio de autenticación (implementación concreta)
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final firebase = ref.watch(firebaseAuthDatasourceProvider);
  return AuthRepositoryImpl(firebase);
});

/// Provider para LoginUseCase
final loginUseCaseProvider = Provider<LoginUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return LoginUseCase(repository);
});

final registerUseCaseProvider = Provider<RegisterUseCase>((ref) {
  return RegisterUseCase(
    authRepository: ref.read(authRepositoryProvider),
    userRepository: ref.read(userRepositoryProvider),
  );
});

/// Provider para ResetPasswordUseCase
final resetPasswordUseCaseProvider = Provider<ResetPasswordUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return ResetPasswordUseCase(repository);
});

/// StateNotifierProvider del AuthController
final authControllerProvider = StateNotifierProvider<AuthController, AuthState>(
  (ref) {
    return AuthController(
      loginUseCase: ref.watch(loginUseCaseProvider),
      registerUseCase: ref.watch(registerUseCaseProvider),
      resetPasswordUseCase: ref.watch(resetPasswordUseCaseProvider),
      repository: ref.watch(authRepositoryProvider),
    );
  },
);
