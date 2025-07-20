import 'package:per_habit/features/auth/domain/entities/auth_user.dart';

/// Modelo que representa al usuario autenticado desde Firebase.
class FirebaseAuthUserModel extends AuthUser {
  FirebaseAuthUserModel({
    required super.uid,
    required super.email,
  });
}