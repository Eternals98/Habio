import 'package:per_habit/features/user/domain/entities/user_profile.dart';
import 'package:per_habit/features/user/domain/repositories/user_repository.dart';

/// Caso de uso: actualizar los datos del perfil del usuario
class UpdateUserProfileUseCase {
  final UserRepository repository;

  UpdateUserProfileUseCase(this.repository);

  Future<void> call(UserProfile profile) {
    return repository.updateProfile(profile);
  }
}
