import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:per_habit/features/user/application/get_user_profile_use_case.dart';
import 'package:per_habit/features/user/application/update_user_profile_use_case.dart';
import 'package:per_habit/features/user/data/datasources/user_firebase_datasource.dart';
import 'package:per_habit/features/user/data/user_repository_impl.dart';
import 'package:per_habit/features/user/domain/repositories/user_repository.dart';
import 'package:per_habit/features/user/presentation/controllers/user_controller.dart';



/// Datasource para acceder a Firestore
final userFirestoreDatasourceProvider = Provider<UserFirestoreDatasource>((ref) {
  return UserFirestoreDatasource();
});

/// Repositorio que implementa UserRepository
final userRepositoryProvider = Provider<UserRepository>((ref) {
  final datasource = ref.watch(userFirestoreDatasourceProvider);
  return UserRepositoryImpl(datasource);
});

/// Caso de uso: obtener perfil de usuario
final getUserProfileUseCaseProvider = Provider<GetUserProfileUseCase>((ref) {
  final repository = ref.watch(userRepositoryProvider);
  return GetUserProfileUseCase(repository);
});

/// Caso de uso: actualizar perfil de usuario
final updateUserProfileUseCaseProvider = Provider<UpdateUserProfileUseCase>((ref) {
  final repository = ref.watch(userRepositoryProvider);
  return UpdateUserProfileUseCase(repository);
});

/// Controlador del perfil de usuario
final userControllerProvider =
    StateNotifierProvider<UserController, UserState>((ref) {
  return UserController(
    getUserProfile: ref.watch(getUserProfileUseCaseProvider),
    updateUserProfile: ref.watch(updateUserProfileUseCaseProvider),
  );
});
