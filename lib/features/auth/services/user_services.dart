import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:per_habit/features/auth/models/user_model.dart';
import 'package:logger/logger.dart';

class UserServices {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Singleton instance
  static final UserServices _instance = UserServices._internal();

  // Factory getter for singleton
  static UserServices get instance => _instance;

  // Private constructor
  UserServices._internal();

  Future<UserModel?> getUserById(String uid) async {
    final logger = Logger();

    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        return UserModel.fromMap(doc.data()!);
      } else {
        return null;
      }
    } catch (e, stack) {
      logger.e('Error al obtener el usuario', error: e, stackTrace: stack);
      return null;
    }
  }
}
