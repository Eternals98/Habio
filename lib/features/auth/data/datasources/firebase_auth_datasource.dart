import 'package:firebase_auth/firebase_auth.dart';

/// Fuente de datos directa para Firebase Auth.
/// Encapsula las llamadas al SDK de Firebase.
class FirebaseAuthDatasource {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<User> login(String email, String password) async {
    final result = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return result.user!;
  }

  Future<User> register(String email, String password) async {
    final result = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    return result.user!;
  }

  Future<void> logout() => _auth.signOut();

  Stream<User?> authStateChanges() => _auth.authStateChanges();

  Future<void> resetPassword(String email) =>
      _auth.sendPasswordResetEmail(email: email);
}
