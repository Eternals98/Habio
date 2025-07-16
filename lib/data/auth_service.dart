import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Método para registrar usuario
  Future<UserCredential?> registerWithEmail(
    String email,
    String password,
  ) async {
    try {
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);
      return userCredential;
    } catch (e) {
      print("Error al registrarse: $e");
      return null;
    }
  }

  /// Método para login
  Future<UserCredential?> signInWithEmail(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential;
    } catch (e) {
      print("Error signing in: $e");
      return null;
    }
  }

  /// Método para logout
  Future<void> signOut() async {
    await _auth.signOut();
  }

  /// Obtenemos usuario actual
  User? get currentUser => _auth.currentUser;
}
