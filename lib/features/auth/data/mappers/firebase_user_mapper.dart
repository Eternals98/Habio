import 'package:firebase_auth/firebase_auth.dart';
import 'package:per_habit/features/auth/data/models/firebase_auth_user_model.dart';

/// Mapper que convierte un [FirebaseAuth User] en nuestro modelo interno.
class FirebaseUserMapper {
  static FirebaseAuthUserModel fromFirebase(User user) {
    return FirebaseAuthUserModel(
      uid: user.uid,
      email: user.email ?? '',
    );
  }
}