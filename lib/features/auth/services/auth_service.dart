import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final _uuid = Uuid();

  /// Registro con email y contraseña
  Future<UserCredential> registerWithEmail(
    String email,
    String password,
  ) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Crear documento de usuario en Firestore
      final user = userCredential.user;
      if (user != null) {
        final customUid = _uuid.v4();
        await _db.collection('users').doc(user.uid).set({
          'uid': user.uid, // uid de Firebase Auth
          'customId': customUid, // tu propio uuid
          'email': email,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw FirebaseAuthException(code: e.code, message: e.message);
    } catch (e) {
      throw Exception('Error inesperado al registrarse: $e');
    }
  }

  /// Iniciar sesión con email y contraseña
  Future<UserCredential> signInWithEmail(String email, String password) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw FirebaseAuthException(code: e.code, message: e.message);
    } catch (e) {
      throw Exception('Error inesperado al iniciar sesión: $e');
    }
  }

  /// Cerrar sesión
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw Exception('Error cerrando sesión: $e');
    }
  }

  /// Usuario actual
  User? get currentUser => _auth.currentUser;
}
