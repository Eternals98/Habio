import 'package:per_habit/features/auth/domain/entities/auth_user.dart';
import 'package:per_habit/features/auth/domain/repositories/auth_repository.dart';
import 'package:per_habit/features/user/domain/repositories/user_repository.dart';
import 'package:per_habit/features/user/domain/entities/user_profile.dart';

/// Caso de uso para registrar un nuevo usuario.
class RegisterUseCase {
  final AuthRepository authRepository;
  final UserRepository userRepository;

  RegisterUseCase({required this.authRepository, required this.userRepository});

  /// Ejecuta el registro y crea el perfil del usuario en Firestore.
  Future<AuthUser> call({
    required String email,
    required String password,
  }) async {
    final authUser = await authRepository.register(
      email: email,
      password: password,
    );

    // Crear perfil en Firestore
    final userProfile = UserProfile(
      id: authUser.uid,
      email: authUser.email,
      displayName: '',
      bio: '',
      photoUrl: '',
      onboardingCompleted: false,
    );

    await userRepository.createUserProfile(userProfile);

    return authUser;
  }
}
