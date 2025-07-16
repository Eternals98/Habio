import 'package:cloud_firestore/cloud_firestore.dart';

/// Servicio general para interactuar con Firestore u otros servicios de Firebase.
class FirebaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Ejemplo de obtener colección de usuarios.
  Stream<QuerySnapshot> getUsers() {
    return _db.collection('users').snapshots();
  }
}
