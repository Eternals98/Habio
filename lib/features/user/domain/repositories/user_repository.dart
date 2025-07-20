

import 'package:per_habit/features/user/domain/entities/user_profile.dart';

abstract class UserRepository {
  /// Obtiene el perfil de un usuario por su UID
  Future<UserProfile> getProfile(String uid);

  /// Actualiza el perfil del usuario
  Future<void> updateProfile(UserProfile profile);
}
