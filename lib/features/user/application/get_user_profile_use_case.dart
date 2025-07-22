import 'package:per_habit/features/user/domain/entities/user_profile.dart';
import 'package:per_habit/features/user/domain/repositories/user_repository.dart';

/// Caso de uso: obtener el perfil del usuario a partir del UID
class GetUserProfileUseCase {
  final UserRepository repository;

  GetUserProfileUseCase(this.repository);

  Future<UserProfile?> call(String uid) {
    return repository.getUserProfile(uid);
  }
}
